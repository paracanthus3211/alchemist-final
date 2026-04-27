<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_tasks', function (Blueprint $table) {
            $table->id();
            $table->string('task_name');
            $table->enum('task_type', ['FINISH_LESSONS', 'GAIN_XP', 'READ_ARTICLE', 'LAB_EXPERIMENT', 'DAILY_LOGIN']);
            $table->text('description')->nullable();
            $table->integer('target_value')->default(1);
            $table->integer('xp_reward')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_tasks');
    }
};
