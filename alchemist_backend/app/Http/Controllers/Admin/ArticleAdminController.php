<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\ArticleContent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ArticleAdminController extends Controller
{
    public function create()
    {
        $article = null;
        return view('admin.articles.create_edit', compact('article'));
    }

    public function edit($id)
    {
        $article = Article::with('contents')->findOrFail($id);
        return view('admin.articles.create_edit', compact('article'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:255',
            'difficulty_level' => 'required|string|in:Dasar,Menengah,Sulit',
            'thumbnail_url' => 'required|string',
            'contents' => 'required|array',
        ]);

        return DB::transaction(function() use ($request) {
            $article = Article::create([
                'title' => $request->title,
                'description' => $request->description,
                'category' => $request->category,
                'difficulty_level' => $request->difficulty_level,
                'thumbnail_url' => $request->thumbnail_url,
            ]);

            foreach ($request->contents as $index => $contentBlock) {
                // Ensure content is properly structured/encoded
                $content = $contentBlock['content'];
                if ($contentBlock['type'] === 'text' && is_array($content)) {
                    $content = json_encode($content);
                } elseif ($contentBlock['type'] === 'table' && is_array($content)) {
                    $content = json_encode($content);
                }

                $article->contents()->create([
                    'type' => $contentBlock['type'],
                    'content' => $content,
                    'order_index' => $index,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Article created successfully!',
                'redirect' => route('library')
            ]);
        });
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:255',
            'difficulty_level' => 'required|string|in:Dasar,Menengah,Sulit',
            'thumbnail_url' => 'required|string',
            'contents' => 'required|array',
        ]);

        $article = Article::findOrFail($id);

        return DB::transaction(function() use ($request, $article) {
            $article->update([
                'title' => $request->title,
                'description' => $request->description,
                'category' => $request->category,
                'difficulty_level' => $request->difficulty_level,
                'thumbnail_url' => $request->thumbnail_url,
            ]);

            // Clear old contents and replace
            $article->contents()->delete();

            foreach ($request->contents as $index => $contentBlock) {
                $content = $contentBlock['content'];
                if ($contentBlock['type'] === 'text' && is_array($content)) {
                    $content = json_encode($content);
                } elseif ($contentBlock['type'] === 'table' && is_array($content)) {
                    $content = json_encode($content);
                }

                $article->contents()->create([
                    'type' => $contentBlock['type'],
                    'content' => $content,
                    'order_index' => $index,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Article updated successfully!',
                'redirect' => route('library')
            ]);
        });
    }

    public function destroy($id)
    {
        $article = Article::findOrFail($id);
        $article->contents()->delete();
        $article->delete();

        return redirect()->route('library')->with('success', 'Article deleted successfully.');
    }

    public function uploadImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            
            // Move file to public/images/articles
            $file->move(public_path('images/articles'), $filename);
            $url = '/images/articles/' . $filename;

            return response()->json([
                'success' => true,
                'url' => $url
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'No image uploaded'
        ], 400);
    }
}
