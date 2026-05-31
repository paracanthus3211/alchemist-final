@extends('layouts.app')

@section('title', 'Quiz — Alchemist')

@push('styles')
    <style>
        /* Flush quiz header to top of main scroll area */
        .main { padding-top: 0 !important; }

        .main-content-wrap {
            width: 100%;
            max-width: 720px;
            margin: 0 auto;
            padding: 0 8px 80px;
            display: flex;
            flex-direction: column;
        }

        /* ── STICKY HEADER WRAPPER ── */
        .quiz-sticky-header {
            position: sticky;
            top: 0;
            z-index: 100;
            background: rgba(8, 13, 14, 0.95);
            backdrop-filter: blur(8px);
            padding: 12px 0 12px;
            margin-bottom: 24px;
            overflow: visible;
        }
        .quiz-header-row {
            display: flex;
            align-items: flex-start;
            gap: 28px;
            width: 100%;
        }
        .quiz-header-row .chapter-banner {
            flex: 1;
            min-width: 0;
            margin-bottom: 0;
            box-sizing: border-box;
        }

        /* ── HEADER STATS — kanan banner (seperti mockup) ── */
        .header-stats {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: flex-start;
            gap: 28px;
            flex-shrink: 0;
            padding-top: 4px;
            white-space: nowrap;
        }
        .stat-item {
            display: flex; align-items: center; gap: 12px;
            font-size: 18px; font-weight: 500; color: #ffffff;
            white-space: nowrap;
        }
        .stat-icon-flame { width: 32px; height: 32px; object-fit: contain; }
        .stat-icon-bolt { width: 32px; height: 32px; object-fit: contain; }

        /* ── CHAPTER BANNER ── (diperbesar tinggi vertikalnya) */
        .chapter-banner {
            border-radius: 16px 16px 6px 6px;
            padding: 24px 20px;  /* ← UBAH: dari 16px menjadi 24px (tambah tinggi) */
            margin-bottom: 0;
            cursor: pointer;
            display: block;
            text-decoration: none;
            color: inherit;
            border: 1px solid rgba(255,255,255,0.03);
            user-select: none;
            transform: translateY(0);
            transition: transform 0.05s, box-shadow 0.05s;
        }
        .chapter-banner:active { transform: translateY(4px); box-shadow: none !important; }

        .chapter-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }

        .chapter-title { font-size: 16px; font-weight: 600; line-height: 1.3; color: #ffffff; font-family: 'Space Grotesk', sans-serif; } /* line-height ditambah */
        .chapter-subtitle { font-size: 12px; color: rgba(255,255,255,0.7); margin-top: 6px; font-weight: 500; line-height: 1.3; font-family: 'Space Grotesk', sans-serif; } /* margin-top ditambah */
        .chapter-pct { font-size: 17px; font-weight: 700; line-height: 1.3; font-family: 'Space Grotesk', sans-serif; }

        .progress-bar-wrap { height: 6px; background: rgba(255, 255, 255, 0.2); border-radius: 99px; margin: 12px 0 10px; overflow: hidden; } /* margin ditambah */
        .progress-bar-fill { height: 100%; border-radius: 99px; transition: width 0.3s ease-in-out; }

        .xp-row { display: flex; align-items: center; gap: 5px; }
        .xp-row img { width: 14px; height: 14px; }
        .xp-row span { font-size: 11px; font-weight: 500; color: rgba(255,255,255,0.7); font-family: 'Space Grotesk', sans-serif; }
        /* ── LEVEL SEPARATOR ── */
        .chapter-separator {
            display: flex; align-items: center; justify-content: center; margin: 24px 0 32px; width: 100%;
        }
        .separator-line { flex: 1; height: 1px; background: rgba(255, 255, 255, 0.1); }
        .separator-text { padding: 0 16px; font-size: 16px; font-weight: 500; color: rgba(255, 255, 255, 0.5); text-transform: lowercase; letter-spacing: 0.05em; }

        /* ── HEX PATH TREE LAYOUT ── */
        .hex-path {
            display: flex; flex-direction: column; align-items: center; gap: 56px;
            margin-top: 8px; position: relative; width: 100%;
            max-width: 420px; margin-left: auto; margin-right: auto;
            padding-bottom: 120px;
        }
        .hex-item { display: flex; flex-direction: column; align-items: center; position: relative; width: 100%; }
        
        /* Zig-zag vertikal seperti referensi */
        .hex-item:nth-child(odd) { transform: translateX(-90px); }
        .hex-item:nth-child(even) { transform: translateX(90px); }

        /* 3D Tactile Hexagon Button */
        .hex-btn {
            --hex-color: #00d4d4; --hex-shadow: #007777;
            width: 120px; height: 138px; position: relative; cursor: pointer; user-select: none;
        }
        .hex-shape { width: 100%; height: 100%; position: absolute; top: 0; left: 0; clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%); }
        .hex-shadow { transform: translateY(6px); background: var(--hex-shadow); transition: transform 0.05s; }
        .hex-top {
            background: var(--hex-color); display: flex; align-items: center; justify-content: center;
            transition: transform 0.05s; border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .hex-top svg { width: 48px; height: 48px; color: #ffffff; opacity: 0.95; }
        .hex-btn:active .hex-top { transform: translateY(6px); }
        .hex-btn:active .hex-shadow { transform: translateY(6px); }

        .hex-label { margin-top: 14px; font-size: 15px; font-weight: 500; color: #ffffff; text-align: center; font-family: 'Space Grotesk', sans-serif; opacity: 0.9; }

        /* ── FAB ── */
        .fab {
            position: fixed; bottom: 32px; right: 32px;
            width: 72px; height: 72px; border-radius: 50%;
            background: var(--cyan); color: #000; font-size: 40px; font-weight: 400;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; box-shadow: 0 6px 24px rgba(0, 212, 212, 0.3);
            transition: transform 0.2s, box-shadow 0.2s; text-decoration: none; border: none; z-index: 100;
        }
        .fab:hover { transform: scale(1.08); box-shadow: 0 8px 32px rgba(0, 212, 212, 0.45); }

        /* ── RESPONSIVE ── */
        @media (max-width: 768px) {
            .quiz-header-row { flex-wrap: wrap; gap: 16px; }
            .header-stats {
                flex-direction: row;
                gap: 24px;
                width: 100%;
                justify-content: center;
                padding-top: 0;
            }
            .hex-item:nth-child(odd) { transform: translateX(-60px); }
            .hex-item:nth-child(even) { transform: translateX(60px); }
            .hex-path { max-width: 100%; }
        }

        /* ── NEW BADGE ── */
        .hex-new-badge {
            position: absolute;
            top: -8px; right: -8px;
            background: #ff4646;
            color: #fff;
            font-size: 9px;
            font-weight: 900;
            letter-spacing: 0.08em;
            padding: 3px 7px;
            border-radius: 100px;
            text-transform: uppercase;
            z-index: 10;
            box-shadow: 0 2px 8px rgba(255,70,70,0.5);
            animation: pulse-badge 1.6s ease-in-out infinite;
        }
        @keyframes pulse-badge {
            0%, 100% { transform: scale(1); box-shadow: 0 2px 8px rgba(255,70,70,0.5); }
            50% { transform: scale(1.12); box-shadow: 0 4px 14px rgba(255,70,70,0.75); }
        }

        /* ── LEVEL POPUP ── */
        .level-popup-backdrop {
            position: fixed; inset: 0; z-index: 5000;
            background: rgba(0, 0, 0, 0.45);
            pointer-events: auto;
            cursor: pointer;
        }
        .level-popup-backdrop[hidden] {
            display: none !important;
            pointer-events: none;
        }
        .level-popup {
            position: fixed; z-index: 5001;
            width: min(300px, calc(100vw - 48px));
            pointer-events: auto;
            animation: levelPopupIn 0.25s ease-out;
            display: flex;
            flex-direction: column;
        }
        @keyframes levelPopupIn {
            from { opacity: 0; transform: translateY(8px) scale(0.96); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .level-popup-tail {
            width: 0; height: 0;
            border-left: 11px solid transparent;
            border-right: 11px solid transparent;
            border-bottom: 12px solid var(--popup-bg, #ff4646);
            margin-bottom: -1px;
        }
        .level-popup-body {
            background: var(--popup-bg, #ff4646);
            border-radius: 16px;
            padding: 10px 14px 10px;
            text-align: center;
            color: #f5f0d0;
        }
        .level-popup-chapter {
            font-size: 15px; font-weight: 600; color: #f5f0d0;
            font-family: 'Space Grotesk', sans-serif;
            line-height: 1.2;
        }
        .level-popup-progress {
            font-size: 11px; font-weight: 500; color: rgba(245, 240, 208, 0.85);
            margin-top: 2px; font-family: 'Space Grotesk', sans-serif;
        }
        .level-popup-name {
            font-size: 36px; font-weight: 700; color: #f5f0d0;
            line-height: 1; margin: 4px 0 2px;
            font-family: 'Space Grotesk', sans-serif;
        }
        .level-popup-requirements {
            font-size: 12px; font-weight: 500; color: #f5f0d0;
            margin-bottom: 8px; font-family: 'Space Grotesk', sans-serif;
            display: flex; flex-direction: column; gap: 2px;
        }
        .level-popup-btn {
            display: flex; align-items: center; justify-content: center;
            width: 100%; height: 34px; border: none; border-radius: 999px;
            background: #f5f0d0; cursor: pointer;
            font-family: 'Space Grotesk', sans-serif;
            font-size: 13px; font-weight: 700; letter-spacing: 0.04em;
            transition: transform 0.1s, opacity 0.1s;
            text-decoration: none;
            color: var(--popup-accent, #ff4646);
        }
        .level-popup.locked .level-popup-btn {
            cursor: default; pointer-events: none;
            color: #1a1a1a;
        }
        .level-popup-btn:active:not(:disabled) { transform: scale(0.98); }
        .level-popup-lock-icon {
            width: 22px; height: 22px;
            display: block;
        }
    </style>
@endpush

@section('content')
@php
    $initialChapter = collect($allChaptersData)->first(fn ($c) => ($c['isActive'] ?? false))
        ?? ($allChaptersData[0] ?? null);
    $initBannerStyle = '';
    if ($initialChapter) {
        $ich = ltrim($initialChapter['color'] ?? '#00d4d4', '#');
        if (strlen($ich) === 6) {
            $ir = hexdec(substr($ich, 0, 2)); $ig = hexdec(substr($ich, 2, 2)); $ib = hexdec(substr($ich, 4, 2));
            $initBannerStyle = 'background: rgb('.round($ir * 0.18).','.round($ig * 0.18).','.round($ib * 0.18).'); box-shadow: 0 6px 0 rgb('.round($ir * 0.10).','.round($ig * 0.10).','.round($ib * 0.10).');';
        }
    }
@endphp
<div class="main-content-wrap">

    <!-- Sticky Header containing stats and chapter banner -->
    <div class="quiz-sticky-header">
        <div class="quiz-header-row">
            <!-- Sticky Global Chapter Banner -->
            <div id="sticky-global-banner" class="chapter-banner" style="transition: background 0.2s, box-shadow 0.2s; {{ $initBannerStyle }}">
                <div class="chapter-header">
                    <div>
                        <div id="g-banner-title" class="chapter-title">{{ $initialChapter['title'] ?? '' }}</div>
                        <div id="g-banner-subtitle" class="chapter-subtitle">{{ $initialChapter ? ($initialChapter['chapterName'] ?? $initialChapter['chapter']->title) : '' }}</div>
                    </div>
                    <div id="g-banner-pct" class="chapter-pct" style="{{ $initialChapter ? 'color:' . $initialChapter['color'] : '' }}">{{ $initialChapter ? $initialChapter['progress'] . ' %' : '' }}</div>
                </div>
                <div class="progress-bar-wrap">
                    <div id="g-banner-progress-fill" class="progress-bar-fill" style="{{ $initialChapter ? 'width:' . $initialChapter['progress'] . '%;background:' . $initialChapter['color'] : '' }}"></div>
                </div>
                <div class="xp-row">
                    <img src="/images/xp.png" alt="XP">
                    <span id="g-banner-xp">{{ $initialChapter ? $initialChapter['earnedXp'] . '/' . ($initialChapter['totalXp'] > 0 ? $initialChapter['totalXp'] : 5) . ' XP' : '' }}</span>
                </div>
            </div>

            <!-- Streak & total XP — right of banner -->
            <div class="header-stats">
                <div class="stat-item">
                    <img src="/images/streak.png" alt="Streak" class="stat-icon-flame">
                    <span>{{ $user->streak_count ?? 0 }} streak</span>
                </div>
                <div class="stat-item">
                    <img src="/images/xp.png" alt="XP" class="stat-icon-bolt">
                    <span>{{ $user->xp ?? 0 }}</span>
                </div>
            </div>
        </div>
    </div>

    @foreach($allChaptersData as $cData)
    @php
        $chColor = $cData['color'];
        
        // Parse hex color to RGB for background blending
        $hex = ltrim($chColor, '#');
        // Handle invalid hex by providing a default
        $r = 0; $g = 212; $b = 212;
        if(strlen($hex) == 6) {
            $r = hexdec(substr($hex, 0, 2));
            $g = hexdec(substr($hex, 2, 2));
            $b = hexdec(substr($hex, 4, 2));
        }

        // Blend with black (82% black, 18% color)
        $bgR = round($r * 0.18);
        $bgG = round($g * 0.18);
        $bgB = round($b * 0.18);
        $baseBgColor = "rgb($bgR, $bgG, $bgB)";

        // Blend with black (90% black, 10% color) for shadow
        $shR = round($r * 0.10);
        $shG = round($g * 0.10);
        $shB = round($b * 0.10);
        $shadowColorHex = "rgb($shR, $shG, $shB)";
        
        $opacity = $cData['isLocked'] ? '0.4' : '1';
        $pointerEvents = $cData['isLocked'] ? 'none' : 'auto';
        $chapterNum = $cData['chapter']->order_index > 0 ? $cData['chapter']->order_index : $cData['chapter']->id;
    @endphp
    <div class="chapter-section"
         @if($cData['isActive'] ?? false) data-is-active="1" @endif
         style="opacity: {{ $opacity }}; pointer-events: {{ $pointerEvents }};">

        <!-- Chapter Separator -->
        <div class="chapter-separator"
             data-banner-title="{{ $cData['title'] }}"
             data-banner-chapter-name="{{ $cData['chapterName'] }}"
             data-banner-active-level="{{ $cData['activeLevelName'] }}"
             data-banner-progress="{{ (int) $cData['progress'] }}"
             data-banner-color="{{ $cData['color'] }}"
             data-banner-earned-xp="{{ (int) $cData['earnedXp'] }}"
             data-banner-total-xp="{{ (int) $cData['totalXp'] }}">
            <div class="separator-line"></div>
            <div class="separator-text">{{ $cData['chapter']->title }}</div>
            <div class="separator-line"></div>
        </div>

        <!-- Staggered 3D Hexagon Levels -->
        <div class="hex-path">
            @php
                // Compute shadow for hex
                $hexBase = ltrim($chColor, '#');
                $hr = 0; $hg = 212; $hb = 212;
                if(strlen($hexBase) == 6) {
                    $hr = hexdec(substr($hexBase, 0, 2));
                    $hg = hexdec(substr($hexBase, 2, 2));
                    $hb = hexdec(substr($hexBase, 4, 2));
                }
                // Darken by 40% for shadow
                $hsR = max(0, $hr - 100);
                $hsG = max(0, $hg - 100);
                $hsB = max(0, $hb - 100);
                $hexShadow = "rgb($hsR, $hsG, $hsB)";
            @endphp
            @if($cData['levelData']->isNotEmpty())
                @php $totalLevelsInChapter = $cData['levelData']->count(); @endphp
                @foreach($cData['levelData'] as $index => $ld)
                    @php
                        $level  = $ld['level'];
                        $hasNew = $ld['hasNew'];
                        $isDone = $ld['isDone'];
                        $chapterNum = $cData['chapter']->order_index > 0 ? $cData['chapter']->order_index : $cData['chapter']->id;
                    @endphp
                    <div class="hex-item">
                        <button type="button"
                            class="hex-level-trigger"
                            style="background: none; border: none; padding: 0; cursor: pointer; position: relative;"
                            data-chapter-num="{{ $chapterNum }}"
                            data-chapter-name="{{ $cData['chapter']->title }}"
                            data-level-num="{{ $ld['levelIndex'] }}"
                            data-level-name="{{ $level->name }}"
                            data-total-levels="{{ $totalLevelsInChapter }}"
                            data-is-unlocked="{{ $ld['isUnlocked'] ? '1' : '0' }}"
                            data-needs-xp="{{ $ld['isXpMet'] ? '0' : '1' }}"
                            data-needs-prev="{{ $ld['isPrevDone'] ? '0' : '1' }}"
                            data-xp-required="{{ $ld['xpRequired'] }}"
                            data-play-url="{{ route('quiz.play', $level->id) }}"
                            data-chapter-color="{{ $chColor }}"
                            data-side="{{ $index % 2 === 0 ? 'left' : 'right' }}"
                            aria-label="Level {{ $level->name }}">
                            @if($hasNew)
                                <span class="hex-new-badge">NEW</span>
                            @endif
                            <div class="hex-btn" style="--hex-color: {{ $chColor }}; --hex-shadow: {{ $hexShadow }};">
                                <div class="hex-shape hex-shadow"></div>
                                <div class="hex-shape hex-top">
                                    <svg viewBox="0 0 24 24" fill="currentColor">
                                        <path d="M19 6h-1.5V4.5c0-.83-.67-1.5-1.5-1.5h-8c-.83 0-1.5.67-1.5 1.5V6H5c-1.1 0-2 .9-2 2v11c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm-6 12.5H7v-2h6v2zm4-4H7v-2h10v2zm0-4H7V8h10v2z"/>
                                    </svg>
                                </div>
                            </div>
                        </button>
                        <div class="hex-label">{{ $level->name }}</div>
                    </div>
                @endforeach
            @else
                <!-- Beautiful Fallback Hexagons exactly like the screenshot -->
                <div class="hex-item">
                    <div class="hex-btn" style="--hex-color: {{ $chColor }}; --hex-shadow: {{ $hexShadow }};">
                        <div class="hex-shape hex-shadow"></div>
                        <div class="hex-shape hex-top">
                            <svg viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2L2 22h20L12 2zm0 3.99L19.53 19H4.47L12 5.99z"/>
                            </svg>
                        </div>
                    </div>
                    <div class="hex-label">New Level</div>
                </div>
            @endif
        </div>
    </div>
    @endforeach
</div>

<!-- Floating Action Button -->
<a href="{{ route('admin.quiz.index') }}" class="fab">+</a>

<!-- Level info popup (shown on hex tap) -->
<div id="level-popup-backdrop" class="level-popup-backdrop" hidden></div>
<div id="level-popup" class="level-popup" hidden role="dialog" aria-modal="true" aria-labelledby="level-popup-chapter" style="--popup-bg: #ff4646; --popup-accent: #ff4646;">
    <div id="level-popup-tail" class="level-popup-tail" style="margin-left: 24px;"></div>
    <div class="level-popup-body">
        <div id="level-popup-chapter" class="level-popup-chapter"></div>
        <div id="level-popup-progress" class="level-popup-progress"></div>
        <div id="level-popup-name" class="level-popup-name"></div>
        <div id="level-popup-requirements" class="level-popup-requirements" hidden></div>
        <a id="level-popup-btn" class="level-popup-btn" href="#">Start Quiz</a>
    </div>
</div>
@endsection

@push('scripts')
<script>

    window.QuizLevelPopup = window.QuizLevelPopup || { activeTrigger: null };

    function quizPopupIsOpen() {
        const popup = document.getElementById('level-popup');
        return popup !== null && !popup.hasAttribute('hidden');
    }

    function quizPopupDismiss() {
        const backdrop = document.getElementById('level-popup-backdrop');
        const popup = document.getElementById('level-popup');
        if (!popup) return;
        backdrop?.setAttribute('hidden', '');
        popup.setAttribute('hidden', '');
        window.QuizLevelPopup.activeTrigger = null;
    }

    function quizPopupHandleOutsideEvent(e) {
        if (!quizPopupIsOpen()) return;

        const popup = document.getElementById('level-popup');
        const backdrop = document.getElementById('level-popup-backdrop');
        if (!popup) return;

        if (popup.contains(e.target)) return;
        if (e.target.closest('.hex-level-trigger')) return;

        if (e.target === backdrop || backdrop?.contains(e.target)) {
            e.preventDefault();
            quizPopupDismiss();
            return;
        }

        quizPopupDismiss();
    }

    if (!window.__quizPopupDismissBound) {
        window.__quizPopupDismissBound = true;
        document.addEventListener('click', (e) => {
            if (e.target.closest('#level-popup-backdrop')) {
                e.preventDefault();
                quizPopupDismiss();
            }
        }, true);
        document.addEventListener('click', quizPopupHandleOutsideEvent, true);
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') quizPopupDismiss();
        });
    }

    function initLevelPopup() {
        const backdrop = document.getElementById('level-popup-backdrop');
        const popup = document.getElementById('level-popup');
        const tail = document.getElementById('level-popup-tail');
        const elChapter = document.getElementById('level-popup-chapter');
        const elProgress = document.getElementById('level-popup-progress');
        const elName = document.getElementById('level-popup-name');
        const elRequirements = document.getElementById('level-popup-requirements');
        const btn = document.getElementById('level-popup-btn');

        if (!backdrop || !popup || !btn) return;

        const state = window.QuizLevelPopup;
        state.backdrop = backdrop;
        state.popup = popup;
        state.tail = tail;
        state.activeTrigger = state.activeTrigger || null;

        if (popup.dataset.popupClickBound !== '1') {
            popup.dataset.popupClickBound = '1';
            popup.addEventListener('click', (e) => e.stopPropagation());
        }

        function hidePopup() {
            quizPopupDismiss();
        }
        state.hidePopup = hidePopup;

        function isPopupOpen() {
            return quizPopupIsOpen();
        }

        function getContentBounds() {
            const main = document.querySelector('.main');
            const pad = 16;
            if (main) {
                const r = main.getBoundingClientRect();
                return {
                    left: r.left + pad,
                    right: r.right - pad,
                    top: r.top + pad,
                    bottom: r.bottom - pad,
                };
            }
            const sidebar = document.querySelector('.sidebar');
            const left = sidebar ? sidebar.getBoundingClientRect().right + pad : pad;
            return {
                left,
                right: window.innerWidth - pad,
                top: pad,
                bottom: window.innerHeight - pad,
            };
        }


        function blendChapterColor(hex, blackRatio) {
            const raw = (hex || '#ff4646').replace('#', '');
            if (raw.length !== 6) return '#4a5244';
            const r = Math.round(parseInt(raw.slice(0, 2), 16) * (1 - blackRatio));
            const g = Math.round(parseInt(raw.slice(2, 4), 16) * (1 - blackRatio));
            const b = Math.round(parseInt(raw.slice(4, 6), 16) * (1 - blackRatio));
            return `rgb(${r}, ${g}, ${b})`;
        }

        function applyPopupColors(chapterColor, isUnlocked) {
            const bg = isUnlocked ? chapterColor : blendChapterColor(chapterColor, 0.5);
            popup.style.setProperty('--popup-bg', bg);
            popup.style.setProperty('--popup-accent', chapterColor);
        }

        function rectsOverlap(a, b, margin) {
            return !(
                a.right + margin < b.left ||
                a.left - margin > b.right ||
                a.bottom + margin < b.top ||
                a.top - margin > b.bottom
            );
        }

        function positionPopup(trigger) {
            const rect = trigger.getBoundingClientRect();
            const item = trigger.closest('.hex-item');
            const itemRect = item ? item.getBoundingClientRect() : rect;
            const bounds = getContentBounds();
            const maxWidth = bounds.right - bounds.left;
            const popupWidth = Math.min(300, maxWidth);
            const side = trigger.getAttribute('data-side') || 'left';
            const otherTriggers = [...document.querySelectorAll('.hex-level-trigger')].filter(t => t !== trigger);
            const gap = 20;
            const margin = 16;
            const centerX = rect.left + rect.width / 2;

            popup.style.width = popupWidth + 'px';
            popup.removeAttribute('hidden');
            popup.style.visibility = 'hidden';
            popup.style.left = '-9999px';
            popup.style.top = '0';
            const popupHeight = popup.offsetHeight;

            let top = itemRect.bottom + gap;
            if (top + popupHeight > bounds.bottom) {
                top = bounds.bottom - popupHeight;
            }
            if (top < bounds.top) {
                top = bounds.top;
            }

            function clampLeft(left) {
                return Math.max(bounds.left, Math.min(left, bounds.right - popupWidth));
            }

            function popupRect(left) {
                return { top, left, right: left + popupWidth, bottom: top + popupHeight };
            }

            function isClear(left) {
                const box = popupRect(left);
                return !otherTriggers.some(t => rectsOverlap(box, t.getBoundingClientRect(), margin));
            }

            const shiftSteps = [0, 20, 40];
            const candidates = [clampLeft(centerX - popupWidth / 2)];
            if (side === 'left') {
                shiftSteps.forEach(shift => {
                    candidates.push(clampLeft(centerX - popupWidth + 12 - shift));
                });
            } else {
                shiftSteps.forEach(shift => {
                    candidates.push(clampLeft(centerX - 12 + shift));
                });
            }

            let left = candidates.find(l => isClear(l));
            if (left === undefined) {
                left = candidates[0];
            }

            popup.style.left = left + 'px';
            popup.style.top = top + 'px';
            popup.style.visibility = '';

            const tailOffset = Math.max(16, Math.min(
                centerX - left - 11,
                popupWidth - 40
            ));
            tail.style.marginLeft = tailOffset + 'px';
        }

        function scrollToFitPopup(trigger) {
            const scrollContainer = document.querySelector('.main');
            if (!scrollContainer) return;

            const padding = 24;
            const item = trigger.closest('.hex-item') || trigger;

            requestAnimationFrame(() => {
                positionPopup(trigger);

                const stickyHeader = document.querySelector('.quiz-sticky-header');
                const headerBottom = stickyHeader
                    ? stickyHeader.getBoundingClientRect().bottom
                    : padding;

                const bounds = getContentBounds();
                const popupRect = popup.getBoundingClientRect();
                const itemRect = item.getBoundingClientRect();
                const alignAnchor = headerBottom + (bounds.bottom - headerBottom) * 0.3;

                let scrollDelta = 0;

                if (popupRect.bottom > bounds.bottom - padding) {
                    scrollDelta += popupRect.bottom - (bounds.bottom - padding);
                }

                if (itemRect.top < alignAnchor) {
                    scrollDelta += itemRect.top - alignAnchor;
                }

                if (Math.abs(scrollDelta) < 1) return;

                scrollContainer.scrollBy({ top: scrollDelta, behavior: 'smooth' });

                let rafId;
                const syncPosition = () => {
                    positionPopup(trigger);
                    rafId = requestAnimationFrame(syncPosition);
                };
                rafId = requestAnimationFrame(syncPosition);

                const stopSync = () => {
                    cancelAnimationFrame(rafId);
                    positionPopup(trigger);
                };

                scrollContainer.addEventListener('scroll', stopSync, { passive: true });
                setTimeout(() => {
                    scrollContainer.removeEventListener('scroll', stopSync);
                    stopSync();
                }, 550);
            });
        }

        function showPopup(trigger) {
            const chapterNum = trigger.getAttribute('data-chapter-num');
            const chapterName = trigger.getAttribute('data-chapter-name');
            const levelNum = trigger.getAttribute('data-level-num');
            const levelName = trigger.getAttribute('data-level-name');
            const totalLevels = trigger.getAttribute('data-total-levels');
            const isUnlocked = trigger.getAttribute('data-is-unlocked') === '1';
            const needsXp = trigger.getAttribute('data-needs-xp') === '1';
            const needsPrev = trigger.getAttribute('data-needs-prev') === '1';
            const xpRequired = trigger.getAttribute('data-xp-required');
            const playUrl = trigger.getAttribute('data-play-url');
            const chapterColor = trigger.getAttribute('data-chapter-color') || '#ff4646';

            applyPopupColors(chapterColor, isUnlocked);

            elChapter.textContent = 'Chapter ' + chapterNum + ', ' + chapterName;
            elProgress.textContent = levelNum + ' out of ' + totalLevels + ' level';
            elName.textContent = levelName;

            elRequirements.innerHTML = '';
            if (!isUnlocked) {
                popup.classList.remove('unlocked');
                popup.classList.add('locked');
                if (needsXp) {
                    const xpLine = document.createElement('span');
                    xpLine.textContent = 'Reach ' + Number(xpRequired).toLocaleString() + ' XP';
                    elRequirements.appendChild(xpLine);
                }
                if (needsPrev) {
                    const prevLine = document.createElement('span');
                    prevLine.textContent = 'Finish previous level';
                    elRequirements.appendChild(prevLine);
                }
                elRequirements.hidden = elRequirements.children.length === 0;
                btn.textContent = '';
                btn.innerHTML = '<svg class="level-popup-lock-icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M17 10V8a5 5 0 00-10 0v2H5v12h14V10h-2zm-8 0V8a3 3 0 016 0v2H9z" fill="#1a1a1a"/></svg>';
                btn.removeAttribute('href');
            } else {
                popup.classList.remove('locked');
                popup.classList.add('unlocked');
                elRequirements.hidden = true;
                btn.textContent = 'Start Quiz';
                btn.style.color = chapterColor;
                btn.setAttribute('href', playUrl);
            }

            state.activeTrigger = trigger;
            backdrop.removeAttribute('hidden');
            popup.removeAttribute('hidden');
            positionPopup(trigger);
            scrollToFitPopup(trigger);
        }

        const scrollContainer = document.querySelector('.main');
        let popupScrollTicking = false;

        document.querySelectorAll('.hex-level-trigger').forEach(trigger => {
            if (trigger.dataset.popupBound === '1') return;
            trigger.dataset.popupBound = '1';
            trigger.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                if (state.activeTrigger === trigger && isPopupOpen()) {
                    hidePopup();
                    return;
                }
                showPopup(trigger);
            });
        });

        if (scrollContainer && scrollContainer.dataset.popupScrollBound !== '1') {
            scrollContainer.dataset.popupScrollBound = '1';
            scrollContainer.addEventListener('scroll', () => {
                if (!quizPopupIsOpen() || !state.activeTrigger) return;
                if (popupScrollTicking) return;
                popupScrollTicking = true;
                requestAnimationFrame(() => {
                    positionPopup(state.activeTrigger);
                    popupScrollTicking = false;
                });
            }, { passive: true });
        }

        if (!window.__quizPopupResizeBound) {
            window.__quizPopupResizeBound = true;
            window.addEventListener('resize', () => {
                if (quizPopupIsOpen() && state.activeTrigger) {
                    positionPopup(state.activeTrigger);
                }
            });
        }
    }

    document.addEventListener('livewire:navigated', initLevelPopup);
    document.addEventListener('DOMContentLoaded', initLevelPopup);
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        initLevelPopup();
    }

    // ── Sticky Chapter Banner Sync (update banner on scroll) ──
    function hexToRgb(hex) {
        if (!hex) return null;
        const raw = String(hex).replace('#', '').trim();
        if (raw.length !== 6) return null;
        const r = parseInt(raw.slice(0, 2), 16);
        const g = parseInt(raw.slice(2, 4), 16);
        const b = parseInt(raw.slice(4, 6), 16);
        if ([r, g, b].some(n => Number.isNaN(n))) return null;
        return { r, g, b };
    }

    function blendedRgb(rgb, ratio) {
        // ratio = how much original color to keep (0..1); rest is black
        const r = Math.round(rgb.r * ratio);
        const g = Math.round(rgb.g * ratio);
        const b = Math.round(rgb.b * ratio);
        return `rgb(${r},${g},${b})`;
    }

    function setGlobalBannerFromSeparator(sepEl) {
        if (!sepEl) return;

        const title = sepEl.getAttribute('data-banner-title') || '';
        const chapterName = sepEl.getAttribute('data-banner-chapter-name') || '';
        const activeLevel = sepEl.getAttribute('data-banner-active-level') || '';
        const progress = parseInt(sepEl.getAttribute('data-banner-progress') || '0', 10) || 0;
        const color = sepEl.getAttribute('data-banner-color') || '#00d4d4';
        const earnedXp = parseInt(sepEl.getAttribute('data-banner-earned-xp') || '0', 10) || 0;
        const totalXpRaw = parseInt(sepEl.getAttribute('data-banner-total-xp') || '0', 10) || 0;
        const totalXp = totalXpRaw > 0 ? totalXpRaw : 5;

        const banner = document.getElementById('sticky-global-banner');
        const elTitle = document.getElementById('g-banner-title');
        const elSubtitle = document.getElementById('g-banner-subtitle');
        const elPct = document.getElementById('g-banner-pct');
        const elFill = document.getElementById('g-banner-progress-fill');
        const elXp = document.getElementById('g-banner-xp');
        if (!banner || !elTitle || !elSubtitle || !elPct || !elFill || !elXp) return;

        // Subtitle shows chapter name + active level (requested: chapter & level update)
        const subtitle = (chapterName && activeLevel)
            ? `${chapterName} • ${activeLevel}`
            : (chapterName || activeLevel);

        elTitle.textContent = title;
        elSubtitle.textContent = subtitle;
        elPct.textContent = `${progress} %`;
        elPct.style.color = color;
        elFill.style.width = `${progress}%`;
        elFill.style.background = color;
        elXp.textContent = `${earnedXp}/${totalXp} XP`;

        // Banner bg/shadow follow the same formula used on initial render
        const rgb = hexToRgb(color);
        if (rgb) {
            const bg = blendedRgb(rgb, 0.18);
            const shadow = blendedRgb(rgb, 0.10);
            banner.style.background = bg;
            banner.style.boxShadow = `0 6px 0 ${shadow}`;
        } else {
            banner.style.background = 'rgba(0, 212, 212, 0.12)';
            banner.style.boxShadow = '0 6px 0 rgba(0, 212, 212, 0.08)';
        }
    }

    function initStickyBannerSync() {
        const scrollRoot = document.querySelector('.main') || null;
        const stickyHeader = document.querySelector('.quiz-sticky-header');
        const headerH = stickyHeader ? stickyHeader.getBoundingClientRect().height : 0;

        const separators = Array.from(document.querySelectorAll('.chapter-separator'));
        if (separators.length === 0) return;

        let current = null;
        const setActive = (el) => {
            if (!el || el === current) return;
            current = el;
            setGlobalBannerFromSeparator(el);
        };

        if ('IntersectionObserver' in window) {
            const obs = new IntersectionObserver((entries) => {
                // Pick the intersecting separator closest to the top
                const hits = entries
                    .filter(e => e.isIntersecting)
                    .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
                if (hits.length > 0) setActive(hits[0].target);
            }, {
                root: scrollRoot,
                threshold: 0,
                // Trigger when separator passes below the sticky header
                rootMargin: `-${Math.round(headerH + 8)}px 0px -70% 0px`,
            });

            separators.forEach(s => obs.observe(s));

            // Set initial based on first visible separator
            requestAnimationFrame(() => {
                // Find separator closest to top (below header)
                const rootRect = (scrollRoot || document.documentElement).getBoundingClientRect();
                const anchorY = (stickyHeader ? stickyHeader.getBoundingClientRect().bottom : rootRect.top) + 8;
                let best = separators[0];
                let bestDist = Infinity;
                separators.forEach(s => {
                    const r = s.getBoundingClientRect();
                    const d = Math.abs(r.top - anchorY);
                    if (d < bestDist) { bestDist = d; best = s; }
                });
                setActive(best);
            });
            return;
        }

        // Fallback (no IntersectionObserver): scroll listener
        const onScroll = () => {
            const rootRect = (scrollRoot || document.documentElement).getBoundingClientRect();
            const anchorY = (stickyHeader ? stickyHeader.getBoundingClientRect().bottom : rootRect.top) + 8;
            let best = separators[0];
            let bestDist = Infinity;
            separators.forEach(s => {
                const r = s.getBoundingClientRect();
                const d = Math.abs(r.top - anchorY);
                if (d < bestDist) { bestDist = d; best = s; }
            });
            setActive(best);
        };
        (scrollRoot || window).addEventListener('scroll', onScroll, { passive: true });
        onScroll();
    }

    document.addEventListener('livewire:navigated', initStickyBannerSync);
    document.addEventListener('DOMContentLoaded', initStickyBannerSync);
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        initStickyBannerSync();
    }
</script>
@endpush
