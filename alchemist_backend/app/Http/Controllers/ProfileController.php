<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Article;
use App\Models\Rank;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        // --- FOLLOWING: people the user has sent a friend request to (user_id = user)
        $followingCount = DB::table('friends')
            ->where('user_id', $user->id)
            ->count();

        // --- FOLLOWERS: people who have sent a request to this user (friend_id = user)
        $followersCount = DB::table('friends')
            ->where('friend_id', $user->id)
            ->count();

        // --- FRIENDS: mutual accepted connections
        $friendsCount = DB::table('friends')
            ->where('status', 'accepted')
            ->where(function ($q) use ($user) {
                $q->where('user_id', $user->id)
                  ->orWhere('friend_id', $user->id);
            })->count();

        // --- READING HISTORY: real articles from user_article_history
        $historyArticleIds = DB::table('user_article_history')
            ->where('user_id', $user->id)
            ->orderByDesc('updated_at')
            ->limit(10)
            ->pluck('article_id');

        $historyArticles = Article::whereIn('id', $historyArticleIds)->get();

        // --- ACTIVE LEVEL INFO from user_level_completions + levels + chapters
        $activeLevel = DB::table('user_level_completions')
            ->join('levels', 'user_level_completions.level_id', '=', 'levels.id')
            ->join('chapters', 'levels.chapter_id', '=', 'chapters.id')
            ->where('user_level_completions.user_id', $user->id)
            ->select('levels.name as level_name', 'levels.order_index', 'chapters.title as chapter_title')
            ->orderByDesc('user_level_completions.created_at')
            ->first();

        // --- ALL RANKS for achievement display
        $allRanks = Rank::all();

        // --- SELECTED RANK
        $selectedRank = $user->selected_rank_id
            ? Rank::find($user->selected_rank_id)
            : null;

        $formatCount = function($count) {
            if ($count >= 1000) {
                $formatted = number_format($count / 1000, 1);
                return rtrim(rtrim($formatted, '0'), '.') . 'k';
            }
            return $count;
        };

        return view('profile', [
            'user' => $user,
            'followingCount' => $formatCount($followingCount),
            'followersCount' => $formatCount($followersCount),
            'friendsCount' => $formatCount($friendsCount),
            'historyArticles' => $historyArticles,
            'allRanks' => $allRanks,
            'selectedRank' => $selectedRank,
            'activeLevel' => $activeLevel
        ]);
    }

    public function avatar()
    {
        $user = Auth::user();
        
        // For simplicity, we are returning all avatars here. 
        // A more advanced logic would check user_avatars table for unlocked ones.
        $avatars = \App\Models\Avatar::all();
        
        return view('profile.avatar', compact('user', 'avatars'));
    }

    public function saveAvatar(Request $request)
    {
        $request->validate([
            'avatar_id' => 'required|exists:avatars,id',
            'bg_color' => 'required|string',
        ]);

        $user = Auth::user();
        $user->equipped_avatar_id = $request->avatar_id;
        $user->profile_bg_color = $request->bg_color;
        $user->save();

        return redirect()->route('profile')->with('success', 'Avatar updated successfully.');
    }
}
