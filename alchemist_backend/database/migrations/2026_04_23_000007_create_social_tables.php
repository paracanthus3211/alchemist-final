<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add FK columns to users that depend on ranks & avatars existing first
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('selected_rank_id')->nullable()->constrained('ranks')->onDelete('set null');
            $table->foreignId('equipped_avatar_id')->nullable()->constrained('avatars')->nullOnDelete();
        });

        Schema::create('friends', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('friend_id')->constrained('users')->onDelete('cascade');
            $table->string('status')->default('pending'); // pending, accepted, blocked
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->nullable();

            $table->unique(['user_id', 'friend_id']);
        });

        Schema::create('follows', function (Blueprint $table) {
            $table->id();
            $table->foreignId('follower_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('following_id')->constrained('users')->onDelete('cascade');
            $table->timestamps();

            $table->unique(['follower_id', 'following_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('follows');
        Schema::dropIfExists('friends');
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('equipped_avatar_id');
            $table->dropConstrainedForeignId('selected_rank_id');
        });
    }
};
