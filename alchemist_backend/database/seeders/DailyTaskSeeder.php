<?php

namespace Database\Seeders;

use App\Models\DailyTask;
use Illuminate\Database\Seeder;

class DailyTaskSeeder extends Seeder
{
    public function run(): void
    {
        DailyTask::truncate();

        $tasks = [
            [
                'task_name'    => 'Quiz Master',
                'task_type'    => 'SCORE',
                'description'  => 'Dapatkan nilai quiz minimal 80%',
                'target_value' => 80,
                'xp_reward'    => 30,
                'is_active'    => true,
                'stages'       => json_encode([
                    ['target' => 80, 'reward' => 30],
                    ['target' => 80, 'reward' => 40],
                    ['target' => 80, 'reward' => 50],
                ]),
            ],
            [
                'task_name'    => 'XP Hunter',
                'task_type'    => 'GAIN_XP',
                'description'  => 'Kumpulkan XP dari aktivitas belajar',
                'target_value' => 200,
                'xp_reward'    => 40,
                'is_active'    => true,
                'stages'       => json_encode([
                    ['target' => 50,  'reward' => 20],
                    ['target' => 100, 'reward' => 30],
                    ['target' => 200, 'reward' => 40],
                ]),
            ],
            [
                'task_name'    => 'Daily Reader',
                'task_type'    => 'READ_ARTICLE',
                'description'  => 'Baca artikel kimia hari ini',
                'target_value' => 3,
                'xp_reward'    => 25,
                'is_active'    => true,
                'stages'       => json_encode([
                    ['target' => 1, 'reward' => 15],
                    ['target' => 2, 'reward' => 20],
                    ['target' => 3, 'reward' => 25],
                ]),
            ],
            [
                'task_name'    => 'Daily Login',
                'task_type'    => 'DAILY_LOGIN',
                'description'  => 'Login setiap hari untuk menjaga streak',
                'target_value' => 1,
                'xp_reward'    => 15,
                'is_active'    => true,
                'stages'       => null,
            ],
            [
                'task_name'    => 'Level Climber',
                'task_type'    => 'FINISH_LESSONS',
                'description'  => 'Selesaikan level quiz hari ini',
                'target_value' => 1,
                'xp_reward'    => 50,
                'is_active'    => true,
                'stages'       => null,
            ],
            [
                'task_name'    => 'Lab Alchemist',
                'task_type'    => 'LAB_EXPERIMENT',
                'description'  => 'Lakukan eksperimen di Virtual Lab',
                'target_value' => 1,
                'xp_reward'    => 60,
                'is_active'    => true,
                'stages'       => null,
            ],
        ];

        foreach ($tasks as $task) {
            DailyTask::create($task);
        }

        echo count($tasks) . " task templates seeded successfully!\n";
    }
}
