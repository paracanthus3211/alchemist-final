<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Avatar;
use Illuminate\Http\Request;

class AvatarController extends Controller
{
    /**
     * Display a listing of all avatars.
     */
    public function index(Request $request)
    {
        // Auto-check if user qualifies for any locked avatars
        if ($request->user()) {
            $request->user()->checkAvatarUnlocks();
        }

        $avatars = Avatar::all();
        return response()->json([
            'success' => true,
            'data' => $avatars
        ]);
    }

    /**
     * Get avatars belonging to the authenticated user.
     */
    public function myAvatars(Request $request)
    {
        $user = $request->user();
        $user->checkAvatarUnlocks(); // Sync unlocks
        $unlocked = $user->avatars;
        
        return response()->json([
            'success' => true,
            'data' => $unlocked,
            'equipped_id' => $user->equipped_avatar_id
        ]);
    }

    /**
     * Equip an avatar.
     */
    public function equip(Request $request, $id)
    {
        $user = $request->user();
        
        // Check if user owns this avatar
        if (!$user->avatars()->where('avatars.id', $id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'You haven\'t unlocked this avatar yet.'
            ], 403);
        }

        $user->equipped_avatar_id = $id;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Avatar equipped successfully!',
            'equipped_id' => $id
        ]);
    }

    /**
     * Admin: Store a new avatar.
     */
    public function store(Request $request)
    {
        if (strtolower($request->user()->role) !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image_url' => 'required|string',
            'unlock_type' => 'required|in:xp,streak,special',
            'unlock_value' => 'required|integer|min:0',
            'rarity' => 'required|in:common,rare,epic,legendary',
        ]);

        $avatar = Avatar::create($validated);

        return response()->json([
            'success' => true,
            'data' => $avatar
        ], 201);
    }

    /**
     * Admin: Update an avatar.
     */
    public function update(Request $request, $id)
    {
        if (strtolower($request->user()->role) !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $avatar = Avatar::findOrFail($id);
        
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'image_url' => 'sometimes|string',
            'unlock_type' => 'sometimes|in:xp,streak,special',
            'unlock_value' => 'sometimes|integer|min:0',
            'rarity' => 'sometimes|in:common,rare,epic,legendary',
        ]);

        $avatar->update($validated);

        return response()->json([
            'success' => true,
            'data' => $avatar
        ]);
    }

    /**
     * Admin: Delete an avatar.
     */
    public function destroy(Request $request, $id)
    {
        if (strtolower($request->user()->role) !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $avatar = Avatar::findOrFail($id);
        $avatar->delete();

        return response()->json([
            'success' => true,
            'message' => 'Avatar deleted successfully.'
        ]);
    }
}
