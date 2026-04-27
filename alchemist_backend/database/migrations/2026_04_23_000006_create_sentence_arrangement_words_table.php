<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sentence_arrangement_words', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained('questions')->onDelete('cascade');
            $table->string('word_text');
            $table->integer('correct_order_index');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sentence_arrangement_words');
    }
};
