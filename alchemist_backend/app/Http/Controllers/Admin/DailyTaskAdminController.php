<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DailyTask;
use Illuminate\Http\Request;

class DailyTaskAdminController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        
        $templatesCount = DailyTask::count();
        $activeCount = DailyTask::where('is_active', true)->count();
        $inactiveCount = DailyTask::where('is_active', false)->count();
        
        $tasks = DailyTask::orderBy('created_at', 'desc')->get();
        
        return view('admin.daily_tasks.index', compact(
            'user',
            'tasks',
            'templatesCount',
            'activeCount',
            'inactiveCount'
        ));
    }

    public function create()
    {
        $user = auth()->user();
        return view('admin.daily_tasks.form', compact('user'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'task_name' => 'required|string|max:255',
            'task_type' => 'required|string|max:255',
            'description' => 'nullable|string',
            'target_value' => 'required|integer|min:1',
            'xp_reward' => 'required|integer|min:0',
        ]);

        $validated['is_active'] = $request->has('is_active') ? true : false;
        
        DailyTask::create($validated);

        return redirect()->route('admin.daily-tasks.index')
            ->with('success', 'Daily task template created successfully!');
    }

    public function edit($id)
    {
        $user = auth()->user();
        $task = DailyTask::findOrFail($id);
        return view('admin.daily_tasks.form', compact('user', 'task'));
    }

    public function update(Request $request, $id)
    {
        $task = DailyTask::findOrFail($id);
        
        $validated = $request->validate([
            'task_name' => 'required|string|max:255',
            'task_type' => 'required|string|max:255',
            'description' => 'nullable|string',
            'target_value' => 'required|integer|min:1',
            'xp_reward' => 'required|integer|min:0',
        ]);

        $validated['is_active'] = $request->has('is_active') ? true : false;

        $task->update($validated);

        return redirect()->route('admin.daily-tasks.index')
            ->with('success', 'Daily task template updated successfully!');
    }

    public function destroy($id)
    {
        $task = DailyTask::findOrFail($id);
        $task->delete();

        return redirect()->route('admin.daily-tasks.index')
            ->with('success', 'Daily task template deleted successfully!');
    }
}
