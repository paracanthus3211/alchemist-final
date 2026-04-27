<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SentenceArrangementWord extends Model
{
    protected $table = 'sentence_arrangement_words';
    protected $fillable = ['question_id', 'word', 'correct_index'];

    public function question()
    {
        return $this->belongsTo(Question::class);
    }
}
