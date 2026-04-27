<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('level_id')->constrained('levels')->onDelete('cascade');
            $table->enum('type', ['MULTIPLE_CHOICE', 'SENTENCE_ARRANGEMENT', 'LAB_PRACTICE']);
            $table->text('question_text');
            $table->integer('xp_reward')->default(0);
            $table->text('explanation')->nullable();
            $table->integer('order_index')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};
