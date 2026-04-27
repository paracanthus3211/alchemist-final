<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Rank;
use Illuminate\Http\Request;

class RankController extends Controller
{
    public function index()
    {
        $ranks = Rank::orderBy('xp_threshold', 'asc')->get();
        return response()->json([
            'success' => true,
            'data' => $ranks
        ]);
    }

    public function leaderboard()
    {
        $users = \App\Models\User::orderBy('xp', 'desc')
            ->take(20)
            ->get(['id', 'username', 'xp', 'avatar_url', 'role']);
            
        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'xp_threshold' => 'required|integer',
            'icon_url' => 'nullable|string'
        ]);

        $rank = Rank::create($validated);

        return response()->json(['success' => true, 'data' => $rank], 201);
    }

    public function update(Request $request, Rank $rank)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'xp_threshold' => 'sometimes|integer',
            'icon_url' => 'nullable|string'
        ]);

        $rank->update($validated);

        return response()->json(['success' => true, 'data' => $rank]);
    }

    public function destroy(Rank $rank)
    {
        $rank->delete();
        return response()->json(['success' => true]);
    }
}
