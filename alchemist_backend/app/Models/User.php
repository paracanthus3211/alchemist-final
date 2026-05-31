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
        'first_name',
        'last_name',
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
        'gender',
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

    public function selectedRank()
    {
        return $this->belongsTo(Rank::class, 'selected_rank_id');
    }

    /**
     * Check if streak should be reset (called on login/me)
     * Streak resets to 0 only if user hasn't studied for 2+ days
     */
    public function checkStreakReset()
    {
        if (!$this->last_study_at) return;

        $today = now()->startOfDay();
        $lastStudy = \Carbon\Carbon::parse($this->last_study_at)->startOfDay();
        $daysDiff = $today->diffInDays($lastStudy);

        // If more than 1 day has passed since last study, reset streak
        if ($daysDiff > 1) {
            $this->streak_count = 0;
            $this->save();
        }
    }

    /**
     * Update user streak — grants +1 streak per calendar day of activity.
     * Streak resets to 0 if user hasn't played for more than 1 day.
     */
    public function updateStreak()
    {
        $today = now()->startOfDay();
        $lastStudy = $this->last_study_at 
            ? $this->last_study_at->startOfDay() 
            : null;

        // Already updated today — do nothing
        if ($lastStudy && $lastStudy->eq($today)) {
            return null;
        }

        // Calculate days difference
        $daysDiff = $lastStudy ? $today->diffInDays($lastStudy) : 999;

        if ($daysDiff === 1) {
            // Played yesterday → continue streak
            $this->streak_count = ($this->streak_count ?? 0) + 1;
        } else if ($daysDiff > 1) {
            // Missed more than 1 day → reset to 1
            $this->streak_count = 1;
        } else {
            // First time (daysDiff = 999) or edge case → set to 1
            $this->streak_count = 1;
        }

        if ($this->streak_count > ($this->max_streak ?? 0)) {
            $this->max_streak = $this->streak_count;
        }

        $this->last_study_at = $today;

        // Streak milestone rewards
        $bonusXp = 0;
        $rewardMessage = '';

        switch ($this->streak_count) {
            case 3:   $bonusXp = 30;   $rewardMessage = 'Beginner Streak Badge Unlocked! 🔥'; break;
            case 7:   $bonusXp = 70;   $rewardMessage = 'Week Warrior Badge Unlocked! ⭐'; break;
            case 14:  $bonusXp = 150;  $rewardMessage = 'Dedicated Badge Unlocked! 💪'; break;
            case 30:  $bonusXp = 300;  $rewardMessage = 'Monthly Master Title Unlocked! 👑'; break;
            case 60:  $bonusXp = 600;  $rewardMessage = 'Veteran Status Unlocked! 🏆'; break;
            case 100: $bonusXp = 1000; $rewardMessage = 'Legendary Status Unlocked! ⚡'; break;
            case 365: $bonusXp = 5000; $rewardMessage = 'Immortal Status Unlocked! 🌟'; break;
        }

        if ($bonusXp > 0) {
            $this->xp = ($this->xp ?? 0) + $bonusXp;
            \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
                'user_id'    => $this->id,
                'source_type'=> 'streak_bonus',
                'xp_amount'  => $bonusXp,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->save();

        $this->checkAvatarUnlocks();

        return [
            'streak'   => $this->streak_count,
            'bonus_xp' => $bonusXp,
            'message'  => $rewardMessage,
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

