<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_daily_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('task_id')->constrained('daily_tasks')->onDelete('cascade');
            $table->date('date');
            $table->integer('current_progress')->default(0);
            $table->boolean('is_completed')->default(false);
            $table->timestamps();

            $table->unique(['user_id', 'task_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_daily_progress');
    }
};
