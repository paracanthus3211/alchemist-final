<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
    use HasFactory;

    protected $fillable = [
        'level_id',
        'type',
        'question_text',
        'explanation',
        'xp_reward',
        'order_index',
    ];

    public function level()
    {
        return $this->belongsTo(Level::class);
    }

    public function multipleChoiceOptions()
    {
        return $this->hasMany(MultipleChoiceOption::class);
    }

    public function sentenceArrangementWords()
    {
        return $this->hasMany(SentenceArrangementWord::class);
    }

    public function labPracticeConfig()
    {
        return $this->hasOne(LabPracticeConfig::class);
    }
}
