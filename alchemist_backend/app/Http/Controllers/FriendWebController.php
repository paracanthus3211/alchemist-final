<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class FriendWebController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();
        return view('friends.index', compact('user'));
    }

    private function attachUserData($users, $authUser)
    {
        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();

        foreach ($users as $u) {
            $userXp = (int)$u->xp;
            
            // Get Rank
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

            // Get Chapter (Based on user_level_completions)
            $activeLevel = DB::table('user_level_completions')
                ->join('levels', 'user_level_completions.level_id', '=', 'levels.id')
                ->join('chapters', 'levels.chapter_id', '=', 'chapters.id')
                ->where('user_level_completions.user_id', $u->id)
                ->select('chapters.title as chapter_title', 'levels.order_index')
                ->orderByDesc('user_level_completions.created_at')
                ->first();
            
            $u->chapter_title = $activeLevel ? $activeLevel->chapter_title : 'Chapter 1';

            // Friendship Status
            $friendship = DB::table('friends')
                ->where(function ($q) use ($authUser, $u) {
                    $q->where('user_id', $authUser->id)->where('friend_id', $u->id);
                })
                ->orWhere(function ($q) use ($authUser, $u) {
                    $q->where('user_id', $u->id)->where('friend_id', $authUser->id);
                })
                ->first();

            $u->friendship_status = $friendship ? $friendship->status : 'none';
            if ($friendship && $friendship->status === 'pending' && $friendship->friend_id == $authUser->id) {
                $u->friendship_status = 'requested_to_me';
            }
            
            if ($friendship) {
                $u->request_id = $friendship->id;
                $u->requested_at = \Carbon\Carbon::parse($friendship->created_at)->diffForHumans();
            }
        }

        return $users;
    }

    public function search(Request $request)
    {
        $query = $request->query('q');
        $user = Auth::user();

        // If no query, return empty or some recommendations
        if (!$query) {
            // For now, let's just return top XP users who aren't friends
            $users = User::with('equippedAvatar')
                ->where('id', '!=', $user->id)
                ->orderByDesc('xp')
                ->limit(10)
                ->get();
        } else {
            $users = User::with('equippedAvatar')
                ->where('username', 'LIKE', "%{$query}%")
                ->where('id', '!=', $user->id)
                ->get();
        }

        $users = $this->attachUserData($users, $user);
        return response()->json(['success' => true, 'data' => $users]);
    }

    public function getFriends(Request $request)
    {
        $user = Auth::user();

        $friendIds = DB::table('friends')
            ->where('status', 'accepted')
            ->where(function ($q) use ($user) {
                $q->where('user_id', $user->id)->orWhere('friend_id', $user->id);
            })
            ->get()
            ->map(function ($f) use ($user) {
                return $f->user_id == $user->id ? $f->friend_id : $f->user_id;
            });

        $friends = User::with('equippedAvatar')->whereIn('id', $friendIds)->get();
        $friends = $this->attachUserData($friends, $user);

        return response()->json(['success' => true, 'data' => $friends]);
    }

    public function getRequests(Request $request)
    {
        $user = Auth::user();

        // Get all pending requests sent TO the current user
        $pendingRows = DB::table('friends')
            ->where('friend_id', $user->id)
            ->where('status', 'pending')
            ->get();

        if ($pendingRows->isEmpty()) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $requesterIds = $pendingRows->pluck('user_id');
        $requesters   = User::with('equippedAvatar')->whereIn('id', $requesterIds)->get();

        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();

        $result = $requesters->map(function ($u) use ($pendingRows, $ranks) {
            $row = $pendingRows->firstWhere('user_id', $u->id);

            $userXp   = (int) $u->xp;
            $userRank = null;
            if ($u->selected_rank_id) {
                $userRank = $ranks->firstWhere('id', $u->selected_rank_id);
            }
            if (! $userRank) {
                $userRank = $ranks->firstWhere('xp_threshold', '<=', $userXp);
            }

            $activeLevel = DB::table('user_level_completions')
                ->join('levels', 'user_level_completions.level_id', '=', 'levels.id')
                ->join('chapters', 'levels.chapter_id', '=', 'chapters.id')
                ->where('user_level_completions.user_id', $u->id)
                ->select('chapters.title as chapter_title')
                ->orderByDesc('user_level_completions.created_at')
                ->first();

            return [
                'id'               => $u->id,
                'username'         => $u->username,
                'xp'               => $userXp,
                'avatar_url'       => $u->equippedAvatar
                                        ? $u->equippedAvatar->image_url
                                        : ($u->avatar_url ?: '/images/chapter.png'),
                'rank_title'       => $userRank ? $userRank->name : 'Unranked',
                'rank_icon_url'    => $userRank ? $userRank->icon_url : null,
                'chapter_title'    => $activeLevel ? $activeLevel->chapter_title : 'Chapter 1',
                'friendship_status'=> 'requested_to_me',
                'request_id'       => $row->id,
                'requested_at'     => \Carbon\Carbon::parse($row->created_at)->diffForHumans(),
            ];
        });

        return response()->json(['success' => true, 'data' => $result->values()]);
    }

    public function sendRequest(Request $request, $friendId)
    {
        $user = Auth::user();

        if ($user->id == $friendId) {
            return response()->json(['success' => false, 'message' => 'Cannot add yourself']);
        }

        $exists = DB::table('friends')
            ->where(function ($q) use ($user, $friendId) {
                $q->where('user_id', $user->id)->where('friend_id', $friendId);
            })
            ->orWhere(function ($q) use ($user, $friendId) {
                $q->where('user_id', $friendId)->where('friend_id', $user->id);
            })
            ->exists();

        if ($exists) {
            return response()->json(['success' => false, 'message' => 'Relationship already exists']);
        }

        DB::table('friends')->insert([
            'user_id' => $user->id,
            'friend_id' => $friendId,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true]);
    }

    public function acceptRequest(Request $request, $requesterId)
    {
        $user = Auth::user();

        $updated = DB::table('friends')
            ->where('user_id', $requesterId)
            ->where('friend_id', $user->id)
            ->where('status', 'pending')
            ->update([
                'status' => 'accepted',
                'updated_at' => now()
            ]);

        return response()->json(['success' => (bool)$updated]);
    }

    public function unfriend(Request $request, $friendId)
    {
        $user = Auth::user();

        $deleted = DB::table('friends')
            ->where(function ($q) use ($user, $friendId) {
                $q->where('user_id', $user->id)->where('friend_id', $friendId);
            })
            ->orWhere(function ($q) use ($user, $friendId) {
                $q->where('user_id', $friendId)->where('friend_id', $user->id);
            })
            ->delete();

        return response()->json(['success' => (bool) $deleted]);
    }

    public function ignoreRequest(Request $request, $requesterId)
    {
        $user = Auth::user();

        $deleted = DB::table('friends')
            ->where(function($q) use ($user, $requesterId) {
                $q->where('user_id', $requesterId)->where('friend_id', $user->id);
            })
            ->orWhere(function($q) use ($user, $requesterId) {
                $q->where('user_id', $user->id)->where('friend_id', $requesterId);
            })
            ->where('status', 'pending')
            ->delete();

        return response()->json(['success' => (bool)$deleted]);
    }
}

