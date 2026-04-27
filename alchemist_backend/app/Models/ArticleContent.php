<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ArticleContent extends Model
{
    protected $fillable = ['article_id', 'type', 'content', 'order_index'];

    public function article()
    {
        return $this->belongsTo(Article::class);
    }
}
