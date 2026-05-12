<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DailyTask;
use App\Models\UserDailyProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class DailyTaskController extends Controller
{
    // ─────────────────────────────────────────────────────────────────────────
    // GET /daily-tasks
    // ADMIN  → returns all templates
    // USER   → returns today's randomly assigned tasks with progress
    // ─────────────────────────────────────────────────────────────────────────
    public function index(Request $request)
    {
        $user  = $request->user();
        $today = Carbon::today()->toDateString();

        // ── ADMIN MODE: return all templates for management ──────────────────
        if ($request->query('mode') === 'admin' && strtoupper($user->role) === 'ADMIN') {
            $tasks = DailyTask::orderBy('created_at', 'desc')->get();
            return response()->json(['success' => true, 'data' => $tasks]);
        }

        // ── USER & ADMIN: get personal daily progress ────────────────────────

        // Check if tasks already generated for today
        $assigned = UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $today)
            ->with('task')
            ->get()
            ->filter(fn($p) => $p->task !== null); // skip orphan records

        // If no tasks yet for today → pick random templates
        if ($assigned->isEmpty()) {
            $this->_generateDailyTasksForUser($user, $today);

            $assigned = UserDailyProgress::where('user_id', $user->id)
                ->whereDate('date', $today)
                ->with('task')
                ->get()
                ->filter(fn($p) => $p->task !== null);
        }

        $formatted = $assigned->map(fn($progress) => $this->_formatTask($progress))->values();

        return response()->json(['success' => true, 'data' => $formatted]);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal: generate daily tasks randomly based on user level
    // ─────────────────────────────────────────────────────────────────────────
    private function _generateDailyTasksForUser($user, string $today): void
    {
        // Get user level to decide how many tasks to give
        $level = (new AuthController())->getQuizProgressData($user)['level'] ?? 1;

        $taskCount = match(true) {
            $level <= 5  => 3,
            $level <= 15 => 4,
            default      => rand(5, 6),
        };

        $available = DailyTask::where('is_active', true)->count();
        $taskCount = min($taskCount, $available);

        if ($taskCount === 0) return;

        $templates = DailyTask::where('is_active', true)
            ->inRandomOrder()
            ->limit($taskCount)
            ->get();

        foreach ($templates as $template) {
            UserDailyProgress::firstOrCreate(
                [
                    'user_id' => $user->id,
                    'task_id' => $template->id,
                    'date'    => $today,
                ],
                [
                    'current_progress' => 0,
                    'completed_stages' => [],
                    'is_completed'     => false,
                ]
            );
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal: format a UserDailyProgress → clean array for Flutter
    // ─────────────────────────────────────────────────────────────────────────
    private function _formatTask(UserDailyProgress $progress): array
    {
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
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /daily-tasks/stats  — admin statistics
    // ─────────────────────────────────────────────────────────────────────────
    public function stats()
    {
        return response()->json([
            'success' => true,
            'data'    => [
                'templates' => DailyTask::count(),
                'active'    => DailyTask::where('is_active', true)->count(),
                'inactive'  => DailyTask::where('is_active', false)->count(),
            ],
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /daily-tasks  — create template (admin only)
    // ─────────────────────────────────────────────────────────────────────────
    public function store(Request $request)
    {
        $validated = $request->validate([
            'task_name'    => 'required|string|max:255',
            'task_type'    => 'required|string',
            'description'  => 'nullable|string',
            'target_value' => 'required|integer|min:1',
            'xp_reward'    => 'required|integer|min:0',
            'is_active'    => 'boolean',
            'stages'       => 'nullable|array',
        ]);

        $task = DailyTask::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Task template created.',
            'data'    => $task,
        ], 201);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PUT /daily-tasks/{id}  — update template (admin only)
    // ─────────────────────────────────────────────────────────────────────────
    public function update(Request $request, DailyTask $dailyTask)
    {
        $validated = $request->validate([
            'task_name'    => 'sometimes|string|max:255',
            'task_type'    => 'sometimes|string',
            'description'  => 'nullable|string',
            'target_value' => 'sometimes|integer|min:1',
            'xp_reward'    => 'sometimes|integer|min:0',
            'is_active'    => 'boolean',
            'stages'       => 'nullable|array',
        ]);

        $dailyTask->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Task template updated.',
            'data'    => $dailyTask,
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DELETE /daily-tasks/{id}  — delete template (admin only)
    // ─────────────────────────────────────────────────────────────────────────
    public function destroy(DailyTask $dailyTask)
    {
        $dailyTask->delete();

        return response()->json(['success' => true, 'message' => 'Task template deleted.']);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /daily-tasks/{id}/progress  — manual progress update (legacy)
    // ─────────────────────────────────────────────────────────────────────────
    public function updateProgress(Request $request, DailyTask $dailyTask)
    {
        $request->validate(['current_progress' => 'required|integer|min:0']);

        $user     = $request->user();
        $today    = Carbon::today()->toDateString();

        $progress = UserDailyProgress::firstOrNew([
            'user_id' => $user->id,
            'task_id' => $dailyTask->id,
            'date'    => $today,
        ]);

        $wasCompleted              = (bool) $progress->is_completed;
        $progress->current_progress = $request->current_progress;
        $progress->is_completed    = $progress->current_progress >= $dailyTask->target_value;
        $progress->save();

        if ($progress->is_completed && !$wasCompleted) {
            $user->increment('xp', $dailyTask->xp_reward);
            \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
                'user_id'     => $user->id,
                'source_type' => 'daily_task',
                'source_id'   => $dailyTask->id,
                'xp_amount'   => $dailyTask->xp_reward,
                'created_at'  => now(),
                'updated_at'  => now(),
            ]);
        }

        return response()->json([
            'success'           => true,
            'is_just_completed' => ($progress->is_completed && !$wasCompleted),
            'data'              => $progress,
        ]);
    }

    /**
     * Regenerate daily tasks for the user (clears today's progress and re-picks).
     * Useful for testing new task templates immediately.
     */
    public function regenerate(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today()->toDateString();

        // Delete today's existing progress
        UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $today)
            ->delete();

        // Re-generate
        $this->_generateDailyTasksForUser($user, $today);

        // Fetch the new ones
        $newTasks = UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $today)
            ->with('task')
            ->get()
            ->map(fn($p) => $this->_formatTask($p))
            ->values();

        return response()->json([
            'success' => true,
            'message' => 'Tasks regenerated successfully.',
            'data'    => $newTasks
        ]);
    }
}
