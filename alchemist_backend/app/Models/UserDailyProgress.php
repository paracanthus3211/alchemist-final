<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserDailyProgress extends Model
{
    protected $fillable = [
        'user_id',
        'task_id',
        'date',
        'current_progress',
        'is_completed',
    ];

    protected $casts = [
        'is_completed' => 'boolean',
        'date' => 'date',
        'current_progress' => 'integer',
    ];

    public function task()
    {
        return $this->belongsTo(DailyTask::class, 'task_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
