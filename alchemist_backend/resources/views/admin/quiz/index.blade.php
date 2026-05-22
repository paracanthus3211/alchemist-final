<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Admin — Alchemist</title>
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

        /* ── STATS CARDS ── */
        .stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 40px;
        }
        .stat-card {
            background: var(--card); border: 1px solid var(--border); border-radius: 16px;
            padding: 32px 24px; text-align: center;
        }
        .stat-number { font-size: 44px; font-weight: 700; margin-bottom: 8px; font-family: 'Space Grotesk', sans-serif; }
        .stat-number.cyan-text { color: var(--cyan); }
        .stat-number.purple-text { color: var(--purple); }
        .stat-number.lime-text { color: var(--lime); }
        .stat-label { font-size: 13px; color: var(--muted); font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; }

        /* ── TAB SELECTOR ── */
        .tab-selector {
            display: flex; gap: 32px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 32px;
        }
        .tab-btn {
            font-size: 14px; font-weight: 700; color: var(--muted); cursor: pointer;
            text-transform: uppercase; letter-spacing: 0.05em; padding-bottom: 12px;
            text-decoration: none; position: relative;
        }
        .tab-btn.active { color: var(--cyan); }
        .tab-btn.active::after {
            content: ''; position: absolute; bottom: -1px; left: 0; right: 0; height: 2px; background: var(--cyan);
        }

        /* ── CHAPTER CONTENT (TAB 1) ── */
        .chapter-card {
            background: var(--card2); border: 1px solid rgba(255,255,255,0.05);
            border-radius: 16px; padding: 24px; margin-bottom: 24px;
        }
        .chapter-card-header {
            font-size: 18px; font-weight: 700; color: #fff; margin-bottom: 20px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .chapter-actions { display: flex; gap: 16px; }
        
        .level-list { display: flex; flex-direction: column; gap: 12px; margin-bottom: 24px; }
        .level-item {
            background: rgba(0,0,0,0.2); border: 1px solid rgba(255,255,255,0.03);
            border-radius: 12px; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center;
        }
        .level-details .level-num { font-size: 11px; color: var(--cyan); font-weight: 700; text-transform: uppercase; }
        .level-details .level-name { font-size: 14px; font-weight: 600; color: #fff; margin-top: 2px; }
        .level-actions { display: flex; gap: 16px; align-items: center; }

        .btn-text {
            font-size: 13px; font-weight: 600; color: var(--muted); cursor: pointer;
            background: none; border: none; text-decoration: none; transition: 0.2s;
        }
        .btn-text:hover { color: #fff; }
        .btn-text.danger:hover { color: #ff5555; }
        .btn-text.cyan-txt:hover { color: var(--cyan); }

        .action-icon {
            cursor: pointer; background: none; border: none; color: var(--muted); transition: 0.2s;
        }
        .action-icon:hover { color: #fff; }
        .action-icon.delete:hover { color: #ff5555; }

        /* ── QUIZ CARD (TAB 2) ── */
        .quiz-grid {
            display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; margin-bottom: 32px;
        }
        .quiz-card {
            background: var(--card2); border: 1px solid rgba(255,255,255,0.05);
            border-radius: 16px; padding: 24px; display: flex; flex-direction: column; gap: 16px;
            position: relative;
        }
        .quiz-card-header {
            display: flex; justify-content: space-between; align-items: flex-start;
        }
        .quiz-title { font-size: 15px; font-weight: 600; color: #fff; }
        .quiz-badge {
            display: inline-block; padding: 4px 10px; border-radius: 99px;
            font-size: 9px; font-weight: 700; letter-spacing: 0.05em;
            background: rgba(176, 115, 255, 0.15); color: var(--purple);
            text-transform: uppercase; margin-top: 8px;
        }
        .quiz-question-box {
            background: rgba(0,0,0,0.2); border-radius: 8px; padding: 16px;
            font-size: 14px; font-style: italic; color: rgba(255,255,255,0.7);
            font-family: 'Inter', sans-serif; min-height: 70px;
        }
        .quiz-card-footer {
            display: flex; justify-content: space-between; align-items: center; font-size: 11px;
            font-weight: 700; color: var(--lime); text-transform: uppercase;
        }
        .quiz-view-details { color: var(--cyan); text-decoration: none; cursor: pointer; }

        /* ── DASHED ADD BUTTONS ── */
        .btn-dashed-add {
            width: 100%; border: 2px dashed rgba(255,255,255,0.15); border-radius: 16px;
            padding: 24px; display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 8px; color: var(--cyan); font-size: 15px; font-weight: 700; cursor: pointer;
            background: transparent; transition: 0.2s;
        }
        .btn-dashed-add:hover { border-color: var(--cyan); background: rgba(0, 212, 212, 0.02); }
        .btn-dashed-add svg { width: 24px; height: 24px; }

        /* ── MODALS ── */
        .modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.8); z-index: 1000;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; pointer-events: none; transition: 0.2s ease-in-out;
        }
        .modal-overlay.open { opacity: 1; pointer-events: auto; }
        .modal-box {
            background: #0d1618; border: 1px solid var(--border); border-radius: 20px;
            width: 100%; max-width: 500px; padding: 32px; display: flex; flex-direction: column; gap: 24px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.5); transform: translateY(-20px); transition: 0.2s;
        }
        .modal-overlay.open .modal-box { transform: translateY(0); }
        .modal-header { font-size: 20px; font-weight: 700; color: #fff; display: flex; justify-content: space-between; align-items: center; }
        .modal-close { cursor: pointer; color: var(--muted); background: none; border: none; font-size: 20px; }
        .modal-close:hover { color: #fff; }

        /* ── FORMS ── */
        .form-group { display: flex; flex-direction: column; gap: 8px; }
        .form-label { font-size: 12px; font-weight: 700; color: var(--muted); text-transform: uppercase; }
        .form-control {
            background: rgba(255,255,255,0.03); border: 1px solid var(--border); border-radius: 8px;
            padding: 12px 16px; color: #fff; font-size: 14px; font-family: inherit; outline: none;
        }
        .form-control:focus { border-color: var(--cyan); }
        
        .btn-submit {
            background: var(--cyan); color: #000; font-size: 14px; font-weight: 700;
            padding: 14px; border-radius: 8px; border: none; cursor: pointer; text-transform: uppercase;
            text-align: center; font-family: inherit; margin-top: 12px;
        }
        .btn-submit:hover { opacity: 0.9; }

        /* ── ULTRA-PREMIUM QUESTION MODAL ── */
        #questionModal.modal-overlay {
            background: rgba(4, 7, 8, 0.95);
            backdrop-filter: blur(10px);
        }

        #questionModal .modal-box {
            background: #080d0e;
            max-width: 800px;
            width: 95%;
            border: 1px solid rgba(0, 212, 212, 0.15);
            border-radius: 24px;
            box-shadow: 0 20px 50px rgba(0, 212, 212, 0.05);
            padding: 40px;
            max-height: 90vh;
            overflow-y: auto;
        }

        #questionModal .modal-header {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 0.05em;
            color: #fff;
            text-transform: uppercase;
            margin-bottom: 32px;
        }

        /* Segmented Tabs Control */
        .q-segmented-tabs {
            display: flex;
            background: #0e1719;
            border-radius: 14px;
            padding: 6px;
            margin-bottom: 40px;
            border: 1px solid rgba(255,255,255,0.03);
        }

        .q-tab-btn {
            flex: 1;
            text-align: center;
            padding: 14px 0;
            font-size: 13px;
            font-weight: 700;
            color: rgba(255,255,255,0.4);
            cursor: pointer;
            border-radius: 10px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            transition: all 0.2s ease;
        }

        .q-tab-btn.active {
            background: #094f57;
            color: #00ffff;
            box-shadow: 0 4px 15px rgba(0, 212, 212, 0.15);
        }

        /* Form Section Card */
        .form-card {
            background: #111a1c;
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 20px;
            padding: 28px;
            margin-bottom: 28px;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .form-card-title {
            font-size: 11px;
            font-weight: 700;
            color: var(--cyan);
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 4px;
        }

        /* Sleek Inputs */
        .form-card input.form-control, 
        .form-card textarea.form-control,
        .form-card select.form-control {
            background: #162427;
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 12px;
            padding: 16px;
            font-size: 14px;
            color: #fff;
            outline: none;
            font-family: 'Inter', sans-serif;
            transition: all 0.2s;
            width: 100%;
        }

        .form-card input.form-control:focus, 
        .form-card textarea.form-control:focus,
        .form-card select.form-control:focus {
            border-color: var(--cyan);
            box-shadow: 0 0 10px rgba(0, 212, 212, 0.1);
        }

        /* Real-time word order correct order preview */
        .preview-box-sentence {
            background: rgba(0,0,0,0.2);
            border-radius: 12px;
            padding: 16px;
            font-size: 14px;
            color: #00ffff;
            font-family: 'Inter', sans-serif;
            font-style: italic;
            border: 1px dashed rgba(0, 212, 212, 0.2);
        }

        /* Option blocks matching mockup A, B, C, D */
        .option-edit-row {
            background: #084d56;
            border: 1px solid rgba(255,255,255,0.03);
            border-radius: 12px;
            padding: 14px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            cursor: pointer;
            box-shadow: 0 6px 0 #032e34;
            transition: all 0.1s;
            user-select: none;
        }

        .option-edit-row:active {
            transform: translateY(2px);
            box-shadow: 0 4px 0 #032e34;
        }

        .option-edit-row.selected {
            background: #b8f400;
            box-shadow: 0 6px 0 #7fa600;
        }

        .option-edit-row.selected:active {
            transform: translateY(2px);
            box-shadow: 0 4px 0 #7fa600;
        }

        .option-edit-label {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 22px;
            font-weight: 700;
            color: #fff;
            width: 28px;
            text-align: center;
        }

        .option-edit-row.selected .option-edit-label {
            color: #000;
        }

        .option-edit-input {
            flex: 1;
            background: transparent !important;
            border: none !important;
            color: #fff !important;
            font-size: 14px;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            padding: 4px 0 !important;
            outline: none;
        }

        .option-edit-row.selected .option-edit-input {
            color: #000 !important;
        }

        .option-edit-row.selected .option-edit-input::placeholder {
            color: rgba(0,0,0,0.4);
        }

        .option-edit-input::placeholder {
            color: rgba(255,255,255,0.4);
        }

        /* XP Potential Bar */
        .xp-potential-bar {
            background: #fff;
            border-radius: 12px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: #000;
        }

        .xp-potential-bar .xp-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 700;
            font-size: 14px;
        }

        .xp-potential-bar input {
            background: transparent;
            border: none;
            font-size: 18px;
            font-weight: 700;
            color: #000;
            width: 80px;
            text-align: right;
            outline: none;
            font-family: 'Space Grotesk', sans-serif;
        }

        /* Big counter reward for sentence arrangement */
        .big-xp-counter {
            background: rgba(255,255,255,0.02);
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 16px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .big-xp-counter input {
            background: transparent;
            border: none;
            font-size: 40px;
            font-weight: 700;
            color: #b8f400;
            text-align: center;
            width: 150px;
            outline: none;
            font-family: 'Space Grotesk', sans-serif;
        }

        /* Modal Action buttons */
        .modal-actions-wrap {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-top: 40px;
        }

        .btn-modal-action {
            padding: 18px 0;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            cursor: pointer;
            border: none;
            font-family: inherit;
            text-align: center;
            transition: all 0.2s;
        }

        .btn-modal-action.cancel {
            background: #273a3d;
            color: #fff;
        }

        .btn-modal-action.cancel:hover {
            background: #314a4e;
        }

        .btn-modal-action.save {
            background: #00d4d4;
            color: #000;
            box-shadow: 0 4px 15px rgba(0, 212, 212, 0.2);
        }

        .btn-modal-action.save:hover {
            opacity: 0.9;
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
            <a href="{{ route('quiz') }}" class="nav-item active">
                <span class="nav-icon"><img src="/images/quiz_logo.png" alt="Quiz"></span>Quiz
            </a>
            @if(auth()->user()->role === 'ADMIN')
            <a href="{{ route('admin.daily-tasks.index') }}" class="nav-item">
                <span class="nav-icon"><svg viewBox="0 0 24 24" fill="rgba(255,255,255,0.65)" width="20" height="20"><path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg></span>Daily Task
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

    <!-- MAIN -->
    <main class="main">
        <div class="admin-container">
            
            <!-- STATS CARDS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number cyan-text">{{ $chapters->count() }}</div>
                    <div class="stat-label">Chapters</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number purple-text">{{ $levelsCount }}</div>
                    <div class="stat-label">Levels</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number lime-text">{{ $questionsCount }}</div>
                    <div class="stat-label">Quizzes</div>
                </div>
            </div>

            <!-- TAB SELECTOR -->
            <div class="tab-selector">
                <a href="{{ route('admin.quiz.index', ['tab' => 'chapter']) }}" class="tab-btn {{ $tab === 'chapter' ? 'active' : '' }}">Chapter</a>
                <a href="{{ route('admin.quiz.index', ['tab' => 'quiz']) }}" class="tab-btn {{ $tab === 'quiz' ? 'active' : '' }}">Quiz Content</a>
            </div>

            <!-- TAB CONTENT: CHAPTERS -->
            @if($tab === 'chapter')
                <div class="tab-pane">
                    @foreach($chapters as $chapter)
                        <div class="chapter-card">
                            <div class="chapter-card-header">
                                <span>{{ $chapter->title }}</span>
                                <div class="chapter-actions">
                                    <button class="btn-text cyan-txt" onclick="openEditChapterModal({{ json_encode($chapter) }})">Edit Chapter</button>
                                    <form method="POST" action="{{ route('admin.chapters.destroy', $chapter->id) }}" style="display:inline;" onsubmit="return confirm('Delete this chapter? This will delete all levels inside!')">
                                        @csrf
                                        <button type="submit" class="btn-text danger">Delete Chapter</button>
                                    </form>
                                </div>
                            </div>
                            
                            <!-- Levels under this chapter -->
                            <div class="level-list">
                                @forelse($chapter->levels as $level)
                                    <div class="level-item">
                                        <div class="level-details">
                                            <div class="level-num">Level {{ $loop->iteration }}</div>
                                            <div class="level-name">{{ $level->name }}</div>
                                        </div>
                                        <div class="level-actions">
                                            <button class="action-icon" onclick="openEditLevelModal({{ json_encode($level) }})">
                                                <!-- Edit Icon -->
                                                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                            </button>
                                            <form method="POST" action="{{ route('admin.levels.destroy', $level->id) }}" onsubmit="return confirm('Delete this level?')">
                                                @csrf
                                                <button type="submit" class="action-icon delete">
                                                    <!-- Trash Icon -->
                                                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                @empty
                                    <div style="font-size:13px; color:var(--muted); text-align:center; padding:12px 0;">No levels in this chapter.</div>
                                @endforelse
                            </div>

                            <!-- Add Level to Chapter -->
                            <button class="btn-dashed-add" style="padding:16px; border-radius:12px; font-size:13px;" onclick="openAddLevelModal({{ $chapter->id }})">
                                + Add New Level
                            </button>
                        </div>
                    @endforeach

                    <!-- Add New Chapter Button -->
                    <button class="btn-dashed-add" onclick="openAddChapterModal()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                        <span>Add New Chapter</span>
                    </button>
                </div>
            @endif

            <!-- TAB CONTENT: QUIZ CONTENT -->
            @if($tab === 'quiz')
                <div class="tab-pane">
                    <div class="quiz-grid">
                        @foreach($questions as $question)
                            <div class="quiz-card">
                                <div class="quiz-card-header">
                                    <div>
                                        <div class="quiz-title">Soal ({{ $question->type == 'MULTIPLE_CHOICE' ? 'Pilihan Ganda' : ($question->type == 'SENTENCE_ARRANGEMENT' ? 'Susun Kalimat' : 'Praktek Lab') }})</div>
                                        <span class="quiz-badge">{{ str_replace('_', ' ', $question->type) }}</span>
                                    </div>
                                    <div class="level-actions" style="position: absolute; right: 24px; top: 24px;">
                                        <button class="action-icon" onclick="openEditQuestionModal({{ json_encode($question) }})">
                                            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                        </button>
                                        <form method="POST" action="{{ route('admin.questions.destroy', $question->id) }}" onsubmit="return confirm('Delete this question?')">
                                            @csrf
                                            <button type="submit" class="action-icon delete">
                                                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                                <div class="quiz-question-box">
                                    {{ $question->question_text }}
                                </div>
                                <div class="quiz-card-footer">
                                    <span>⚡ {{ $question->xp_reward }} XP REWARD</span>
                                    <span class="quiz-view-details" onclick="alert('Explanation: {{ $question->explanation }}')">View Details</span>
                                </div>
                            </div>
                        @endforeach
                    </div>

                    <!-- Add New Question Button -->
                    <button class="btn-dashed-add" onclick="openAddQuestionModal()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                        <span>Add new question</span>
                    </button>
                </div>
            @endif

        </div>
    </main>
</div>

<!-- ──────────────── MODALS ──────────────── -->

<!-- 1. CHAPTER MODAL -->
<div id="chapterModal" class="modal-overlay" onclick="closeModalOnOverlay(event, 'chapterModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span id="chapterModalTitle">Add New Chapter</span>
            <button class="modal-close" onclick="closeModal('chapterModal')">&times;</button>
        </div>
        <form id="chapterForm" method="POST" action="{{ route('admin.chapters.store') }}">
            @csrf
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Chapter Title</label>
                <input type="text" id="chapter_title" name="title" class="form-control" placeholder="e.g. Pengenalan Kimia" required>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">XP Threshold</label>
                <input type="number" id="chapter_xp" name="xp_threshold" class="form-control" placeholder="e.g. 100" required>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Icon Emoji / Color</label>
                <input type="text" id="chapter_emoji" name="icon_emoji" class="form-control" placeholder="e.g. 🧪 or #00d4d4">
            </div>
            <div class="form-group" style="margin-bottom: 24px;">
                <label class="form-label">Order Index</label>
                <input type="number" id="chapter_order" name="order_index" class="form-control" placeholder="e.g. 1">
            </div>
            <button type="submit" class="btn-submit" style="width:100%;">Save Chapter</button>
        </form>
    </div>
</div>

<!-- 2. LEVEL MODAL -->
<div id="levelModal" class="modal-overlay" onclick="closeModalOnOverlay(event, 'levelModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span id="levelModalTitle">Add New Level</span>
            <button class="modal-close" onclick="closeModal('levelModal')">&times;</button>
        </div>
        <form id="levelForm" method="POST" action="{{ route('admin.levels.store') }}">
            @csrf
            <input type="hidden" id="level_id" name="id">
            <input type="hidden" id="level_chapter_id" name="chapter_id">
            
            <div class="form-group" style="margin-bottom: 16px;" id="chapterSelectGroup">
                <label class="form-label">Chapter</label>
                <select name="chapter_id" id="level_chapter_select" class="form-control" style="background:#0c1214; border:1px solid var(--border);">
                    @foreach($chapters as $c)
                        <option value="{{ $c->id }}">{{ $c->title }}</option>
                    @endforeach
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Level Name</label>
                <input type="text" id="level_name" name="name" class="form-control" placeholder="e.g. Struktur Inti Atom" required>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">XP Required</label>
                <input type="number" id="level_xp" name="xp_required" class="form-control" placeholder="e.g. 50" required>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Description</label>
                <textarea id="level_desc" name="description" class="form-control" placeholder="Brief details about the level contents"></textarea>
            </div>
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Timer Limit (Seconds)</label>
                <input type="number" id="level_timer" name="timer_limit" class="form-control" placeholder="e.g. 60">
            </div>
            <div class="form-group" style="margin-bottom: 24px;">
                <label class="form-label">Order Index</label>
                <input type="number" id="level_order" name="order_index" class="form-control" placeholder="e.g. 1">
            </div>
            <button type="submit" class="btn-submit" style="width:100%;">Save Level</button>
        </form>
    </div>
</div>

<!-- 3. QUESTION MODAL -->
<div id="questionModal" class="modal-overlay" onclick="closeModalOnOverlay(event, 'questionModal')">
    <div class="modal-box">
        <div class="modal-header">
            <span id="questionModalTitle">Edit Question</span>
        </div>
        
        <!-- Segmented Tab buttons -->
        <div class="q-segmented-tabs">
            <div class="q-tab-btn active" id="tab-mc" onclick="setQuestionType('MULTIPLE_CHOICE')">Pilihan Ganda</div>
            <div class="q-tab-btn" id="tab-sa" onclick="setQuestionType('SENTENCE_ARRANGEMENT')">Susun Kalimat</div>
            <div class="q-tab-btn" id="tab-lab" onclick="setQuestionType('LAB_PRACTICE')">Lab Practice</div>
        </div>

        <form id="questionForm" method="POST" action="">
            @csrf
            <input type="hidden" name="type" id="q_type" value="MULTIPLE_CHOICE">
            
            <div class="form-card" style="padding: 20px; margin-bottom: 24px;">
                <div class="form-card-title">Target Level</div>
                <select name="level_id" id="q_level_id" class="form-control" style="background:#162427; border:1px solid rgba(255,255,255,0.08); width:100%;" required>
                    @foreach($levels as $lvl)
                        <option value="{{ $lvl->id }}">{{ $lvl->chapter->title ?? 'Chapter' }} &rarr; {{ $lvl->name }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Unified hidden fields populated on submit -->
            <input type="hidden" name="explanation" id="q_explanation">
            <input type="hidden" name="xp_reward" id="q_xp">

            <!-- Shared Question Text Card -->
            <div class="form-card">
                <div class="form-card-title">Question</div>
                <textarea name="question_text" id="q_text" class="form-control" placeholder="Write question text here..." rows="4" required></textarea>
            </div>

            <!-- MULTIPLE CHOICE SPECIFIC FIELDS -->
            <div id="mc_specific_fields">
                <!-- Card 2: OPTIONS -->
                <div class="form-card">
                    <div class="form-card-title">Option</div>
                    <div style="display: flex; flex-direction: column; gap: 16px;">
                        
                        <!-- Option A -->
                        <div class="option-edit-row" id="mc-row-A" onclick="selectCorrectOption('A')">
                            <div class="option-edit-label">A</div>
                            <input type="text" name="options[0][option_text]" id="mc_opt_A" class="option-edit-input" placeholder="Enter option A text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="options[0][option_label]" value="A">
                            <input type="checkbox" name="options[0][is_correct]" id="mc_check_A" value="1" style="display:none;">
                        </div>

                        <!-- Option B -->
                        <div class="option-edit-row" id="mc-row-B" onclick="selectCorrectOption('B')">
                            <div class="option-edit-label">B</div>
                            <input type="text" name="options[1][option_text]" id="mc_opt_B" class="option-edit-input" placeholder="Enter option B text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="options[1][option_label]" value="B">
                            <input type="checkbox" name="options[1][is_correct]" id="mc_check_B" value="1" style="display:none;">
                        </div>

                        <!-- Option C -->
                        <div class="option-edit-row" id="mc-row-C" onclick="selectCorrectOption('C')">
                            <div class="option-edit-label">C</div>
                            <input type="text" name="options[2][option_text]" id="mc_opt_C" class="option-edit-input" placeholder="Enter option C text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="options[2][option_label]" value="C">
                            <input type="checkbox" name="options[2][is_correct]" id="mc_check_C" value="1" style="display:none;">
                        </div>

                        <!-- Option D -->
                        <div class="option-edit-row" id="mc-row-D" onclick="selectCorrectOption('D')">
                            <div class="option-edit-label">D</div>
                            <input type="text" name="options[3][option_text]" id="mc_opt_D" class="option-edit-input" placeholder="Enter option D text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="options[3][option_label]" value="D">
                            <input type="checkbox" name="options[3][is_correct]" id="mc_check_D" value="1" style="display:none;">
                        </div>

                    </div>
                </div>

                <!-- Card 3: PEMBAHASAN -->
                <div class="form-card">
                    <div class="form-card-title">Pembahasan</div>
                    <textarea id="q_explanation_mc" class="form-control" placeholder="Write explanation here..." rows="3"></textarea>
                </div>

                <!-- Card 4: CORRECT ANSWER & XP POTENTIAL -->
                <div class="form-card">
                    <div class="form-card-title">Correct Answer</div>
                    <select id="mc_correct_answer_dropdown" class="form-control" onchange="syncCorrectOptionFromDropdown(this.value)">
                        <option value="A">Option A (Selected)</option>
                        <option value="B">Option B (Selected)</option>
                        <option value="C">Option C (Selected)</option>
                        <option value="D">Option D (Selected)</option>
                    </select>

                    <div class="form-card-title" style="margin-top: 16px;">XP Reward Potential</div>
                    <div class="xp-potential-bar">
                        <div class="xp-label">⚡ XP</div>
                        <input type="number" id="q_xp_mc" value="500">
                    </div>
                </div>
            </div>

            <!-- SENTENCE ARRANGEMENT SPECIFIC FIELDS -->
            <div id="sa_specific_fields" style="display:none;">
                <!-- Card 2: WORDS -->
                <div class="form-card">
                    <div class="form-card-title">Available Words</div>
                    <textarea name="words" id="q_words" class="form-control" placeholder="e.g. ikatan, atom, berbagi, elektron, kovalen, terjadi, antara" rows="2" onkeyup="updateSentencePreview()"></textarea>
                    
                    <div class="form-card-title" style="margin-top: 12px;">Correct Order</div>
                    <input type="text" name="correct_order" id="q_correct_order" class="form-control" placeholder="e.g. 4, 3, 2, 1, 5" onkeyup="updateSentencePreview()">

                    <div class="form-card-title" style="margin-top: 12px;">Correct Sentence</div>
                    <div class="preview-box-sentence" id="q_sentence_preview">-</div>
                </div>

                <!-- Card 3: PEMBAHASAN -->
                <div class="form-card">
                    <div class="form-card-title">Pembahasan</div>
                    <textarea id="q_explanation_sa" class="form-control" placeholder="Write explanation here..." rows="3"></textarea>
                </div>

                <!-- Card 4: XP REWARD -->
                <div class="form-card">
                    <div class="form-card-title">XP Reward</div>
                    <div class="big-xp-counter">
                        <input type="number" id="q_xp_sa" value="250">
                        <div style="font-size:11px; font-weight:700; color:rgba(255,255,255,0.4); text-transform:uppercase;">XP Potential</div>
                    </div>
                </div>
            </div>

            <!-- LAB PRACTICE SPECIFIC FIELDS -->
            <div id="lab_specific_fields" style="display:none;">
                <!-- Card 2: BEAKERS -->
                <div class="form-card">
                    <div class="form-card-title">Beaker A</div>
                    <input type="text" name="beaker_a" id="q_beaker_a" class="form-control" placeholder="e.g. HCl (Asam Klorida)">

                    <div class="form-card-title" style="margin-top: 12px;">Beaker B</div>
                    <input type="text" name="beaker_b" id="q_beaker_b" class="form-control" placeholder="e.g. NaOH (Natrium Hidroksida)">
                </div>

                <!-- Card 3: RESULTS -->
                <div class="form-card">
                    <div class="form-card-title">Visual Result</div>
                    <input type="text" name="visual_result" id="q_visual_result" class="form-control" placeholder="e.g. Colorless Liquid / Gas Bubble">

                    <div class="form-card-title" style="margin-top: 12px;">Reaction Equation</div>
                    <input type="text" name="reaction_equation" id="q_reaction_equation" class="form-control" placeholder="e.g. HCl + NaOH -> NaCl + H2O">
                </div>

                <!-- Card 4: OPTIONS (LAB) -->
                <div class="form-card">
                    <div class="form-card-title">Option</div>
                    <div style="display: flex; flex-direction: column; gap: 16px;">
                        
                        <!-- Option A -->
                        <div class="option-edit-row" id="lab-row-A" onclick="selectLabCorrectOption('A')">
                            <div class="option-edit-label">A</div>
                            <input type="text" name="lab_options[0][option_text]" id="lab_opt_A" class="option-edit-input" placeholder="Enter option A text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="lab_options[0][option_label]" value="A">
                            <input type="checkbox" name="lab_options[0][is_correct]" id="lab_check_A" value="1" style="display:none;">
                        </div>

                        <!-- Option B -->
                        <div class="option-edit-row" id="lab-row-B" onclick="selectLabCorrectOption('B')">
                            <div class="option-edit-label">B</div>
                            <input type="text" name="lab_options[1][option_text]" id="lab_opt_B" class="option-edit-input" placeholder="Enter option B text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="lab_options[1][option_label]" value="B">
                            <input type="checkbox" name="lab_options[1][is_correct]" id="lab_check_B" value="1" style="display:none;">
                        </div>

                        <!-- Option C -->
                        <div class="option-edit-row" id="lab-row-C" onclick="selectLabCorrectOption('C')">
                            <div class="option-edit-label">C</div>
                            <input type="text" name="lab_options[2][option_text]" id="lab_opt_C" class="option-edit-input" placeholder="Enter option C text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="lab_options[2][option_label]" value="C">
                            <input type="checkbox" name="lab_options[2][is_correct]" id="lab_check_C" value="1" style="display:none;">
                        </div>

                        <!-- Option D -->
                        <div class="option-edit-row" id="lab-row-D" onclick="selectLabCorrectOption('D')">
                            <div class="option-edit-label">D</div>
                            <input type="text" name="lab_options[3][option_text]" id="lab_opt_D" class="option-edit-input" placeholder="Enter option D text..." onclick="event.stopPropagation()">
                            <input type="hidden" name="lab_options[3][option_label]" value="D">
                            <input type="checkbox" name="lab_options[3][is_correct]" id="lab_check_D" value="1" style="display:none;">
                        </div>

                    </div>
                </div>

                <!-- Card 5: CORRECT ANSWER & XP POTENTIAL -->
                <div class="form-card">
                    <div class="form-card-title">Correct Answer</div>
                    <select id="lab_correct_answer_dropdown" class="form-control" onchange="syncLabCorrectOptionFromDropdown(this.value)">
                        <option value="A">Option A (Selected)</option>
                        <option value="B">Option B (Selected)</option>
                        <option value="C">Option C (Selected)</option>
                        <option value="D">Option D (Selected)</option>
                    </select>

                    <div class="form-card-title" style="margin-top: 16px;">XP Reward Potential</div>
                    <div class="xp-potential-bar">
                        <div class="xp-label">⚡ XP</div>
                        <input type="number" id="q_xp_lab" value="500">
                    </div>
                </div>

                <!-- Card 6: PEMBAHASAN -->
                <div class="form-card">
                    <div class="form-card-title">Pembahasan</div>
                    <textarea id="q_explanation_lab" class="form-control" placeholder="Write explanation here..." rows="3"></textarea>
                </div>
            </div>

            <!-- ORDER INDEX -->
            <div class="form-card" style="padding: 20px;">
                <div class="form-card-title">Order Index</div>
                <input type="number" name="order_index" id="q_order" class="form-control" placeholder="e.g. 1" style="width:100%;">
            </div>

            <!-- SUBMIT BUTTONS -->
            <div class="modal-actions-wrap">
                <button type="button" class="btn-modal-action cancel" onclick="closeModal('questionModal')">Cancel</button>
                <button type="submit" class="btn-modal-action save">Save</button>
            </div>
        </form>
    </div>
</div>

<script>
    // MODAL STATE MANAGEMENT
    function openModal(id) {
        document.getElementById(id).classList.add('open');
    }
    
    function closeModal(id) {
        document.getElementById(id).classList.remove('open');
    }

    function closeModalOnOverlay(e, id) {
        if (e.target.id === id) {
            closeModal(id);
        }
    }

    // 1. CHAPTER FUNCTIONS
    function openAddChapterModal() {
        document.getElementById('chapterModalTitle').innerText = 'Add New Chapter';
        document.getElementById('chapterForm').action = "{{ route('admin.chapters.store') }}";
        document.getElementById('chapter_title').value = '';
        document.getElementById('chapter_xp').value = '';
        document.getElementById('chapter_emoji').value = '';
        document.getElementById('chapter_order').value = '';
        openModal('chapterModal');
    }

    function openEditChapterModal(chapter) {
        document.getElementById('chapterModalTitle').innerText = 'Edit Chapter';
        document.getElementById('chapterForm').action = "/admin/chapters/" + chapter.id;
        document.getElementById('chapter_title').value = chapter.title;
        document.getElementById('chapter_xp').value = chapter.xp_threshold;
        document.getElementById('chapter_emoji').value = chapter.icon_emoji || '';
        document.getElementById('chapter_order').value = chapter.order_index || '';
        openModal('chapterModal');
    }

    // 2. LEVEL FUNCTIONS
    function openAddLevelModal(chapterId) {
        document.getElementById('levelModalTitle').innerText = 'Add New Level';
        document.getElementById('levelForm').action = "{{ route('admin.levels.store') }}";
        document.getElementById('level_chapter_id').value = chapterId;
        document.getElementById('chapterSelectGroup').style.display = 'none';
        
        document.getElementById('level_name').value = '';
        document.getElementById('level_xp').value = '';
        document.getElementById('level_desc').value = '';
        document.getElementById('level_timer').value = '';
        document.getElementById('level_order').value = '';
        openModal('levelModal');
    }

    function openEditLevelModal(level) {
        document.getElementById('levelModalTitle').innerText = 'Edit Level';
        document.getElementById('levelForm').action = "/admin/levels/" + level.id;
        document.getElementById('chapterSelectGroup').style.display = 'flex';
        document.getElementById('level_chapter_select').value = level.chapter_id;
        
        document.getElementById('level_name').value = level.name;
        document.getElementById('level_xp').value = level.xp_required;
        document.getElementById('level_desc').value = level.description || '';
        document.getElementById('level_timer').value = level.timer_limit || '';
        document.getElementById('level_order').value = level.order_index || '';
        openModal('levelModal');
    }

    // 3. QUESTION FUNCTIONS
    function setQuestionType(type) {
        document.getElementById('q_type').value = type;

        document.querySelectorAll('.q-tab-btn').forEach(btn => btn.classList.remove('active'));
        if (type === 'MULTIPLE_CHOICE') document.getElementById('tab-mc').classList.add('active');
        if (type === 'SENTENCE_ARRANGEMENT') document.getElementById('tab-sa').classList.add('active');
        if (type === 'LAB_PRACTICE') document.getElementById('tab-lab').classList.add('active');

        document.getElementById('mc_specific_fields').style.display = (type === 'MULTIPLE_CHOICE') ? 'block' : 'none';
        document.getElementById('sa_specific_fields').style.display = (type === 'SENTENCE_ARRANGEMENT') ? 'block' : 'none';
        document.getElementById('lab_specific_fields').style.display = (type === 'LAB_PRACTICE') ? 'block' : 'none';
    }

    function selectCorrectOption(label) {
        ['A', 'B', 'C', 'D'].forEach(l => {
            document.getElementById(`mc-row-${l}`).classList.remove('selected');
            document.getElementById(`mc_check_${l}`).checked = false;
        });

        document.getElementById(`mc-row-${label}`).classList.add('selected');
        document.getElementById(`mc_check_${label}`).checked = true;
        document.getElementById('mc_correct_answer_dropdown').value = label;
    }

    function syncCorrectOptionFromDropdown(label) {
        selectCorrectOption(label);
    }

    function selectLabCorrectOption(label) {
        ['A', 'B', 'C', 'D'].forEach(l => {
            document.getElementById(`lab-row-${l}`).classList.remove('selected');
            document.getElementById(`lab_check_${l}`).checked = false;
        });

        document.getElementById(`lab-row-${label}`).classList.add('selected');
        document.getElementById(`lab_check_${label}`).checked = true;
        document.getElementById('lab_correct_answer_dropdown').value = label;
    }

    function syncLabCorrectOptionFromDropdown(label) {
        selectLabCorrectOption(label);
    }

    function updateSentencePreview() {
        const wordsStr = document.getElementById('q_words').value;
        const orderStr = document.getElementById('q_correct_order').value;
        const previewEl = document.getElementById('q_sentence_preview');
        
        if (!wordsStr) {
            previewEl.innerText = '-';
            return;
        }

        const words = wordsStr.split(',').map(w => w.trim());
        const indices = orderStr.split(',').map(i => parseInt(i.trim())).filter(i => !isNaN(i));

        if (indices.length > 0) {
            const orderedWords = indices.map(idx => words[idx] || '').filter(w => w !== '');
            previewEl.innerText = `"${orderedWords.join(' ')}."`;
        } else {
            previewEl.innerText = `"${words.join(' ')}."`;
        }
    }

    function openAddQuestionModal() {
        document.getElementById('questionModalTitle').innerText = 'Add New Question';
        document.getElementById('questionForm').action = "{{ route('admin.questions.store') }}";
        
        document.getElementById('q_text').value = '';
        document.getElementById('q_order').value = '';
        
        ['A', 'B', 'C', 'D'].forEach(l => {
            document.getElementById(`mc-row-${l}`).classList.remove('selected');
            document.getElementById(`mc_check_${l}`).checked = false;
            document.getElementById(`mc_opt_${l}`).value = '';
            document.getElementById(`lab-row-${l}`).classList.remove('selected');
            document.getElementById(`lab_check_${l}`).checked = false;
            document.getElementById(`lab_opt_${l}`).value = '';
        });

        document.getElementById('q_explanation_mc').value = '';
        document.getElementById('q_xp_mc').value = '500';
        document.getElementById('q_explanation_sa').value = '';
        document.getElementById('q_xp_sa').value = '250';
        document.getElementById('q_explanation_lab').value = '';
        document.getElementById('q_xp_lab').value = '500';

        document.getElementById('q_words').value = '';
        document.getElementById('q_correct_order').value = '';
        document.getElementById('q_sentence_preview').innerText = '-';

        document.getElementById('q_beaker_a').value = '';
        document.getElementById('q_beaker_b').value = '';
        document.getElementById('q_visual_result').value = '';
        document.getElementById('q_reaction_equation').value = '';

        selectCorrectOption('A');
        selectLabCorrectOption('A');

        setQuestionType('MULTIPLE_CHOICE');
        openModal('questionModal');
    }

    function openEditQuestionModal(question) {
        document.getElementById('questionModalTitle').innerText = 'Edit Question';
        document.getElementById('questionForm').action = "/admin/questions/" + question.id;
        
        document.getElementById('q_level_id').value = question.level_id;
        document.getElementById('q_text').value = question.question_text;
        document.getElementById('q_order').value = question.order_index || '';

        ['A', 'B', 'C', 'D'].forEach(l => {
            document.getElementById(`mc-row-${l}`).classList.remove('selected');
            document.getElementById(`mc_check_${l}`).checked = false;
            document.getElementById(`mc_opt_${l}`).value = '';
            document.getElementById(`lab-row-${l}`).classList.remove('selected');
            document.getElementById(`lab_check_${l}`).checked = false;
            document.getElementById(`lab_opt_${l}`).value = '';
        });

        if (question.type === 'MULTIPLE_CHOICE') {
            document.getElementById('q_explanation_mc').value = question.explanation || '';
            document.getElementById('q_xp_mc').value = question.xp_reward;
            
            if (question.multiple_choice_options) {
                question.multiple_choice_options.forEach(opt => {
                    const l = opt.option_label;
                    document.getElementById(`mc_opt_${l}`).value = opt.option_text;
                    if (opt.is_correct == 1) {
                        selectCorrectOption(l);
                    }
                });
            }
        } else if (question.type === 'SENTENCE_ARRANGEMENT') {
            document.getElementById('q_explanation_sa').value = question.explanation || '';
            document.getElementById('q_xp_sa').value = question.xp_reward;

            if (question.sentence_arrangement_words) {
                const rawWords = question.sentence_arrangement_words.map(w => w.word_text).join(', ');
                const indices = question.sentence_arrangement_words.map(w => w.correct_order_index).join(', ');
                document.getElementById('q_words').value = rawWords;
                document.getElementById('q_correct_order').value = indices;
                updateSentencePreview();
            }
        } else if (question.type === 'LAB_PRACTICE') {
            document.getElementById('q_explanation_lab').value = question.explanation || '';
            document.getElementById('q_xp_lab').value = question.xp_reward;

            if (question.lab_practice_config) {
                document.getElementById('q_beaker_a').value = question.lab_practice_config.beaker_a_chemical || '';
                document.getElementById('q_beaker_b').value = question.lab_practice_config.beaker_b_chemical || '';
                document.getElementById('q_visual_result').value = question.lab_practice_config.expected_visual_result || '';
                document.getElementById('q_reaction_equation').value = question.lab_practice_config.expected_reaction_equation || '';
            }

            if (question.multiple_choice_options) {
                question.multiple_choice_options.forEach(opt => {
                    const l = opt.option_label;
                    document.getElementById(`lab_opt_${l}`).value = opt.option_text;
                    if (opt.is_correct == 1) {
                        selectLabCorrectOption(l);
                    }
                });
            }
        }

        setQuestionType(question.type);
        openModal('questionModal');
    }

    // Dynamic fields sync on submit
    document.getElementById('questionForm').onsubmit = function() {
        const type = document.getElementById('q_type').value;
        
        // Reset all inputs disabled attribute
        ['A', 'B', 'C', 'D'].forEach(l => {
            document.getElementById(`mc_opt_${l}`).disabled = false;
            document.getElementById(`mc_check_${l}`).disabled = false;
            document.getElementById(`lab_opt_${l}`).disabled = false;
            document.getElementById(`lab_check_${l}`).disabled = false;
        });

        if (type === 'LAB_PRACTICE') {
            // Rename lab_options to options
            ['A', 'B', 'C', 'D'].forEach((l, idx) => {
                document.getElementById(`lab_opt_${l}`).name = `options[${idx}][option_text]`;
                document.getElementById(`lab_check_${l}`).name = `options[${idx}][is_correct]`;
                document.querySelector(`#lab-row-${l} input[type="hidden"]`).name = `options[${idx}][option_label]`;
            });
            // Disable MC inputs to prevent submission
            ['A', 'B', 'C', 'D'].forEach(l => {
                document.getElementById(`mc_opt_${l}`).disabled = true;
                document.getElementById(`mc_check_${l}`).disabled = true;
            });
        } else if (type === 'MULTIPLE_CHOICE') {
            // Disable Lab inputs to prevent submission
            ['A', 'B', 'C', 'D'].forEach(l => {
                document.getElementById(`lab_opt_${l}`).disabled = true;
                document.getElementById(`lab_check_${l}`).disabled = true;
            });
        } else {
            // Sentence arrangement: Disable options completely
            ['A', 'B', 'C', 'D'].forEach(l => {
                document.getElementById(`mc_opt_${l}`).disabled = true;
                document.getElementById(`mc_check_${l}`).disabled = true;
                document.getElementById(`lab_opt_${l}`).disabled = true;
                document.getElementById(`lab_check_${l}`).disabled = true;
            });
        }
        
        // Sync unified hidden fields
        if (type === 'MULTIPLE_CHOICE') {
            document.getElementById('q_explanation').value = document.getElementById('q_explanation_mc').value;
            document.getElementById('q_xp').value = document.getElementById('q_xp_mc').value;
        } else if (type === 'SENTENCE_ARRANGEMENT') {
            document.getElementById('q_explanation').value = document.getElementById('q_explanation_sa').value;
            document.getElementById('q_xp').value = document.getElementById('q_xp_sa').value;
        } else if (type === 'LAB_PRACTICE') {
            document.getElementById('q_explanation').value = document.getElementById('q_explanation_lab').value;
            document.getElementById('q_xp').value = document.getElementById('q_xp_lab').value;
        }
    };
</script>
</body>
</html>
