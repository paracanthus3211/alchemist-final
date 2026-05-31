<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Rank;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class RankAdminController extends Controller
{
    public function index()
    {
        $ranks = Rank::all();
        return view('admin.ranks.index', compact('ranks'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'chapter' => 'nullable|string|max:255',
            'xp_threshold' => 'required|integer|min:0',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $rank = new Rank();
        $rank->name = $request->name;
        $rank->chapter = $request->chapter;
        $rank->xp_threshold = $request->xp_threshold;

        if ($request->hasFile('icon')) {
            $file = $request->file('icon');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('images/ranks'), $filename);
            $rank->icon_url = '/images/ranks/' . $filename;
        }

        $rank->save();

        return redirect()->route('admin.ranks.index')->with('success', 'Rank created successfully.');
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'chapter' => 'nullable|string|max:255',
            'xp_threshold' => 'required|integer|min:0',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $rank = Rank::findOrFail($id);
        $rank->name = $request->name;
        $rank->chapter = $request->chapter;
        $rank->xp_threshold = $request->xp_threshold;

        if ($request->hasFile('icon')) {
            $file = $request->file('icon');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('images/ranks'), $filename);
            $rank->icon_url = '/images/ranks/' . $filename;
        }

        $rank->save();

        return redirect()->route('admin.ranks.index')->with('success', 'Rank updated successfully.');
    }

    public function destroy($id)
    {
        $rank = Rank::findOrFail($id);
        // Optional: remove file if exists
        if ($rank->icon_url && file_exists(public_path($rank->icon_url))) {
            @unlink(public_path($rank->icon_url));
        }
        $rank->delete();

        return redirect()->route('admin.ranks.index')->with('success', 'Rank deleted successfully.');
    }
}

