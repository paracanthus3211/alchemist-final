<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MultipleChoiceOption extends Model
{
    protected $table = 'multiple_choice_options';
    protected $fillable = ['question_id', 'option_label', 'option_text', 'is_correct'];

    public function question()
    {
        return $this->belongsTo(Question::class);
    }
}
