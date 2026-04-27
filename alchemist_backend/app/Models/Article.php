<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Article extends Model
{
    use HasFactory;

    protected $fillable = ['title', 'category', 'difficulty_level', 'thumbnail_url'];

    public function contents()
    {
        return $this->hasMany(ArticleContent::class)->orderBy('order_index');
    }

    public function bookmarks()
    {
        return $this->hasMany(Bookmark::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
