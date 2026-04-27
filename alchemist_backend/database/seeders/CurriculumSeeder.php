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
        // 1. Create Chapter
        $chapter = Chapter::create([
            'title'         => 'Pengenalan Atom',
            'icon_emoji'    => '⚛️',
            'xp_threshold'  => 0,
            'order_index'   => 1,
        ]);

        // 2. Create Levels
        $level1 = Level::create([
            'chapter_id'  => $chapter->id,
            'name'        => 'Struktur Inti Atom',
            'xp_required' => 0,
            'order_index' => 1,
        ]);

        Level::create([
            'chapter_id'  => $chapter->id,
            'name'        => 'Konfigurasi Elektron',
            'xp_required' => 150,
            'order_index' => 2,
        ]);

        // 3. Create Questions for Level 1
        Question::create([
            'level_id'      => $level1->id,
            'type'          => 'MULTIPLE_CHOICE',
            'question_text' => 'Partikel bermuatan positif dalam inti atom disebut...',
            'explanation'   => 'Proton adalah partikel penyusun inti atom yang memiliki muatan listrik positif.',
            'xp_reward'     => 20,
            'order_index'   => 1,
        ]);

        $qLab = Question::create([
            'level_id'      => $level1->id,
            'type'          => 'LAB_PRACTICE',
            'question_text' => 'Lakukan eksperimen pencampuran Asam Klorida (HCl) dan Natrium Hidroksida (NaOH)! Apa yang kamu amati?',
            'explanation'   => 'Reaksi antara asam kuat (HCl) dan basa kuat (NaOH) adalah reaksi netralisasi yang menghasilkan garam (NaCl) dan air (H2O).',
            'xp_reward'     => 50,
            'order_index'   => 3,
        ]);

        \App\Models\LabPracticeConfig::create([
            'question_id' => $qLab->id,
            'beaker_a_chemical' => 'hcl',
            'beaker_b_chemical' => 'naoh',
            'expected_visual_result' => '💧 Larutan menjadi bening dan melepaskan panas (Sedikit Hangat)',
            'expected_reaction_equation' => 'HCl + NaOH -> NaCl + H2O',
        ]);

        $options = [
            ['label' => 'A', 'text' => 'Terbentuk gas beracun', 'correct' => false],
            ['label' => 'B', 'text' => 'Larutan menjadi bening dan hangat', 'correct' => true],
            ['label' => 'C', 'text' => 'Terbentuk endapan berwarna merah', 'correct' => false],
            ['label' => 'D', 'text' => 'Tidak terjadi reaksi apapun', 'correct' => false],
        ];

        foreach ($options as $opt) {
            \App\Models\MultipleChoiceOption::create([
                'question_id' => $qLab->id,
                'option_label' => $opt['label'],
                'option_text' => $opt['text'],
                'is_correct' => $opt['correct'],
            ]);
        }

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
