@extends('layouts.app')

@section('title', 'Rank — Alchemist')

@push('styles')
    <style>
        :root {
            --rank-teal: #082d32;
            --rank-teal-light: #0d4a52;
            --podium-bg: #151a1a;
            --podium-top: #1c2222;
        }

        .rank-container {
            max-width: 680px; margin: 0 auto; display: flex; flex-direction: column;
            align-items: center;
        }

        /* ── HEADER & TABS ── */
        .header-label { font-size: 10px; font-weight: 700; letter-spacing: 0.15em; color: var(--cyan); text-transform: uppercase; margin-bottom: 8px; }
        .header-title { font-size: 28px; font-weight: 700; color: #fff; margin-bottom: 24px; font-family: 'Space Grotesk', sans-serif; }

        .time-tabs {
            display: flex; background: rgba(255,255,255,0.03); border-radius: 99px;
            padding: 4px; margin-bottom: 20px; border: 1px solid var(--border);
        }
        .time-tab {
            padding: 8px 24px; font-size: 11px; font-weight: 600; color: var(--muted);
            border-radius: 99px; cursor: pointer; text-transform: uppercase; letter-spacing: 0.05em;
            transition: 0.2s;
        }
        .time-tab.active { background: var(--rank-teal-light); color: var(--cyan); }

        .scope-tabs {
            display: flex; gap: 32px; margin-bottom: 32px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px; width: 300px; justify-content: center;
        }
        .scope-tab {
            font-size: 13px; font-weight: 600; color: var(--muted); cursor: pointer;
            text-transform: uppercase; letter-spacing: 0.05em; position: relative;
        }
        .scope-tab.active { color: var(--cyan); }
        .scope-tab.active::after {
            content: ''; position: absolute; bottom: -11px; left: 0; right: 0; height: 2px; background: var(--cyan);
        }

        /* ── MY RANK CARD ── */
        .my-rank-card {
            width: 100%; background: #0b3c43;
            border-radius: 16px; padding: 24px; display: flex; align-items: center; gap: 24px;
            margin-bottom: 60px;
            box-shadow: 0 6px 0 #05262a;
            cursor: pointer;
            transition: transform 0.05s, box-shadow 0.05s;
        }
        .my-rank-card:active {
            transform: translateY(6px);
            box-shadow: none !important;
        }
        
        .my-rank-badge-wrap {
            flex-shrink: 0;
            width: 76px; height: 86px;
            display: flex; align-items: center; justify-content: center;
        }

        .my-rank-content { flex: 1; display: flex; flex-direction: column; gap: 12px; }
        .my-rank-top { display: flex; justify-content: space-between; align-items: flex-end; }
        
        .my-details .my-name { font-size: 22px; font-weight: 500; color: #fff; font-family: 'Space Grotesk', sans-serif; letter-spacing: 0.02em; }
        .my-details .my-level { font-size: 11px; color: rgba(255,255,255,0.7); margin-top: 4px; letter-spacing: 0.02em; }

        .my-xp { font-size: 22px; font-weight: 500; font-family: 'Space Grotesk', sans-serif; }

        .my-progress-bar { width: 100%; height: 10px; background: rgba(255,255,255,0.15); border-radius: 99px; overflow: hidden; }
        .my-progress-fill { height: 100%; border-radius: 99px; transition: width 0.4s ease; }
        .my-progress-text { font-size: 10px; color: rgba(255,255,255,0.6); text-align: center; margin-top: 8px; }

        /* ── PODIUM ── */
        .podium-section {
            display: flex; align-items: flex-end; justify-content: center;
            margin-bottom: 40px; height: 320px; position: relative;
        }
        .podium-stairs-bg {
            position: absolute; bottom: 0; left: 50%; transform: translateX(-50%);
            width: 100%; max-width: 420px; object-fit: contain; z-index: 0;
        }
        
        .podium-box-wrap {
            display: flex; flex-direction: column; align-items: center; position: relative;
            z-index: 1; width: 110px;
        }

        .podium-avatar-wrap {
            position: relative; margin-bottom: 12px; display: flex; flex-direction: column; align-items: center;
        }
        
        .podium-avatar {
            border-radius: 50%; object-fit: cover;
            border: 4px solid; padding: 4px; background: var(--bg);
        }
        
        /* Rank 1 */
        .podium-rank-1 .podium-avatar { width: 80px; height: 80px; border-color: var(--lime); box-shadow: 0 0 20px rgba(184, 244, 0, 0.4); }
        /* Rank 2 */
        .podium-rank-2 .podium-avatar { width: 70px; height: 70px; border-color: #d896ff; box-shadow: 0 0 20px rgba(216, 150, 255, 0.3); }
        /* Rank 3 */
        .podium-rank-3 .podium-avatar { width: 70px; height: 70px; border-color: var(--cyan); box-shadow: 0 0 20px rgba(0, 212, 212, 0.3); }

        .podium-crown { position: absolute; top: -44px; width: 64px; height: 64px; display: flex; align-items: center; justify-content: center; z-index: 2; }
        .podium-crown img { width: 58px; height: 58px; }
        
        .podium-badge {
            position: absolute; bottom: 30px; right: -5px; width: 24px; height: 24px;
            background: linear-gradient(135deg, #FFD700, #DAA520);
            clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
            display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 900; color: #000;
        }

        .podium-name { font-size: 13px; font-weight: 700; color: #fff; margin-top: 8px; text-align: center; }
        .podium-xp { font-size: 11px; font-weight: 600; margin-top: 2px; }
        .podium-rank-1 .podium-xp { color: var(--lime); }
        .podium-rank-2 .podium-xp { color: #d896ff; }
        .podium-rank-3 .podium-xp { color: var(--cyan); }

        .podium-rank-2 { padding-bottom: 130px; }
        .podium-rank-1 { padding-bottom: 190px; z-index: 2; margin: 0 10px; }
        .podium-rank-3 { padding-bottom: 110px; }


        /* ── RANK LIST ── */
        .rank-list-wrap {
            width: 100%; background: #0c1112; border-radius: 20px;
            padding: 24px; border: 1px solid var(--border);
        }

        .rank-list-item {
            display: flex; align-items: center; gap: 20px;
            padding: 16px 20px; border-radius: 12px;
            margin-bottom: 12px; background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.03);
            transition: 0.2s;
        }
        .rank-list-item:hover { background: rgba(255,255,255,0.05); }
        .rank-list-item.is-me {
            background: linear-gradient(90deg, var(--rank-teal-light) 0%, var(--rank-teal) 100%);
            border-color: rgba(0,212,212,0.3);
        }

        .list-rank-num { font-size: 20px; font-weight: 600; color: rgba(255,255,255,0.7); width: 28px; text-align: center; }
        .list-avatar-wrap { position: relative; width: 44px; height: 44px; }
        .list-avatar { width: 100%; height: 100%; border-radius: 50%; object-fit: cover; background: #2a3a3a; }
        .list-badge {
            position: absolute; bottom: -4px; right: -4px; width: 20px; height: 20px;
            background: linear-gradient(135deg, #FFD700, #DAA520);
            clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
            display: flex; align-items: center; justify-content: center; font-size: 8px; font-weight: 900; color: #000;
        }

        .list-details { flex: 1; }
        .list-name { font-size: 15px; font-weight: 600; color: #fff; }
        .list-level { font-size: 12px; color: rgba(255,255,255,0.5); margin-top: 2px; }

        .list-xp { font-size: 14px; font-weight: 700; color: var(--cyan); text-align: right; }
        .list-xp span { font-size: 10px; font-weight: 500; opacity: 0.7; }
        
    </style>
@endpush

@section('content')
<div class="rank-container">
    
    <div class="header-label">Laboratory Leaderboard</div>
    <div class="header-title">Alchemy Rank</div>

    <div class="time-tabs">
        <a href="{{ route('rank', ['period' => 'week', 'scope' => $scope]) }}" class="time-tab {{ $period === 'week' ? 'active' : '' }}" style="text-decoration:none;">This Week</a>
        <a href="{{ route('rank', ['period' => 'month', 'scope' => $scope]) }}" class="time-tab {{ $period === 'month' ? 'active' : '' }}" style="text-decoration:none;">This Month</a>
        <a href="{{ route('rank', ['period' => 'all', 'scope' => $scope]) }}" class="time-tab {{ $period === 'all' ? 'active' : '' }}" style="text-decoration:none;">All Time</a>
    </div>

    <div class="scope-tabs">
        <a href="{{ route('rank', ['period' => $period, 'scope' => 'global']) }}" class="scope-tab {{ $scope === 'global' ? 'active' : '' }}" style="text-decoration:none;">Global</a>
        <a href="{{ route('rank', ['period' => $period, 'scope' => 'friends']) }}" class="scope-tab {{ $scope === 'friends' ? 'active' : '' }}" style="text-decoration:none;">Friend</a>
    </div>

    <!-- MY RANK CARD -->
    <a href="{{ route('ranks.index') }}" class="my-rank-card" style="text-decoration:none; color:inherit; display:flex;">
        <div class="my-rank-badge-wrap">
            @php
                // Get selected rank or default to Novice
                $displayRank = null;
                if ($user->selected_rank_id) {
                    $displayRank = $user->selectedRank;
                }
                
                // If no selected rank, auto-detect by XP or default to Novice
                if (!$displayRank) {
                    $userXp = $user->xp ?? 0;
                    $displayRank = \App\Models\Rank::where('xp_threshold', '<=', $userXp)
                        ->orderByDesc('xp_threshold')
                        ->first();
                    
                    // If still no rank, get Novice as default
                    if (!$displayRank) {
                        $displayRank = \App\Models\Rank::where('name', 'Novice')->first();
                    }
                }
            @endphp
            
            @if($displayRank && $displayRank->icon_url)
                <img src="{{ $displayRank->icon_url }}" style="width:100%; height:100%; object-fit:contain;" alt="{{ $displayRank->name }}">
            @else
                <svg width="76" height="86" viewBox="0 0 100 115" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M50 2 L98 22 L98 82 L50 113 L2 82 L2 22 Z" fill="#d3aa4e" stroke="#fae188" stroke-width="4"/>
                    <path d="M50 8 L90 25 L90 78 L50 104 L10 78 L10 25 Z" stroke="#8c6a2b" stroke-width="2"/>
                    <g stroke="#3e2a0b" stroke-width="3" fill="none">
                        <ellipse cx="50" cy="55" rx="15" ry="30" transform="rotate(45 50 55)"/>
                        <ellipse cx="50" cy="55" rx="15" ry="30" transform="rotate(-45 50 55)"/>
                        <ellipse cx="50" cy="55" rx="30" ry="10" />
                        <path d="M42 45 L58 45 L62 70 L38 70 Z" fill="#3e2a0b" />
                    </g>
                </svg>
            @endif
        </div>
        <div class="my-rank-content">
            <div class="my-rank-top">
                <div class="my-details">
                    <div class="my-name">{{ $user->username ?? $user->name }}</div>
                    <div class="my-level">{{ $userChapterLabel }}</div>
                </div>
                <div class="my-xp" style="color: {{ $user->profile_bg_color ?? 'var(--cyan)' }}">{{ number_format($currentUserXp) }} XP</div>
            </div>
            <div>
                <div class="my-progress-bar">
                    <div class="my-progress-fill" style="background-color: {{ $user->profile_bg_color ?? 'var(--cyan)' }}; width: {{ $rankProgressPct }}%;"></div>
                </div>
                @if($nextRankName)
                    <div class="my-progress-text">{{ number_format($user->xp) }}/{{ number_format($nextRankXp) }} XP towards <strong>{{ $nextRankName }}</strong></div>
                @else
                    <div class="my-progress-text">{{ number_format($user->xp) }} XP — Max Rank Achieved 🏆</div>
                @endif
            </div>
        </div>
    </a>

    <!-- PODIUM -->
    @if($top3->count() >= 3)
    <div class="podium-section">
        <img src="{{ asset('images/rank_stair.png') }}" class="podium-stairs-bg" alt="Podium Stairs">
        
        <!-- Rank 2 (Left) -->
        @php $rank2 = $top3->values()->get(1); @endphp
        <div class="podium-box-wrap podium-rank-2">
            <div class="podium-avatar-wrap">
                <img src="{{ $rank2->equippedAvatar->image_url ?? $rank2->avatar_url ?? '/images/chapter.png' }}" class="podium-avatar">
            </div>
            <div class="podium-name">{{ $rank2->username }}</div>
            <div class="podium-xp">{{ number_format($rank2->xp) }} XP</div>
        </div>

        <!-- Rank 1 (Center) -->
        @php $rank1 = $top3->values()->get(0); @endphp
        <div class="podium-box-wrap podium-rank-1">
            <div class="podium-avatar-wrap">
                <div class="podium-crown">
                    <img src="{{ asset('images/rank_crown.png') }}" alt="Crown" style="width:28px; height:28px; object-fit:contain;">
                </div>
                <img src="{{ $rank1->equippedAvatar->image_url ?? $rank1->avatar_url ?? '/images/chapter.png' }}" class="podium-avatar">
            </div>
            <div class="podium-name">{{ $rank1->username }}</div>
            <div class="podium-xp">{{ number_format($rank1->xp) }} XP</div>
        </div>

        <!-- Rank 3 (Right) -->
        @php $rank3 = $top3->values()->get(2); @endphp
        <div class="podium-box-wrap podium-rank-3">
            <div class="podium-avatar-wrap">
                <img src="{{ $rank3->equippedAvatar->image_url ?? $rank3->avatar_url ?? '/images/chapter.png' }}" class="podium-avatar">
            </div>
            <div class="podium-name">{{ $rank3->username }}</div>
            <div class="podium-xp">{{ number_format($rank3->xp) }} XP</div>
        </div>

    </div>
    @endif

    <!-- RANK LIST -->
    <div class="rank-list-wrap">
        @php $currentRankNum = 4; @endphp
        @foreach($rest as $rUser)
            @php
                // Get current rank for this user
                $userCurrentRank = null;
                if ($rUser->selected_rank_id) {
                    $userCurrentRank = $rUser->selectedRank;
                }
                
                // If no selected rank, auto-detect by XP
                if (!$userCurrentRank) {
                    $userXp = $rUser->xp ?? 0;
                    $userCurrentRank = \App\Models\Rank::where('xp_threshold', '<=', $userXp)
                        ->orderByDesc('xp_threshold')
                        ->first();
                    
                    // If still no rank, get Novice as default
                    if (!$userCurrentRank) {
                        $userCurrentRank = \App\Models\Rank::where('name', 'Novice')->first();
                    }
                }
            @endphp
            <div class="rank-list-item {{ $rUser->id == $user->id ? 'is-me' : '' }}"
                 style="cursor:pointer;" onclick="window.location.href='{{ $rUser->id == $user->id ? route('profile') : route('profile.show', $rUser->id) }}'">
                <div class="list-rank-num">{{ $currentRankNum }}</div>
                <div class="list-avatar-wrap">
                    <img src="{{ $rUser->equippedAvatar->image_url ?? $rUser->avatar_url ?? '/images/chapter.png' }}" class="list-avatar">
                    @if($userCurrentRank && $userCurrentRank->icon_url)
                        <div style="position:absolute; bottom:4px; right:-6px; width:20px; height:22px;">
                            <img src="{{ $userCurrentRank->icon_url }}" alt="{{ $userCurrentRank->name }}"
                                 style="width:100%; height:100%; object-fit:contain; filter:drop-shadow(0 0 4px rgba(211,170,78,0.5));">
                        </div>
                    @else
                        <div class="list-badge">
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="#000"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/></svg>
                        </div>
                    @endif
                </div>
                <div class="list-details">
                    <div class="list-name">{{ $rUser->username }}</div>
                    <div class="list-level">{{ $userCurrentRank ? $userCurrentRank->name : 'Novice' }}</div>
                </div>
                <div class="list-xp">{{ number_format($rUser->xp) }} <br><span>XP</span></div>
            </div>
            @php $currentRankNum++; @endphp
        @endforeach
        
        @if($rest->isEmpty() && $top3->count() < 4)
            <div style="text-align:center; color:rgba(255,255,255,0.4); padding: 20px;">No more users to display.</div>
        @endif
    </div>

</div>
@endsection

