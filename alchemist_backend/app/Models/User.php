<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

#[Fillable(['name', 'email', 'password'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'role',
        'avatar_url',
        'xp',
        'streak_count',
        'max_streak',
        'last_study_at',
        'equipped_avatar_id',
        'selected_rank_id',
        'profile_bg_color',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'selected_rank_id' => 'integer',
            'xp' => 'integer',
            'streak_count' => 'integer',
            'max_streak' => 'integer',
            'last_study_at' => 'date',
            'equipped_avatar_id' => 'integer',
        ];
    }

    public function bookmarks()
    {
        return $this->hasMany(Bookmark::class);
    }

    public function avatars()
    {
        return $this->belongsToMany(Avatar::class, 'user_avatars');
    }

    public function equippedAvatar()
    {
        return $this->belongsTo(Avatar::class, 'equipped_avatar_id');
    }

    /**
     * Check if streak should be reset (called on login/me)
     */
    public function checkStreakReset()
    {
        if (!$this->last_study_at) return;

        $today = now()->startOfDay();
        $lastStudy = \Carbon\Carbon::parse($this->last_study_at)->startOfDay();

        // If last study was before yesterday, reset streak to 0
        if ($lastStudy->lessThan($today->copy()->subDay())) {
            $this->streak_count = 0;
            $this->save();
        }
    }

    /**
     * Update user streak and grant rewards
     */
    public function updateStreak()
    {
        $today = now()->startOfDay();
        $lastStudy = $this->last_study_at ? \Carbon\Carbon::parse($this->last_study_at)->startOfDay() : null;

        if ($lastStudy && $lastStudy->equalTo($today)) {
            return null; // Already updated today
        }

        if ($lastStudy && $lastStudy->equalTo($today->copy()->subDay())) {
            // Studied yesterday, increment streak
            $this->streak_count++;
        } else {
            // Missed a day or first time
            $this->streak_count = 1;
        }

        if ($this->streak_count > $this->max_streak) {
            $this->max_streak = $this->streak_count;
        }

        $this->last_study_at = $today;
        
        // Check for Streak Rewards
        $bonusXp = 0;
        $rewardMessage = "";

        switch ($this->streak_count) {
            case 3: $bonusXp = 30; $rewardMessage = "Beginner Streak Badge Unlocked! 🔥"; break;
            case 7: $bonusXp = 70; $rewardMessage = "Week Warrior Badge Unlocked! ⭐"; break;
            case 14: $bonusXp = 150; $rewardMessage = "Dedicated Badge Unlocked! 💪"; break;
            case 30: $bonusXp = 300; $rewardMessage = "Monthly Master Title Unlocked! 👑"; break;
            case 60: $bonusXp = 600; $rewardMessage = "Veteran Status Unlocked! 🏆"; break;
            case 100: $bonusXp = 1000; $rewardMessage = "Legendary Status Unlocked! ⚡"; break;
            case 365: $bonusXp = 5000; $rewardMessage = "Immortal Status Unlocked! 🌟"; break;
        }

        if ($bonusXp > 0) {
            $this->xp += $bonusXp;
            // Log bonus XP
            \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
                'user_id' => $this->id,
                'source_type' => 'streak_bonus',
                'xp_amount' => $bonusXp,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->save();

        // Auto-unlock avatars based on streak/xp
        $this->checkAvatarUnlocks();

        return [
            'streak' => $this->streak_count,
            'bonus_xp' => $bonusXp,
            'message' => $rewardMessage
        ];
    }

    public function checkAvatarUnlocks()
    {
        $unlockedIds = $this->avatars()->pluck('avatars.id')->toArray();
        
        $toUnlock = \App\Models\Avatar::whereNotIn('id', $unlockedIds)
            ->where(function($q) {
                $q->where(function($sq) {
                    $sq->where('unlock_type', 'xp')->where('unlock_value', '<=', $this->xp);
                })->orWhere(function($sq) {
                    $sq->where('unlock_type', 'streak')->where('unlock_value', '<=', $this->streak_count);
                });
            })->get();

        if ($toUnlock->isNotEmpty()) {
            $this->avatars()->attach($toUnlock->pluck('id'));
        }
    }
}
