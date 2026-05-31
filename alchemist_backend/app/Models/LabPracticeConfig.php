<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LabPracticeConfig extends Model
{
    protected $table = 'lab_practice_config';
    protected $fillable = [
        'question_id', 
        'beaker_a_chemical', 
        'beaker_b_chemical', 
        'expected_visual_result', 
        'expected_reaction_equation'
    ];

    public function question()
    {
        return $this->belongsTo(Question::class);
    }
}

