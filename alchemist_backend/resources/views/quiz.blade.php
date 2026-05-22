@extends('layouts.app')

@section('title', 'Quiz — Alchemist')

@push('styles')
    <style>
        .main-content-wrap {
            max-width: 680px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
        }

        /* ── HEADER STATS (STREAK & XP) ── */
        .header-stats {
            display: flex; align-items: center; justify-content: center;
            gap: 80px; margin-bottom: 32px; padding: 8px 0;
        }
        .stat-item {
            display: flex; align-items: center; gap: 12px;
            font-size: 18px; font-weight: 500; color: #ffffff;
        }
        .stat-icon-flame { width: 32px; height: 32px; object-fit: contain; }
        .stat-icon-bolt { font-size: 28px; line-height: 1; font-weight: 900; }

        /* ── CHAPTER BANNER ── */
        .chapter-banner {
            border-radius: 20px 20px 8px 8px; /* Asymmetrical corners */
            padding: 24px 28px; margin-bottom: 32px; cursor: pointer;
            display: block; text-decoration: none; color: inherit;
            border: 1px solid rgba(255,255,255,0.03); user-select: none;
            /* Tactile 3D shadow style */
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

        /* ── LEVEL SEPARATOR ── */
        .chapter-separator {
            display: flex; align-items: center; justify-content: center; margin: 24px 0 32px; width: 100%;
        }
        .separator-line { flex: 1; height: 1px; background: rgba(255, 255, 255, 0.1); }
        .separator-text { padding: 0 16px; font-size: 16px; font-weight: 500; color: rgba(255, 255, 255, 0.5); text-transform: lowercase; letter-spacing: 0.05em; }

        /* ── HEX PATH TREE LAYOUT ── */
        .hex-path {
            display: flex; flex-direction: column; align-items: center; gap: 48px;
            margin-top: 24px; position: relative; width: 100%; padding-bottom: 60px;
        }
        .hex-item { display: flex; flex-direction: column; align-items: center; position: relative; }
        
        /* Staggered layout exactly matching the screenshot */
        .hex-item:nth-child(odd) { transform: translateX(-110px); }
        .hex-item:nth-child(even) { transform: translateX(110px); }

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
            .hex-item:nth-child(odd) { transform: translateX(-60px); }
            .hex-item:nth-child(even) { transform: translateX(60px); }
        }
    </style>
@endpush

@section('content')
<div class="main-content-wrap">

    <!-- HEADER STATS (STREAK & XP) -->
    <div class="header-stats">
        <div class="stat-item">
            <img src="/images/streak.png" alt="Streak" class="stat-icon-flame">
            <span>{{ $user->streak_count ?? 0 }} streak</span>
        </div>
        <div class="stat-item">
            <span class="stat-icon-bolt" style="color: #FF0055;">⚡</span>
            <span>{{ $user->xp ?? 0 }}</span>
        </div>
    </div>

    <!-- Chapter Banner (Tactile Red Theme) -->
    @if($activeChapter)
    @php
        $chColor = $chapterColor ?? '#00d4d4'; // Dynamic color
        
        // Parse hex color to RGB for background blending
        $hex = ltrim($chColor, '#');
        $r = hexdec(substr($hex, 0, 2));
        $g = hexdec(substr($hex, 2, 2));
        $b = hexdec(substr($hex, 4, 2));

        // Blend with black (82% black, 18% red)
        $bgR = round($r * 0.18);
        $bgG = round($g * 0.18);
        $bgB = round($b * 0.18);
        $baseBgColor = "rgb($bgR, $bgG, $bgB)";

        // Blend with black (90% black, 10% red) for shadow
        $shR = round($r * 0.10);
        $shG = round($g * 0.10);
        $shB = round($b * 0.10);
        $shadowColorHex = "rgb($shR, $shG, $shB)";
        
        $formattedTitle = 'Chapter ' . $activeChapter->order_index . ' - ' . ucfirst(strtolower($activeChapter->title));
        $formattedLevel = !empty($activeLevelName) ? ucfirst(strtolower($activeLevelName)) : '';
        $pct = round($chapterProgress);
    @endphp
    <div class="chapter-banner" style="background: {{ $baseBgColor }}; box-shadow: 0 6px 0 {{ $shadowColorHex }}; cursor: default;">
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
            <span>{{ $chapterEarnedXp }}/{{ $chapterTotalXp > 0 ? $chapterTotalXp : 5 }} XP</span>
        </div>
    </div>
    @endif

    <!-- Chapter Separator -->
    @if($activeChapter)
    <div class="chapter-separator">
        <div class="separator-line"></div>
        <div class="separator-text">chapter {{ $activeChapter->order_index }}</div>
        <div class="separator-line"></div>
    </div>
    @endif

    <!-- Staggered 3D Hexagon Levels -->
    <div class="hex-path">
        @php
            // Compute shadow for hex
            $hexBase = ltrim($chapterColor ?? '#00d4d4', '#');
            $hr = hexdec(substr($hexBase, 0, 2));
            $hg = hexdec(substr($hexBase, 2, 2));
            $hb = hexdec(substr($hexBase, 4, 2));
            // Darken by 40% for shadow
            $hsR = max(0, $hr - 100);
            $hsG = max(0, $hg - 100);
            $hsB = max(0, $hb - 100);
            $hexShadow = "rgb($hsR, $hsG, $hsB)";
        @endphp
        @if($levels->isNotEmpty())
            @foreach($levels as $index => $level)
                <div class="hex-item">
                    <a href="{{ route('quiz.play', $level->id) }}" style="text-decoration: none;">
                        <div class="hex-btn" style="--hex-color: {{ $chapterColor ?? '#00d4d4' }}; --hex-shadow: {{ $hexShadow }};">
                            <div class="hex-shape hex-shadow"></div>
                            <div class="hex-shape hex-top">
                                <svg viewBox="0 0 24 24" fill="currentColor">
                                    <!-- Hexagon inner beaker or chemistry flask path -->
                                    <path d="M19 6h-1.5V4.5c0-.83-.67-1.5-1.5-1.5h-8c-.83 0-1.5.67-1.5 1.5V6H5c-1.1 0-2 .9-2 2v11c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm-6 12.5H7v-2h6v2zm4-4H7v-2h10v2zm0-4H7V8h10v2z"/>
                                </svg>
                            </div>
                        </div>
                    </a>
                    <div class="hex-label">{{ $level->name }}</div>
                </div>
            @endforeach
        @else
            <!-- Beautiful Fallback Hexagons exactly like the screenshot -->
            <div class="hex-item">
                <div class="hex-btn" style="--hex-color: {{ $chapterColor ?? '#00d4d4' }}; --hex-shadow: {{ $hexShadow ?? '#007777' }};">
                    <div class="hex-shape hex-shadow"></div>
                    <div class="hex-shape hex-top">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2L2 22h20L12 2zm0 3.99L19.53 19H4.47L12 5.99z"/>
                        </svg>
                    </div>
                </div>
                <div class="hex-label">Chemical</div>
            </div>
            <div class="hex-item">
                <div class="hex-btn" style="--hex-color: {{ $chapterColor ?? '#00d4d4' }}; --hex-shadow: {{ $hexShadow ?? '#007777' }};">
                    <div class="hex-shape hex-shadow"></div>
                    <div class="hex-shape hex-top">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2L2 22h20L12 2zm0 3.99L19.53 19H4.47L12 5.99z"/>
                        </svg>
                    </div>
                </div>
                <div class="hex-label">Chemical</div>
            </div>
            <div class="hex-item">
                <div class="hex-btn" style="--hex-color: {{ $chapterColor ?? '#00d4d4' }}; --hex-shadow: {{ $hexShadow ?? '#007777' }};">
                    <div class="hex-shape hex-shadow"></div>
                    <div class="hex-shape hex-top">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2L2 22h20L12 2zm0 3.99L19.53 19H4.47L12 5.99z"/>
                        </svg>
                    </div>
                </div>
                <div class="hex-label">Chemical</div>
            </div>
        @endif
    </div>

</div>

<!-- Floating Action Button -->
<a href="{{ route('admin.quiz.index') }}" class="fab">+</a>
@endsection
