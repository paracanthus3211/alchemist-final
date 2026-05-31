<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\DailyTask;

class DailyTaskSeeder extends Seeder
{
    public function run(): void
    {
        // Clear existing tasks (use delete instead of truncate due to foreign key)
        \DB::table('user_daily_progress')->delete();
        DailyTask::query()->delete();

        // Task 1: Complete Quiz (Finish Lessons)
        DailyTask::create([
            'task_name' => 'Complete 3 Quiz',
            'task_type' => 'FINISH_LESSONS',
            'target_value' => 3,
            'xp_reward' => 15,
            'is_active' => true,
        ]);

        // Task 2: Gain XP
        DailyTask::create([
            'task_name' => 'Gain XP',
            'task_type' => 'GAIN_XP',
            'target_value' => 10,
            'xp_reward' => 15,
            'is_active' => true,
        ]);

        // Task 3: Read Article
        DailyTask::create([
            'task_name' => 'Read 1 Article',
            'task_type' => 'READ_ARTICLE',
            'target_value' => 1,
            'xp_reward' => 15,
            'is_active' => true,
        ]);

        // Task 4: Quiz Score
        DailyTask::create([
            'task_name' => 'Score 70%',
            'task_type' => 'QUIZ_SCORE',
            'target_value' => 70,
            'xp_reward' => 15,
            'is_active' => true,
        ]);
    }
}
