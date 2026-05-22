<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_question_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('question_id')->constrained('questions')->onDelete('cascade');
            $table->boolean('is_correct')->default(false);
            $table->integer('xp_earned')->default(0);
            $table->timestamp('attempted_at')->useCurrent();
            $table->timestamps();
        });

        Schema::create('user_daily_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('task_id')->constrained('daily_tasks')->onDelete('cascade');
            $table->date('date');
            $table->integer('current_progress')->default(0);
            $table->text('completed_stages')->nullable(); // JSON array of completed stage indices
            $table->boolean('is_completed')->default(false);
            $table->timestamps();

            $table->unique(['user_id', 'task_id', 'date']);
        });

        Schema::create('user_level_completions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('level_id')->constrained()->onDelete('cascade');
            $table->integer('score')->default(100);
            $table->integer('completion_time_seconds');
            $table->integer('wrong_answers_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_level_completions');
        Schema::dropIfExists('user_daily_progress');
        Schema::dropIfExists('user_question_attempts');
    }
};
