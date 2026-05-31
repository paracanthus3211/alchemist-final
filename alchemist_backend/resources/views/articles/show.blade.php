@extends('layouts.app')

@section('title', $article->title . ' — Alchemist')

@push('styles')
<style>
    /* ── ARTICLE READ PAGE ── */
    .article-read-wrapper {
        max-width: 820px;
        margin: 0 auto;
        padding: 48px 32px 80px;
    }

    /* Back button */
    .article-back-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: rgba(255,255,255,0.45);
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        transition: color 0.2s;
        margin-bottom: 36px;
    }
    .article-back-btn:hover { color: rgba(255,255,255,0.85); }
    .article-back-btn svg { flex-shrink: 0; }

    /* Title */
    .article-read-title {
        font-size: clamp(24px, 4vw, 36px);
        font-weight: 800;
        color: #fff;
        text-align: center;
        line-height: 1.25;
        margin-bottom: 36px;
        letter-spacing: -0.01em;
    }

    /* Hero thumbnail */
    .article-hero-img {
        width: 72%;
        max-width: 620px;
        aspect-ratio: 4/3;
        border-radius: 20px;
        object-fit: cover;
        display: block;
        margin: 0 auto 40px;
        background: #d0d0d0;
    }
    .article-hero-placeholder {
        width: 72%;
        max-width: 620px;
        aspect-ratio: 4/3;
        border-radius: 20px;
        background: #c8c8c8;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 56px;
        margin: 0 auto 40px;
    }

    /* Content blocks */
    .article-content-block {
        margin-bottom: 32px;
    }

    /* Text block */
    .article-text {
        font-size: 16px;
        line-height: 1.85;
        color: rgba(255,255,255,0.82);
        font-family: 'Inter', sans-serif;
        font-weight: 400;
    }

    /* Table block */
    .article-table-wrap {
        width: 100%;
        overflow-x: auto;
        border-radius: 12px;
        border: 1px solid var(--cyan);
    }
    .article-table-wrap table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
        color: rgba(255,255,255,0.85);
        font-family: 'Inter', sans-serif;
    }
    .article-table-wrap table thead th {
        padding: 14px 18px;
        font-weight: 700;
        font-size: 12px;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: var(--cyan);
        border-bottom: 1px solid var(--cyan);
        border-right: 1px solid rgba(0,212,212,0.25);
        background: rgba(0,212,212,0.04);
        text-align: left;
    }
    .article-table-wrap table thead th:last-child { border-right: none; }
    .article-table-wrap table tbody tr:not(:last-child) td {
        border-bottom: 1px solid rgba(0,212,212,0.18);
    }
    .article-table-wrap table tbody td {
        padding: 16px 18px;
        border-right: 1px solid rgba(0,212,212,0.18);
        vertical-align: top;
        line-height: 1.6;
    }
    .article-table-wrap table tbody td:last-child { border-right: none; }
    .article-table-wrap table tbody tr:hover td {
        background: rgba(0,212,212,0.03);
    }

    /* Image content block */
    .article-content-image {
        width: 100%;
        border-radius: 16px;
        object-fit: cover;
        display: block;
    }

    /* Meta pill */
    .article-meta-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        margin-bottom: 36px;
        flex-wrap: wrap;
    }
    .article-pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(255,255,255,0.05);
        border: 1px solid rgba(255,255,255,0.08);
        border-radius: 100px;
        padding: 6px 14px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: rgba(255,255,255,0.55);
    }
    .article-pill.cyan { color: var(--cyan); border-color: rgba(0,212,212,0.25); background: rgba(0,212,212,0.06); }
</style>
@endpush

@section('content')
<div class="article-read-wrapper">

    {{-- Back button --}}
    <a href="{{ route('library') }}" class="article-back-btn">
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 18 9 12 15 6"/>
        </svg>
        Back to Library
    </a>

    {{-- Title --}}
    <h1 class="article-read-title">{{ $article->title }}</h1>

    {{-- Meta pills --}}
    <div class="article-meta-row">
        @if($article->category)
            <span class="article-pill cyan">{{ $article->category }}</span>
        @endif
        @if($article->difficulty_level)
            <span class="article-pill">{{ $article->difficulty_level }}</span>
        @endif
    </div>

    {{-- Hero image --}}
    @if($article->thumbnail_url)
        <img src="{{ $article->thumbnail_url }}" alt="{{ $article->title }}" class="article-hero-img">
    @else
        <div class="article-hero-placeholder">🧪</div>
    @endif

    {{-- Content blocks --}}
    @foreach($article->contents->sortBy('order_index') as $block)
        <div class="article-content-block">

            @if($block->type === 'text')
                <p class="article-text">{{ $block->content }}</p>

            @elseif($block->type === 'image')
                <img src="{{ $block->content }}" alt="Article illustration" class="article-content-image">

            @elseif($block->type === 'table')
                @php
                    $tableData = json_decode($block->content, true);
                @endphp
                @if($tableData && isset($tableData['headers']) && isset($tableData['rows']))
                    <div class="article-table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    @foreach($tableData['headers'] as $header)
                                        <th>{{ $header }}</th>
                                    @endforeach
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($tableData['rows'] as $row)
                                    <tr>
                                        @foreach($row as $cell)
                                            <td>{{ $cell }}</td>
                                        @endforeach
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif

            @endif
        </div>
    @endforeach

</div>
@endsection
