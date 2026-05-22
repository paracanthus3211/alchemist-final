<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Tasks Admin — Alchemist</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Silkscreen&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --bg:       #080d0e;
            --sidebar:  #0b1416;
            --card:     #0d1c1e;
            --card2:    #102224;
            --cyan:     #00d4d4;
            --lime:     #b8f400;
            --purple:   #b073ff;
            --active-bg:#0f2f2c;
            --border:   rgba(255,255,255,0.06);
            --muted:    rgba(255,255,255,0.4);
            --text:     #ffffff;
        }

        html, body {
            height: 100%; font-family: 'Space Grotesk', sans-serif;
            background: var(--bg); color: var(--text);
            overflow: hidden;
        }

        .layout { display: flex; height: 100vh; }

        /* ── SIDEBAR ── */
        .sidebar {
            width: 240px; min-width: 240px;
            background: var(--sidebar);
            border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            overflow: hidden;
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

        .sidebar-user-info .name { font-size: 14px; font-weight: 600; color: #fff; }
        .sidebar-user-info .rank { font-size: 11px; color: var(--muted); margin-top: 1px; }

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
        }
        .nav-item:hover { color: rgba(255,255,255,0.95); background: rgba(255,255,255,0.03); }
        .nav-item.active {
            color: var(--cyan);
            background: var(--active-bg);
            border-right-color: var(--cyan);
            font-weight: 600;
        }

        .nav-icon { width: 28px; height: 28px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; }
        .nav-icon img, .nav-icon svg { width: 20px; height: 20px; opacity: 0.75; color: rgba(255,255,255,0.65); }
        .nav-icon img.octopus-logo { width: 28px; height: 28px; }
        .nav-item.active .nav-icon img, .nav-item:hover .nav-icon img { opacity: 1.0; }
        .nav-item.active .nav-icon svg { opacity: 1.0; color: var(--cyan); }

        .sidebar-footer { padding: 12px 16px; border-top: 1px solid var(--border); }
        .btn-logout-sm {
            display: flex; align-items: center; gap: 10px; width: 100%; padding: 10px 14px; border-radius: 10px;
            background: rgba(255,70,70,0.07); border: 1px solid rgba(255,70,70,0.15);
            color: rgba(255,120,120,0.8); font-size: 12px; font-weight: 700;
            cursor: pointer; text-transform: uppercase; font-family: inherit;
        }

        /* ── MAIN CONTENT ── */
        .main {
            flex: 1; overflow-y: auto; padding: 40px; position: relative;
        }
        .main::-webkit-scrollbar { width: 6px; }
        .main::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }

        .admin-container {
            max-width: 900px; margin: 0 auto; display: flex; flex-direction: column;
        }

        .dashboard-header {
            font-size: 32px; font-weight: 700; color: #fff; margin-bottom: 32px;
        }

        /* ── STATS CARDS ── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 40px;
        }
        .stat-card {
            background: var(--card); border: 1px solid var(--border); border-radius: 16px;
            padding: 32px 24px; text-align: left;
            position: relative;
            overflow: hidden;
        }
        .stat-card::after {
            content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 3px;
            background: rgba(255,255,255,0.05);
        }
        .stat-card.templates::after { background: var(--purple); }
        .stat-card.active-tasks::after { background: var(--cyan); }
        .stat-card.inactive-tasks::after { background: var(--muted); }

        .stat-number { font-size: 44px; font-weight: 700; margin-bottom: 8px; font-family: 'Space Grotesk', sans-serif; }
        .stat-number.cyan-text { color: var(--cyan); }
        .stat-number.purple-text { color: var(--purple); }
        .stat-number.muted-text { color: var(--muted); }
        .stat-label { font-size: 11px; color: var(--muted); font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em; }

        /* ── QUEUE LIST HEADER ── */
        .queue-header-row {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;
        }
        .queue-title {
            display: flex; align-items: center; gap: 10px;
            font-size: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em;
            color: #fff;
        }
        .queue-title svg { width: 22px; height: 22px; color: var(--cyan); }

        .btn-new-task {
            background: var(--cyan); color: #000; font-size: 12px; font-weight: 700;
            padding: 10px 18px; border-radius: 8px; border: none; cursor: pointer;
            text-transform: uppercase; text-decoration: none; display: flex; align-items: center; gap: 8px;
            box-shadow: 0 4px 0 #008888; transition: transform 0.1s, box-shadow 0.1s;
        }
        .btn-new-task:active {
            transform: translateY(2px); box-shadow: 0 2px 0 #008888;
        }

        /* ── TASK QUEUE ITEMS ── */
        .queue-list {
            display: flex; flex-direction: column; gap: 16px;
        }
        .task-card {
            background: var(--card); border: 1px solid var(--border); border-radius: 16px;
            padding: 20px 24px; display: flex; align-items: center; gap: 20px;
            transition: all 0.2s;
        }
        .task-card:hover {
            border-color: rgba(255,255,255,0.1);
            background: var(--card2);
        }

        .task-icon {
            width: 52px; height: 52px; border-radius: 12px;
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            color: var(--cyan); flex-shrink: 0;
        }
        .task-icon.xp { color: var(--lime); }
        .task-icon.lessons { color: var(--cyan); }
        .task-icon.library { color: var(--purple); }

        .task-details {
            flex: 1; display: flex; flex-direction: column; gap: 6px;
        }
        .task-title {
            font-size: 16px; font-weight: 600; color: #fff;
            font-family: 'Space Grotesk', sans-serif;
        }
        .task-meta {
            display: flex; align-items: center; justify-content: space-between;
            font-size: 11px; font-weight: 700; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.05em;
        }
        .task-status-text {
            color: var(--cyan);
        }
        .task-status-text.active { color: var(--lime); }
        .task-status-text.inactive { color: var(--muted); }

        .progress-bar-wrap {
            height: 6px; background: rgba(255,255,255,0.06); border-radius: 99px;
            overflow: hidden; width: 100%;
        }
        .progress-bar-fill {
            height: 100%; border-radius: 99px; width: 0%;
            transition: width 0.3s ease;
        }
        .progress-bar-fill.cyan { background: var(--cyan); box-shadow: 0 0 6px var(--cyan); }
        .progress-bar-fill.lime { background: var(--lime); box-shadow: 0 0 6px var(--lime); }
        .progress-bar-fill.grey { background: var(--muted); }

        .task-actions {
            display: flex; gap: 12px; align-items: center;
        }
        .action-btn {
            background: none; border: none; cursor: pointer; color: var(--muted);
            padding: 8px; border-radius: 8px; transition: all 0.2s;
        }
        .action-btn:hover { color: #fff; background: rgba(255,255,255,0.04); }
        .action-btn.delete:hover { color: #ff4646; background: rgba(255,70,70,0.05); }

        /* Alerts */
        .alert-success {
            background: rgba(184, 244, 0, 0.08); border: 1px solid rgba(184, 244, 0, 0.2);
            color: var(--lime); padding: 16px 20px; border-radius: 12px; font-size: 14px;
            margin-bottom: 24px; font-weight: 600; display: flex; align-items: center; gap: 12px;
        }

    </style>
</head>
<body>
<div class="layout">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-logo">ALCHEMIST</div>
        <div class="sidebar-user">
            <div class="sidebar-avatar">
                @if($user->avatar_url)
                    <img src="{{ $user->avatar_url }}" alt="avatar">
                @else
                    {{ strtoupper(substr($user->username ?? $user->name ?? 'U', 0, 1)) }}
                @endif
            </div>
            <div class="sidebar-user-info">
                <div class="name">{{ $user->username ?? $user->name }}</div>
                <div class="rank">Admin</div>
            </div>
        </div>
        <div class="sidebar-divider"></div>
        <nav class="nav">
            <a href="{{ route('home') }}" class="nav-item">
                <span class="nav-icon"><img src="/images/home_logo.png" alt="Home"></span>Home
            </a>
            <a href="{{ route('quiz') }}" class="nav-item">
                <span class="nav-icon"><img src="/images/quiz_logo.png" alt="Quiz"></span>Quiz
            </a>
            @if(auth()->user()->role === 'ADMIN')
            <a href="{{ route('admin.daily-tasks.index') }}" class="nav-item active">
                <span class="nav-icon"><svg viewBox="0 0 24 24" fill="var(--cyan)" width="20" height="20"><path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg></span>Daily Task
            </a>
            @endif
            <a href="{{ route('rank') }}" class="nav-item">
                <span class="nav-icon"><img src="/images/rank_logo.png" alt="Rank"></span>Rank
            </a>
            <a href="#" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg></span>Profile
            </a>
            <a href="{{ route('library') }}" class="nav-item">
                <span class="nav-icon"><img src="/images/library_logo.png" alt="Library"></span>Library
            </a>
            <a href="#" class="nav-item">
                <span class="nav-icon"><img src="/images/logo.png" alt="Virtual Lab" class="octopus-logo"></span>Virtual Lab
            </a>
            <a href="#" class="nav-item">
                <span class="nav-icon"><img src="/images/add_friend.png" alt="Friends"></span>Friends
            </a>
            <a href="#" class="nav-item">
                <span class="nav-icon" style="position: relative;">
                    <svg viewBox="0 0 24 24" fill="rgba(255,255,255,0.3)" width="20" height="20" style="opacity: 1;"><path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/></svg>
                </span>Bookmark
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

    <!-- MAIN CONTENT -->
    <main class="main">
        <div class="admin-container">
            
            <h1 class="dashboard-header">Daily Tasks</h1>

            @if(session('success'))
                <div class="alert-success">
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            <!-- STATS CARDS -->
            <div class="stats-grid">
                <div class="stat-card templates">
                    <div class="stat-number purple-text">{{ $templatesCount }}</div>
                    <div class="stat-label">Templates</div>
                </div>
                <div class="stat-card active-tasks">
                    <div class="stat-number cyan-text">{{ $activeCount }}</div>
                    <div class="stat-label">Active</div>
                </div>
                <div class="stat-card inactive-tasks">
                    <div class="stat-number muted-text">{{ $inactiveCount }}</div>
                    <div class="stat-label">Inactive Task</div>
                </div>
            </div>

            <!-- QUEUE LIST SECTION -->
            <div class="queue-header-row">
                <div class="queue-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    <span>Queue List</span>
                </div>
                <a href="{{ route('admin.daily-tasks.create') }}" class="btn-new-task">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    <span>New Task</span>
                </a>
            </div>

            <div class="queue-list">
                @forelse($tasks as $task)
                    @php
                        // Dynamically pick some beautiful preview state to match the premium design screenshot
                        $iconClass = 'lessons';
                        $iconPath = '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>';
                        $statusClass = 'cyan';
                        $statusLabel = 'In Progress';
                        $sampleVal = round($task->target_value * 0.65);
                        $percent = $task->target_value > 0 ? round(($sampleVal / $task->target_value) * 100) : 0;
                        $unit = 'Completed';

                        if (str_contains(strtoupper($task->task_type), 'XP')) {
                            $iconClass = 'xp';
                            $iconPath = '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>';
                            $statusClass = 'lime';
                            $statusLabel = 'Active';
                            $sampleVal = round($task->target_value * 0.45);
                            $percent = $task->target_value > 0 ? round(($sampleVal / $task->target_value) * 100) : 0;
                            $unit = 'Units';
                        } elseif (str_contains(strtoupper($task->task_type), 'READ') || str_contains(strtoupper($task->task_type), 'ARTICLE')) {
                            $iconClass = 'library';
                            $iconPath = '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>';
                            $statusClass = 'grey';
                            $statusLabel = 'Synchronized';
                            $sampleVal = $task->target_value;
                            $percent = 100;
                            $unit = 'Completed';
                        }

                        if (!$task->is_active) {
                            $statusClass = 'grey';
                            $statusLabel = 'Inactive';
                            $percent = 0;
                            $sampleVal = 0;
                        }
                    @endphp

                    <div class="task-card">
                        <div class="task-icon {{ $iconClass }}">
                            {!! $iconPath !!}
                        </div>
                        <div class="task-details">
                            <div class="task-title">{{ $task->task_name }}</div>
                            
                            <div class="progress-bar-wrap">
                                <div class="progress-bar-fill {{ $statusClass }}" style="width: {{ $percent }}%"></div>
                            </div>
                            
                            <div class="task-meta">
                                <span class="task-status-text {{ !$task->is_active ? 'inactive' : ($statusClass == 'lime' ? 'active' : '') }}">{{ strtoupper($statusLabel) }}</span>
                                <span>{{ $sampleVal }}/{{ $task->target_value }} {{ strtoupper($unit) }}</span>
                            </div>
                        </div>
                        <div class="task-actions">
                            <a href="{{ route('admin.daily-tasks.edit', $task->id) }}" class="action-btn" title="Edit Task">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                            </a>
                            <form method="POST" action="{{ route('admin.daily-tasks.destroy', $task->id) }}" style="display:inline;" onsubmit="return confirm('Delete this daily task template?')">
                                @csrf
                                <button type="submit" class="action-btn delete" title="Delete Task">
                                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>
                                </button>
                            </form>
                        </div>
                    </div>
                @empty
                    <div style="text-align: center; padding: 40px; border: 2px dashed rgba(255,255,255,0.06); border-radius: 16px; color: var(--muted);">
                        No daily task templates found. Click "+ New Task" to create one.
                    </div>
                @endforelse
            </div>

        </div>
    </main>
</div>
</body>
</html>
