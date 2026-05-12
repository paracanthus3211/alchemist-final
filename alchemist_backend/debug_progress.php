<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "--- DAILY PROGRESS FOR " . date('Y-m-d') . " ---\n";
$progress = App\Models\UserDailyProgress::whereDate('date', date('Y-m-d'))
    ->with(['task', 'user'])
    ->get();

if ($progress->isEmpty()) {
    echo "No progress records found for today.\n";
}

foreach ($progress as $p) {
    echo "User: " . ($p->user->email ?? 'N/A') . " (ID: " . $p->user_id . ")\n";
    echo "Task: " . ($p->task->task_name ?? 'N/A') . " (Type: " . ($p->task->task_type ?? 'N/A') . ")\n";
    echo " - Progress: " . $p->current_progress . "\n";
    echo " - Completed: " . ($p->is_completed ? 'YES' : 'NO') . "\n";
    echo " - Completed Stages: " . json_encode($p->completed_stages) . "\n";
    echo "--------------------------\n";
}
