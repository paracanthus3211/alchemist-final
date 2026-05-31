<?php

use App\Http\Controllers\Admin\ArticleAdminController;
use App\Http\Controllers\Admin\AvatarAdminController;
use App\Http\Controllers\Admin\DailyTaskAdminController;
use App\Http\Controllers\Admin\QuizAdminController;
use App\Http\Controllers\Admin\RankAdminController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\FriendWebController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\VirtualLabController;
use App\Http\Controllers\PeriodicTableController;
use App\Http\Controllers\PeriodicArticleController;
use App\Models\Article;
use App\Models\Bookmark;
use App\Models\Chapter;
use App\Models\DailyTask;
use App\Models\Level;
use App\Models\Rank;
use App\Models\User;
use App\Models\UserDailyProgress;
use App\Models\UserLevelCompletion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    // Redirect authenticated users away from landing page
    if (Auth::check()) {
        return redirect('/home');
    }

    return view('welcome');
});

Route::get('/home', [HomeController::class, 'index'])->middleware('auth')->name('home');

// Virtual Lab (Web)
Route::middleware('auth')->group(function () {
    Route::get('/virtual-lab', [VirtualLabController::class, 'index'])->name('virtual_lab');
    Route::post('/virtual-lab/reaction', [VirtualLabController::class, 'recordReaction'])->name('virtual_lab.reaction');
    Route::get('/periodic-table', [PeriodicTableController::class, 'index'])->name('periodic_table');
    
    // Periodic Article Routes
    Route::get('/periodic-article/{elementNumber}', [PeriodicArticleController::class, 'show'])->name('periodic_article.show');
    Route::post('/periodic-article/save', [PeriodicArticleController::class, 'store'])->name('periodic_article.store');
    Route::get('/periodic-article/get/{elementNumber}', [PeriodicArticleController::class, 'getArticle'])->name('periodic_article.get');
    Route::delete('/periodic-article/{elementNumber}', [PeriodicArticleController::class, 'destroy'])->name('periodic_article.destroy');
});

Route::get('/login', function () {
    // Already logged in → go to home
    if (Auth::check()) {
        return redirect('/home');
    }

    return view('auth.login');
})->name('login');

// Handle web login form POST
Route::post('/login', function (Request $request) {
    $credentials = $request->validate([
        'email' => ['required'],
        'password' => ['required'],
    ]);

    // Try login with email
    if (Auth::attempt(['email' => $credentials['email'], 'password' => $credentials['password']], true)) {
        $request->session()->regenerate();

        return redirect()->intended('/home');
    }

    // Try login with username
    if (Auth::attempt(['username' => $credentials['email'], 'password' => $credentials['password']], true)) {
        $request->session()->regenerate();

        return redirect()->intended('/home');
    }

    return back()->withErrors([
        'email' => 'These credentials do not match our records.',
    ])->onlyInput('email');
});

Route::get('/register', function () {
    return view('auth.register');
})->name('register');

Route::get('/verify-email', function (Request $request) {
    $email = $request->query('email');
    
    if (!$email) {
        return redirect()->route('register');
    }
    
    return view('auth.verify-email', compact('email'));
})->name('verify-email');

Route::post('/logout', function (Request $request) {
    Auth::logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();

    return redirect('/');
})->name('logout');

Route::get('/quiz', function () {
    $user = auth()->user();

    // Latest article for "Continue Reading"
    $latestArticle = Article::latest()->first();

    // Streak days (last 7 days)
    $today = now();
    $days = [];
    for ($i = 6; $i >= 0; $i--) {
        $date = $today->copy()->subDays($i);
        $days[] = [
            'label' => $date->format('D'),
            'date'  => $date->format('j M'),
            'isToday' => $i === 0,
        ];
    }

    $todayStr = now()->toDateString();

    // Ensure tasks exist for today
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
                [
                    'user_id' => $user->id,
                    'task_id' => $template->id,
                    'date' => $todayStr,
                ],
                [
                    'current_progress' => 0,
                    'completed_stages' => [],
                    'is_completed' => false,
                ]
            );
        }
    }

    // Now get the assigned progress for today
    $dailyTasks = UserDailyProgress::where('user_id', $user->id)
        ->whereDate('date', $todayStr)
        ->with('task')
        ->get()
        ->filter(fn ($p) => $p->task !== null)
        ->map(function ($progress) {
            return (object) [
                'id' => $progress->task->id,
                'task_name' => $progress->task->task_name,
                'target_value' => $progress->task->target_value,
                'xp_reward' => $progress->task->xp_reward,
                'current_progress' => $progress->current_progress,
                'is_completed' => (bool) $progress->is_completed,
            ];
        });

    $completedCount = $dailyTasks->where('is_completed', true)->count();
    $totalCount = $dailyTasks->count();

    // Calculate Progress for ALL chapters
    $chapters = Chapter::with(['levels.questions'])->orderBy('order_index')->get();

    $allChaptersData = [];
    $foundActive = false;

    $userXp = (int) ($user->xp ?? 0);
    $prevChapterLastLevelDone = true;

    foreach ($chapters as $chIndex => $ch) {
        $levels = $ch->levels;
        $totalChEarnedXp = 0;
        $totalChTotalXp = 0;
        $chActiveLevelName = '';

        $levelData = collect();
        $prevLevelDone = $prevChapterLastLevelDone;

        foreach ($levels as $lvlIndex => $lvl) {
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

            // Use UserLevelCompletion as the primary source of truth for completion.
            // Fall back to XP comparison if no completion record exists yet.
            $isLevelDone = $everCompleted || ($lvlTotalXp > 0 && $lvlUserXp >= $lvlTotalXp);
            $hasNew = $everCompleted && ($lvlTotalXp > $lvlUserXp);

            if (! $isLevelDone && empty($chActiveLevelName)) {
                $chActiveLevelName = $lvl->name;
            }

            $isPrevDone = $prevLevelDone;
            $xpRequired = (int) ($lvl->xp_required ?? 0);
            $isXpMet = $userXp >= $xpRequired;

            $levelData->push([
                'level' => $lvl,
                'hasNew' => $hasNew,
                'earnedXp' => $lvlUserXp,
                'totalXp' => $lvlTotalXp,
                'isDone' => $isLevelDone,
                'levelIndex' => (int) ($lvl->order_index > 0 ? $lvl->order_index : $lvlIndex + 1),
                'isPrevDone' => $isPrevDone,
                'isXpMet' => $isXpMet,
                'isUnlocked' => $isLevelDone || ($isPrevDone && $isXpMet),
                'xpRequired' => $xpRequired,
            ]);

            $prevLevelDone = $isLevelDone;
        }

        $prevChapterLastLevelDone = $prevLevelDone;

        // Chapter progress: based on how many levels are completed (not XP ratio),
        // so that adding new questions to a completed level doesn't re-lock the chapter.
        $totalLevelsInCh = $levelData->count();
        $completedLevelsInCh = $levelData->where('isDone', true)->count();
        $chProgress = $totalLevelsInCh > 0
            ? min(100, round(($completedLevelsInCh / $totalLevelsInCh) * 100))
            : 0;

        if (empty($chActiveLevelName) && $levels->isNotEmpty()) {
            $chActiveLevelName = $levels->last()->name;
        }

        $isActive = false;
        $isLocked = false;

        if (! $foundActive) {
            if ($chProgress < 100) {
                $isActive = true;
                $foundActive = true;
            }
        } else {
            $isLocked = true;
        }

        $allChaptersData[] = [
            'chapter' => $ch,
            'title' => 'Chapter '.($ch->order_index > 0 ? $ch->order_index : $ch->id),
            'chapterName' => $ch->title,
            'activeLevelName' => $chActiveLevelName,
            'progress' => $chProgress,
            'color' => $ch->icon_emoji ?? '#00d4d4',
            'earnedXp' => $totalChEarnedXp,
            'totalXp' => $totalChTotalXp,
            'levelData' => $levelData,
            'isActive' => $isActive,
            'isLocked' => $isLocked,
        ];
    }

    if (! $foundActive && count($allChaptersData) > 0) {
        $allChaptersData[count($allChaptersData) - 1]['isActive'] = true;
        $allChaptersData[count($allChaptersData) - 1]['isLocked'] = false;
    }

    return view('quiz', compact(
        'user',
        'dailyTasks',
        'days',
        'completedCount',
        'totalCount',
        'allChaptersData'
    ));
})->middleware('auth')->name('quiz');

Route::get('/rank', function (Request $request) {
    $user = auth()->user();

    $period = $request->query('period', 'month'); // Default to month to match "This Month" active tab
    $scope = $request->query('scope', 'global');

    $query = User::query();

    if ($scope === 'friends' && $user) {
        $friendIds = DB::table('friends')
            ->where('status', 'accepted')
            ->where(function ($q) use ($user) {
                $q->where('user_id', $user->id)
                    ->orWhere('friend_id', $user->id);
            })
            ->get()
            ->map(function ($friend) use ($user) {
                return $friend->user_id == $user->id ? $friend->friend_id : $friend->user_id;
            })->toArray();

        $friendIds[] = $user->id; // Include user themselves
        $query->whereIn('users.id', $friendIds);
    }

    if (in_array($period, ['week', 'month'])) {
        if ($period === 'week') {
            // Start of current week (Monday)
            $startDate = now()->startOfWeek(\Carbon\Carbon::MONDAY)->startOfDay();
        } else {
            // Start of current month
            $startDate = now()->startOfMonth()->startOfDay();
        }

        $query->leftJoin('xp_transactions', function ($join) use ($startDate) {
            $join->on('users.id', '=', 'xp_transactions.user_id')
                ->where('xp_transactions.created_at', '>=', $startDate);
        })
            ->selectRaw('users.id, users.username, users.avatar_url, users.equipped_avatar_id, users.selected_rank_id, users.role, users.profile_bg_color, COALESCE(SUM(xp_transactions.xp_amount), 0) as xp')
            ->groupBy('users.id', 'users.username', 'users.avatar_url', 'users.equipped_avatar_id', 'users.selected_rank_id', 'users.role', 'users.profile_bg_color')
            ->orderByDesc('xp');
    } else {
        $query->select('users.id', 'users.username', 'users.xp', 'users.avatar_url', 'users.equipped_avatar_id', 'users.selected_rank_id', 'users.role', 'users.profile_bg_color')
            ->orderByDesc('users.xp');
    }

    // Get all users for leaderboard to calculate rankings
    $allUsers = $query->with('equippedAvatar')->get();

    // Top 3 for podium
    $top3 = $allUsers->take(3);

    // Remaining users
    $rest = $allUsers->slice(3);

    // Find current user's rank
    $rankPosition = $allUsers->search(function ($item) use ($user) {
        return $item->id == $user->id;
    });
    $rankPosition = $rankPosition !== false ? $rankPosition + 1 : '-';

    // Current user's displayed XP in this period
    $currentUserLeaderboardData = $allUsers->firstWhere('id', $user->id);
    $currentUserXp = $currentUserLeaderboardData ? $currentUserLeaderboardData->xp : 0;

    // Active chapter for the current user
    $userActiveChapter = DB::table('user_level_completions')
        ->join('levels', 'user_level_completions.level_id', '=', 'levels.id')
        ->join('chapters', 'levels.chapter_id', '=', 'chapters.id')
        ->where('user_level_completions.user_id', $user->id)
        ->select('chapters.order_index as chapter_order', 'chapters.title as chapter_title')
        ->orderByDesc('user_level_completions.created_at')
        ->first();

    $userChapterLabel = $userActiveChapter
        ? 'Chapter ' . $userActiveChapter->chapter_order . ', ' . $userActiveChapter->chapter_title
        : 'Chapter 1';

    // Next rank to achieve (lowest xp_threshold above user's current XP)
    $allRanks = \App\Models\Rank::orderBy('xp_threshold')->get();
    $nextRank = $allRanks->first(fn($r) => $r->xp_threshold > $user->xp);
    $nextRankXp = $nextRank ? $nextRank->xp_threshold : null;
    $nextRankName = $nextRank ? $nextRank->name : null;

    // Progress toward next rank
    // Find the rank just below (current rank threshold)
    $currentRankObj = $allRanks->filter(fn($r) => $r->xp_threshold <= $user->xp)->last();
    $currentRankThreshold = $currentRankObj ? $currentRankObj->xp_threshold : 0;
    $rankProgressPct = 100;
    if ($nextRank) {
        $range = $nextRankXp - $currentRankThreshold;
        $earned = $user->xp - $currentRankThreshold;
        $rankProgressPct = $range > 0 ? min(100, round(($earned / $range) * 100)) : 100;
    }

    return view('rank', compact(
        'user', 'top3', 'rest', 'rankPosition', 'allUsers',
        'period', 'scope', 'currentUserXp',
        'userChapterLabel', 'nextRankName', 'nextRankXp', 'rankProgressPct', 'currentRankThreshold'
    ));
})->middleware('auth')->name('rank');

Route::get('/library', function (Request $request) {
    $user = auth()->user();

    $search = $request->query('search');
    $category = $request->query('category', 'all');

    // Get unique categories for the tabs (fallback to default if none exist)
    $dbCategories = Article::select('category')
        ->whereNotNull('category')
        ->where('category', '!=', '')
        ->distinct()
        ->pluck('category');

    $categories = $dbCategories->isNotEmpty() ? $dbCategories : collect(['Acid Reactions', 'Elemental Study', 'Lab Protocols']);

    $query = Article::query();

    if ($search) {
        $query->where(function ($q) use ($search) {
            $q->where('title', 'like', '%'.$search.'%')
                ->orWhere('description', 'like', '%'.$search.'%');
        });
    }

    if ($category === 'bookmarks') {
        $query->whereHas('bookmarks', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        });
    } elseif ($category !== 'all') {
        $query->where('category', $category);
    }

    $articles = $query->latest()->get();

    $bookmarkedArticleIds = $user->bookmarks()->pluck('article_id')->toArray();

    return view('library', compact('user', 'articles', 'search', 'category', 'categories', 'bookmarkedArticleIds'));
})->middleware('auth')->name('library');

Route::get('/articles/{id}', function ($id) {
    $user = auth()->user();
    $article = Article::with(['contents'])->findOrFail($id);

    return view('articles.show', compact('user', 'article'));
})->middleware('auth')->name('articles.show');

Route::post('/articles/{id}/bookmark', function ($id) {
    $user = auth()->user();
    $bookmark = Bookmark::where('user_id', $user->id)->where('article_id', $id)->first();
    if ($bookmark) {
        $bookmark->delete();
        $isBookmarked = false;
    } else {
        Bookmark::create(['user_id' => $user->id, 'article_id' => $id]);
        $isBookmarked = true;
    }
    $count = $user->bookmarks()->count();

    return response()->json([
        'status' => 'success',
        'is_bookmarked' => $isBookmarked,
        'count' => $count,
    ]);
})->middleware('auth')->name('articles.bookmark');

Route::get('/profile', [ProfileController::class, 'index'])->middleware('auth')->name('profile');
Route::get('/profile/avatar', [ProfileController::class, 'avatar'])->middleware('auth')->name('profile.avatar');
Route::post('/profile/avatar', [ProfileController::class, 'saveAvatar'])->middleware('auth')->name('profile.avatar.save');
Route::get('/profile/{id}', [ProfileController::class, 'show'])->middleware('auth')->name('profile.show');
Route::post('/profile/{id}/follow', [ProfileController::class, 'follow'])->middleware('auth')->name('profile.follow');
Route::post('/profile/{id}/unfollow', [ProfileController::class, 'unfollow'])->middleware('auth')->name('profile.unfollow');

// Friends Web Routes
Route::middleware('auth')->prefix('friends')->name('friends.')->group(function () {
    Route::get('/', [FriendWebController::class, 'index'])->name('index');
    Route::get('/search', [FriendWebController::class, 'search'])->name('search');
    Route::get('/list', [FriendWebController::class, 'getFriends'])->name('list');
    Route::get('/requests', [FriendWebController::class, 'getRequests'])->name('requests');
    Route::post('/request/{id}', [FriendWebController::class, 'sendRequest'])->name('sendRequest');
    Route::post('/accept/{id}', [FriendWebController::class, 'acceptRequest'])->name('acceptRequest');
    Route::post('/ignore/{id}', [FriendWebController::class, 'ignoreRequest'])->name('ignoreRequest');
    Route::post('/unfriend/{id}', [FriendWebController::class, 'unfriend'])->name('unfriend');
});

Route::get('/ranks', function () {
    $user = auth()->user();
    $ranks = Rank::all();

    return view('ranks.index', compact('user', 'ranks'));
})->middleware('auth')->name('ranks.index');

Route::post('/ranks/equip/{id}', function (Request $request, $id) {
    $user = auth()->user();
    $rank = Rank::findOrFail($id);

    // Check threshold if you want
    if ($user->xp >= $rank->xp_threshold) {
        // Assume users have a 'selected_rank_id' column or 'role' might be used, but since 'equipped_avatar_id' is there, maybe 'selected_rank_id' is too. Let's just update 'selected_rank_id'
        $user->selected_rank_id = $rank->id;
        $user->save();

        return redirect()->route('ranks.index')->with('success', 'Rank equipped!');
    }

    return redirect()->route('ranks.index')->with('error', 'Not enough XP for this rank.');
})->middleware('auth')->name('ranks.equip');

Route::group(['middleware' => 'auth', 'prefix' => 'admin'], function () {
    Route::get('/quiz', [QuizAdminController::class, 'index'])->name('admin.quiz.index');

    // Chapters
    Route::post('/chapters', [QuizAdminController::class, 'storeChapter'])->name('admin.chapters.store');
    Route::post('/chapters/{id}', [QuizAdminController::class, 'updateChapter'])->name('admin.chapters.update');
    Route::post('/chapters/{id}/delete', [QuizAdminController::class, 'destroyChapter'])->name('admin.chapters.destroy');

    // Levels
    Route::post('/levels', [QuizAdminController::class, 'storeLevel'])->name('admin.levels.store');
    Route::post('/levels/{id}', [QuizAdminController::class, 'updateLevel'])->name('admin.levels.update');
    Route::post('/levels/{id}/delete', [QuizAdminController::class, 'destroyLevel'])->name('admin.levels.destroy');

    // Questions
    Route::post('/questions', [QuizAdminController::class, 'storeQuestion'])->name('admin.questions.store');
    Route::post('/questions/{id}', [QuizAdminController::class, 'updateQuestion'])->name('admin.questions.update');
    Route::post('/questions/{id}/delete', [QuizAdminController::class, 'destroyQuestion'])->name('admin.questions.destroy');

    // Daily Tasks
    Route::get('/daily-tasks', [DailyTaskAdminController::class, 'index'])->name('admin.daily-tasks.index');
    Route::get('/daily-tasks/create', [DailyTaskAdminController::class, 'create'])->name('admin.daily-tasks.create');
    Route::post('/daily-tasks', [DailyTaskAdminController::class, 'store'])->name('admin.daily-tasks.store');
    Route::get('/daily-tasks/{id}/edit', [DailyTaskAdminController::class, 'edit'])->name('admin.daily-tasks.edit');
    Route::post('/daily-tasks/{id}', [DailyTaskAdminController::class, 'update'])->name('admin.daily-tasks.update');
    Route::post('/daily-tasks/{id}/delete', [DailyTaskAdminController::class, 'destroy'])->name('admin.daily-tasks.destroy');

    // Ranks
    Route::get('/ranks', [RankAdminController::class, 'index'])->name('admin.ranks.index');
    Route::post('/ranks', [RankAdminController::class, 'store'])->name('admin.ranks.store');
    Route::post('/ranks/{id}', [RankAdminController::class, 'update'])->name('admin.ranks.update');
    Route::post('/ranks/{id}/delete', [RankAdminController::class, 'destroy'])->name('admin.ranks.destroy');

    // Avatars
    Route::get('/avatars', [AvatarAdminController::class, 'index'])->name('admin.avatars.index');
    Route::post('/avatars', [AvatarAdminController::class, 'store'])->name('admin.avatars.store');
    Route::post('/avatars/{id}', [AvatarAdminController::class, 'update'])->name('admin.avatars.update');
    Route::post('/avatars/{id}/delete', [AvatarAdminController::class, 'destroy'])->name('admin.avatars.destroy');

    // Articles Admin
    Route::get('/articles/create', [ArticleAdminController::class, 'create'])->name('admin.articles.create');
    Route::get('/articles/{id}/edit', [ArticleAdminController::class, 'edit'])->name('admin.articles.edit');
    Route::post('/articles', [ArticleAdminController::class, 'store'])->name('admin.articles.store');
    Route::post('/articles/upload-image', [ArticleAdminController::class, 'uploadImage'])->name('admin.articles.upload_image');
    Route::post('/articles/{id}', [ArticleAdminController::class, 'update'])->name('admin.articles.update');
    Route::post('/articles/{id}/delete', [ArticleAdminController::class, 'destroy'])->name('admin.articles.destroy');
});

Route::get('/quiz/play/{level_id}', function ($level_id) {
    $user = auth()->user();
    $level = Level::with(['chapter', 'questions' => function ($q) {
        $q->with(['multipleChoiceOptions', 'sentenceArrangementWords', 'labPracticeConfig'])
            ->orderBy('order_index');
    }])->findOrFail($level_id);

    return view('quiz.play', compact('user', 'level'));
})->middleware('auth')->name('quiz.play');

Route::post('/quiz/play/{level_id}/complete', function (Request $request, $level_id) {
    $user = auth()->user();

    // Check if the level has already been completed before to prevent XP farming!
    $alreadyCompleted = UserLevelCompletion::where('user_id', $user->id)
        ->where('level_id', $level_id)
        ->exists();

    $completion = UserLevelCompletion::updateOrCreate(
        ['user_id' => $user->id, 'level_id' => $level_id],
        [
            'score' => $request->score ?? 100,
            'completion_time_seconds' => $request->completion_time_seconds ?? 60,
            'wrong_answers_count' => $request->wrong_answers_count ?? 0,
        ]
    );

    $xpEarned = $request->xp_earned ?? 10;

    if (! $alreadyCompleted) {
        // Increment User's XP
        $user->xp += $xpEarned;

        // Save user
        $user->save();

        // Create XP Transaction with correct DB schema columns
        DB::table('xp_transactions')->insert([
            'user_id' => $user->id,
            'source_type' => 'quiz_level',
            'source_id' => $level_id,
            'xp_amount' => $xpEarned,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Update daily task progress if trait methods exist, otherwise safe fallback
        try {
            $user->updateStreak();
        } catch (Exception $e) {
            // Ignore if method is missing or handles differently
        }
    } else {
        $xpEarned = 0;
    }

    return response()->json(['success' => true, 'redirect' => route('quiz'), 'xp_earned' => $xpEarned]);
})->middleware('auth')->name('quiz.complete');
