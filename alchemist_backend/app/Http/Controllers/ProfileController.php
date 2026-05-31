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

        // --- FOLLOWING: people the user follows
        $followingCount = DB::table('follows')
            ->where('follower_id', $user->id)
            ->count();

        // --- FOLLOWERS: people who follow this user
        $followersCount = DB::table('follows')
            ->where('following_id', $user->id)
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

    public function show($id)
    {
        $authUser    = Auth::user();
        $user        = \App\Models\User::with('equippedAvatar')->findOrFail($id);

        // Redirect to own profile page
        if ($user->id === $authUser->id) {
            return redirect()->route('profile');
        }

        // Following/Followers from dedicated follows table
        $followingCount = DB::table('follows')->where('follower_id', $user->id)->count();
        $followersCount = DB::table('follows')->where('following_id', $user->id)->count();
        $friendsCount   = DB::table('friends')
            ->where('status', 'accepted')
            ->where(function ($q) use ($user) {
                $q->where('user_id', $user->id)->orWhere('friend_id', $user->id);
            })->count();

        // Is auth user following this profile?
        $isFollowing = DB::table('follows')
            ->where('follower_id', $authUser->id)
            ->where('following_id', $user->id)
            ->exists();

        $historyArticleIds = DB::table('user_article_history')
            ->where('user_id', $user->id)
            ->orderByDesc('updated_at')
            ->limit(10)
            ->pluck('article_id');
        $historyArticles = Article::whereIn('id', $historyArticleIds)->get();

        $activeLevel = DB::table('user_level_completions')
            ->join('levels', 'user_level_completions.level_id', '=', 'levels.id')
            ->join('chapters', 'levels.chapter_id', '=', 'chapters.id')
            ->where('user_level_completions.user_id', $user->id)
            ->select('levels.name as level_name', 'levels.order_index', 'chapters.title as chapter_title')
            ->orderByDesc('user_level_completions.created_at')
            ->first();

        $allRanks    = Rank::all();
        $selectedRank = $user->selected_rank_id ? Rank::find($user->selected_rank_id) : null;

        // Friendship status between auth user and this profile
        $friendship = DB::table('friends')
            ->where(function ($q) use ($authUser, $user) {
                $q->where('user_id', $authUser->id)->where('friend_id', $user->id);
            })
            ->orWhere(function ($q) use ($authUser, $user) {
                $q->where('user_id', $user->id)->where('friend_id', $authUser->id);
            })
            ->first();

        $friendshipStatus = 'none';
        if ($friendship) {
            if ($friendship->status === 'accepted') {
                $friendshipStatus = 'accepted';
            } elseif ($friendship->status === 'pending' && $friendship->user_id === $authUser->id) {
                $friendshipStatus = 'pending'; // auth user sent request
            } elseif ($friendship->status === 'pending' && $friendship->friend_id === $authUser->id) {
                $friendshipStatus = 'requested_to_me'; // they sent request to auth user
            }
        }

        $formatCount = function ($count) {
            if ($count >= 1000) {
                $formatted = number_format($count / 1000, 1);
                return rtrim(rtrim($formatted, '0'), '.') . 'k';
            }
            return $count;
        };

        return view('profile.show', [
            'user'             => $user,
            'authUser'         => $authUser,
            'followingCount'   => $formatCount($followingCount),
            'followersCount'   => $formatCount($followersCount),
            'friendsCount'     => $formatCount($friendsCount),
            'historyArticles'  => $historyArticles,
            'allRanks'         => $allRanks,
            'selectedRank'     => $selectedRank,
            'activeLevel'      => $activeLevel,
            'friendshipStatus' => $friendshipStatus,
            'isFollowing'      => $isFollowing,
        ]);
    }

    public function follow($id)
    {
        $authUser = Auth::user();
        if ($authUser->id == $id) {
            return response()->json(['success' => false, 'message' => 'Cannot follow yourself']);
        }
        DB::table('follows')->insertOrIgnore([
            'follower_id'  => $authUser->id,
            'following_id' => $id,
            'created_at'   => now(),
            'updated_at'   => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function unfollow($id)
    {
        $authUser = Auth::user();
        DB::table('follows')
            ->where('follower_id', $authUser->id)
            ->where('following_id', $id)
            ->delete();
        return response()->json(['success' => true]);
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

