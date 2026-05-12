<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\DailyTask;
use App\Models\UserDailyProgress;
use App\Models\User;

$tasks = DailyTask::all();
echo "TASKS:\n";
foreach($tasks as $t) {
    echo "ID: {$t->id}, Name: {$t->task_name}, Type: {$t->task_type}, Target: {$t->target_value}, Reward: {$t->xp_reward}\n";
}

$user = User::first(); // Assuming first user for check
if($user) {
    echo "\nUSER: {$user->username} (XP: {$user->xp})\n";
    $progress = UserDailyProgress::where('user_id', $user->id)->get();
    echo "PROGRESS:\n";
    foreach($progress as $p) {
        echo "TaskID: {$p->task_id}, Progress: {$p->current_progress}, Completed: {$p->is_completed}, Date: {$p->date}\n";
    }
}
