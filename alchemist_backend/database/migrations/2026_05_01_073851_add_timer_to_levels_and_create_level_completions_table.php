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
        // Add timer_limit to levels
        Schema::table('levels', function (Blueprint $table) {
            $table->integer('timer_limit')->nullable()->after('order_index');
        });

        // Create level completions table to store speed and score
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

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_level_completions');
        Schema::table('levels', function (Blueprint $table) {
            $table->dropColumn('timer_limit');
        });
    }
};
