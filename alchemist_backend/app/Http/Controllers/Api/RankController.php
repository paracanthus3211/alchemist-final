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

    public function leaderboard(Request $request)
    {
        $period = $request->query('period', 'all');
        $scope = $request->query('scope', 'global');
        $user = $request->user();

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
            $query->whereIn('id', $friendIds);
        }

        if ($period === 'week' || $period === 'month' || $period === 'last_week' || $period === 'last_month') {
            $days = ($period === 'week' || $period === 'last_week') ? 7 : 30;
            $startDate = now()->subDays($days);
            
            $query->leftJoin('xp_transactions', function ($join) use ($startDate) {
                $join->on('users.id', '=', 'xp_transactions.user_id')
                     ->where('xp_transactions.created_at', '>=', $startDate);
            })
            ->selectRaw('users.id, users.username, users.avatar_url, users.equipped_avatar_id, users.selected_rank_id, users.role, users.profile_bg_color, COALESCE(SUM(xp_transactions.xp_amount), 0) as xp')
            ->groupBy('users.id', 'users.username', 'users.avatar_url', 'users.equipped_avatar_id', 'users.selected_rank_id', 'users.role', 'users.profile_bg_color')
            ->orderByDesc('xp');
        } else {
            $query->select('id', 'username', 'xp', 'avatar_url', 'equipped_avatar_id', 'selected_rank_id', 'role', 'profile_bg_color')
                  ->orderByDesc('xp');
        }

        $users = $query->with('equippedAvatar')->take(20)->get();

        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();
        
        $users = $users->map(function ($u) use ($ranks) {
            $userXp = (int)$u->xp;
            
            $userRank = null;
            if ($u->selected_rank_id) {
                $userRank = $ranks->firstWhere('id', $u->selected_rank_id);
            }
            if (!$userRank) {
                $userRank = $ranks->firstWhere('xp_threshold', '<=', $userXp);
            }

            $u->rank_title = $userRank ? $userRank->name : 'Unranked';
            $u->rank_icon_url = $userRank ? $userRank->icon_url : null;
            $u->avatar_url = $u->equippedAvatar ? $u->equippedAvatar->image_url : ($u->avatar_url ?: '/images/chapter.png');
            
            return $u;
        });

        return response()->json([
            'success' => true,
            'data' => $users
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'chapter' => 'nullable|string|max:255',
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
            'chapter' => 'sometimes|string|max:255',
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



