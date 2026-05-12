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
        // Add stages to daily_tasks templates
        Schema::table('daily_tasks', function (Blueprint $table) {
            $table->text('stages')->nullable()->after('target_value'); // Will store JSON array of {target, reward}
        });

        // Add completed_stages to user daily progress
        Schema::table('user_daily_progress', function (Blueprint $table) {
            $table->text('completed_stages')->nullable()->after('current_progress'); // Will store JSON array of completed stage indices
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('daily_tasks', function (Blueprint $table) {
            $table->dropColumn('stages');
        });

        Schema::table('user_daily_progress', function (Blueprint $table) {
            $table->dropColumn('completed_stages');
        });
    }
};
