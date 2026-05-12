<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Cleanup existing dummy users to avoid duplicate email errors
        $emails = [
            'neon@example.com', 'quantum@example.com', 'atomic@example.com', 
            'chem@example.com', 'lab@example.com', 'molecule@example.com', 
            'reactive@example.com', 'catalyst@example.com', 'isotope@example.com', 
            'electron@example.com'
        ];
        User::whereIn('email', $emails)->delete();

        $players = [
            ['username' => 'NeonAlchemist', 'email' => 'neon@example.com'],
            ['username' => 'QuantumWizard', 'email' => 'quantum@example.com'],
            ['username' => 'AtomicBrain', 'email' => 'atomic@example.com'],
            ['username' => 'ChemicalPro', 'email' => 'chem@example.com'],
            ['username' => 'LabExplorer', 'email' => 'lab@example.com'],
            ['username' => 'MoleculeKing', 'email' => 'molecule@example.com'],
            ['username' => 'ReactiveMind', 'email' => 'reactive@example.com'],
            ['username' => 'CatalystX', 'email' => 'catalyst@example.com'],
            ['username' => 'IsotopeMaster', 'email' => 'isotope@example.com'],
            ['username' => 'ElectronFlow', 'email' => 'electron@example.com'],
        ];

        foreach ($players as $player) {
            $userXp = rand(500, 3000);
            $user = User::create([
                'username' => $player['username'],
                'email'    => $player['email'],
                'password' => 'password', // Default password
                'role'     => 'USER',
                'xp'       => $userXp,
                'streak_count' => rand(1, 15),
            ]);

            // Add random transactions so they show up in weekly/monthly leaderboards
            // We'll split the total XP into a few transactions in the last 7 days
            $remainingXp = $userXp;
            $numTransactions = rand(3, 8);
            
            for ($i = 0; $i < $numTransactions; $i++) {
                $amount = ($i == $numTransactions - 1) ? $remainingXp : rand(50, floor($remainingXp / 2) + 1);
                if ($amount <= 0) break;
                
                DB::table('xp_transactions')->insert([
                    'user_id' => $user->id,
                    'source_type' => 'seed_data',
                    'xp_amount' => $amount,
                    'created_at' => now()->subDays(rand(0, 10)),
                    'updated_at' => now(),
                ]);
                $remainingXp -= $amount;
            }
        }
    }
}
