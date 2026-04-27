<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CurriculumController;
use App\Http\Controllers\Api\DailyTaskController;
use App\Http\Controllers\Api\ArticleController;
use App\Http\Controllers\Api\RankController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::get('/curriculum', [CurriculumController::class, 'index']);
Route::get('/ranks', [RankController::class, 'index']);
Route::get('/leaderboard', [RankController::class, 'leaderboard']);
Route::get('/articles', [ArticleController::class, 'index']);
Route::get('/articles/{id}', [ArticleController::class, 'show']);
Route::get('/images/{path}', [ArticleController::class, 'serveImage'])->where('path', '.*');

Route::get('/ping', function () {
    return response()->json(['status' => 'success', 'message' => 'API is reachable']);
});

Route::get('/fix-images', function() {
    foreach(App\Models\Article::all() as $a) {
        $a->thumbnail_url = str_replace('/storage/', '/api/images/', $a->thumbnail_url);
        $a->save();
    }
    foreach(App\Models\ArticleContent::where('type', 'image')->get() as $c) {
        $c->content = str_replace('/storage/', '/api/images/', $c->content);
        $c->save();
    }
    return "Existing images updated!";
});

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::post('/user/xp', [AuthController::class, 'addXp']);

    // Curriculum Management (CRUD)
    Route::post('/chapters', [CurriculumController::class, 'storeChapter']);
    Route::put('/chapters/{chapter}', [CurriculumController::class, 'updateChapter']);
    Route::delete('/chapters/{chapter}', [CurriculumController::class, 'destroyChapter']);
    Route::post('/levels', [CurriculumController::class, 'storeLevel']);
    Route::put('/levels/{level}', [CurriculumController::class, 'updateLevel']);
    Route::delete('/levels/{level}', [CurriculumController::class, 'destroyLevel']);
    Route::post('/quizzes', [CurriculumController::class, 'storeQuiz']);
    Route::post('/questions', [CurriculumController::class, 'storeQuestion']);
    Route::put('/questions/{question}', [CurriculumController::class, 'updateQuestion']);
    Route::delete('/questions/{question}', [CurriculumController::class, 'destroyQuestion']);

    // Daily Tasks
    Route::get('/daily-tasks', [DailyTaskController::class, 'index']);
    Route::get('/daily-tasks/stats', [DailyTaskController::class, 'stats']);
    Route::post('/daily-tasks', [DailyTaskController::class, 'store']);
    Route::put('/daily-tasks/{dailyTask}', [DailyTaskController::class, 'update']);
    Route::delete('/daily-tasks/{dailyTask}', [DailyTaskController::class, 'destroy']);
    Route::post('/daily-tasks/{dailyTask}/progress', [DailyTaskController::class, 'updateProgress']);

    // Articles
    Route::post('/articles', [ArticleController::class, 'store']);
    Route::put('/articles/{id}', [ArticleController::class, 'update']);
    Route::delete('/articles/{id}', [ArticleController::class, 'destroy']);
    Route::post('/articles/{id}/bookmark', [ArticleController::class, 'toggleBookmark']);
    Route::get('/bookmarks', [ArticleController::class, 'bookmarks']);

    // Ranks
    Route::post('/ranks', [RankController::class, 'store']);
    Route::put('/ranks/{rank}', [RankController::class, 'update']);
    Route::delete('/ranks/{rank}', [RankController::class, 'destroy']);

    // Image Upload
    Route::post('/upload-image', [ArticleController::class, 'uploadImage']);
});
