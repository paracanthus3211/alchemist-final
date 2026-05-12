<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserLevelCompletion extends Model
{
    protected $fillable = [
        'user_id',
        'level_id',
        'score',
        'completion_time_seconds',
        'wrong_answers_count',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function level()
    {
        return $this->belongsTo(Level::class);
    }
}
