<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CurriculumController;
use App\Http\Controllers\Api\DailyTaskController;
use App\Http\Controllers\Api\ArticleController;
use App\Http\Controllers\Api\RankController;
use App\Http\Controllers\Api\FriendController;
use App\Http\Controllers\Api\AvatarController;
use App\Http\Controllers\PeriodicArticleController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/curriculum', [CurriculumController::class, 'index']);
Route::get('/ranks', [RankController::class, 'index']);

Route::get('/articles', [ArticleController::class, 'index']);
Route::get('/articles/{id}', [ArticleController::class, 'show']);
Route::get('/images/{path}', [ArticleController::class, 'serveImage'])->where('path', '.*');

// Periodic Articles (Public)
Route::get('/periodic-articles', [PeriodicArticleController::class, 'index']);
Route::get('/periodic-articles/{elementNumber}', [PeriodicArticleController::class, 'show']);

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
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/user/xp', [AuthController::class, 'addXp']);
    Route::post('/user/lab-xp', [AuthController::class, 'addLabXp']);
    Route::post('/user/lab-reaction', [AuthController::class, 'recordLabReaction']);
    Route::post('/user/select-rank', [AuthController::class, 'selectRank']);
    Route::put('/user/profile-bg', [AuthController::class, 'updateProfileBg']);

    // Curriculum Management (CRUD)
    Route::post('/chapters', [CurriculumController::class, 'storeChapter']);
    Route::put('/chapters/{chapter}', [CurriculumController::class, 'updateChapter']);
    Route::delete('/chapters/{chapter}', [CurriculumController::class, 'destroyChapter']);
    Route::post('/levels', [CurriculumController::class, 'storeLevel']);
    Route::put('/levels/{level}', [CurriculumController::class, 'updateLevel']);
    Route::delete('/levels/{level}', [CurriculumController::class, 'destroyLevel']);
    Route::post('/levels/{level}/complete', [CurriculumController::class, 'saveLevelCompletion']);
    Route::post('/quizzes', [CurriculumController::class, 'storeQuiz']);
    Route::post('/questions', [CurriculumController::class, 'storeQuestion']);
    Route::put('/questions/{question}', [CurriculumController::class, 'updateQuestion']);
    Route::delete('/questions/{question}', [CurriculumController::class, 'destroyQuestion']);

    // Daily Tasks
    Route::get('/daily-tasks', [DailyTaskController::class, 'index']);
    Route::get('/daily-tasks/stats', [DailyTaskController::class, 'stats']);
    Route::post('/daily-tasks/regenerate', [DailyTaskController::class, 'regenerate']);
    Route::post('/daily-tasks', [DailyTaskController::class, 'store']);
    Route::put('/daily-tasks/{dailyTask}', [DailyTaskController::class, 'update']);
    Route::delete('/daily-tasks/{dailyTask}', [DailyTaskController::class, 'destroy']);
    Route::post('/daily-tasks/{dailyTask}/progress', [DailyTaskController::class, 'updateProgress']);

    // Articles
    Route::apiResource('articles', ArticleController::class);
    Route::get('/user/reading-history', [ArticleController::class, 'history']);
    Route::post('/articles/{id}/finish', [ArticleController::class, 'finish']);
    Route::post('/articles/{id}/bookmark', [ArticleController::class, 'toggleBookmark']);
    Route::get('/bookmarks', [ArticleController::class, 'bookmarks']);

    // Ranks
    Route::post('/ranks', [RankController::class, 'store']);
    Route::put('/ranks/{rank}', [RankController::class, 'update']);
    Route::delete('/ranks/{rank}', [RankController::class, 'destroy']);
    Route::get('/leaderboard', [RankController::class, 'leaderboard']);

    // Friends
    Route::get('/users/search', [FriendController::class, 'search']);
    Route::get('/friends', [FriendController::class, 'getFriends']);
    Route::get('/friends/requests', [FriendController::class, 'getRequests']);
    Route::get('/friends/stats', [FriendController::class, 'stats']);
    Route::post('/friends/{friendId}', [FriendController::class, 'sendRequest']);
    Route::put('/friends/{requesterId}/accept', [FriendController::class, 'acceptRequest']);
    Route::delete('/friends/{requesterId}/ignore', [FriendController::class, 'ignoreRequest']);
    Route::get('/users/{userId}/profile', [FriendController::class, 'getProfile']);
    Route::post('/users/{userId}/follow', [FriendController::class, 'toggleFollow']);

    // Avatars
    Route::get('/avatars', [AvatarController::class, 'index']);
    Route::get('/user/avatars', [AvatarController::class, 'myAvatars']);
    Route::post('/user/avatars/{id}/equip', [AvatarController::class, 'equip']);
    Route::post('/avatars', [AvatarController::class, 'store']);
    Route::put('/avatars/{id}', [AvatarController::class, 'update']);
    Route::delete('/avatars/{id}', [AvatarController::class, 'destroy']);

    // Image Upload
    Route::post('/upload-image', [ArticleController::class, 'uploadImage']);

    // Periodic Articles (Admin Only)
    Route::post('/periodic-articles', [PeriodicArticleController::class, 'store']);
    Route::delete('/periodic-articles/{elementNumber}', [PeriodicArticleController::class, 'destroy']);
});
