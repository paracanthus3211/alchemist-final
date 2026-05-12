<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== RANKS SAAT INI ===\n";
$ranks = \App\Models\Rank::orderBy('xp_threshold')->get(['id','name','xp_threshold']);
foreach ($ranks as $r) {
    echo "ID:{$r->id} | {$r->name} | threshold: {$r->xp_threshold}\n";
}

echo "\n=== USER XP ===\n";
$users = \App\Models\User::select('id','username','xp','selected_rank_id')->get();
foreach ($users as $u) {
    echo "ID:{$u->id} | {$u->username} | xp:{$u->xp} | selected_rank_id:{$u->selected_rank_id}\n";
}

echo "\nDone.\n";
