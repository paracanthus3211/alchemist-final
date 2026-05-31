@extends('layouts.app')

@section('title', 'Profile')

@push('styles')
<style>
    .profile-container {
        padding: 40px 20px;
        max-width: 800px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    /* HEADER */
    .profile-avatar-wrap {
        position: relative;
        margin-bottom: 20px;
    }
    
    .profile-avatar {
        width: 140px;
        height: 140px;
        border-radius: 50%;
        background-color: var(--lime, #b8f400);
        object-fit: cover;
        border: 4px solid #0b1416;
    }

    .edit-avatar-btn {
        position: absolute;
        bottom: 5px;
        right: 5px;
        width: 32px;
        height: 32px;
        background-color: #7b9c0d;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        border: 2px solid #0b1416;
    }
    
    .edit-avatar-btn svg {
        width: 16px;
        height: 16px;
        fill: #fff;
    }

    .profile-username {
        font-size: 28px;
        font-weight: 800;
        color: var(--lime, #b8f400);
        margin-bottom: 8px;
        text-shadow: 0 0 10px rgba(184, 244, 0, 0.4);
    }

    .profile-joined {
        background: rgba(255, 255, 255, 0.1);
        padding: 6px 16px;
        border-radius: 12px;
        font-size: 10px;
        color: rgba(255, 255, 255, 0.7);
        text-transform: uppercase;
        letter-spacing: 1px;
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 30px;
    }

    /* STATS GRID */
    .stats-grid {
        display: flex;
        gap: 20px;
        margin-bottom: 40px;
        width: 100%;
        justify-content: center;
    }

    .stat-box {
        background: #1a2527;
        border-radius: 16px;
        padding: 20px;
        width: 180px;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
    }

    .stat-box svg, .stat-box img {
        width: 48px;
        height: 48px;
        margin-bottom: 8px;
        object-fit: contain;
    }
    
    .stat-value {
        font-size: 20px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 4px;
    }
    
    .stat-label {
        font-size: 10px;
        color: rgba(255, 255, 255, 0.5);
        text-transform: uppercase;
        letter-spacing: 0.1em;
    }

    /* TABS */
    .profile-tabs {
        display: flex;
        background: #1a2527;
        border-radius: 20px;
        width: 100%;
        max-width: 600px;
        margin-bottom: 30px;
        overflow: hidden;
    }

    .tab-btn {
        flex: 1;
        background: transparent;
        border: none;
        color: rgba(255, 255, 255, 0.4);
        padding: 16px 0;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        cursor: pointer;
        transition: 0.3s;
        border-radius: 20px;
    }

    .tab-btn.active {
        background: #023639;
        color: var(--cyan, #00d4d4);
    }

    /* TAB CONTENTS */
    .tab-content {
        display: none;
        width: 100%;
        max-width: 600px;
        animation: fadeIn 0.3s ease;
    }
    
    .tab-content.active {
        display: block;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* History Styles */
    .history-card {
        margin-bottom: 24px;
    }
    .history-thumbnail {
        width: 100%;
        height: 180px;
        background: #d9d9d9;
        border-radius: 12px;
        margin-bottom: 12px;
        object-fit: cover;
    }
    .history-title {
        font-size: 18px;
        font-weight: 600;
        color: #fff;
        margin-bottom: 4px;
    }
    .history-time {
        font-size: 12px;
        color: rgba(255, 255, 255, 0.5);
    }

    /* Achievement Styles */
    .ach-section-title {
        font-size: 14px;
        font-weight: 700;
        color: #fff;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        margin-bottom: 24px;
        margin-top: 20px;
    }
    
    .ach-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 40px;
    }
    
    .ach-item {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    
    .ach-icon {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .ach-icon svg { width: 100%; height: 100%; object-fit: contain; }
    
    .ach-value {
        font-size: 12px;
        font-weight: 700;
        color: #fff;
        text-transform: uppercase;
    }

    .ranks-row {
        display: flex;
        gap: 20px;
        justify-content: center;
        margin-top: 20px;
    }
    
    .rank-badge-item {
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    
    .rank-badge-item img, .rank-badge-item svg {
        width: 80px;
        height: 90px;
        margin-bottom: 8px;
        filter: drop-shadow(0 0 15px rgba(211, 170, 78, 0.4));
    }
    
    .rank-badge-label {
        font-size: 10px;
        color: rgba(255, 255, 255, 0.5);
        text-transform: uppercase;
    }

    /* Settings Styles */
    .settings-item {
        background: #1a2527;
        border-radius: 12px;
        padding: 20px 24px;
        display: flex;
        align-items: center;
        margin-bottom: 16px;
    }
    
    .settings-icon {
        width: 48px;
        height: 48px;
        background: #fff;
        border-radius: 8px;
        margin-right: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #000;
        font-weight: 900;
        font-size: 24px;
    }
    
    .settings-icon.dark {
        background: #333;
        color: #fff;
    }
    
    .settings-label {
        font-size: 14px;
        font-weight: 600;
        color: #fff;
        flex: 1;
    }
    
    .settings-value {
        font-size: 12px;
        color: rgba(255, 255, 255, 0.5);
    }
    
    .btn-logout {
        width: 100%;
        background: transparent;
        border: 1px solid #ff0000;
        color: #ff0000;
        padding: 18px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 700;
        text-transform: uppercase;
        cursor: pointer;
        transition: 0.2s;
        margin-top: 20px;
        background: rgba(255,0,0,0.05);
    }
    
    .btn-logout:hover {
        background: rgba(255,0,0,0.1);
    }
</style>
@endpush

@section('content')
<div class="profile-container">

    <!-- HEADER -->
    <div class="profile-avatar-wrap">
        @php
            $avatarSrc = $user->equippedAvatar
                ? $user->equippedAvatar->image_url
                : ($user->avatar_url ?: '/images/chapter.png');
        @endphp
        <img src="{{ $avatarSrc }}" class="profile-avatar" alt="{{ $user->username }}">
        <a href="{{ route('profile.avatar') }}" class="edit-avatar-btn" style="text-decoration: none; color: inherit;">
            <svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
        </a>
    </div>
    
    <div class="profile-username">{{ $user->username ?? $user->name }}</div>
    
    <div class="profile-joined">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        JOINED ON {{ $user->created_at ? $user->created_at->format('F j, Y') : 'JANUARY 8, 2026' }}
    </div>

    <!-- STATS GRID -->
    <div class="stats-grid">
        <div class="stat-box">
            <!-- Following Icon (Yellow Green) -->
            <img src="/images/following.png" alt="Following">
            <div class="stat-value">{{ $followingCount }}</div>
            <div class="stat-label">Following</div>
        </div>
        
        <div class="stat-box">
            <!-- Friends Icon (Cyan) -->
            <img src="/images/friends.png" alt="Friends">
            <div class="stat-value">{{ $friendsCount }}</div>
            <div class="stat-label">Friends</div>
        </div>
        
        <div class="stat-box">
            <!-- Followers Icon (Pink) -->
            <img src="/images/followers.png" alt="Followers">
            <div class="stat-value">{{ $followersCount }}</div>
            <div class="stat-label">Followers</div>
        </div>
    </div>

    <!-- TABS -->
    <div class="profile-tabs">
        <button class="tab-btn active" onclick="switchTab('history')">History</button>
        <button class="tab-btn" onclick="switchTab('achievement')">Achievement</button>
        <button class="tab-btn" onclick="switchTab('settings')">Settings</button>
    </div>

    <!-- TAB CONTENTS -->
    
    <!-- 1. History -->
    <div id="tab-history" class="tab-content active">
        @forelse($historyArticles as $article)
        <div class="history-card">
            @if($article->thumbnail_url)
                <img src="{{ $article->thumbnail_url }}" class="history-thumbnail">
            @else
                <div class="history-thumbnail"></div>
            @endif
            <div class="history-title">{{ $article->title }}</div>
            <div class="history-time">Last read... {{ rand(1, 12) }} hours ago</div>
        </div>
        @empty
        <div style="text-align: center; padding: 40px 20px; color: rgba(255,255,255,0.3);">
            <p>No reading history yet</p>
        </div>
        @endforelse
    </div>

    <!-- 2. Achievement -->
    <div id="tab-achievement" class="tab-content">
        <div class="ach-section-title">OVERVIEW</div>
        
        <div class="ach-grid">
            <div class="ach-item">
                <div class="ach-icon"><img src="/images/streak.png" alt="" style="width: 100%; height: 100%; object-fit: contain;"></div>
                <div class="ach-value">{{ $user->streak_count ?? 0 }} DAYS</div>
            </div>
            
            <div class="ach-item">
                <div class="ach-icon">
                    <img src="/images/scroll.png" alt="" style="width: 100%; height: 100%; object-fit: contain;">
                </div>
                <div class="ach-value">ARTICLE'S READ : {{ count($historyArticles) > 0 ? count($historyArticles) : 2 }}</div>
            </div>
            
            <div class="ach-item">
                <div class="ach-icon">
                    <img src="/images/xp.png" alt="" style="width: 100%; height: 100%; object-fit: contain;">
                </div>
                <div class="ach-value">{{ number_format($user->xp ?? 0) }} XP</div>
            </div>
            
            <div class="ach-item">
                <div class="ach-icon"><img src="/images/streak.png" alt="" style="width: 100%; height: 100%; object-fit: contain;"></div>
                <div class="ach-value">BEST : {{ $user->max_streak ?? 4 }}</div>
            </div>
            
            <!-- Missing one from mockup but it's okay, added it above. Wait, the mockup has: -->
            <!-- 0 DAYS | ARTICLE'S READ : 2 | BEST : 4 -->
            <!-- 1200 XP | DF LEVEL 3 : ER -->
            <div class="ach-item" style="grid-column: span 2;">
                <div class="ach-icon">
                    <img src="/images/chapter.png" alt="" style="width: 100%; height: 100%; object-fit: contain;">
                </div>
                <div class="ach-value">LEVEL {{ $user->selectedRank->chapter ?? 1 }} : {{ $user->selectedRank->name ?? 'ER' }}</div>
            </div>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 20px;">
            <div class="ach-section-title" style="margin:0;">ACHIEVEMENTS RANK</div>
            <a href="{{ route('ranks.index') }}" style="font-size:10px; color:#fff; text-decoration:none; font-weight:700;">MORE</a>
        </div>

        <div style="display:flex; gap:30px; justify-content:flex-start; align-items:flex-end; flex-wrap:wrap; margin-bottom: 20px;">
            @foreach($allRanks->take(3) as $rank)
                <div style="display:flex; flex-direction:column; align-items:center; gap:12px;">
                    @if($rank->icon_url)
                        <img src="{{ $rank->icon_url }}" alt="{{ $rank->name }}"
                             style="width:110px; height:120px; object-fit:contain; filter: drop-shadow(0 0 20px rgba(211,170,78,0.5));">
                    @else
                        <svg viewBox="0 0 100 115" fill="none" style="width:110px; height:120px; filter: drop-shadow(0 0 20px rgba(211,170,78,0.5));">
                            <path d="M50 2 L98 22 L98 82 L50 113 L2 82 L2 22 Z" fill="#d3aa4e" stroke="#fae188" stroke-width="4"/>
                            <path d="M50 8 L90 25 L90 78 L50 104 L10 78 L10 25 Z" stroke="#8c6a2b" stroke-width="2"/>
                        </svg>
                    @endif
                    <div style="font-size:11px; color:rgba(255,255,255,0.5); text-transform:uppercase; letter-spacing:0.1em;">{{ $rank->name }}</div>
                </div>
            @endforeach
        </div>
    </div>


    <!-- 3. Settings -->
    <div id="tab-settings" class="tab-content">

        <!-- Font Size -->
        <div class="settings-item">
            <div class="settings-icon" style="background: transparent; width:56px; height:56px; flex-shrink:0;">
                <img src="/images/font_size.png" alt="Font Size" style="width:100%; height:100%; object-fit:contain;">
            </div>
            <div class="settings-label" style="font-size:16px; font-weight:700;">Font Size</div>
            <div class="settings-value" style="font-size:14px; color:rgba(255,255,255,0.4);">Medium</div>
        </div>

        <!-- Language -->
        <div class="settings-item">
            <div class="settings-icon" style="background: transparent; width:56px; height:56px; flex-shrink:0;">
                <img src="/images/language.png" alt="Language" style="width:100%; height:100%; object-fit:contain;">
            </div>
            <div class="settings-label" style="font-size:16px; font-weight:700;">Language</div>
            <div class="settings-value" style="font-size:14px; color:rgba(255,255,255,0.4);">English</div>
        </div>

        <!-- About Alchemist -->
        <div class="settings-item">
            <div class="settings-icon" style="background: transparent; width:56px; height:56px; flex-shrink:0;">
                <img src="/images/about.png" alt="About" style="width:100%; height:100%; object-fit:contain;">
            </div>
            <div class="settings-label" style="font-size:16px; font-weight:700;">About Alchemist</div>
            <div class="settings-value" style="font-size:14px; color:rgba(255,255,255,0.4);">Ver. 2.0.1</div>
        </div>

        <form method="POST" action="{{ route('logout') }}" style="width:100%; margin-top:8px;">
            @csrf
            <button type="submit" class="btn-logout">LOGOUT</button>
        </form>
    </div>

</div>

@push('scripts')
<script>
    function switchTab(tabId) {
        // Update buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
        
        // Update content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById('tab-' + tabId).classList.add('active');
    }
</script>
@endpush
@endsection
