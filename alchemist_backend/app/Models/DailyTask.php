<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DailyTask extends Model
{
    protected $fillable = [
        'task_name',
        'task_type',
        'description',
        'target_value',
        'xp_reward',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'target_value' => 'integer',
        'xp_reward' => 'integer',
    ];

    public function userProgress()
    {
        return $this->hasMany(UserDailyProgress::class, 'task_id');
    }
}
