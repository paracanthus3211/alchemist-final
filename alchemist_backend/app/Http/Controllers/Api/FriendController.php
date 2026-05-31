<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\AuthController;

class FriendController extends Controller
{
    public function search(Request $request)
    {
        $query = $request->query('q');
        $user = $request->user();

        if (!$query) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $users = User::with('equippedAvatar')->where('username', 'LIKE', "%{$query}%")
            ->where('id', '!=', $user->id)
            ->get(['id', 'username', 'avatar_url', 'xp', 'equipped_avatar_id', 'selected_rank_id']);

        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();

        // Attach relationship status and details
        foreach ($users as $u) {
            $userXp = (int)$u->xp;
            $u->level = floor($userXp / 200) + 1;
            
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

            $friendship = DB::table('friends')
                ->where(function ($q) use ($user, $u) {
                    $q->where('user_id', $user->id)->where('friend_id', $u->id);
                })
                ->orWhere(function ($q) use ($user, $u) {
                    $q->where('user_id', $u->id)->where('friend_id', $user->id);
                })
                ->first();

            $u->friendship_status = $friendship ? $friendship->status : 'none';
            if ($friendship && $friendship->status === 'pending' && $friendship->friend_id == $user->id) {
                $u->friendship_status = 'requested_to_me';
            }
        }

        return response()->json(['success' => true, 'data' => $users]);
    }

    public function sendRequest(Request $request, $friendId)
    {
        $user = $request->user();

        if ($user->id == $friendId) {
            return response()->json(['success' => false, 'message' => 'Cannot add yourself'], 400);
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
            return response()->json(['success' => false, 'message' => 'Relationship already exists'], 400);
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

    public function getFriends(Request $request)
    {
        $user = $request->user();

        $friendIds = DB::table('friends')
            ->where('status', 'accepted')
            ->where(function ($q) use ($user) {
                $q->where('user_id', $user->id)->orWhere('friend_id', $user->id);
            })
            ->get()
            ->map(function ($f) use ($user) {
                return $f->user_id == $user->id ? $f->friend_id : $f->user_id;
            });

        $friends = User::with('equippedAvatar')->whereIn('id', $friendIds)->get(['id', 'username', 'avatar_url', 'xp', 'equipped_avatar_id', 'selected_rank_id']);
        
        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();

        $friends = $friends->map(function ($f) use ($ranks) {
            $userXp = (int)$f->xp;
            $f->level = floor($userXp / 200) + 1;
            
            $userRank = null;
            if ($f->selected_rank_id) {
                $userRank = $ranks->firstWhere('id', $f->selected_rank_id);
            }
            if (!$userRank) {
                $userRank = $ranks->firstWhere('xp_threshold', '<=', $userXp);
            }

            $f->rank_title = $userRank ? $userRank->name : 'Unranked';
            $f->rank_icon_url = $userRank ? $userRank->icon_url : null;
            $f->avatar_url = $f->equippedAvatar ? $f->equippedAvatar->image_url : ($f->avatar_url ?: '/images/chapter.png');
            return $f;
        });

        return response()->json(['success' => true, 'data' => $friends]);
    }

    public function getRequests(Request $request)
    {
        $user = $request->user();

        $requesterIds = DB::table('friends')
            ->where('friend_id', $user->id)
            ->where('status', 'pending')
            ->pluck('user_id');

        $requests = User::with('equippedAvatar')->whereIn('id', $requesterIds)->get(['id', 'username', 'avatar_url', 'xp', 'equipped_avatar_id', 'selected_rank_id']);
        
        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();

        // Map to include friendship ID if needed, or just use user ID
        $data = $requests->map(function($r) use ($user, $ranks) {
            $f = DB::table('friends')
                ->where('user_id', $r->id)
                ->where('friend_id', $user->id)
                ->first();
            
            $userXp = (int)$r->xp;
            $r->level = floor($userXp / 200) + 1;
            
            $userRank = null;
            if ($r->selected_rank_id) {
                $userRank = $ranks->firstWhere('id', $r->selected_rank_id);
            }
            if (!$userRank) {
                $userRank = $ranks->firstWhere('xp_threshold', '<=', $userXp);
            }

            $r->rank_title = $userRank ? $userRank->name : 'Unranked';
            $r->rank_icon_url = $userRank ? $userRank->icon_url : null;
            $r->avatar_url = $r->equippedAvatar ? $r->equippedAvatar->image_url : ($r->avatar_url ?: '/images/chapter.png');

            $r->request_id = $f->id;
            $r->requested_at = $f->created_at;
            return $r;
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function acceptRequest(Request $request, $requesterId)
    {
        $user = $request->user();

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

    public function ignoreRequest(Request $request, $requesterId)
    {
        $user = $request->user();

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

    public function getProfile($userId)
    {
        $user = User::with('equippedAvatar')->findOrFail($userId);
        
        $ranks = \App\Models\Rank::orderByDesc('xp_threshold')->get();
        $userXp = (int)$user->xp;
        $user->quiz_level = floor($userXp / 200) + 1;
        
        $userRank = null;
        if ($user->selected_rank_id) {
            $userRank = $ranks->firstWhere('id', $user->selected_rank_id);
        }
        if (!$userRank) {
            $userRank = $ranks->firstWhere('xp_threshold', '<=', $userXp);
        }
        
        $user->current_level_name = $userRank ? $userRank->name : 'Unranked';
        $user->rank_icon_url = $userRank ? $userRank->icon_url : null;
        $user->avatar_url = $user->equippedAvatar ? $user->equippedAvatar->image_url : ($user->avatar_url ?: '/images/chapter.png');

        // Stats
        $following = DB::table('friends')->where('user_id', $user->id)->count();
        $followers = DB::table('friends')->where('friend_id', $user->id)->count();
        $friendsCount = DB::table('friends as f1')
            ->join('friends as f2', function($join) {
                $join->on('f1.user_id', '=', 'f2.friend_id')
                     ->on('f1.friend_id', '=', 'f2.user_id');
            })
            ->where('f1.user_id', $user->id)
            ->count();

        // Reading History
        $history = DB::table('user_article_history')
            ->where('user_id', $user->id)
            ->join('articles', 'user_article_history.article_id', '=', 'articles.id')
            ->select('articles.*', 'user_article_history.completed_at', 'user_article_history.updated_at as last_read_at')
            ->orderBy('user_article_history.updated_at', 'desc')
            ->limit(10)
            ->get();

        // Get Quiz Progress (Using the same logic as AuthController)
        $authController = new AuthController();
        $progress = $authController->getQuizProgressData($user);

        // Check relationship with authenticated user
        $authUserId = auth('sanctum')->id();
        $friendshipStatus = 'none';
        if ($authUserId && $authUserId != $userId) {
            $friendship = DB::table('friends')
                ->where(function ($q) use ($authUserId, $userId) {
                    $q->where('user_id', $authUserId)->where('friend_id', $userId);
                })
                ->orWhere(function ($q) use ($authUserId, $userId) {
                    $q->where('user_id', $userId)->where('friend_id', $authUserId);
                })
                ->first();

            if ($friendship) {
                $friendshipStatus = $friendship->status;
                // If it's pending, distinguish who sent it
                if ($friendshipStatus === 'pending' && $friendship->friend_id == $authUserId) {
                    $friendshipStatus = 'requested_to_me';
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => array_merge($user->toArray(), [
                    'quiz_level' => $progress['level'],
                    'current_level_name' => $progress['level_name'],
                    'current_chapter_title' => $progress['chapter_title'],
                    'current_level_progress' => $progress['level_progress'],
                    'profile_bg_color' => $user->profile_bg_color,
                ]),
                'stats' => [
                    'following' => $following,
                    'followers' => $followers,
                    'friends' => $friendsCount,
                ],
                'history' => $history,
                'friendship_status' => $friendshipStatus
            ]
        ]);
    }

    public function toggleFollow(Request $request, $friendId)
    {
        $user = $request->user();
        if ($user->id == $friendId) {
            return response()->json(['success' => false, 'message' => 'Cannot follow yourself'], 400);
        }

        $friendship = DB::table('friends')
            ->where('user_id', $user->id)
            ->where('friend_id', $friendId)
            ->first();

        if ($friendship) {
            // Unfollow
            DB::table('friends')
                ->where('user_id', $user->id)
                ->where('friend_id', $friendId)
                ->delete();
            
            // If they were friends, the other person's follow should become pending again 
            // (or stay accepted depending on your preference, here we keep it simple)
            DB::table('friends')
                ->where('user_id', $friendId)
                ->where('friend_id', $user->id)
                ->update(['status' => 'pending']);

            return response()->json(['success' => true, 'action' => 'unfollowed']);
        } else {
            // Check if they are already following me
            $reverseFriendship = DB::table('friends')
                ->where('user_id', $friendId)
                ->where('friend_id', $user->id)
                ->first();

            $status = $reverseFriendship ? 'accepted' : 'pending';

            // Follow
            DB::table('friends')->insert([
                'user_id' => $user->id,
                'friend_id' => $friendId,
                'status' => $status,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // If mutual, update the other one to accepted too
            if ($reverseFriendship) {
                DB::table('friends')
                    ->where('user_id', $friendId)
                    ->where('friend_id', $user->id)
                    ->update(['status' => 'accepted']);
            }

            return response()->json(['success' => true, 'action' => 'followed', 'is_mutual' => !!$reverseFriendship]);
        }
    }

    public function stats(Request $request)
    {
        $user = $request->user();
        
        // Following = Requests I sent
        $following = DB::table('friends')->where('user_id', $user->id)->count();
        
        // Followers = Requests sent to me
        $followers = DB::table('friends')->where('friend_id', $user->id)->count();
        
        // Friends = True Mutual Follows (A follows B AND B follows A)
        $friendsCount = DB::table('friends as f1')
            ->join('friends as f2', function($join) {
                $join->on('f1.user_id', '=', 'f2.friend_id')
                     ->on('f1.friend_id', '=', 'f2.user_id');
            })
            ->where('f1.user_id', $user->id)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'following' => $following,
                'followers' => $followers,
                'friends' => $friendsCount,
            ]
        ]);
    }
}



