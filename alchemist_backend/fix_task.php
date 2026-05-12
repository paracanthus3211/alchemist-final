<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\DailyTask;

$task = DailyTask::find(1);
if($task) {
    echo "Updating Task 1...\n";
    $task->target_value = 1;
    $task->task_name = 'Finish 1 Lesson';
    $task->description = 'Complete one quiz level to earn XP';
    $task->save();
    echo "Done.\n";
} else {
    echo "Task 1 not found.\n";
}
