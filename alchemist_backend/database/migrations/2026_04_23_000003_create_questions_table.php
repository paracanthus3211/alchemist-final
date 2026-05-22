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

        Schema::create('multiple_choice_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained('questions')->onDelete('cascade');
            $table->string('option_label'); // A, B, C, D
            $table->text('option_text');
            $table->boolean('is_correct')->default(false);
            $table->timestamps();
        });

        Schema::create('sentence_arrangement_words', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained('questions')->onDelete('cascade');
            $table->string('word_text');
            $table->integer('correct_order_index');
            $table->timestamps();
        });

        Schema::create('lab_practice_config', function (Blueprint $table) {
            $table->id();
            $table->foreignId('question_id')->constrained('questions')->onDelete('cascade');
            $table->text('initial_question')->nullable();
            $table->string('beaker_a_chemical')->nullable();
            $table->string('beaker_b_chemical')->nullable();
            $table->text('expected_visual_result')->nullable();
            $table->text('expected_reaction_equation')->nullable();
            $table->string('correct_answer_label')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_practice_config');
        Schema::dropIfExists('sentence_arrangement_words');
        Schema::dropIfExists('multiple_choice_options');
        Schema::dropIfExists('questions');
    }
};
