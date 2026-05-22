<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Chapter;
use App\Models\Level;
use App\Models\Question;

class CurriculumSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1.5 Create Chapter 2 (asd)
        $chapter2 = Chapter::create([
            'title'         => 'asd',
            'icon_emoji'    => '#FF0055',
            'xp_threshold'  => 0,
            'order_index'   => 2,
        ]);

        // 2.5 Create Levels for Chapter 2
        $level2 = Level::create([
            'chapter_id'  => $chapter2->id,
            'name'        => 'rt',
            'xp_required' => 0,
            'order_index' => 1,
        ]);

        // 3.5 Create Questions for Chapter 2 Level "rt"
        Question::create([
            'level_id'      => $level2->id,
            'type'          => 'MULTIPLE_CHOICE',
            'question_text' => 'Dummy question for asd',
            'explanation'   => 'Explanation',
            'xp_reward'     => 5,
            'order_index'   => 1,
        ]);

        // 4. Create Ranks
        $ranks = [
            ['name' => 'Novice', 'xp_threshold' => 0, 'icon_url' => 'bronze'],
            ['name' => 'Apprentice', 'xp_threshold' => 500, 'icon_url' => 'silver'],
            ['name' => 'Adept', 'xp_threshold' => 1500, 'icon_url' => 'gold'],
            ['name' => 'Senior Researcher', 'xp_threshold' => 3000, 'icon_url' => 'cyan'],
            ['name' => 'Expert Chemist', 'xp_threshold' => 6000, 'icon_url' => 'lime'],
            ['name' => 'Grand Alchemist', 'xp_threshold' => 12000, 'icon_url' => 'neon'],
        ];

        foreach ($ranks as $rank) {
            \App\Models\Rank::create($rank);
        }
    }
}
