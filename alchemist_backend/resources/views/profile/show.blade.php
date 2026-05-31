@extends('layouts.app')

@section('title', $user->username . ' — Profile')

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

    .profile-avatar-wrap { position: relative; margin-bottom: 20px; }

    .profile-avatar {
        width: 140px; height: 140px; border-radius: 50%;
        background-color: var(--lime, #b8f400);
        object-fit: cover; border: 4px solid #0b1416;
    }

    .profile-username {
        font-size: 28px; font-weight: 800;
        color: var(--lime, #b8f400); margin-bottom: 8px;
        text-shadow: 0 0 10px rgba(184, 244, 0, 0.4);
    }

    .profile-joined {
        background: rgba(255,255,255,0.1); padding: 6px 16px;
        border-radius: 12px; font-size: 10px; color: rgba(255,255,255,0.7);
        text-transform: uppercase; letter-spacing: 1px;
        display: flex; align-items: center; gap: 6px; margin-bottom: 20px;
    }

    /* Friend button */
    .friend-action-wrap { margin-bottom: 24px; display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }

    .btn-friend {
        padding: 10px 28px; border-radius: 12px; font-size: 13px;
        font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase;
        cursor: pointer; border: none; transition: opacity 0.2s;
    }
    .btn-friend:hover { opacity: 0.85; }
    .btn-friend.add    { background: var(--cyan, #00d4d4); color: #031415; }
    .btn-friend.pending { background: #1a2527; color: rgba(255,255,255,0.5); cursor: default; }
    .btn-friend.friends { background: #1a2527; color: var(--cyan, #00d4d4); }
    .btn-friend.accept  { background: var(--lime, #b8f400); color: #031415; }
    .btn-follow { padding: 10px 28px; border-radius: 12px; font-size: 13px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; cursor: pointer; border: none; transition: opacity 0.2s; }
    .btn-follow.follow { background: var(--lime, #b8f400); color: #031415; }
    .btn-follow.follow:hover { opacity: 0.85; }
    .btn-follow.following { background: #1a2527; color: var(--lime, #b8f400); }

    /* STATS GRID */
    .stats-grid {
        display: flex; gap: 20px; margin-bottom: 40px;
        width: 100%; justify-content: center;
    }
    .stat-box {
        background: #1a2527; border-radius: 16px; padding: 20px;
        width: 180px; display: flex; flex-direction: column;
        align-items: center; text-align: center;
    }
    .stat-box img { width: 48px; height: 48px; margin-bottom: 8px; object-fit: contain; }
    .stat-value { font-size: 20px; font-weight: 700; color: #fff; margin-bottom: 4px; }
    .stat-label { font-size: 10px; color: rgba(255,255,255,0.5); text-transform: uppercase; letter-spacing: 0.1em; }

    /* TABS */
    .profile-tabs {
        display: flex; background: #1a2527; border-radius: 20px;
        width: 100%; max-width: 600px; margin-bottom: 30px; overflow: hidden;
    }
    .tab-btn {
        flex: 1; background: transparent; border: none;
        color: rgba(255,255,255,0.4); padding: 16px 0;
        font-size: 12px; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.1em; cursor: pointer; transition: 0.3s; border-radius: 20px;
    }
    .tab-btn.active { background: #023639; color: var(--cyan, #00d4d4); }

    .tab-content { display: none; width: 100%; max-width: 600px; animation: fadeIn 0.3s ease; }
    .tab-content.active { display: block; }
    @keyframes fadeIn { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }

    /* History */
    .history-card { margin-bottom: 24px; }
    .history-thumbnail { width:100%; height:180px; background:#d9d9d9; border-radius:12px; margin-bottom:12px; object-fit:cover; }
    .history-title { font-size:18px; font-weight:600; color:#fff; margin-bottom:4px; }
    .history-time { font-size:12px; color:rgba(255,255,255,0.5); }

    /* Achievement */
    .ach-section-title { font-size:14px; font-weight:700; color:#fff; text-transform:uppercase; letter-spacing:0.1em; margin-bottom:24px; margin-top:20px; }
    .ach-grid { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:40px; }
    .ach-item { display:flex; align-items:center; gap:16px; }
    .ach-icon { width:40px; height:40px; display:flex; align-items:center; justify-content:center; }
    .ach-icon img { width:100%; height:100%; object-fit:contain; }
    .ach-value { font-size:12px; font-weight:700; color:#fff; text-transform:uppercase; }
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
        @if($selectedRank && $selectedRank->icon_url)
        <div style="position:absolute; top:-20px; left:50%; transform:translateX(-50%); width:48px; height:48px;">
            <img src="{{ $selectedRank->icon_url }}" alt="{{ $selectedRank->name }}"
                 style="width:100%; height:100%; object-fit:contain; filter:drop-shadow(0 0 8px rgba(211,170,78,0.6));">
        </div>
        @endif
    </div>

    <div class="profile-username">{{ $user->username ?? $user->name }}</div>

    <div class="profile-joined">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/>
            <line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
        JOINED ON {{ $user->created_at ? $user->created_at->format('F j, Y') : 'JANUARY 8, 2026' }}
    </div>

    <!-- FRIEND ACTION BUTTON -->
    <div class="friend-action-wrap">
        @if($friendshipStatus === 'accepted')
            <button class="btn-friend friends" disabled>✓ Friends</button>
        @elseif($friendshipStatus === 'pending')
            <button class="btn-friend pending" disabled>Requested</button>
        @elseif($friendshipStatus === 'requested_to_me')
            <button class="btn-friend accept" id="btn-friend-action"
                onclick="acceptFriendRequest({{ $user->id }})">Accept Request</button>
        @else
            <button class="btn-friend add" id="btn-friend-action"
                onclick="sendFriendRequest({{ $user->id }})">+ Add Friend</button>
        @endif

        {{-- Following button (separate from friend request) --}}
        <button class="btn-follow {{ $isFollowing ? 'following' : 'follow' }}"
                id="btn-follow-action"
                onclick="toggleFollow({{ $user->id }})">
            {{ $isFollowing ? '✓ Following' : 'Follow' }}
        </button>
    </div>

    <!-- STATS GRID -->
    <div class="stats-grid">
        <div class="stat-box">
            <img src="/images/following.png" alt="Following">
            <div class="stat-value">{{ $followingCount }}</div>
            <div class="stat-label">Following</div>
        </div>
        <div class="stat-box">
            <img src="/images/friends.png" alt="Friends">
            <div class="stat-value">{{ $friendsCount }}</div>
            <div class="stat-label">Friends</div>
        </div>
        <div class="stat-box">
            <img src="/images/followers.png" alt="Followers">
            <div class="stat-value">{{ $followersCount }}</div>
            <div class="stat-label">Followers</div>
        </div>
    </div>

    <!-- TABS (no Settings tab) -->
    <div class="profile-tabs">
        <button class="tab-btn active" onclick="switchTab('history', event)">History</button>
        <button class="tab-btn" onclick="switchTab('achievement', event)">Achievement</button>
    </div>

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
        </div>
        @empty
        <div style="color: rgba(255,255,255,0.4); text-align:center; padding: 40px 0;">No reading history yet.</div>
        @endforelse
    </div>

    <!-- 2. Achievement -->
    <div id="tab-achievement" class="tab-content">
        <div class="ach-section-title">OVERVIEW</div>
        <div class="ach-grid">
            <div class="ach-item">
                <div class="ach-icon"><img src="/images/streak.png" alt=""></div>
                <div class="ach-value">{{ $user->streak_count ?? 0 }} DAYS</div>
            </div>
            <div class="ach-item">
                <div class="ach-icon"><img src="/images/scroll.png" alt=""></div>
                <div class="ach-value">ARTICLES READ: {{ count($historyArticles) }}</div>
            </div>
            <div class="ach-item">
                <div class="ach-icon"><img src="/images/xp.png" alt=""></div>
                <div class="ach-value">{{ number_format($user->xp ?? 0) }} XP</div>
            </div>
            <div class="ach-item">
                <div class="ach-icon"><img src="/images/streak.png" alt=""></div>
                <div class="ach-value">BEST: {{ $user->max_streak ?? 0 }}</div>
            </div>
            <div class="ach-item" style="grid-column: span 2;">
                <div class="ach-icon"><img src="/images/chapter.png" alt=""></div>
                <div class="ach-value">
                    {{ $activeLevel ? 'CHAPTER: ' . $activeLevel->chapter_title : 'CHAPTER 1' }}
                </div>
            </div>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <div class="ach-section-title" style="margin:0;">ACHIEVEMENTS RANK</div>
            <a href="{{ route('ranks.index') }}" style="font-size:10px; color:#fff; text-decoration:none; font-weight:700;">MORE</a>
        </div>

        <div style="display:flex; gap:30px; justify-content:flex-start; align-items:flex-end; flex-wrap:wrap; margin-bottom:20px;">
            @foreach($allRanks->take(3) as $rank)
            <div style="display:flex; flex-direction:column; align-items:center; gap:12px;">
                @if($rank->icon_url)
                    <img src="{{ $rank->icon_url }}" alt="{{ $rank->name }}"
                         style="width:110px; height:120px; object-fit:contain; filter:drop-shadow(0 0 20px rgba(211,170,78,0.5));">
                @else
                    <svg viewBox="0 0 100 115" fill="none" style="width:110px; height:120px; filter:drop-shadow(0 0 20px rgba(211,170,78,0.5));">
                        <path d="M50 2 L98 22 L98 82 L50 113 L2 82 L2 22 Z" fill="#d3aa4e" stroke="#fae188" stroke-width="4"/>
                    </svg>
                @endif
                <div style="font-size:11px; color:rgba(255,255,255,0.5); text-transform:uppercase; letter-spacing:0.1em;">{{ $rank->name }}</div>
            </div>
            @endforeach
        </div>
    </div>

</div>

@push('scripts')
<script>
    function switchTab(tabId, event) {
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        if (event && event.target) event.target.classList.add('active');
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.getElementById('tab-' + tabId).classList.add('active');
    }

    function sendFriendRequest(id) {
        fetch(`/friends/request/${id}`, {
            method: 'POST',
            headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}', 'Accept': 'application/json' }
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const btn = document.getElementById('btn-friend-action');
                btn.className = 'btn-friend pending';
                btn.textContent = 'Requested';
                btn.disabled = true;
            }
        });
    }

    function acceptFriendRequest(id) {
        fetch(`/friends/accept/${id}`, {
            method: 'POST',
            headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}', 'Accept': 'application/json' }
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const btn = document.getElementById('btn-friend-action');
                btn.className = 'btn-friend friends';
                btn.textContent = '✓ Friends';
                btn.disabled = true;
            }
        });
    }

    function toggleFollow(id) {
        const btn = document.getElementById('btn-follow-action');
        const isFollowing = btn.classList.contains('following');
        const url = isFollowing ? `/profile/${id}/unfollow` : `/profile/${id}/follow`;

        fetch(url, {
            method: 'POST',
            headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}', 'Accept': 'application/json' }
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                if (isFollowing) {
                    btn.className = 'btn-follow follow';
                    btn.textContent = 'Follow';
                } else {
                    btn.className = 'btn-follow following';
                    btn.textContent = '✓ Following';
                }
            }
        });
    }
</script>
@endpush
@endsection
