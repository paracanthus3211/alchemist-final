<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->integer('streak_count')->default(0);
            $table->integer('max_streak')->default(0);
            $table->date('last_study_at')->nullable();
            $table->foreignId('equipped_avatar_id')->nullable()->constrained('avatars')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['streak_count', 'max_streak', 'last_study_at', 'equipped_avatar_id']);
        });
    }
};
