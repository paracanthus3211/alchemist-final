<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Alchemist')</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Silkscreen&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    @livewireStyles
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --bg:       #080d0e;
            --sidebar:  #0b1416;
            --card:     #0d1c1e;
            --card2:    #101f22;
            --cyan:     #00d4d4;
            --lime:     #b8f400;
            --active-bg:#0f2f2c;
            --border:   rgba(255,255,255,0.06);
            --muted:    rgba(255,255,255,0.4);
            --text:     #ffffff;
        }

        html, body {
            height: 100%; 
            font-family: 'Space Grotesk', sans-serif;
            background: var(--bg); 
            color: var(--text);
            overflow: hidden;
            width: 100%;
        }

        .layout { display: flex; height: 100vh; width: 100%; }

        /* ── SIDEBAR ── */
        .sidebar {
            width: 240px; 
            min-width: 240px;
            max-width: 240px;
            background: var(--sidebar);
            border-right: 1px solid var(--border);
            display: flex; 
            flex-direction: column;
            overflow: hidden;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 100;
            flex-shrink: 0;
        }

        .sidebar-logo {
            padding: 24px 20px 16px;
            font-family: 'Silkscreen', cursive;
            font-size: 0.85rem; letter-spacing: 0.14em;
            color: var(--text);
        }

        .sidebar-user {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 16px 20px;
        }

        .sidebar-avatar {
            width: 44px; height: 44px; border-radius: 50%;
            background: #2a3a3a;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; color: #fff; font-weight: 700;
            flex-shrink: 0;
            border: 2px solid rgba(255,255,255,0.1);
            overflow: hidden;
        }
        .sidebar-avatar img { width: 100%; height: 100%; object-fit: cover; }

        .sidebar-user-info .name {
            font-size: 14px; font-weight: 600; color: #fff;
        }
        .sidebar-user-info .rank {
            font-size: 11px; color: var(--muted); margin-top: 1px;
        }

        .sidebar-divider { height: 1px; background: var(--border); margin: 0 16px 8px; }

        .nav { flex: 1; overflow-y: auto; padding: 4px 0; }
        .nav::-webkit-scrollbar { display: none; }

        .nav-item {
            display: flex; align-items: center; gap: 14px;
            padding: 12px 20px;
            font-size: 13.5px; font-weight: 500;
            color: rgba(255,255,255,0.65);
            cursor: pointer; text-decoration: none;
            transition: all 0.15s;
            border-right: 4px solid transparent;
            position: relative;
        }
        .nav-item:hover { color: rgba(255,255,255,0.95); background: rgba(255,255,255,0.03); }
        .nav-item.active {
            color: var(--cyan);
            background: var(--active-bg);
            border-right-color: var(--cyan);
            font-weight: 600;
        }

        .nav-icon { width: 28px; height: 28px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; }
        .nav-icon img {
            width: 22px;
            height: 22px;
            object-fit: contain;
            opacity: 0.85;
            transition: opacity 0.15s;
        }
        .nav-icon img.octopus-logo {
            width: 28px;
            height: 28px;
        }
        .nav-item.active .nav-icon img {
            opacity: 1.0;
        }
        .nav-item:hover .nav-icon img {
            opacity: 1.0;
        }

        .nav-icon svg {
            width: 20px;
            height: 20px;
            opacity: 0.75;
            transition: opacity 0.15s;
            color: rgba(255,255,255,0.65);
        }
        .nav-item.active .nav-icon svg {
            opacity: 1.0;
            color: var(--cyan);
        }
        .nav-item:hover .nav-icon svg {
            opacity: 1.0;
            color: rgba(255,255,255,0.95);
        }

        /* ── SIDEBAR BOTTOM ── */
        .sidebar-footer {
            padding: 12px 16px;
            border-top: 1px solid var(--border);
        }
        .btn-logout-sm {
            display: flex; align-items: center; gap: 10px;
            width: 100%; padding: 10px 14px; border-radius: 10px;
            background: rgba(255,70,70,0.07); border: 1px solid rgba(255,70,70,0.15);
            color: rgba(255,120,120,0.8); font-size: 12px; font-weight: 700;
            letter-spacing: 0.06em; cursor: pointer; text-transform: uppercase;
            transition: all 0.2s; font-family: inherit;
        }
        .btn-logout-sm:hover { background: rgba(255,70,70,0.14); }

        /* ── MAIN CONTENT ── */
        .main {
            flex: 1; 
            overflow-y: auto;
            overflow-x: hidden;
            padding: 32px 40px 80px;
            position: relative;
            height: auto;
            min-height: 100vh;
            margin-left: 240px;
        }
        .main::-webkit-scrollbar { 
            width: 8px; 
        }
        .main::-webkit-scrollbar-track { 
            background: rgba(255,255,255,0.02);
            border-radius: 10px;
        }
        .main::-webkit-scrollbar-thumb { 
            background: rgba(0, 212, 212, 0.4);
            border-radius: 10px;
            border: 2px solid rgba(255,255,255,0.02);
        }
        .main::-webkit-scrollbar-thumb:hover {
            background: rgba(0, 212, 212, 0.7);
        }

        @media (max-width: 768px) {
            .sidebar { width: 200px; min-width: 200px; }
            .main { padding: 20px 20px 80px; }
        }
    </style>
    @stack('styles')
</head>
<body>
<div class="layout">

    <!-- SIDEBAR -->
    @persist('sidebar')
    <aside class="sidebar">
        <div class="sidebar-logo">ALCHEMIST</div>

        <div class="sidebar-user">
            <div class="sidebar-avatar">
                @php
                    $sidebarUser = auth()->user();
                    $sidebarAvatarImg = null;
                    if ($sidebarUser) {
                        // Priority: equipped avatar image → profile avatar_url → initial
                        if ($sidebarUser->equipped_avatar_id) {
                            $equippedAv = $sidebarUser->equippedAvatar;
                            if ($equippedAv && $equippedAv->image_url) {
                                $sidebarAvatarImg = $equippedAv->image_url;
                            }
                        }
                        if (!$sidebarAvatarImg && $sidebarUser->avatar_url) {
                            $sidebarAvatarImg = $sidebarUser->avatar_url;
                        }
                    }
                @endphp
                @if($sidebarAvatarImg)
                    <img src="{{ $sidebarAvatarImg }}" alt="avatar">
                @else
                    {{ strtoupper(substr(auth()->user()->username ?? auth()->user()->name ?? 'U', 0, 1)) }}
                @endif
            </div>
            <div class="sidebar-user-info">
                <div class="name">{{ auth()->user()->username ?? auth()->user()->name ?? 'Guest' }}</div>
                <div class="rank">
                    @php
                        $sidebarRankName = 'Novice';
                        if ($sidebarUser) {
                            // First try explicitly selected rank
                            if ($sidebarUser->selected_rank_id) {
                                $selRank = $sidebarUser->selectedRank;
                                if ($selRank) {
                                    $sidebarRankName = $selRank->name;
                                }
                            } else {
                                // Auto-detect highest rank the user qualifies for by XP
                                $userXp = $sidebarUser->xp ?? 0;
                                $autoRank = \App\Models\Rank::where('xp_threshold', '<=', $userXp)
                                    ->orderByDesc('xp_threshold')
                                    ->first();
                                if ($autoRank) {
                                    $sidebarRankName = $autoRank->name;
                                }
                            }
                        }
                    @endphp
                    {{ $sidebarRankName }}
                </div>
            </div>
        </div>

        <div class="sidebar-divider"></div>

        <nav class="nav">
            <!-- Home -->
            <a href="{{ route('home') }}" wire:navigate class="nav-item {{ request()->routeIs('home') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/home_logo.png" alt="Home">
                </span>
                Home
            </a>

            <!-- Quiz -->
            <a href="{{ route('quiz') }}" wire:navigate class="nav-item {{ request()->routeIs('quiz') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/quiz_logo.png" alt="Quiz">
                </span>
                Quiz
            </a>

            @if(auth()->check() && auth()->user()->role === 'ADMIN')
            <a href="{{ route('admin.daily-tasks.index') }}" wire:navigate class="nav-item {{ request()->routeIs('admin.daily-tasks.*') ? 'active' : '' }}">
                <span class="nav-icon"><svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20"><path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg></span>Daily Task
            </a>
            @endif

            <!-- Rank -->
            <a href="{{ route('rank') }}" wire:navigate class="nav-item {{ request()->routeIs('rank') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/rank_logo.png" alt="Rank">
                </span>
                Rank
            </a>

            <!-- Profile -->
            <a href="{{ route('profile') }}" wire:navigate class="nav-item {{ request()->routeIs('profile') ? 'active' : '' }}">
                <span class="nav-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg>
                </span>
                Profile
            </a>

            <!-- Library -->
            <a href="{{ route('library') }}" wire:navigate class="nav-item {{ request()->routeIs('library') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/library_logo.png" alt="Library">
                </span>
                Library
            </a>

            <!-- Virtual Lab -->
            <a href="{{ route('virtual_lab') }}" wire:navigate class="nav-item {{ request()->routeIs('virtual_lab') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/logo.png" alt="Virtual Lab" class="octopus-logo">
                </span>
                Virtual Lab
            </a>

            <!-- Periodic Table -->
            <a href="{{ route('periodic_table') }}" wire:navigate class="nav-item {{ request()->routeIs('periodic_table') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/periodic_table.png" alt="Periodic Table" style="width: 22px; height: 22px;">
                </span>
                Periodic Table
            </a>

            <!-- Friends -->
            <a href="{{ route('friends.index') }}" wire:navigate class="nav-item {{ request()->routeIs('friends.*') ? 'active' : '' }}">
                <span class="nav-icon">
                    <img src="/images/add_friend.png" alt="Friends">
                </span>
                Friends
            </a>

            <!-- Bookmark -->
            <a href="{{ route('library', ['category' => 'bookmarks']) }}" wire:navigate class="nav-item {{ request()->query('category') === 'bookmarks' ? 'active' : '' }}">
                <span class="nav-icon" style="position: relative;" id="sidebar-bookmark-icon-container">
                    @php
                        $bookmarkCount = auth()->check() ? auth()->user()->bookmarks()->count() : 0;
                    @endphp
                    @if($bookmarkCount > 0)
                        <svg viewBox="0 0 24 24" fill="#00d4d4" width="20" height="20" style="opacity: 1;" class="sidebar-bookmark-svg">
                            <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
                        </svg>
                        <span class="sidebar-bookmark-badge" style="position: absolute; top: -4px; right: -4px; background: #ff4646; color: white; font-size: 8px; font-weight: 900; width: 13px; height: 13px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 4px rgba(0,0,0,0.4); z-index: 2;">{{ $bookmarkCount }}</span>
                    @else
                        <svg viewBox="0 0 24 24" fill="rgba(255,255,255,0.3)" width="20" height="20" style="opacity: 1;" class="sidebar-bookmark-svg">
                            <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
                        </svg>
                    @endif
                </span>
                Bookmark
            </a>
        </nav>

        <div class="sidebar-footer">
            <form method="POST" action="{{ route('logout') }}" style="margin:0">
                @csrf
                <button type="submit" class="btn-logout-sm">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
                    </svg>
                    Logout
                </button>
            </form>
        </div>
    </aside>
    @endpersist

    <!-- MAIN -->
    <main class="main">
        @yield('content')
    </main>

</div>
@livewireScripts
<script>
    document.addEventListener('livewire:navigated', () => {
        // Update active class on sidebar links based on current URL
        const currentPath = window.location.pathname;
        const navItems = document.querySelectorAll('.sidebar .nav-item');
        
        navItems.forEach(item => {
            const href = item.getAttribute('href');
            if (!href) return;
            
            const url = new URL(href, window.location.origin);
            item.classList.remove('active');
            
            // exact match or active tab logic
            if (currentPath === url.pathname || (currentPath.startsWith(url.pathname) && url.pathname !== '/')) {
                item.classList.add('active');
            } else if (currentPath === '/' && url.pathname === '/home') {
                // Handle edge cases if needed
            }
        });
    });
</script>
@stack('scripts')
</body>
</html>
