<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PeriodicTableController extends Controller
{
    public function index()
    {
        return view('periodic_table');
    }
}
