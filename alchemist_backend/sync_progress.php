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

$user = User::where('username', 'admin')->first(); 
if(!$user) {
    echo "User not found\n";
    exit;
}

$today = now()->toDateString();
echo "Syncing progress for user: {$user->username} for date: $today\n";

// 1. Find levels completed today
$attemptsToday = UserQuestionAttempt::where('user_id', $user->id)
    ->where('is_correct', true)
    ->whereDate('created_at', $today)
    ->get();

$levelsToday = $attemptsToday->map(function($a) {
    return Question::find($a->question_id)->level_id;
})->unique();

$completedLevelsCount = 0;
foreach($levelsToday as $levelId) {
    $totalInLevel = Question::where('level_id', $levelId)->count();
    $completedByUser = UserQuestionAttempt::where('user_id', $user->id)
        ->whereIn('question_id', Question::where('level_id', $levelId)->pluck('id'))
        ->where('is_correct', true)
        ->count();
    
    if($totalInLevel > 0 && $completedByUser >= $totalInLevel) {
        $completedLevelsCount++;
        echo "Level $levelId is completed.\n";
    }
}

echo "Total completed levels today: $completedLevelsCount\n";

// 2. Update Daily Tasks
$tasks = DailyTask::where('task_type', 'FINISH_LESSONS')
    ->where('is_active', true)
    ->get();

foreach($tasks as $task) {
    $progress = UserDailyProgress::firstOrNew([
        'user_id' => $user->id,
        'task_id' => $task->id,
        'date'    => $today,
    ]);

    $wasCompleted = $progress->is_completed;
    $progress->current_progress = $completedLevelsCount;
    $progress->is_completed = $progress->current_progress >= $task->target_value;
    $progress->save();
    
    echo "Task '{$task->task_name}' progress updated to {$progress->current_progress}.\n";

    if($progress->is_completed && !$wasCompleted) {
        echo "Task completed! Awarding {$task->xp_reward} XP.\n";
        $user->xp += $task->xp_reward;
        $user->save();
        
        \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
            'user_id' => $user->id,
            'source_type' => 'daily_task',
            'source_id' => $task->id,
            'xp_amount' => $task->xp_reward,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}

echo "Sync complete.\n";
