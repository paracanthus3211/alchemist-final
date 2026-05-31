<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\Chapter;
use App\Models\DailyTask;
use App\Models\UserDailyProgress;
use App\Models\UserLevelCompletion;
use App\Traits\UpdatesDailyTasks;
use Illuminate\Support\Facades\DB;

class HomeController extends Controller
{
    use UpdatesDailyTasks;

    public function index()
    {
        $user = auth()->user();

        // ── Streak reset check ──────────────────────────────────────────────
        $user->checkStreakReset();

        // ── Streak days (last 7 days) ───────────────────────────────────────
        $today = now();
        $days  = [];
        for ($i = 6; $i >= 0; $i--) {
            $date   = $today->copy()->subDays($i);
            $days[] = [
                'label'   => $date->format('D'),
                'date'    => $date->format('j M'),
                'isToday' => $i === 0,
            ];
        }

        $todayStr = now()->toDateString();

        // ── Ensure tasks exist for today ────────────────────────────────────
        $hasTasksToday = UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $todayStr)
            ->exists();

        if (! $hasTasksToday) {
            $templates = DailyTask::where('is_active', true)
                ->inRandomOrder()
                ->limit(3)
                ->get();

            foreach ($templates as $template) {
                UserDailyProgress::firstOrCreate(
                    ['user_id' => $user->id, 'task_id' => $template->id, 'date' => $todayStr],
                    ['current_progress' => 0, 'completed_stages' => [], 'is_completed' => false]
                );
            }
        }

        // ── Track DAILY_LOGIN progress (once per day via cache) ─────────────
        $loginCacheKey = "daily_login_web_{$user->id}_{$todayStr}";
        if (! \Illuminate\Support\Facades\Cache::has($loginCacheKey)) {
            $this->_incrementDailyTaskProgress($user, 'DAILY_LOGIN');
            \Illuminate\Support\Facades\Cache::put($loginCacheKey, true, now()->endOfDay());
        }

        // ── Fetch today's tasks with fresh progress ─────────────────────────
        $dailyTasks = UserDailyProgress::where('user_id', $user->id)
            ->whereDate('date', $todayStr)
            ->with('task')
            ->get()
            ->filter(fn ($p) => $p->task !== null)
            ->map(function ($progress) {
                return (object) [
                    'id'               => $progress->task->id,
                    'task_name'        => $progress->task->task_name,
                    'target_value'     => $progress->task->target_value,
                    'xp_reward'        => $progress->task->xp_reward,
                    'current_progress' => $progress->current_progress,
                    'is_completed'     => (bool) $progress->is_completed,
                ];
            });

        $completedCount = $dailyTasks->where('is_completed', true)->count();
        $totalCount     = $dailyTasks->count();

        // ── Latest article ──────────────────────────────────────────────────
        $latestArticle = Article::latest()->first();

        // ── Active chapter banner ───────────────────────────────────────────
        $chapters       = Chapter::with(['levels.questions'])->orderBy('order_index')->get();
        $activeChapter  = null;
        $activeLevelName = '';
        $chapterProgress = 0;
        $chapterColor   = '#00FBFF';
        $chapterEarnedXp = 0;
        $chapterTotalXp  = 0;

        foreach ($chapters as $ch) {
            $levels            = $ch->levels;
            $totalChEarnedXp   = 0;
            $totalChTotalXp    = 0;
            $chActiveLevelName = '';
            $totalLevelsInCh   = $levels->count();
            $completedLevelsInCh = 0;

            foreach ($levels as $lvl) {
                $lvlTotalXp = $lvl->questions->sum('xp_reward');
                $totalChTotalXp += $lvlTotalXp;

                $lvlUserXp = DB::table('xp_transactions')
                    ->where('user_id', $user->id)
                    ->where('source_type', 'quiz_level')
                    ->where('source_id', $lvl->id)
                    ->sum('xp_amount');
                $totalChEarnedXp += $lvlUserXp;

                $everCompleted = UserLevelCompletion::where('user_id', $user->id)
                    ->where('level_id', $lvl->id)->exists();
                $isLevelDone = $everCompleted || ($lvlTotalXp > 0 && $lvlUserXp >= $lvlTotalXp);

                if ($isLevelDone) {
                    $completedLevelsInCh++;
                }
                if (! $isLevelDone && empty($chActiveLevelName)) {
                    $chActiveLevelName = $lvl->name;
                }
            }

            $chProgress = $totalLevelsInCh > 0
                ? min(100, round(($completedLevelsInCh / $totalLevelsInCh) * 100))
                : 0;

            if (empty($chActiveLevelName) && $levels->isNotEmpty()) {
                $chActiveLevelName = $levels->last()->name;
            }

            if ($chProgress < 100 || $activeChapter === null) {
                $activeChapter   = $ch;
                $activeLevelName = $chActiveLevelName;
                $chapterProgress = $chProgress;
                $chapterColor    = $ch->icon_emoji ?? '#00FBFF';
                $chapterEarnedXp = $totalChEarnedXp;
                $chapterTotalXp  = $totalChTotalXp;
                if ($chProgress < 100) {
                    break;
                }
            }
        }

        if (! $activeChapter && $chapters->isNotEmpty()) {
            $activeChapter = $chapters->last();
            $chapterColor  = $activeChapter->icon_emoji ?? '#00FBFF';
        }

        return view('home', compact(
            'user',
            'latestArticle',
            'dailyTasks',
            'days',
            'completedCount',
            'totalCount',
            'activeChapter',
            'activeLevelName',
            'chapterProgress',
            'chapterColor',
            'chapterEarnedXp',
            'chapterTotalXp'
        ));
    }
}
