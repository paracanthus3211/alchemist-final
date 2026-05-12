<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\DailyTask;
use App\Models\UserDailyProgress;
use App\Models\User;
use App\Models\UserQuestionAttempt;
use App\Models\Question;
use Illuminate\Support\Facades\DB;

$user = User::where('username', 'admin')->first(); 
if(!$user) {
    echo "User not found\n";
    exit;
}

$today = now()->toDateString();
echo "Syncing progress for user: {$user->username} (ID: {$user->id}) for date: $today\n";

// 1. Calculate progress
$attemptsToday = UserQuestionAttempt::where('user_id', $user->id)
    ->where('is_correct', true)
    ->whereDate('created_at', $today)
    ->get();

$levelsToday = $attemptsToday->map(function($a) {
    $q = Question::find($a->question_id);
    return $q ? $q->level_id : null;
})->filter()->unique();

$completedLevelsCount = 0;
foreach($levelsToday as $levelId) {
    $totalInLevel = Question::where('level_id', $levelId)->count();
    $completedByUser = UserQuestionAttempt::where('user_id', $user->id)
        ->whereIn('question_id', Question::where('level_id', $levelId)->pluck('id'))
        ->where('is_correct', true)
        ->count();
    
    if($totalInLevel > 0 && $completedByUser >= $totalInLevel) {
        $completedLevelsCount++;
    }
}

echo "Levels finished today: $completedLevelsCount\n";

// 2. Update progress
$tasks = DailyTask::where('task_type', 'FINISH_LESSONS')->get();
foreach($tasks as $task) {
    // Delete existing to avoid unique constraint if being weird
    DB::table('user_daily_progress')
        ->where('user_id', $user->id)
        ->where('task_id', $task->id)
        ->where('date', $today)
        ->delete();

    $progress = UserDailyProgress::create([
        'user_id' => $user->id,
        'task_id' => $task->id,
        'date' => $today,
        'current_progress' => $completedLevelsCount,
        'is_completed' => ($completedLevelsCount >= $task->target_value)
    ]);

    echo "Task '{$task->task_name}' progress updated to {$progress->current_progress}.\n";

    // Award XP if completed (check if already rewarded today to be safe, but since we are syncing...)
    if ($progress->is_completed) {
        // Check if already had a transaction for this today
        $alreadyRewarded = DB::table('xp_transactions')
            ->where('user_id', $user->id)
            ->where('source_type', 'daily_task')
            ->where('source_id', $task->id)
            ->whereDate('created_at', $today)
            ->exists();

        if (!$alreadyRewarded) {
            echo "Awarding reward for {$task->task_name}\n";
            $user->xp += $task->xp_reward;
            $user->save();
            
            DB::table('xp_transactions')->insert([
                'user_id' => $user->id,
                'source_type' => 'daily_task',
                'source_id' => $task->id,
                'xp_amount' => $task->xp_reward,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}

echo "Done.\n";
