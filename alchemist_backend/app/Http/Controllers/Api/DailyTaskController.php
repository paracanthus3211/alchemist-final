<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DailyTask;
use App\Models\UserDailyProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class DailyTaskController extends Controller
{
    // ─────────────────────────────────────────────
    // GET /daily-tasks  — list all tasks (admin) or active tasks (user)
    // ─────────────────────────────────────────────
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'ADMIN') {
            $tasks = DailyTask::orderBy('created_at', 'desc')->get();
        } else {
            $tasks = DailyTask::where('is_active', true)->orderBy('created_at', 'desc')->get();
        }

        // Attach today's progress for the user
        $today = Carbon::today()->toDateString();
        $progressMap = UserDailyProgress::where('user_id', $user->id)
            ->where('date', $today)
            ->get()
            ->keyBy('task_id');

        $tasks = $tasks->map(function ($task) use ($progressMap) {
            $progress = $progressMap->get($task->id);
            $task->current_progress = $progress?->current_progress ?? 0;
            $task->is_completed     = $progress?->is_completed ?? false;
            return $task;
        });

        return response()->json([
            'success' => true,
            'data'    => $tasks,
        ]);
    }

    // ─────────────────────────────────────────────
    // GET /daily-tasks/stats  — admin statistics
    // ─────────────────────────────────────────────
    public function stats()
    {
        $total    = DailyTask::count();
        $active   = DailyTask::where('is_active', true)->count();
        $inactive = DailyTask::where('is_active', false)->count();

        return response()->json([
            'success' => true,
            'data'    => [
                'templates' => $total,
                'active'    => $active,
                'inactive'  => $inactive,
            ],
        ]);
    }

    // ─────────────────────────────────────────────
    // POST /daily-tasks  — create (admin only)
    // ─────────────────────────────────────────────
    public function store(Request $request)
    {
        $validated = $request->validate([
            'task_name'    => 'required|string|max:255',
            'task_type'    => 'required|in:FINISH_LESSONS,GAIN_XP,READ_ARTICLE,LAB_EXPERIMENT,DAILY_LOGIN',
            'description'  => 'nullable|string',
            'target_value' => 'required|integer|min:1',
            'xp_reward'    => 'required|integer|min:0',
            'is_active'    => 'boolean',
        ]);

        $task = DailyTask::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Daily task created successfully.',
            'data'    => $task,
        ], 201);
    }

    // ─────────────────────────────────────────────
    // PUT /daily-tasks/{id}  — update (admin only)
    // ─────────────────────────────────────────────
    public function update(Request $request, DailyTask $dailyTask)
    {
        $validated = $request->validate([
            'task_name'    => 'sometimes|string|max:255',
            'task_type'    => 'sometimes|in:FINISH_LESSONS,GAIN_XP,READ_ARTICLE,LAB_EXPERIMENT,DAILY_LOGIN',
            'description'  => 'nullable|string',
            'target_value' => 'sometimes|integer|min:1',
            'xp_reward'    => 'sometimes|integer|min:0',
            'is_active'    => 'boolean',
        ]);

        $dailyTask->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Daily task updated.',
            'data'    => $dailyTask,
        ]);
    }

    // ─────────────────────────────────────────────
    // DELETE /daily-tasks/{id}  — delete (admin only)
    // ─────────────────────────────────────────────
    public function destroy(DailyTask $dailyTask)
    {
        $dailyTask->delete();

        return response()->json([
            'success' => true,
            'message' => 'Daily task deleted.',
        ]);
    }

    // ─────────────────────────────────────────────
    // POST /daily-tasks/{id}/progress  — update user progress
    // ─────────────────────────────────────────────
    public function updateProgress(Request $request, DailyTask $dailyTask)
    {
        $request->validate([
            'current_progress' => 'required|integer|min:0',
        ]);

        $user  = $request->user();
        $today = Carbon::today()->toDateString();

        $progress = UserDailyProgress::firstOrNew([
            'user_id' => $user->id,
            'task_id' => $dailyTask->id,
            'date'    => $today,
        ]);

        $progress->current_progress = $request->current_progress;
        $progress->is_completed     = $progress->current_progress >= $dailyTask->target_value;
        $progress->save();

        return response()->json([
            'success' => true,
            'data'    => $progress,
        ]);
    }
}
