<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\ArticleContent;
use App\Models\Bookmark;
use App\Traits\UpdatesDailyTasks;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ArticleController extends Controller
{
    use UpdatesDailyTasks;

    public function index(Request $request)
    {
        $query = Article::query();

        if ($request->has('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        if ($request->has('category') && $request->category !== 'ALL RESEARCH') {
            $query->where('category', $request->category);
        }

        if ($request->has('difficulty_level')) {
            $query->where('difficulty_level', $request->difficulty_level);
        }

        $user = $request->user('sanctum');
        $articles = $query->with('contents')->latest()->get();

        $articles = $articles->map(function($article) use ($user) {
            $article->is_bookmarked = $user ? $user->bookmarks()->where('article_id', $article->id)->exists() : false;
            return $article;
        });

        return response()->json(['data' => $articles]);
    }

    public function show($id, Request $request)
    {
        $article = Article::with('contents')->findOrFail($id);
        $user = $request->user('sanctum');
        
        if ($user) {
            $article->is_bookmarked = $user->bookmarks()->where('article_id', $article->id)->exists();
            
            // Track in history (upsert)
            DB::table('user_article_history')->updateOrInsert(
                ['user_id' => $user->id, 'article_id' => $article->id],
                ['completed_at' => null, 'updated_at' => now()]
            );
        } else {
            $article->is_bookmarked = false;
        }
        
        return response()->json(['data' => $article]);
    }

    public function finish($id, Request $request)
    {
        $user = $request->user();
        DB::table('user_article_history')->updateOrInsert(
            ['user_id' => $user->id, 'article_id' => $id],
            ['completed_at' => now(), 'updated_at' => now()]
        );

        // Update Daily Task
        $this->_incrementDailyTaskProgress($user, 'READ_ARTICLE', 1, $id);

        $authController = new AuthController();
        $progress = $authController->getQuizProgressData($user);

        return response()->json([
            'status' => 'success',
            'message' => 'Article finished',
            'user' => [
                'xp' => $user->xp,
                'quiz_level' => $progress['level'],
                'current_level_name' => $progress['level_name'],
                'current_chapter_title' => $progress['chapter_title'],
                'current_level_progress' => $progress['level_progress'],
            ]
        ]);
    }

    public function history(Request $request)
    {
        $user = $request->user();
        $history = DB::table('user_article_history')
            ->where('user_id', $user->id)
            ->whereNull('completed_at') // Hanya tampilkan yang belum selesai
            ->join('articles', 'user_article_history.article_id', '=', 'articles.id')
            ->select('articles.*', 'user_article_history.completed_at', 'user_article_history.updated_at as last_read_at')
            ->orderBy('user_article_history.updated_at', 'desc')
            ->limit(10)
            ->get();
            
        return response()->json(['data' => $history]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'category' => 'nullable|string',
            'difficulty_level' => 'nullable|string',
            'thumbnail_url' => 'nullable|string',
            'contents' => 'required|array',
        ]);

        return DB::transaction(function() use ($request) {
            $article = Article::create($request->only(['title', 'description', 'category', 'difficulty_level', 'thumbnail_url']));

            foreach ($request->contents as $index => $content) {
                $article->contents()->create([
                    'type' => $content['type'],
                    'content' => is_array($content['content']) ? json_encode($content['content']) : $content['content'],
                    'order_index' => $index,
                ]);
            }

            return response()->json(['message' => 'Article created', 'data' => $article->load('contents')]);
        });
    }

    public function update(Request $request, $id)
    {
        $article = Article::findOrFail($id);

        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'category' => 'nullable|string',
            'difficulty_level' => 'nullable|string',
            'thumbnail_url' => 'nullable|string',
            'contents' => 'nullable|array',
        ]);

        return DB::transaction(function() use ($request, $article) {
            $article->update($request->only(['title', 'description', 'category', 'difficulty_level', 'thumbnail_url']));

            if ($request->has('contents')) {
                $article->contents()->delete();
                foreach ($request->contents as $index => $content) {
                    $article->contents()->create([
                        'type' => $content['type'],
                        'content' => is_array($content['content']) ? json_encode($content['content']) : $content['content'],
                        'order_index' => $index,
                    ]);
                }
            }

            return response()->json(['message' => 'Article updated', 'data' => $article->load('contents')]);
        });
    }

    public function destroy($id)
    {
        Article::findOrFail($id)->delete();
        return response()->json(['message' => 'Article deleted']);
    }

    public function toggleBookmark(Request $request, $id)
    {
        $user = $request->user();
        $bookmark = Bookmark::where('user_id', $user->id)->where('article_id', $id)->first();

        if ($bookmark) {
            $bookmark->delete();
            return response()->json(['message' => 'Bookmark removed', 'is_bookmarked' => false]);
        } else {
            Bookmark::create(['user_id' => $user->id, 'article_id' => $id]);
            return response()->json(['message' => 'Article bookmarked', 'is_bookmarked' => true]);
        }
    }

    public function bookmarks(Request $request)
    {
        $user = $request->user();
        $articles = Article::whereHas('bookmarks', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })->get();

        $articles = $articles->map(function($article) {
            $article->is_bookmarked = true;
            return $article;
        });

        return response()->json(['data' => $articles]);
    }

    public function uploadImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        $path = $request->file('image')->store('articles', 'public');
        // Use the API proxy URL instead of direct storage URL to avoid CORS issues on Web
        $url = url('/api/images/' . $path);

        return response()->json([
            'url' => $url,
            'path' => $path,
        ]);
    }

    public function serveImage($path)
    {
        $fullPath = storage_path('app/public/' . $path);
        if (!file_exists($fullPath)) {
            abort(404);
        }
        return response()->file($fullPath);
    }
}

