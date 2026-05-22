<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Article;
use App\Models\Question;
use App\Models\UserQuestionAttempt;
use Illuminate\Support\Facades\DB;

class ArticleAndProgressSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create a beautiful article
        $article = Article::create([
            'title' => 'Misteri Struktur Inti Atom',
            'description' => 'Pelajari bagaimana para ilmuwan memecahkan misteri inti atom dan menemukan partikel penyusunnya.',
            'category' => 'ATOM',
            'difficulty_level' => 'BEGINNER',
            'thumbnail_url' => 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?auto=format&fit=crop&w=600&q=80',
        ]);

        $article->contents()->create([
            'type' => 'text',
            'content' => 'Inti atom adalah pusat dari atom yang sangat padat dan bermuatan positif. Di dalam inti atom terdapat proton yang bermuatan positif dan neutron yang netral. Penemuan inti atom diawali oleh eksperimen lembaran emas Ernest Rutherford pada tahun 1911 yang membuktikan bahwa sebagian besar massa atom terpusat pada inti yang sangat kecil.',
            'order_index' => 0,
        ]);

        // 2. Add question attempts for admin (User ID: 1) to make everything complete
        $admin = User::find(1);
        if ($admin) {
            $questions = Question::all();
            foreach ($questions as $q) {
                UserQuestionAttempt::updateOrCreate(
                    [
                        'user_id' => $admin->id,
                        'question_id' => $q->id,
                    ],
                    [
                        'is_correct' => true,
                        'xp_earned' => $q->xp_reward,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]
                );

                // Add XP transaction
                DB::table('xp_transactions')->updateOrInsert(
                    [
                        'user_id' => $admin->id,
                        'source_type' => 'question',
                        'source_id' => $q->id,
                    ],
                    [
                        'xp_amount' => $q->xp_reward,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]
                );
            }

            // Mark the article as in-progress or read in history
            DB::table('user_article_history')->updateOrInsert(
                [
                    'user_id' => $admin->id,
                    'article_id' => $article->id,
                ],
                [
                    'completed_at' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }

        // 3. Add progress for Paracanthus (User ID: 2) as well
        $user = User::find(2);
        if ($user) {
            $questions = Question::all();
            foreach ($questions as $q) {
                if ($q->level_id == 1 && $q->order_index == 1) {
                    UserQuestionAttempt::updateOrCreate(
                        [
                            'user_id' => $user->id,
                            'question_id' => $q->id,
                        ],
                        [
                            'is_correct' => true,
                            'xp_earned' => $q->xp_reward,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]
                    );
                }
            }
        }
    }
}
