<?php

// Assign random XP and friends to users
$users = App\Models\User::all();

foreach ($users as $user) {
    // Generate some xp transactions for 'week'
    $xpWeek = rand(100, 1000);
    \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
        'user_id' => $user->id,
        'source_type' => 'test',
        'xp_amount' => $xpWeek,
        'created_at' => now()->subDays(rand(1, 6)),
        'updated_at' => now()->subDays(rand(1, 6)),
    ]);

    // Generate some xp transactions for 'month' (older than a week)
    $xpMonth = rand(500, 2000);
    \Illuminate\Support\Facades\DB::table('xp_transactions')->insert([
        'user_id' => $user->id,
        'source_type' => 'test',
        'xp_amount' => $xpMonth,
        'created_at' => now()->subDays(rand(8, 28)),
        'updated_at' => now()->subDays(rand(8, 28)),
    ]);

    // Update total XP
    $user->xp = $xpWeek + $xpMonth;
    $user->save();
}

// Add some friends to 'admin' (assuming id 1 is admin or current user)
$admin = App\Models\User::where('username', 'admin')->first();
if ($admin) {
    $others = App\Models\User::where('id', '!=', $admin->id)->take(5)->get();
    foreach ($others as $other) {
        \Illuminate\Support\Facades\DB::table('friends')->insertOrIgnore([
            'user_id' => $admin->id,
            'friend_id' => $other->id,
            'status' => 'accepted',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}

echo "Dummy XP and Friends generated successfully.\n";
