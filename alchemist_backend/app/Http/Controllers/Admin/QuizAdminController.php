<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Chapter;
use App\Models\Level;
use App\Models\Question;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizAdminController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        
        $tab = $request->query('tab', 'chapter'); // 'chapter' or 'quiz'
        
        $chapters = Chapter::with('levels.questions')->orderBy('order_index')->get();
        $levelsCount = Level::count();
        $questionsCount = Question::count();
        
        // For the quiz content tab, we need all questions or we can paginate
        $questions = Question::with(['level.chapter', 'multipleChoiceOptions', 'sentenceArrangementWords', 'labPracticeConfig'])
            ->orderBy('order_index')
            ->get();
        $levels = Level::orderBy('order_index')->get();

        return view('admin.quiz.index', compact(
            'user', 
            'chapters', 
            'levelsCount', 
            'questionsCount', 
            'tab', 
            'questions',
            'levels'
        ));
    }

    // CHAPTER CRUD
    public function storeChapter(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'xp_threshold' => 'required|integer',
            'icon_emoji' => 'nullable|string',
            'order_index' => 'nullable|integer',
        ]);

        Chapter::create($validated);

        return redirect()->route('admin.quiz.index', ['tab' => 'chapter'])
            ->with('success', 'Chapter created successfully!');
    }

    public function updateChapter(Request $request, $id)
    {
        $chapter = Chapter::findOrFail($id);
        
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'xp_threshold' => 'required|integer',
            'icon_emoji' => 'nullable|string',
            'order_index' => 'nullable|integer',
        ]);

        $chapter->update($validated);

        return redirect()->route('admin.quiz.index', ['tab' => 'chapter'])
            ->with('success', 'Chapter updated successfully!');
    }

    public function destroyChapter($id)
    {
        $chapter = Chapter::findOrFail($id);
        $chapter->delete();

        return redirect()->route('admin.quiz.index', ['tab' => 'chapter'])
            ->with('success', 'Chapter deleted successfully!');
    }

    // LEVEL CRUD
    public function storeLevel(Request $request)
    {
        $validated = $request->validate([
            'chapter_id' => 'required|exists:chapters,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'xp_required' => 'required|integer',
            'icon_url' => 'nullable|string',
            'order_index' => 'nullable|integer',
            'timer_limit' => 'nullable|integer',
        ]);

        Level::create($validated);

        return redirect()->route('admin.quiz.index', ['tab' => 'chapter'])
            ->with('success', 'Level created successfully!');
    }

    public function updateLevel(Request $request, $id)
    {
        $level = Level::findOrFail($id);

        $validated = $request->validate([
            'chapter_id' => 'required|exists:chapters,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'xp_required' => 'required|integer',
            'icon_url' => 'nullable|string',
            'order_index' => 'nullable|integer',
            'timer_limit' => 'nullable|integer',
        ]);

        $level->update($validated);

        return redirect()->route('admin.quiz.index', ['tab' => 'chapter'])
            ->with('success', 'Level updated successfully!');
    }

    public function destroyLevel($id)
    {
        $level = Level::findOrFail($id);
        $level->delete();

        return redirect()->route('admin.quiz.index', ['tab' => 'chapter'])
            ->with('success', 'Level deleted successfully!');
    }

    // QUESTION CRUD
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

        DB::transaction(function () use ($validated, $request) {
            $question = Question::create($validated);

            if (($validated['type'] === 'MULTIPLE_CHOICE' || $validated['type'] === 'LAB_PRACTICE') && $request->has('options')) {
                foreach ($request->input('options') as $option) {
                    if (empty($option['option_text'])) continue;
                    DB::table('multiple_choice_options')->insert([
                        'question_id' => $question->id,
                        'option_label' => $option['option_label'] ?? 'A',
                        'option_text' => $option['option_text'],
                        'is_correct' => isset($option['is_correct']) ? (bool)$option['is_correct'] : false,
                    ]);
                }
            }

            if ($validated['type'] === 'SENTENCE_ARRANGEMENT') {
                $words = explode(',', $request->input('words', ''));
                $orderArr = explode(',', $request->input('correct_order', ''));
                
                foreach ($words as $index => $word) {
                    if (empty(trim($word))) continue;
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
                DB::table('lab_practice_config')->insert([
                    'question_id' => $question->id,
                    'beaker_a_chemical' => $request->input('beaker_a', 'H2O'),
                    'beaker_b_chemical' => $request->input('beaker_b', 'NaCl'),
                    'expected_visual_result' => $request->input('visual_result', 'Colorless Liquid'),
                    'expected_reaction_equation' => $request->input('reaction_equation', 'H2O + NaCl'),
                ]);
            }
        });

        return redirect()->route('admin.quiz.index', ['tab' => 'quiz'])
            ->with('success', 'Question created successfully!');
    }

    public function updateQuestion(Request $request, $id)
    {
        $question = Question::findOrFail($id);

        $validated = $request->validate([
            'level_id' => 'required|exists:levels,id',
            'type' => 'required|in:MULTIPLE_CHOICE,SENTENCE_ARRANGEMENT,LAB_PRACTICE',
            'question_text' => 'required|string',
            'xp_reward' => 'required|integer',
            'explanation' => 'nullable|string',
            'order_index' => 'nullable|integer',
        ]);

        DB::transaction(function () use ($validated, $request, $question) {
            $question->update($validated);
            $type = $validated['type'];

            if ($type === 'MULTIPLE_CHOICE' || $type === 'LAB_PRACTICE') {
                DB::table('multiple_choice_options')->where('question_id', $question->id)->delete();
                if ($request->has('options')) {
                    foreach ($request->input('options') as $option) {
                        if (empty($option['option_text'])) continue;
                        DB::table('multiple_choice_options')->insert([
                            'question_id' => $question->id,
                            'option_label' => $option['option_label'] ?? 'A',
                            'option_text' => $option['option_text'],
                            'is_correct' => isset($option['is_correct']) ? (bool)$option['is_correct'] : false,
                        ]);
                    }
                }
            }

            if ($type === 'SENTENCE_ARRANGEMENT') {
                DB::table('sentence_arrangement_words')->where('question_id', $question->id)->delete();
                $words = explode(',', $request->input('words', ''));
                $orderArr = explode(',', $request->input('correct_order', ''));

                foreach ($words as $index => $word) {
                    if (empty(trim($word))) continue;
                    $correctOrderIndex = array_search((string)$index, array_map('trim', $orderArr));
                    if ($correctOrderIndex === false) $correctOrderIndex = $index;

                    DB::table('sentence_arrangement_words')->insert([
                        'question_id' => $question->id,
                        'word_text' => trim($word),
                        'correct_order_index' => $correctOrderIndex,
                    ]);
                }
            }

            if ($type === 'LAB_PRACTICE') {
                DB::table('lab_practice_config')->updateOrInsert(
                    ['question_id' => $question->id],
                    [
                        'beaker_a_chemical' => $request->input('beaker_a', 'H2O'),
                        'beaker_b_chemical' => $request->input('beaker_b', 'NaCl'),
                        'expected_visual_result' => $request->input('visual_result', 'Colorless Liquid'),
                        'expected_reaction_equation' => $request->input('reaction_equation', 'H2O + NaCl'),
                    ]
                );
            }
        });

        return redirect()->route('admin.quiz.index', ['tab' => 'quiz'])
            ->with('success', 'Question updated successfully!');
    }

    public function destroyQuestion($id)
    {
        $question = Question::findOrFail($id);
        $question->delete();

        return redirect()->route('admin.quiz.index', ['tab' => 'quiz'])
            ->with('success', 'Question deleted successfully!');
    }
}
