<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Level extends Model
{
    use HasFactory;

    protected $fillable = [
        'chapter_id',
        'name',
        'description',
        'icon_url',
        'xp_required',
        'order_index',
    ];

    public function chapter()
    {
        return $this->belongsTo(Chapter::class);
    }

    public function questions()
    {
        return $this->hasMany(Question::class)->orderBy('order_index');
    }
}
