<?php

namespace App\Traits;

use App\Models\DailyTask;
use App\Models\UserDailyProgress;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

trait UpdatesDailyTasks
{
    /**
     * Ensure the user has daily tasks generated for today.
     * Called automatically before updating progress.
     */
    private function _ensureDailyTasksExist($user, string $today): void
    {
        $hasTasksToday = UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $today)
            ->exists();

        if ($hasTasksToday) return;

        // Generate random tasks for today
        $available = DailyTask::where('is_active', true)->count();
        if ($available === 0) return;

        $taskCount = min(3, $available); // default 3 tasks

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

    /**
     * Increment progress for a specific task type for the currently assigned tasks today.
     *
     * @param \App\Models\User $user
     * @param string $type  e.g. 'FINISH_LESSONS', 'GAIN_XP', 'READ_ARTICLE', 'DAILY_LOGIN', 'SCORE', 'LAB_EXPERIMENT'
     * @param int $amount
     * @param int|null $sourceId  optional, used to prevent double-counting (e.g. same levelId)
     */
    protected function _incrementDailyTaskProgress($user, string $type, int $amount = 1, $sourceId = null): void
    {
        $today = now()->toDateString();

        // ── AUTO-GENERATE tasks for today if user hasn't opened home screen yet ──
        $this->_ensureDailyTasksExist($user, $today);

        // ── Anti double-count ──────────────────────────────────────────────────
        if ($sourceId && in_array($type, ['FINISH_LESSONS', 'READ_ARTICLE'])) {
            $cacheKey = "udp_{$user->id}_{$type}_{$sourceId}_{$today}";
            if (Cache::has($cacheKey)) {
                return;
            }
            Cache::put($cacheKey, true, now()->endOfDay());
        }

        // ── Find assigned progress records for today matching this type ─────────
        $progressRecords = UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $today)
            ->whereHas('task', fn($q) => $q->where('task_type', $type))
            ->with('task')
            ->get();

        if ($progressRecords->isEmpty()) return;

        $newlyAwardedXp = 0;

        foreach ($progressRecords as $progress) {
            $task = $progress->task;
            if (!$task) continue;

            // Skip if already fully completed
            if ($progress->is_completed) continue;

            $progress->current_progress += $amount;

            $stages = $task->stages;

            if (!empty($stages) && is_array($stages)) {
                // ── MULTI-STAGE ────────────────────────────────────────────────
                $completedStages = is_array($progress->completed_stages) ? $progress->completed_stages : [];

                foreach ($stages as $idx => $stage) {
                    if (in_array($idx, $completedStages)) continue;

                    $target = (int)($stage['target'] ?? $stage['targetValue'] ?? 0);
                    if ($target > 0 && $progress->current_progress >= $target) {
                        $completedStages[] = $idx;
                        $reward = (int)($stage['reward'] ?? $stage['xpReward'] ?? 0);
                        $newlyAwardedXp += $reward;

                        DB::table('xp_transactions')->insert([
                            'user_id'     => $user->id,
                            'source_type' => 'daily_task_stage',
                            'source_id'   => $task->id,
                            'xp_amount'   => $reward,
                            'created_at'  => now(),
                            'updated_at'  => now(),
                        ]);
                    }
                }

                $progress->completed_stages = array_values(array_unique($completedStages));
                $progress->is_completed = count($progress->completed_stages) >= count($stages);

            } else {
                // ── SINGLE-STAGE (no stages defined) ──────────────────────────
                $wasCompleted = (bool)$progress->is_completed;
                $progress->is_completed = $progress->current_progress >= $task->target_value;

                if ($progress->is_completed && !$wasCompleted) {
                    $reward = (int)$task->xp_reward;
                    $newlyAwardedXp += $reward;

                    DB::table('xp_transactions')->insert([
                        'user_id'     => $user->id,
                        'source_type' => 'daily_task',
                        'source_id'   => $task->id,
                        'xp_amount'   => $reward,
                        'created_at'  => now(),
                        'updated_at'  => now(),
                    ]);
                }
            }

            $progress->save();
        }

        // ── Award accumulated XP ──────────────────────────────────────────────
        if ($newlyAwardedXp > 0) {
            $user->increment('xp', $newlyAwardedXp);
        }
    }
}
