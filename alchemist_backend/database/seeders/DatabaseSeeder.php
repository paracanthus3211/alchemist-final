<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Hapus akun yang mungkin sudah ada agar tidak duplikat
        User::whereIn('email', ['admin@alchemist.com', 'user@alchemist.com'])->delete();

        // 1. Akun Admin
        // NOTE: password cast 'hashed' on User model handles bcrypt automatically
        User::create([
            'username'         => 'admin',
            'email'            => 'admin@alchemist.com',
            'password'         => 'password',   // cast 'hashed' will bcrypt this
            'role'             => 'ADMIN',
            'xp'               => 9999,
            'streak_count'     => 30,
            'profile_bg_color' => '#00897B',
        ]);

        // 2. Akun User biasa
        User::create([
            'username'         => 'Paracanthus',
            'email'            => 'user@alchemist.com',
            'password'         => 'password',   // cast 'hashed' will bcrypt this
            'role'             => 'USER',
            'xp'               => 550,
            'streak_count'     => 3,
            'profile_bg_color' => '#1565C0',
        ]);

        // 3. Curriculum & task data
        $this->call([
            CurriculumSeeder::class,
            DailyTaskSeeder::class,
            UserSeeder::class,
            ArticleAndProgressSeeder::class,
        ]);
    }
}
