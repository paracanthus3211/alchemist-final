<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Create Admin User
        User::factory()->create([
            'username' => 'admin',
            'email' => 'admin@alchemist.com',
            'password' => 'password',
            'role' => 'ADMIN',
        ]);

        // 2. Create Regular User
        User::factory()->create([
            'username' => 'user',
            'email' => 'user@alchemist.com',
            'password' => 'password',
            'role' => 'USER',
        ]);

        // 3. Call Curriculum Seeder
        $this->call([
            CurriculumSeeder::class,
        ]);
    }
}
