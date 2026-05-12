<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Chapter;
use App\Models\Level;
use App\Models\Question;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Traits\UpdatesDailyTasks;

class CurriculumController extends Controller
{
    use UpdatesDailyTasks;
    public function index(Request $request)
    {
        $user = $request->user('sanctum');
        
        $chapters = Chapter::with(['levels.questions' => function($query) {
            $query->with(['multipleChoiceOptions', 'sentenceArrangementWords', 'labPracticeConfig'])
                  ->orderBy('order_index');
        }])->orderBy('order_index')->get();

        $userXp = $user ? $user->xp : 0;

        $formattedChapters = $chapters->map(function($chapter) use ($user, $userXp) {
            $levels = $chapter->levels;
            $completedLevelsCount = 0;
            
            $isChapterLocked = $userXp < ($chapter->xp_threshold ?? 0);

            $formattedLevels = $levels->map(function($level) use ($user, $userXp, &$completedLevelsCount) {
                $totalLevelXp = $level->questions->sum('xp_reward');
                $userLevelXp = 0;
                
                if ($user) {
                    $userLevelXp = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                        ->whereIn('question_id', $level->questions->pluck('id'))
                        ->where('is_correct', true)
                        ->sum('xp_earned');
                }

                $progress = $totalLevelXp > 0 ? min(100, round(($userLevelXp / $totalLevelXp) * 100)) : 0;
                
                if ($progress >= 100) {
                    $completedLevelsCount++;
                }

                $isLevelLocked = $userXp < ($level->xp_required ?? 0);

                return array_merge($level->toArray(), [
                    'user_xp' => $userLevelXp,
                    'total_xp' => $totalLevelXp,
                    'progress' => $progress,
                    'is_locked' => $isLevelLocked
                ]);
            });

            $chapterProgress = $levels->count() > 0 ? round(($completedLevelsCount / $levels->count()) * 100) : 0;

            return array_merge($chapter->toArray(), [
                'levels' => $formattedLevels,
                'chapter_progress' => $chapterProgress,
                'completed_levels_count' => $completedLevelsCount,
                'total_levels_count' => $levels->count(),
                'is_locked' => $isChapterLocked
            ]);
        });

        return response()->json([
            'success' => true,
            'data' => $formattedChapters
        ]);
    }

    public function storeChapter(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'xp_threshold' => 'required|integer',
            'icon_emoji' => 'nullable|string',
            'order_index' => 'nullable|integer',
        ]);

        $chapter = Chapter::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Chapter created successfully',
            'data' => $chapter
        ], 201);
    }

    public function storeLevel(Request $request)
    {
        $validated = $request->validate([
            'chapter_id' => 'required|exists:chapters,id',
            'name' => 'required|string',
            'description' => 'nullable|string',
            'xp_required' => 'required|integer',
            'icon_url' => 'nullable|string',
            'order_index' => 'nullable|integer',
            'timer_limit' => 'nullable|integer',
        ]);

        $level = Level::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Level created successfully',
            'data' => $level
        ], 201);
    }

    public function storeQuestion(Request $request)
    {
        $validated = $request->validate([
            'level_id' => 'required|exists:levels,id',
            'type' => 'required|in:MULTIPLE_CHOICE,SENTENCE_ARRANGEMENT,LAB_PRACTICE',
            'question_text' => 'required|string',
            'xp_reward' => 'required|integer',
            'explanation' => 'nullable|string',
            'order_index' => 'nullable|integer',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $question = Question::create($validated);

            if (($validated['type'] === 'MULTIPLE_CHOICE' || $validated['type'] === 'LAB_PRACTICE') && $request->has('options')) {
                $options = $request->validate([
                    'options' => 'required|array|min:2',
                    'options.*.option_label' => 'required|string',
                    'options.*.option_text' => 'required|string',
                    'options.*.is_correct' => 'required|boolean',
                ]);

                foreach ($options['options'] as $option) {
                    DB::table('multiple_choice_options')->insert([
                        'question_id' => $question->id,
                        'option_label' => $option['option_label'],
                        'option_text' => $option['option_text'],
                        'is_correct' => $option['is_correct'],
                    ]);
                }
            }

            if ($validated['type'] === 'SENTENCE_ARRANGEMENT') {
                $config = $request->validate([
                    'words' => 'required|string', // comma separated
                    'correct_order' => 'required|string', // comma separated indices
                ]);

                $words = explode(',', $config['words']);
                $orderArr = explode(',', $config['correct_order']);
                
                foreach ($words as $index => $word) {
                    $correctOrderIndex = array_search((string)$index, array_map('trim', $orderArr));
                    if ($correctOrderIndex === false) $correctOrderIndex = $index;

                    DB::table('sentence_arrangement_words')->insert([
                        'question_id' => $question->id,
                        'word_text' => trim($word),
                        'correct_order_index' => $correctOrderIndex,
                    ]);
                }
            }

            if ($validated['type'] === 'LAB_PRACTICE') {
                $config = $request->validate([
                    'beaker_a' => 'required|string',
                    'beaker_b' => 'required|string',
                    'visual_result' => 'required|string',
                    'reaction_equation' => 'required|string',
                ]);

                DB::table('lab_practice_config')->insert([
                    'question_id' => $question->id,
                    'beaker_a_chemical' => $config['beaker_a'],
                    'beaker_b_chemical' => $config['beaker_b'],
                    'expected_visual_result' => $config['visual_result'],
                    'expected_reaction_equation' => $config['reaction_equation'],
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Question created successfully',
                'data' => $question
            ], 201);
        });
    }

    public function updateChapter(Request $request, Chapter $chapter)
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'xp_threshold' => 'required|integer',
            'icon_emoji' => 'nullable|string',
            'order_index' => 'nullable|integer',
        ]);
        $chapter->update($validated);
        return response()->json(['success' => true, 'message' => 'Chapter updated successfully', 'data' => $chapter]);
    }

    public function updateQuestion(Request $request, Question $question)
    {
        $validated = $request->validate([
            'question_text' => 'required|string',
            'xp_reward' => 'required|integer',
            'explanation' => 'nullable|string',
            'order_index' => 'nullable|integer',
            'type' => 'nullable|in:MULTIPLE_CHOICE,SENTENCE_ARRANGEMENT,LAB_PRACTICE',
        ]);

        return DB::transaction(function () use ($validated, $request, $question) {
            $question->update($validated);

            $type = $validated['type'] ?? $question->type;

            if (($type === 'MULTIPLE_CHOICE' || $type === 'LAB_PRACTICE') && $request->has('options')) {
                $options = $request->validate([
                    'options' => 'required|array|min:2',
                    'options.*.option_label' => 'required|string',
                    'options.*.option_text' => 'required|string',
                    'options.*.is_correct' => 'required|boolean',
                ]);

                DB::table('multiple_choice_options')->where('question_id', $question->id)->delete();
                foreach ($options['options'] as $option) {
                    DB::table('multiple_choice_options')->insert([
                        'question_id' => $question->id,
                        'option_label' => $option['option_label'],
                        'option_text' => $option['option_text'],
                        'is_correct' => $option['is_correct'],
                    ]);
                }
            }

            if ($type === 'SENTENCE_ARRANGEMENT' && $request->has('words')) {
                $config = $request->validate([
                    'words' => 'required|string',
                    'correct_order' => 'required|string',
                ]);

                DB::table('sentence_arrangement_words')->where('question_id', $question->id)->delete();
                $words = explode(',', $config['words']);
                $orderArr = explode(',', $config['correct_order']);

                foreach ($words as $index => $word) {
                    $correctOrderIndex = array_search((string)$index, array_map('trim', $orderArr));
                    if ($correctOrderIndex === false) $correctOrderIndex = $index;

                    DB::table('sentence_arrangement_words')->insert([
                        'question_id' => $question->id,
                        'word_text' => trim($word),
                        'correct_order_index' => $correctOrderIndex,
                    ]);
                }
            }

            if ($type === 'LAB_PRACTICE' && $request->has('beaker_a')) {
                $config = $request->validate([
                    'beaker_a' => 'required|string',
                    'beaker_b' => 'required|string',
                    'visual_result' => 'required|string',
                    'reaction_equation' => 'required|string',
                ]);

                DB::table('lab_practice_config')->updateOrInsert(
                    ['question_id' => $question->id],
                    [
                        'beaker_a_chemical' => $config['beaker_a'],
                        'beaker_b_chemical' => $config['beaker_b'],
                        'expected_visual_result' => $config['visual_result'],
                        'expected_reaction_equation' => $config['reaction_equation'],
                    ]
                );
            }

            return response()->json([
                'success' => true,
                'message' => 'Question updated successfully',
                'data' => $question->load(['multipleChoiceOptions', 'sentenceArrangementWords', 'labPracticeConfig'])
            ]);
        });
    }

    public function destroyChapter(Chapter $chapter)
    {
        $chapter->delete();
        return response()->json(['success' => true, 'message' => 'Chapter deleted successfully']);
    }

    public function destroyLevel(Level $level)
    {
        $level->delete();
        return response()->json(['success' => true, 'message' => 'Level deleted successfully']);
    }

    public function updateLevel(Request $request, Level $level)
    {
        $validated = $request->validate([
            'chapter_id' => 'required|exists:chapters,id',
            'name' => 'required|string',
            'description' => 'nullable|string',
            'xp_required' => 'required|integer',
            'icon_url' => 'nullable|string',
            'order_index' => 'nullable|integer',
            'timer_limit' => 'nullable|integer',
        ]);
        $level->update($validated);
        return response()->json(['success' => true, 'message' => 'Level updated successfully', 'data' => $level]);
    }

    public function destroyQuestion(Question $question)
    {
        $question->delete();
        return response()->json(['success' => true, 'message' => 'Question deleted successfully']);
    }

    public function saveLevelCompletion(Request $request, $levelId)
    {
        $request->validate([
            'score' => 'required|integer|min:0|max:100',
            'completion_time_seconds' => 'required|integer|min:0',
            'wrong_answers_count' => 'required|integer|min:0',
        ]);

        $user = $request->user();
        
        $completion = \App\Models\UserLevelCompletion::updateOrCreate(
            ['user_id' => $user->id, 'level_id' => $levelId],
            [
                'score' => $request->score,
                'completion_time_seconds' => $request->completion_time_seconds,
                'wrong_answers_count' => $request->wrong_answers_count,
            ]
        );

        // Update Daily Task Progress for SCORE
        $this->_incrementDailyTaskProgress($user, 'SCORE', $request->score);
        
        // Update Daily Task Progress for FINISH_LESSONS
        $this->_incrementDailyTaskProgress($user, 'FINISH_LESSONS', 1, $levelId);
        
        // Note: XP is usually awarded via AuthController@addXp in the app, 
        // but we can also trigger GAIN_XP here if we know the amount.
        // For now, FINISH_LESSONS is the main one for "checking off" quiz tasks.

        return response()->json([
            'success' => true,
            'message' => 'Level completion stats saved',
            'data' => $completion
        ]);
    }
}
