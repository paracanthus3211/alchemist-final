@extends('layouts.app')

@section('title', 'Home — Alchemist')

@push('styles')
    <style>
        .main-content-wrap {
            max-width: 680px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
        }

        /* ── STREAK CARD ── */
        .streak-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 20px 24px;
            margin-bottom: 20px;
            display: flex; align-items: center; gap: 24px;
        }

        .streak-left { display: flex; align-items: center; gap: 14px; }
        .streak-fire-img { width: 48px; height: 48px; object-fit: contain; }
        .streak-count { font-size: 42px; font-weight: 900; line-height: 1; color: #fff; }

        .streak-days { display: flex; gap: 10px; margin-left: auto; }
        .day-pill {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            width: 52px; height: 60px; border-radius: 14px;
            background: rgba(255, 255, 255, 0.04);
            transition: all 0.2s; gap: 2px;
        }
        .day-pill.today { background: var(--lime); }
        .day-pill .day-label {
            font-size: 12.5px; font-weight: 500; color: rgba(255, 255, 255, 0.7); text-transform: capitalize;
        }
        .day-pill .day-date {
            font-size: 10px; font-weight: 400; color: rgba(255, 255, 255, 0.45);
        }
        .day-pill.today .day-label { color: #021a1a !important; font-weight: 700; }
        .day-pill.today .day-date  { color: rgba(2, 26, 26, 0.65) !important; }

        /* ── CHAPTER BANNER ── */
        .chapter-banner {
            border-radius: 20px 20px 8px 8px;
            padding: 24px 28px; margin-bottom: 32px; cursor: pointer;
            display: block; text-decoration: none; color: inherit;
            border: 1px solid rgba(255,255,255,0.03); user-select: none;
            transform: translateY(0); transition: transform 0.05s, box-shadow 0.05s;
        }
        .chapter-banner:active { transform: translateY(6px); box-shadow: none !important; }
        .chapter-header { display: flex; justify-content: space-between; align-items: flex-start; }
        .chapter-title { font-size: 24px; font-weight: 500; color: #ffffff; font-family: 'Space Grotesk', sans-serif; }
        .chapter-subtitle { font-size: 16px; color: rgba(255,255,255,0.7); margin-top: 6px; font-weight: 500; font-family: 'Space Grotesk', sans-serif; }
        .chapter-pct { font-size: 26px; font-weight: 700; font-family: 'Space Grotesk', sans-serif; }

        .progress-bar-wrap { height: 7px; background: rgba(255, 255, 255, 0.2); border-radius: 99px; margin: 16px 0 12px; overflow: hidden; }
        .progress-bar-fill { height: 100%; border-radius: 99px; transition: width 0.3s ease-in-out; }
        .xp-row { display: flex; align-items: center; gap: 8px; }
        .xp-row .bolt { font-size: 16px; }
        .xp-row span { font-size: 14px; font-weight: 500; color: rgba(255,255,255,0.7); font-family: 'Space Grotesk', sans-serif; }

        /* ── SECTION LABEL ── */
        .section-label {
            font-size: 12px; font-weight: 700; letter-spacing: 0.1em;
            text-transform: uppercase; color: var(--muted); margin-bottom: 14px;
        }

        /* ── CONTINUE READING ── */
        .continue-reading-label {
            font-size: 26px !important; font-weight: 400 !important; color: #ffffff !important;
            text-transform: none !important; letter-spacing: normal !important;
            margin-bottom: 20px !important; font-family: 'Space Grotesk', sans-serif;
        }
        
        .reading-card {
            background: transparent; border: none; border-radius: 0;
            overflow: visible; margin-bottom: 36px; display: flex; flex-direction: column; gap: 16px;
        }
        .reading-thumb { width: 100%; height: 260px; object-fit: cover; border-radius: 16px; background: #1a2a2a; display: block; }
        .reading-thumb-placeholder { width: 100%; height: 260px; border-radius: 16px; background: linear-gradient(135deg, #0f2a2a, #1a3a3a); display: flex; align-items: center; justify-content: center; font-size: 48px; }
        .reading-body { padding: 0; display: flex; flex-direction: column; gap: 16px; }
        .reading-title { font-size: 24px; font-weight: 700; color: #ffffff; margin: 0; font-family: 'Inter', sans-serif; }
        .reading-desc { font-size: 15px; color: #ffffff; font-weight: 500; line-height: 1.6; margin: 0; opacity: 0.9; font-family: 'Inter', sans-serif; }

        .btn-read {
            display: inline-flex; align-items: center; justify-content: center; width: 240px;
            background: linear-gradient(135deg, #00d4d4 0%, #009999 100%); color: #031415;
            font-size: 13px; font-weight: 900; letter-spacing: 0.12em; text-transform: uppercase;
            padding: 16px 0; border-radius: 12px; text-align: center; text-decoration: none;
            border: none; cursor: pointer; font-family: inherit; box-shadow: 0 6px 0 #005a5a;
            transform: translateY(0); transition: transform 0.05s, box-shadow 0.05s;
        }
        .btn-read:hover { opacity: 0.95; }
        .btn-read:active { transform: translateY(6px); box-shadow: none; }

        /* ── DAILY TASKS ── */
        .tasks-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; margin-top: 8px; }
        .tasks-completed { font-size: 12.5px; color: rgba(255, 255, 255, 0.5); font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; }
        .task-item { display: flex; align-items: center; justify-content: space-between; gap: 24px; padding: 16px 0; margin-bottom: 20px; background: transparent; border: none; }
        .task-body { flex: 1; display: flex; flex-direction: column; gap: 14px; }
        .task-name { font-size: 15px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: var(--cyan); }
        .task-bar-wrap { height: 18px; background: rgba(255, 255, 255, 0.07); border-radius: 99px; overflow: hidden; width: 100%; max-width: 500px; }
        .task-bar-fill { height: 100%; border-radius: 99px; background: linear-gradient(90deg, var(--lime) 0%, var(--cyan) 100%); transition: width 0.3s ease-in-out; }
        .task-reward { display: flex; flex-direction: column; align-items: center; justify-content: center; flex-shrink: 0; width: 80px; }
        .task-gift-img { width: 56px; height: 56px; object-fit: contain; }
        .task-xp { font-size: 13.5px; font-weight: 900; color: var(--lime); margin-top: 6px; letter-spacing: 0.02em; }

        /* ── FAB ── */
        .fab {
            position: fixed; bottom: 32px; right: 32px;
            width: 72px; height: 72px; border-radius: 50%;
            background: #00d4d4; color: #000000; font-size: 40px; font-weight: 400;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; box-shadow: 0 6px 24px rgba(0,212,212,0.3);
            transition: transform 0.2s, box-shadow 0.2s; text-decoration: none; border: none; z-index: 100;
        }
        .fab:hover { transform: scale(1.08); box-shadow: 0 8px 32px rgba(0,212,212,0.45); }

        @media (max-width: 768px) {
            .streak-days { display: none; }
        }
    </style>
@endpush

@section('content')
<div class="main-content-wrap">
    <!-- Streak Card -->
    <div class="streak-card">
        <div class="streak-left">
            <img src="/images/streak.png" alt="Streak" class="streak-fire-img">
            <span class="streak-count">{{ $user->streak_count ?? 0 }}</span>
        </div>
        <div class="streak-days">
            @foreach($days as $day)
                <div class="day-pill {{ $day['isToday'] ? 'today' : '' }}">
                    <span class="day-label">{{ $day['label'] }}</span>
                    <span class="day-date">{{ $day['date'] }}</span>
                </div>
            @endforeach
        </div>
    </div>

    <!-- Chapter Banner -->
    @if($activeChapter)
    @php
        $chColor = $chapterColor ?? '#00FBFF';
        
        $hex = ltrim($chColor, '#');
        if (strlen($hex) == 6) {
            $r = hexdec(substr($hex, 0, 2));
            $g = hexdec(substr($hex, 2, 2));
            $b = hexdec(substr($hex, 4, 2));
        } else {
            $r = 0; $g = 212; $b = 212;
        }

        $bgR = round($r * 0.18);
        $bgG = round($g * 0.18);
        $bgB = round($b * 0.18);
        $baseBgColor = "rgb($bgR, $bgG, $bgB)";

        $shR = round($r * 0.10);
        $shG = round($g * 0.10);
        $shB = round($b * 0.10);
        $shadowColorHex = "rgb($shR, $shG, $shB)";
        
        $formattedTitle = 'Chapter ' . $activeChapter->order_index . ' - ' . ucfirst(strtolower($activeChapter->title));
        $formattedLevel = !empty($activeLevelName) ? ucfirst(strtolower($activeLevelName)) : '';
        $pct = round($chapterProgress);
    @endphp
    <a href="/quiz" class="chapter-banner" style="background: {{ $baseBgColor }}; box-shadow: 0 6px 0 {{ $shadowColorHex }};">
        <div class="chapter-header">
            <div>
                <div class="chapter-title">{{ $formattedTitle }}</div>
                @if($formattedLevel)
                <div class="chapter-subtitle">{{ $formattedLevel }}</div>
                @endif
            </div>
            <div class="chapter-pct" style="color: {{ $chColor }};">{{ $pct }} %</div>
        </div>
        <div class="progress-bar-wrap">
            <div class="progress-bar-fill" style="width: {{ $pct }}%; background: {{ $chColor }}; box-shadow: 0 0 6px {{ $chColor }};"></div>
        </div>
        <div class="xp-row">
            <span class="bolt" style="color: {{ $chColor }};">⚡</span>
            <span>{{ $chapterEarnedXp }}/{{ $chapterTotalXp > 0 ? $chapterTotalXp : 550 }} XP</span>
        </div>
    </a>
    @endif

    <!-- Continue Reading -->
    <div class="section-label continue-reading-label">Continue Reading</div>
    @if($latestArticle)
    <div class="reading-card">
        @if($latestArticle->thumbnail_url)
            <img src="{{ $latestArticle->thumbnail_url }}" alt="{{ $latestArticle->title }}" class="reading-thumb">
        @else
            <div class="reading-thumb-placeholder">🧪</div>
        @endif
        <div class="reading-body">
            <div class="reading-title">{{ $latestArticle->title }}</div>
            <div class="reading-desc">{{ Str::limit($latestArticle->description, 100) }}</div>
            <a href="/articles/{{ $latestArticle->id }}" class="btn-read" style="text-decoration: none;">READ ARTICLE</a>
        </div>
    </div>
    @else
    <div class="reading-card">
        <div class="reading-thumb-placeholder">📚</div>
        <div class="reading-body">
            <div class="reading-title">No articles yet</div>
            <div class="reading-desc">Articles will appear here once added by the admin.</div>
        </div>
    </div>
    @endif

    <!-- Daily Tasks -->
    <div class="tasks-header">
        <div class="section-label" style="margin-bottom:0">Daily Task</div>
        <div class="tasks-completed">{{ $completedCount }}/{{ $totalCount }} COMPLETED</div>
    </div>

    @foreach($dailyTasks as $task)
    @php
        $pct = min(100, max(0, $task->target_value > 0 ? ($task->current_progress / $task->target_value) * 100 : 0));
    @endphp
    <div class="task-item">
        <div class="task-body">
            <div class="task-name">{{ $task->task_name }}</div>
            <div class="task-bar-wrap">
                <div class="task-bar-fill" style="width: {{ $pct }}%"></div>
            </div>
        </div>
        <div class="task-reward">
            <img src="/images/gift.png" alt="Gift" class="task-gift-img">
            <span class="task-xp">+{{ $task->xp_reward }}xp</span>
        </div>
    </div>
    @endforeach

</div>

<!-- FAB -->
@if(auth()->user()->role === 'ADMIN')
<a href="{{ route('admin.daily-tasks.index') }}" class="fab" title="Daily Tasks">+</a>
@endif
@endsection
