<?php

namespace App\Http\Controllers;

use App\Traits\UpdatesDailyTasks;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class VirtualLabController extends Controller
{
    use UpdatesDailyTasks;

    public function index()
    {
        abort_unless(auth()->check(), 403);

        return view('virtual_lab', [
            'userXp' => auth()->user()->xp ?? 0,
        ]);
    }

    public function recordReaction(Request $request)
    {
        abort_unless(auth()->check(), 403);

        $request->validate([
            'reaction_key' => 'required|string|max:100',
        ]);

        $user = $request->user();
        $reactionKey = strtolower(trim($request->reaction_key));

        $exists = DB::table('user_lab_reactions')
            ->where('user_id', $user->id)
            ->where('reaction_key', $reactionKey)
            ->exists();

        if ($exists) {
            return response()->json([
                'already_completed' => true,
                'xp_added' => 0,
                'total_xp' => $user->xp,
            ]);
        }

        $xp = 25;

        DB::transaction(function () use ($user, $reactionKey, $xp) {
            DB::table('user_lab_reactions')->insert([
                'user_id' => $user->id,
                'reaction_key' => $reactionKey,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $user->xp += $xp;
            $user->save();

            DB::table('xp_transactions')->insert([
                'user_id' => $user->id,
                'source_type' => 'virtual_lab_reaction',
                'xp_amount' => $xp,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $this->_incrementDailyTaskProgress($user, 'GAIN_XP', $xp);
            $this->_incrementDailyTaskProgress($user, 'LAB_EXPERIMENT', 1);
        });

        return response()->json([
            'already_completed' => false,
            'xp_added' => $xp,
            'total_xp' => $user->xp,
        ]);
    }
}


