<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::find(1);
$today = date('Y-m-d');

$assigned = App\Models\UserDailyProgress::where('user_id', $user->id)
    ->whereDate('date', $today)
    ->with('task')
    ->get()
    ->filter(fn($p) => $p->task !== null);

$formatted = $assigned->map(function($progress) {
    $task = $progress->task;
    return [
        'id'               => $task->id,
        'task_name'        => $task->task_name,
        'task_type'        => $task->task_type,
        'description'      => $task->description,
        'target_value'     => $task->target_value,
        'xp_reward'        => $task->xp_reward,
        'stages'           => $task->stages ?? [],
        'current_progress' => $progress->current_progress,
        'completed_stages' => $progress->completed_stages ?? [],
        'is_completed'     => (bool) $progress->is_completed,
    ];
})->values();

header('Content-Type: application/json');
echo json_encode(['success' => true, 'data' => $formatted], JSON_PRETTY_PRINT);
