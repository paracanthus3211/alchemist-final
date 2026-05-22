<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

Route::get('/', function () {
    // Redirect authenticated users away from landing page
    if (Auth::check()) {
        return redirect('/home');
    }
    return view('welcome');
});

Route::get('/home', function () {
    $user = auth()->user();

    // Latest article for "Continue Reading"
    $latestArticle = \App\Models\Article::latest()->first();

    // Streak days (last 7 days)
    $today = now();
    $days = [];
    for ($i = 6; $i >= 0; $i--) {
        $date = $today->copy()->subDays($i);
        $days[] = [
            'label' => $date->format('D'), // Mon, Tue, ...
            'date'  => $date->day,
            'isToday' => $i === 0,
        ];
    }

    $todayStr = now()->toDateString();
    
    // Ensure tasks exist for today (pick up to 4 random templates)
    $hasTasksToday = \App\Models\UserDailyProgress::where('user_id', $user->id)
        ->whereDate('date', $todayStr)
        ->exists();

    if (!$hasTasksToday) {
        $templates = \App\Models\DailyTask::where('is_active', true)
            ->inRandomOrder()
            ->limit(4)
            ->get();

        foreach ($templates as $template) {
            \App\Models\UserDailyProgress::firstOrCreate(
                [
                    'user_id' => $user->id,
                    'task_id' => $template->id,
                    'date'    => $todayStr,
                ],
                [
                    'current_progress' => 0,
                    'completed_stages' => [],
                    'is_completed'     => false,
                ]
            );
        }
    }

    // Now get the assigned progress for today
    $dailyTasks = \App\Models\UserDailyProgress::where('user_id', $user->id)
        ->whereDate('date', $todayStr)
        ->with('task')
        ->get()
        ->filter(fn($p) => $p->task !== null)
        ->map(function($progress) {
            return (object)[
                'id' => $progress->task->id,
                'task_name' => $progress->task->task_name,
                'target_value' => $progress->task->target_value,
                'xp_reward' => $progress->task->xp_reward,
                'current_progress' => $progress->current_progress,
                'is_completed' => (bool)$progress->is_completed,
            ];
        });

    $completedCount = $dailyTasks->where('is_completed', true)->count();
    $totalCount = $dailyTasks->count();

    // Calculate Active/Current Chapter and Level Progress for tactile banner
    $chapters = \App\Models\Chapter::with(['levels.questions'])->orderBy('order_index')->get();
    
    $activeChapter = null;
    $activeLevelName = '';
    $chapterProgress = 0;
    $chapterColor = '#00FBFF'; // Default cyan
    $chapterEarnedXp = 0;
    $chapterTotalXp = 0;

    foreach ($chapters as $ch) {
        $levels = $ch->levels;
        $completedLevelsCount = 0;
        $totalChEarnedXp = 0;
        $totalChTotalXp = 0;
        $chActiveLevelName = '';

        foreach ($levels as $lvl) {
            $lvlTotalXp = $lvl->questions->sum('xp_reward');
            $totalChTotalXp += $lvlTotalXp;

            $lvlUserXp = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                ->whereIn('question_id', $lvl->questions->pluck('id'))
                ->where('is_correct', true)
                ->sum('xp_earned');
            $totalChEarnedXp += $lvlUserXp;

            $lvlProgress = $lvlTotalXp > 0 ? min(100, round(($lvlUserXp / $lvlTotalXp) * 100)) : 0;
            if ($lvlProgress >= 100) {
                $completedLevelsCount++;
            } else {
                if (empty($chActiveLevelName)) {
                    $chActiveLevelName = $lvl->name;
                }
            }
        }

        $chProgress = $levels->count() > 0 ? round(($completedLevelsCount / $levels->count()) * 100) : 0;
        
        if (empty($chActiveLevelName) && $levels->isNotEmpty()) {
            $chActiveLevelName = $levels->last()->name;
        }

        if ($chProgress < 100 || $activeChapter === null) {
            $activeChapter = $ch;
            $activeLevelName = $chActiveLevelName;
            $chapterProgress = $chProgress;
            $chapterColor = $ch->icon_emoji ?? '#00FBFF';
            $chapterEarnedXp = $totalChEarnedXp;
            $chapterTotalXp = $totalChTotalXp;
            if ($chProgress < 100) {
                break;
            }
        }
    }

    if (!$activeChapter && $chapters->isNotEmpty()) {
        $activeChapter = $chapters->last();
        $chapterColor = $activeChapter->icon_emoji ?? '#00FBFF';
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
})->middleware('auth')->name('home');

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
        'email'    => ['required'],
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

Route::post('/logout', function (Request $request) {
    Auth::logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();
    return redirect('/');
})->name('logout');

Route::get('/quiz', function () {
    $user = auth()->user();

    // Latest article for "Continue Reading"
    $latestArticle = \App\Models\Article::latest()->first();

    // Streak days (last 7 days)
    $today = now();
    $days = [];
    for ($i = 6; $i >= 0; $i--) {
        $date = $today->copy()->subDays($i);
        $days[] = [
            'label' => $date->format('D'),
            'date'  => $date->day,
            'isToday' => $i === 0,
        ];
    }

    $todayStr = now()->toDateString();
    
    // Ensure tasks exist for today
    $hasTasksToday = \App\Models\UserDailyProgress::where('user_id', $user->id)
        ->whereDate('date', $todayStr)
        ->exists();

    if (!$hasTasksToday) {
        $templates = \App\Models\DailyTask::where('is_active', true)
            ->inRandomOrder()
            ->limit(4)
            ->get();

        foreach ($templates as $template) {
            \App\Models\UserDailyProgress::firstOrCreate(
                [
                    'user_id' => $user->id,
                    'task_id' => $template->id,
                    'date'    => $todayStr,
                ],
                [
                    'current_progress' => 0,
                    'completed_stages' => [],
                    'is_completed'     => false,
                ]
            );
        }
    }

    // Now get the assigned progress for today
    $dailyTasks = \App\Models\UserDailyProgress::where('user_id', $user->id)
        ->whereDate('date', $todayStr)
        ->with('task')
        ->get()
        ->filter(fn($p) => $p->task !== null)
        ->map(function($progress) {
            return (object)[
                'id' => $progress->task->id,
                'task_name' => $progress->task->task_name,
                'target_value' => $progress->task->target_value,
                'xp_reward' => $progress->task->xp_reward,
                'current_progress' => $progress->current_progress,
                'is_completed' => (bool)$progress->is_completed,
            ];
        });

    $completedCount = $dailyTasks->where('is_completed', true)->count();
    $totalCount = $dailyTasks->count();

    // Calculate Active/Current Chapter and Level Progress
    $chapters = \App\Models\Chapter::with(['levels.questions'])->orderBy('order_index')->get();
    
    $activeChapter = null;
    $activeLevelName = '';
    $chapterProgress = 0;
    $chapterColor = '#00d4d4'; // Default cyan
    $chapterEarnedXp = 0;
    $chapterTotalXp = 0;

    foreach ($chapters as $ch) {
        $levels = $ch->levels;
        $completedLevelsCount = 0;
        $totalChEarnedXp = 0;
        $totalChTotalXp = 0;
        $chActiveLevelName = '';

        foreach ($levels as $lvl) {
            $lvlTotalXp = $lvl->questions->sum('xp_reward');
            $totalChTotalXp += $lvlTotalXp;

            $lvlUserXp = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                ->whereIn('question_id', $lvl->questions->pluck('id'))
                ->where('is_correct', true)
                ->sum('xp_earned');
            $totalChEarnedXp += $lvlUserXp;

            $lvlProgress = $lvlTotalXp > 0 ? min(100, round(($lvlUserXp / $lvlTotalXp) * 100)) : 0;
            if ($lvlProgress >= 100) {
                $completedLevelsCount++;
            } else {
                if (empty($chActiveLevelName)) {
                    $chActiveLevelName = $lvl->name;
                }
            }
        }

        $chProgress = $levels->count() > 0 ? round(($completedLevelsCount / $levels->count()) * 100) : 0;
        
        if (empty($chActiveLevelName) && $levels->isNotEmpty()) {
            $chActiveLevelName = $levels->last()->name;
        }

        if ($chProgress < 100 || $activeChapter === null) {
            $activeChapter = $ch;
            $activeLevelName = $chActiveLevelName;
            $chapterProgress = $chProgress;
            $chapterColor = $ch->icon_emoji ?? '#00d4d4';
            $chapterEarnedXp = $totalChEarnedXp;
            $chapterTotalXp = $totalChTotalXp;
            if ($chProgress < 100) {
                break;
            }
        }
    }

    if (!$activeChapter && $chapters->isNotEmpty()) {
        $activeChapter = $chapters->last();
        $chapterColor = $activeChapter->icon_emoji ?? '#00d4d4';
    }

    // Get levels for the active chapter
    $levels = $activeChapter ? $activeChapter->levels : collect();

    return view('quiz', compact(
        'user', 
        'dailyTasks', 
        'days', 
        'completedCount', 
        'totalCount',
        'activeChapter',
        'activeLevelName',
        'chapterProgress',
        'chapterColor',
        'chapterEarnedXp',
        'chapterTotalXp',
        'levels'
    ));
})->middleware('auth')->name('quiz');

Route::get('/rank', function (Request $request) {
    $user = auth()->user();
    
    $period = $request->query('period', 'month'); // Default to month to match "This Month" active tab
    $scope = $request->query('scope', 'global');
    
    $query = \App\Models\User::query();

    if ($scope === 'friends' && $user) {
        $friendIds = \Illuminate\Support\Facades\DB::table('friends')
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
        $days = ($period === 'week') ? 7 : 30;
        $startDate = now()->subDays($days);
        
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
    
    return view('rank', compact('user', 'top3', 'rest', 'rankPosition', 'allUsers', 'period', 'scope', 'currentUserXp'));
})->middleware('auth')->name('rank');

Route::get('/library', function (Request $request) {
    $user = auth()->user();
    
    $search = $request->query('search');
    $category = $request->query('category', 'all');
    
    // Get unique categories for the tabs (fallback to default if none exist)
    $dbCategories = \App\Models\Article::select('category')
        ->whereNotNull('category')
        ->where('category', '!=', '')
        ->distinct()
        ->pluck('category');
        
    $categories = $dbCategories->isNotEmpty() ? $dbCategories : collect(['Acid Reactions', 'Elemental Study', 'Lab Protocols']);
    
    $query = \App\Models\Article::query();
    
    if ($search) {
        $query->where(function($q) use ($search) {
            $q->where('title', 'like', '%' . $search . '%')
              ->orWhere('description', 'like', '%' . $search . '%');
        });
    }
    
    if ($category === 'bookmarks') {
        $query->whereHas('bookmarks', function($q) use ($user) {
            $q->where('user_id', $user->id);
        });
    } else if ($category !== 'all') {
        $query->where('category', $category);
    }
    
    $articles = $query->latest()->get();
    
    $bookmarkedArticleIds = $user->bookmarks()->pluck('article_id')->toArray();
    
    return view('library', compact('user', 'articles', 'search', 'category', 'categories', 'bookmarkedArticleIds'));
})->middleware('auth')->name('library');

Route::post('/articles/{id}/bookmark', function ($id) {
    $user = auth()->user();
    $bookmark = \App\Models\Bookmark::where('user_id', $user->id)->where('article_id', $id)->first();
    if ($bookmark) {
        $bookmark->delete();
        $isBookmarked = false;
    } else {
        \App\Models\Bookmark::create(['user_id' => $user->id, 'article_id' => $id]);
        $isBookmarked = true;
    }
    $count = $user->bookmarks()->count();
    return response()->json([
        'status' => 'success',
        'is_bookmarked' => $isBookmarked,
        'count' => $count
    ]);
})->middleware('auth')->name('articles.bookmark');

Route::get('/profile', [\App\Http\Controllers\ProfileController::class, 'index'])->middleware('auth')->name('profile');
Route::get('/profile/avatar', [\App\Http\Controllers\ProfileController::class, 'avatar'])->middleware('auth')->name('profile.avatar');
Route::post('/profile/avatar', [\App\Http\Controllers\ProfileController::class, 'saveAvatar'])->middleware('auth')->name('profile.avatar.save');

// Friends Web Routes
Route::middleware('auth')->prefix('friends')->name('friends.')->group(function () {
    Route::get('/', [\App\Http\Controllers\FriendWebController::class, 'index'])->name('index');
    Route::get('/search', [\App\Http\Controllers\FriendWebController::class, 'search'])->name('search');
    Route::get('/list', [\App\Http\Controllers\FriendWebController::class, 'getFriends'])->name('list');
    Route::get('/requests', [\App\Http\Controllers\FriendWebController::class, 'getRequests'])->name('requests');
    Route::post('/request/{id}', [\App\Http\Controllers\FriendWebController::class, 'sendRequest'])->name('sendRequest');
    Route::post('/accept/{id}', [\App\Http\Controllers\FriendWebController::class, 'acceptRequest'])->name('acceptRequest');
    Route::post('/ignore/{id}', [\App\Http\Controllers\FriendWebController::class, 'ignoreRequest'])->name('ignoreRequest');
});

Route::get('/ranks', function () {
    $user = auth()->user();
    $ranks = \App\Models\Rank::all();
    return view('ranks.index', compact('user', 'ranks'));
})->middleware('auth')->name('ranks.index');

Route::post('/ranks/equip/{id}', function (\Illuminate\Http\Request $request, $id) {
    $user = auth()->user();
    $rank = \App\Models\Rank::findOrFail($id);
    
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
    Route::get('/quiz', [\App\Http\Controllers\Admin\QuizAdminController::class, 'index'])->name('admin.quiz.index');
    
    // Chapters
    Route::post('/chapters', [\App\Http\Controllers\Admin\QuizAdminController::class, 'storeChapter'])->name('admin.chapters.store');
    Route::post('/chapters/{id}', [\App\Http\Controllers\Admin\QuizAdminController::class, 'updateChapter'])->name('admin.chapters.update');
    Route::post('/chapters/{id}/delete', [\App\Http\Controllers\Admin\QuizAdminController::class, 'destroyChapter'])->name('admin.chapters.destroy');

    // Levels
    Route::post('/levels', [\App\Http\Controllers\Admin\QuizAdminController::class, 'storeLevel'])->name('admin.levels.store');
    Route::post('/levels/{id}', [\App\Http\Controllers\Admin\QuizAdminController::class, 'updateLevel'])->name('admin.levels.update');
    Route::post('/levels/{id}/delete', [\App\Http\Controllers\Admin\QuizAdminController::class, 'destroyLevel'])->name('admin.levels.destroy');

    // Questions
    Route::post('/questions', [\App\Http\Controllers\Admin\QuizAdminController::class, 'storeQuestion'])->name('admin.questions.store');
    Route::post('/questions/{id}', [\App\Http\Controllers\Admin\QuizAdminController::class, 'updateQuestion'])->name('admin.questions.update');
    Route::post('/questions/{id}/delete', [\App\Http\Controllers\Admin\QuizAdminController::class, 'destroyQuestion'])->name('admin.questions.destroy');

    // Daily Tasks
    Route::get('/daily-tasks', [\App\Http\Controllers\Admin\DailyTaskAdminController::class, 'index'])->name('admin.daily-tasks.index');
    Route::get('/daily-tasks/create', [\App\Http\Controllers\Admin\DailyTaskAdminController::class, 'create'])->name('admin.daily-tasks.create');
    Route::post('/daily-tasks', [\App\Http\Controllers\Admin\DailyTaskAdminController::class, 'store'])->name('admin.daily-tasks.store');
    Route::get('/daily-tasks/{id}/edit', [\App\Http\Controllers\Admin\DailyTaskAdminController::class, 'edit'])->name('admin.daily-tasks.edit');
    Route::post('/daily-tasks/{id}', [\App\Http\Controllers\Admin\DailyTaskAdminController::class, 'update'])->name('admin.daily-tasks.update');
    Route::post('/daily-tasks/{id}/delete', [\App\Http\Controllers\Admin\DailyTaskAdminController::class, 'destroy'])->name('admin.daily-tasks.destroy');

    // Ranks
    Route::get('/ranks', [\App\Http\Controllers\Admin\RankAdminController::class, 'index'])->name('admin.ranks.index');
    Route::post('/ranks', [\App\Http\Controllers\Admin\RankAdminController::class, 'store'])->name('admin.ranks.store');
    Route::post('/ranks/{id}', [\App\Http\Controllers\Admin\RankAdminController::class, 'update'])->name('admin.ranks.update');
    Route::post('/ranks/{id}/delete', [\App\Http\Controllers\Admin\RankAdminController::class, 'destroy'])->name('admin.ranks.destroy');

    // Avatars
    Route::get('/avatars', [\App\Http\Controllers\Admin\AvatarAdminController::class, 'index'])->name('admin.avatars.index');
    Route::post('/avatars', [\App\Http\Controllers\Admin\AvatarAdminController::class, 'store'])->name('admin.avatars.store');
    Route::post('/avatars/{id}', [\App\Http\Controllers\Admin\AvatarAdminController::class, 'update'])->name('admin.avatars.update');
    Route::post('/avatars/{id}/delete', [\App\Http\Controllers\Admin\AvatarAdminController::class, 'destroy'])->name('admin.avatars.destroy');

    // Articles Admin
    Route::get('/articles/create', [\App\Http\Controllers\Admin\ArticleAdminController::class, 'create'])->name('admin.articles.create');
    Route::get('/articles/{id}/edit', [\App\Http\Controllers\Admin\ArticleAdminController::class, 'edit'])->name('admin.articles.edit');
    Route::post('/articles', [\App\Http\Controllers\Admin\ArticleAdminController::class, 'store'])->name('admin.articles.store');
    Route::post('/articles/upload-image', [\App\Http\Controllers\Admin\ArticleAdminController::class, 'uploadImage'])->name('admin.articles.upload_image');
    Route::post('/articles/{id}', [\App\Http\Controllers\Admin\ArticleAdminController::class, 'update'])->name('admin.articles.update');
    Route::post('/articles/{id}/delete', [\App\Http\Controllers\Admin\ArticleAdminController::class, 'destroy'])->name('admin.articles.destroy');
});

Route::get('/quiz/play/{level_id}', function ($level_id) {
    $user = auth()->user();
    $level = \App\Models\Level::with(['chapter', 'questions' => function($q) {
        $q->with(['multipleChoiceOptions', 'sentenceArrangementWords', 'labPracticeConfig'])
          ->orderBy('order_index');
    }])->findOrFail($level_id);
    
    return view('quiz.play', compact('user', 'level'));
})->middleware('auth')->name('quiz.play');

Route::post('/quiz/play/{level_id}/complete', function (\Illuminate\Http\Request $request, $level_id) {
    $user = auth()->user();
    
    // Check if the level has already been completed before to prevent XP farming!
    $alreadyCompleted = \App\Models\UserLevelCompletion::where('user_id', $user->id)
        ->where('level_id', $level_id)
        ->exists();
    
    $completion = \App\Models\UserLevelCompletion::updateOrCreate(
        ['user_id' => $user->id, 'level_id' => $level_id],
        [
            'score' => $request->score ?? 100,
            'completion_time_seconds' => $request->completion_time_seconds ?? 60,
            'wrong_answers_count' => $request->wrong_answers_count ?? 0,
        ]
    );
    
    $xpEarned = $request->xp_earned ?? 10;
    
    if (!$alreadyCompleted) {
        // Increment User's XP
        $user->xp += $xpEarned;
        
        // Save user
        $user->save();
        
        // Create XP Transaction with correct DB schema columns
        \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
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
        } catch (\Exception $e) {
            // Ignore if method is missing or handles differently
        }
    } else {
        $xpEarned = 0;
    }

    return response()->json(['success' => true, 'redirect' => route('quiz'), 'xp_earned' => $xpEarned]);
})->middleware('auth')->name('quiz.complete');
