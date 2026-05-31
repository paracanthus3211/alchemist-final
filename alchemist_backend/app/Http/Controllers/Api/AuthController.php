<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Traits\UpdatesDailyTasks;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    use UpdatesDailyTasks;

    public function login(Request $request)
    {
        \Log::info('Login attempt', $request->all());

        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Kredensial yang Anda masukkan salah.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;
        $user->checkStreakReset();

        // Trigger Daily Login Task
        $this->_incrementDailyTaskProgress($user, 'DAILY_LOGIN');

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => [
                'id'           => $user->id,
                'username'     => $user->username,
                'email'        => $user->email,
                'role'         => $user->role,
                'xp'           => $user->xp,
                'streak_count' => $user->streak_count,
                'max_streak'   => $user->max_streak,
                'gender'       => $user->gender,
                'avatar_url'   => $user->equippedAvatar ? $user->equippedAvatar->image_url : ($user->avatar_url ?: '/images/chapter.png'),
                'created_at'   => $user->created_at ? $user->created_at->toIso8601String() : null,
                'selected_rank_id' => $user->selected_rank_id,
                'profile_bg_color' => $user->profile_bg_color,
                'avatar_url'   => $user->equippedAvatar ? $user->equippedAvatar->image_url : ($user->avatar_url ?: '/images/chapter.png'),
                'quiz_level'   => $this->_getQuizLevel($user),
            ],
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user()->load('equippedAvatar');
        $user->checkStreakReset();

        // Auto-reset selected_rank_id if user no longer has enough XP for it
        if ($user->selected_rank_id) {
            $selectedRank = \App\Models\Rank::find($user->selected_rank_id);
            if ($selectedRank && $user->xp < $selectedRank->xp_threshold) {
                $user->selected_rank_id = null;
                $user->save();
            }
        }

        $progress = $this->getQuizProgressData($user);
        return response()->json([
            'id'           => $user->id,
            'username'     => $user->username,
            'email'        => $user->email,
            'role'         => $user->role,
            'xp'           => $user->xp,
            'streak_count' => $user->streak_count,
            'max_streak'   => $user->max_streak,
            'last_study_at'=> $user->last_study_at ? $user->last_study_at->toIso8601String() : null,
            'equipped_avatar_id' => $user->equipped_avatar_id,
            'avatar_url'   => $user->equippedAvatar ? $user->equippedAvatar->image_url : ($user->avatar_url ?: '/images/chapter.png'),
            'gender'       => $user->gender,
            'created_at'   => $user->created_at ? $user->created_at->toIso8601String() : null,
            'selected_rank_id' => $user->selected_rank_id,
            'profile_bg_color' => $user->profile_bg_color,
            'quiz_level'   => $progress['level'],
            'current_level_name' => $progress['level_name'],
            'current_chapter_title' => $progress['chapter_title'],
            'current_level_progress' => $progress['level_progress'],
            'current_level_xp' => $progress['current_level_xp'],
            'total_level_xp' => $progress['total_level_xp'],
        ]);
    }

    public function getQuizProgressData($user)
    {
        // Eager load everything needed
        $chapters = \App\Models\Chapter::with(['levels.questions'])->orderBy('order_index')->get();
        
        // Get all correct question IDs for this user once to avoid N+1 queries
        $completedQuestionIds = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
            ->where('is_correct', true)
            ->pluck('question_id')
            ->toArray();

        $activeChapter = null;
        $activeLevel = null;
        $globalLevelIndex = 0;
        $foundActive = false;
        $currentLevelNumber = 1;

        foreach ($chapters as $chapter) {
            foreach ($chapter->levels as $level) {
                $globalLevelIndex++;
                
                $levelQuestionIds = $level->questions->pluck('id')->toArray();
                $totalQuestions = count($levelQuestionIds);
                
                if ($totalQuestions === 0) {
                    continue; // Skip levels with no questions
                }

                $userCompletedInLevel = array_intersect($levelQuestionIds, $completedQuestionIds);
                $completedCount = count($userCompletedInLevel);

                if ($completedCount < $totalQuestions) {
                    if (!$foundActive) {
                        $activeLevel = $level;
                        $activeChapter = $chapter;
                        $currentLevelNumber = $globalLevelIndex;
                        $foundActive = true;
                    }
                }
            }
        }

        // If all levels are completed, show the last level as active at 100%
        if (!$foundActive && $chapters->isNotEmpty()) {
            $activeChapter = $chapters->last();
            $activeLevel = $activeChapter->levels->last();
            $currentLevelNumber = $globalLevelIndex;
        }

        $currentLevelXp = 0;
        $totalLevelXp = 0;
        
        if ($activeLevel) {
            $totalLevelXp = $activeLevel->questions->sum('xp_reward');
            
            $currentLevelXp = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                ->whereIn('question_id', $activeLevel->questions->pluck('id'))
                ->where('is_correct', true)
                ->sum('xp_earned');
            
            $progress = $totalLevelXp > 0 ? round(($currentLevelXp / $totalLevelXp) * 100) : 0;
        }

        return [
            'level' => $currentLevelNumber,
            'level_name' => $activeLevel ? $activeLevel->name : 'Novice',
            'chapter_title' => $activeChapter ? $activeChapter->title : 'Prologue',
            'level_progress' => $progress,
            'current_level_xp' => $currentLevelXp,
            'total_level_xp' => $totalLevelXp
        ];
    }

    private function _getQuizLevel($user)
    {
        // Calculate level based on completed quiz levels
        $completedLevelIds = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
            ->where('is_correct', true)
            ->join('questions', 'user_question_attempts.question_id', '=', 'questions.id')
            ->select('questions.level_id')
            ->distinct()
            ->pluck('level_id');
        
        // Count levels where all questions are completed
        $count = 0;
        foreach ($completedLevelIds as $levelId) {
            $totalQuestions = \App\Models\Question::where('level_id', $levelId)->count();
            $completedQuestions = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                ->whereIn('question_id', \App\Models\Question::where('level_id', $levelId)->pluck('id'))
                ->where('is_correct', true)
                ->count();
            if ($totalQuestions > 0 && $completedQuestions >= $totalQuestions) {
                $count++;
            }
        }

        return $count + 1;
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logout berhasil',
        ]);
    }

    public function addXp(Request $request)
    {
        $request->validate([
            'question_ids' => 'required|array',
            'question_ids.*' => 'integer|exists:questions,id'
        ]);

        $user = $request->user();
        $totalXpAdded = 0;
        $processedLevels = [];
        $userPlayedQuiz = false; // Track if user played any quiz

        foreach ($request->question_ids as $questionId) {
            $question = \App\Models\Question::find($questionId);
            if (!$question) continue;

            $levelId = $question->level_id;
            $userPlayedQuiz = true; // User played a quiz

            // Check if already answered correctly
            $existing = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                ->where('question_id', $questionId)
                ->where('is_correct', true)
                ->first();

            if (!$existing) {
                $xp = $question->xp_reward ?? 10;
                
                \App\Models\UserQuestionAttempt::create([
                    'user_id' => $user->id,
                    'question_id' => $questionId,
                    'is_correct' => true,
                    'xp_earned' => $xp
                ]);

                \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
                    'user_id' => $user->id,
                    'source_type' => 'question',
                    'source_id' => $questionId,
                    'xp_amount' => $xp,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                $user->xp += $xp;
                $totalXpAdded += $xp;

                // Update GAIN_XP Daily Task
                $this->_incrementDailyTaskProgress($user, 'GAIN_XP', $xp);
            }

            // ─────────────────────────────────────────────────────────
            // Check if this level is completed (Always check if level just became complete)
            // ─────────────────────────────────────────────────────────
            if (!in_array($levelId, $processedLevels)) {
                $totalQuestionsInLevel = \App\Models\Question::where('level_id', $levelId)->count();
                $completedQuestionsInLevel = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                    ->whereIn('question_id', \App\Models\Question::where('level_id', $levelId)->pluck('id'))
                    ->where('is_correct', true)
                    ->count();

                if ($totalQuestionsInLevel > 0 && $completedQuestionsInLevel >= $totalQuestionsInLevel) {
                    // Check if we already counted THIS level for FINISH_LESSONS today
                    // (We use a cache or a temporary marker to avoid double counting same level completion in one session)
                    $this->_incrementDailyTaskProgress($user, 'FINISH_LESSONS', 1, $levelId);
                    $processedLevels[] = $levelId;
                }
            }
        }

        $user->save();

        // Update Streak Logic - Update streak if user played any quiz
        $streakReward = null;
        if ($userPlayedQuiz) {
            $user->refresh(); // Refresh to get latest data from DB
            $streakReward = $user->updateStreak();
        }

        $progress = $this->getQuizProgressData($user);

        return response()->json([
            'status' => 'success',
            'message' => 'XP added successfully',
            'total_xp' => $user->xp,
            'xp_added' => $totalXpAdded,
            'streak' => $user->streak_count,
            'streak_reward' => $streakReward,
            'quiz_level' => $progress['level'],
            'current_level_name' => $progress['level_name'],
            'current_chapter_title' => $progress['chapter_title'],
            'current_level_progress' => $progress['level_progress'],
            'current_level_xp' => $progress['current_level_xp'],
            'total_level_xp' => $progress['total_level_xp'],
        ]);
    }

    public function selectRank(Request $request)
    {
        $request->validate([
            'rank_id' => 'nullable|exists:ranks,id'
        ]);

        $user = $request->user();

        // Validate that the user has enough XP to select this rank
        if ($request->rank_id) {
            $rank = \App\Models\Rank::find($request->rank_id);
            if ($rank && $user->xp < $rank->xp_threshold) {
                return response()->json([
                    'message' => 'XP tidak cukup untuk memilih rank ini. Butuh ' . $rank->xp_threshold . ' XP, kamu punya ' . $user->xp . ' XP.',
                    'required_xp' => $rank->xp_threshold,
                    'current_xp' => $user->xp,
                ], 403);
            }
        }

        $user->selected_rank_id = $request->rank_id;
        $user->save();

        return response()->json(['message' => 'Rank selected successfully', 'data' => $user]);
    }

    public function updateProfileBg(Request $request)
    {
        $request->validate([
            'color' => 'nullable|string|max:20'
        ]);

        $user = $request->user();
        $user->profile_bg_color = $request->color;
        $user->save();

        return response()->json(['message' => 'Profile background updated successfully', 'data' => $user]);
    }

    public function addLabXp(Request $request)
    {
        $request->validate([
            'xp' => 'required|integer|min:0'
        ]);

        $user = $request->user();
        $xp = $request->xp;

        $user->xp += $xp;
        $user->save();

        // Log XP transaction
        \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
            'user_id' => $user->id,
            'source_type' => 'virtual_lab',
            'xp_amount' => $xp,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Update Daily Task
        $this->_incrementDailyTaskProgress($user, 'GAIN_XP', $xp);
        $this->_incrementDailyTaskProgress($user, 'LAB_EXPERIMENT', 1);

        // Update Streak Logic
        $streakReward = $user->updateStreak();

        return response()->json([
            'status' => 'success',
            'total_xp' => $user->xp,
            'xp_added' => $xp,
            'streak' => $user->streak_count,
            'streak_reward' => $streakReward
        ]);
    }

    /**
     * Record a correct Virtual Lab reaction and award XP ONLY once per reaction key.
     *
     * Request:
     * - reaction_key: string (canonical form, e.g. "hcl+naoh" sorted)
     *
     * Response:
     * - xp_added: 25 or 0
     * - already_completed: bool
     * - total_xp: int
     */
    public function recordLabReaction(Request $request)
    {
        $request->validate([
            'reaction_key' => 'required|string|max:100',
        ]);

        $user = $request->user();
        $reactionKey = strtolower(trim($request->reaction_key));

        // Prevent duplicates (DB unique constraint + explicit check for nicer response)
        $exists = DB::table('user_lab_reactions')
            ->where('user_id', $user->id)
            ->where('reaction_key', $reactionKey)
            ->exists();

        if ($exists) {
            return response()->json([
                'status' => 'success',
                'already_completed' => true,
                'xp_added' => 0,
                'total_xp' => $user->xp,
                'streak' => $user->streak_count,
            ]);
        }

        $xp = 25;

        DB::transaction(function () use ($user, $reactionKey, $xp) {
            DB::table('user_lab_reactions')->insert([
                'user_id' => $user->id,
                'reaction_key' => $reactionKey,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $user->xp += $xp;
            $user->save();

            DB::table('xp_transactions')->insert([
                'user_id' => $user->id,
                'source_type' => 'virtual_lab_reaction',
                'xp_amount' => $xp,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Daily tasks
            $this->_incrementDailyTaskProgress($user, 'GAIN_XP', $xp);
            $this->_incrementDailyTaskProgress($user, 'LAB_EXPERIMENT', 1);
        });

        // Update streak logic (outside transaction is OK)
        $user->refresh();
        $streakReward = $user->updateStreak();

        return response()->json([
            'status' => 'success',
            'already_completed' => false,
            'xp_added' => $xp,
            'total_xp' => $user->xp,
            'streak' => $user->streak_count,
            'streak_reward' => $streakReward,
        ]);
    }

    /**
     * Register user with first name, last name, username, and password (no email)
     */
    public function register(Request $request)
    {
        $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username',
            'password' => 'required|string|min:6',
            'password_confirmation' => 'required|string|same:password',
        ]);

        // Create user account
        $user = User::create([
            'first_name' => $request->first_name,
            'last_name' => $request->last_name,
            'username' => $request->username,
            'email' => $request->username . '@alchemist.local', // Generate email from username
            'password' => Hash::make($request->password),
            'role' => 'user',
            'xp' => 0,
            'streak_count' => 0,
            'max_streak' => 0,
        ]);

        // Generate auth token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Registrasi berhasil',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'username' => $user->username,
                'email' => $user->email,
                'role' => $user->role,
                'xp' => $user->xp,
                'streak_count' => $user->streak_count,
                'max_streak' => $user->max_streak,
                'gender' => $user->gender,
                'avatar_url' => $user->avatar_url ?: '/images/chapter.png',
                'created_at' => $user->created_at ? $user->created_at->toIso8601String() : null,
                'selected_rank_id' => $user->selected_rank_id,
                'profile_bg_color' => $user->profile_bg_color,
                'quiz_level' => 1,
            ],
        ]);
    }
}
