<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('daily_tasks', function (Blueprint $table) {
            // Change enum to string to allow new types like SCORE without DB constraints
            $table->string('task_type')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('daily_tasks', function (Blueprint $table) {
            // No easy way to revert string back to enum in SQLite, but we can leave it as string
        });
    }
};
