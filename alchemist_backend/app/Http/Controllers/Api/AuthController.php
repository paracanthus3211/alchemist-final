<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        \Log::info('Login attempt', $request->all());

        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Kredensial yang Anda masukkan salah.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => [
                'id'           => $user->id,
                'username'     => $user->username,
                'email'        => $user->email,
                'role'         => $user->role,
                'xp'           => $user->xp,
                'streak_days'  => $user->streak_days,
                'gender'       => $user->gender,
                'join_date'    => $user->join_date,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logout berhasil',
        ]);
    }

    public function addXp(Request $request)
    {
        $request->validate([
            'question_ids' => 'required|array',
            'question_ids.*' => 'integer|exists:questions,id'
        ]);

        $user = $request->user();
        $totalXpAdded = 0;

        foreach ($request->question_ids as $questionId) {
            // Check if already answered correctly
            $existing = \App\Models\UserQuestionAttempt::where('user_id', $user->id)
                ->where('question_id', $questionId)
                ->where('is_correct', true)
                ->first();

            if (!$existing) {
                $question = \App\Models\Question::find($questionId);
                $xp = $question->xp_reward ?? 10;
                
                \App\Models\UserQuestionAttempt::create([
                    'user_id' => $user->id,
                    'question_id' => $questionId,
                    'is_correct' => true,
                    'xp_earned' => $xp
                ]);

                $user->xp += $xp;
                $totalXpAdded += $xp;
            }
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'XP added successfully',
            'total_xp' => $user->xp,
            'xp_added' => $totalXpAdded
        ]);
    }
}
