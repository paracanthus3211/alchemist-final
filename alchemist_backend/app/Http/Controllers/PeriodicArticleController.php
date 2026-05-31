<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PeriodicArticleController extends Controller
{
    public function index()
    {
        return response()->json([
            'status' => 'success',
            'data' => []
        ]);
    }

    public function show($elementNumber)
    {
        return response()->json([
            'status' => 'success',
            'data' => null
        ]);
    }

    public function store(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'message' => 'Article stored'
        ]);
    }

    public function getArticle($elementNumber)
    {
        return response()->json([
            'status' => 'success',
            'data' => null
        ]);
    }

    public function destroy($elementNumber)
    {
        return response()->json([
            'status' => 'success',
            'message' => 'Article deleted'
        ]);
    }
}
