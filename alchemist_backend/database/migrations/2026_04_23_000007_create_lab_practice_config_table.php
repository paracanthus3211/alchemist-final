<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
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
    }
};
