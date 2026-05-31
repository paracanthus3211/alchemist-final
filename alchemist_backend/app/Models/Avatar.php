<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Avatar extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'image_url',
        'unlock_type',
        'unlock_value',
        'rarity',
    ];

    public function users()
    {
        return $this->belongsToMany(User::class, 'user_avatars');
    }
}

