<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ isset($task) ? 'Edit' : 'New' }} Daily Task — Alchemist</title>
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
            --input-bg: #1f2d30;
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
            max-width: 600px; margin: 0 auto; display: flex; flex-direction: column;
        }

        .form-title {
            font-size: 24px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em;
            color: var(--cyan); margin-bottom: 32px;
        }

        /* ── FORM CONTROL ── */
        .form-group {
            display: flex; flex-direction: column; gap: 10px; margin-bottom: 24px;
        }
        .form-label {
            font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: 0.1em;
        }
        .form-control {
            background: var(--input-bg); border: 1px solid var(--border); border-radius: 12px;
            padding: 16px 20px; color: #fff; font-size: 15px; font-family: inherit; outline: none;
            transition: all 0.2s;
        }
        .form-control:focus {
            border-color: var(--cyan);
            box-shadow: 0 0 8px rgba(0, 212, 212, 0.1);
        }

        /* Select styling */
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.5)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 20px center;
            background-size: 18px;
            padding-right: 48px;
        }

        .form-row-2 {
            display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
        }

        /* ── TOGGLE SWITCH ── */
        .toggle-container {
            display: flex; align-items: center; justify-content: space-between;
            background: rgba(255,255,255,0.02); border: 1px solid var(--border);
            padding: 16px 24px; border-radius: 12px; margin-bottom: 32px;
        }
        .toggle-label {
            font-size: 14px; font-weight: 500; color: #fff;
        }
        
        .switch {
            position: relative; display: inline-block; width: 50px; height: 26px;
        }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider {
            position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0;
            background-color: #2b3b3e; transition: .3s; border-radius: 34px;
        }
        .slider:before {
            position: absolute; content: ""; height: 18px; width: 18px; left: 4px; bottom: 4px;
            background-color: white; transition: .3s; border-radius: 50%;
        }
        input:checked + .slider {
            background-color: var(--cyan);
            box-shadow: 0 0 8px var(--cyan);
        }
        input:checked + .slider:before {
            transform: translateX(24px);
        }

        /* ── SAVE BUTTON ── */
        .btn-submit {
            background: var(--cyan); color: #000; font-size: 14px; font-weight: 700;
            padding: 18px; border-radius: 12px; border: none; cursor: pointer;
            text-transform: uppercase; letter-spacing: 0.05em; text-align: center;
            font-family: inherit; margin-top: 12px; display: block; width: 100%;
            box-shadow: 0 6px 0 #008888; transition: transform 0.1s, box-shadow 0.1s;
        }
        .btn-submit:active {
            transform: translateY(3px); box-shadow: 0 3px 0 #008888;
        }

        .btn-back-link {
            text-align: center; margin-top: 20px;
        }
        .btn-back-link a {
            color: var(--muted); font-size: 13px; text-decoration: none; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.05em; transition: color 0.2s;
        }
        .btn-back-link a:hover { color: #fff; }

        /* Error validation */
        .invalid-feedback {
            color: #ff4646; font-size: 12px; font-weight: 600; margin-top: 6px;
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

    <!-- MAIN FORM -->
    <main class="main">
        <div class="admin-container">
            
            <h1 class="form-title">Daily Task</h1>

            <form method="POST" action="{{ isset($task) ? route('admin.daily-tasks.update', $task->id) : route('admin.daily-tasks.store') }}">
                @csrf

                <!-- TASK NAME -->
                <div class="form-group">
                    <label class="form-label">Task Name</label>
                    <input type="text" name="task_name" class="form-control" placeholder="e.g. FINISH 3 LESSONS" value="{{ old('task_name', $task->task_name ?? '') }}" required>
                    @error('task_name')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <!-- TASK TYPE -->
                <div class="form-group">
                    <label class="form-label">Task Type</label>
                    <select name="task_type" class="form-control" required>
                        <option value="FINISH_LESSONS" {{ old('task_type', $task->task_type ?? '') == 'FINISH_LESSONS' ? 'selected' : '' }}>FINISH LESSONS</option>
                        <option value="GAIN_XP" {{ old('task_type', $task->task_type ?? '') == 'GAIN_XP' ? 'selected' : '' }}>GAIN XP</option>
                        <option value="READ_ARTICLE" {{ old('task_type', $task->task_type ?? '') == 'READ_ARTICLE' ? 'selected' : '' }}>READ ARTICLE</option>
                        <option value="LAB_EXPERIMENT" {{ old('task_type', $task->task_type ?? '') == 'LAB_EXPERIMENT' ? 'selected' : '' }}>LAB EXPERIMENT</option>
                        <option value="DAILY_LOGIN" {{ old('task_type', $task->task_type ?? '') == 'DAILY_LOGIN' ? 'selected' : '' }}>DAILY LOGIN</option>
                        <option value="SCORE" {{ old('task_type', $task->task_type ?? '') == 'SCORE' ? 'selected' : '' }}>SCORE</option>
                    </select>
                    @error('task_type')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <!-- DESCRIPTION -->
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="description" rows="4" class="form-control" placeholder="Describe this task details...">{{ old('description', $task->description ?? '') }}</textarea>
                    @error('description')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <!-- TARGET VALUE & XP REWARD -->
                <div class="form-row-2">
                    <div class="form-group">
                        <label class="form-label">Target Value</label>
                        <input type="number" name="target_value" class="form-control" min="1" placeholder="e.g. 3" value="{{ old('target_value', $task->target_value ?? '1') }}" required>
                        @error('target_value')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="form-group">
                        <label class="form-label">XP Reward</label>
                        <input type="number" name="xp_reward" class="form-control" min="0" placeholder="e.g. 500" value="{{ old('xp_reward', $task->xp_reward ?? '100') }}" required>
                        @error('xp_reward')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <!-- TOGGLE IS_ACTIVE -->
                <div class="toggle-container">
                    <span class="toggle-label">Set as default for new users</span>
                    <label class="switch">
                        <input type="checkbox" name="is_active" value="1" {{ old('is_active', $task->is_active ?? true) ? 'checked' : '' }}>
                        <span class="slider"></span>
                    </label>
                </div>

                <!-- DUMMY COPY SWITCH TO EXACTLY MATCH SCREENSHOT (IF DESIRED) -->
                <div class="toggle-container" style="margin-top: -16px; margin-bottom: 40px;">
                    <span class="toggle-label">Set as default for new users</span>
                    <label class="switch">
                        <input type="checkbox" checked disabled>
                        <span class="slider"></span>
                    </label>
                </div>

                <!-- SUBMIT BUTTON -->
                <button type="submit" class="btn-submit">Save</button>

                <div class="btn-back-link">
                    <a href="{{ route('admin.daily-tasks.index') }}">Cancel & Go Back</a>
                </div>
            </form>

        </div>
    </main>
</div>
</body>
</html>
