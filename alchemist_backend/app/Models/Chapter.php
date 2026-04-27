<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Chapter extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'icon_emoji',
        'xp_threshold',
        'order_index',
    ];

    public function levels()
    {
        return $this->hasMany(Level::class)->orderBy('order_index');
    }
}
