<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserQuestionAttempt extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'question_id',
        'is_correct',
        'xp_earned',
        'attempted_at',
    ];

    public $timestamps = true;

    protected $casts = [
        'is_correct' => 'boolean',
        'attempted_at' => 'datetime',
    ];
}
