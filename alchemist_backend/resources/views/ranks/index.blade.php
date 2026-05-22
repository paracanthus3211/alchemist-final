@extends('layouts.app')

@section('title', 'Alchemist Ranks')

@push('styles')
<style>
    .rank-page-container {
        padding: 20px;
    }
    .page-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--cyan);
        letter-spacing: 2px;
        text-transform: uppercase;
        margin-bottom: 40px;
    }
    
    .ranks-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
        gap: 30px 20px;
    }

    .rank-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        background: none;
        border: none;
        cursor: pointer;
        transition: transform 0.2s;
        text-decoration: none;
    }
    
    .rank-item:hover {
        transform: translateY(-5px);
    }
    
    .rank-item.locked {
        opacity: 0.5;
        cursor: not-allowed;
    }
    
    .rank-item.locked:hover {
        transform: none;
    }

    .rank-icon-wrap {
        width: 100px;
        height: 110px;
        margin-bottom: 12px;
        position: relative;
    }
    
    .rank-icon {
        width: 100%;
        height: 100%;
        object-fit: contain;
    }
    
    /* Fallback default badge if no image */
    .default-badge {
        width: 100%; height: 100%;
        background: linear-gradient(135deg, #e3c16f, #b9933a);
        clip-path: polygon(50% 0%, 100% 20%, 100% 80%, 50% 100%, 0% 80%, 0% 20%);
        display: flex; align-items: center; justify-content: center;
    }

    .rank-name {
        font-size: 16px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 4px;
    }

    .rank-chapter {
        font-size: 10px;
        color: rgba(255,255,255,0.7);
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .rank-threshold {
        font-size: 10px;
        color: rgba(255,255,255,0.5);
    }
    
    .fab-btn {
        position: fixed;
        bottom: 40px;
        right: 40px;
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: transparent;
        border: 2px solid #fff;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 32px;
        cursor: pointer;
        text-decoration: none;
        transition: 0.2s;
        z-index: 100;
    }
    
    .fab-btn:hover {
        background: rgba(255,255,255,0.1);
        transform: scale(1.05);
    }
</style>
@endpush

@section('content')
<div class="rank-page-container">
    <div class="page-title">ALCHEMIST RANKS</div>

    @if(session('success'))
        <div style="background: rgba(0,212,212,0.1); color: var(--cyan); padding: 10px; border-radius: 8px; margin-bottom: 20px;">
            {{ session('success') }}
        </div>
    @endif
    @if(session('error'))
        <div style="background: rgba(255,0,0,0.1); color: #ff6b6b; padding: 10px; border-radius: 8px; margin-bottom: 20px;">
            {{ session('error') }}
        </div>
    @endif

    <div class="ranks-grid">
        @foreach($ranks as $rank)
            @php
                $isLocked = $user->xp < $rank->xp_threshold;
            @endphp
            <form action="{{ route('ranks.equip', $rank->id) }}" method="POST" class="rank-item {{ $isLocked ? 'locked' : '' }}" onclick="{{ $isLocked ? 'event.preventDefault(); alert(\'Not enough XP to unlock this rank.\');' : 'this.submit();' }}">
                @csrf
                <div class="rank-icon-wrap">
                    @if($rank->icon_url)
                        <img src="{{ $rank->icon_url }}" alt="{{ $rank->name }}" class="rank-icon">
                    @else
                        <div class="default-badge">
                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        </div>
                    @endif
                </div>
                <div class="rank-name">{{ $rank->name }}</div>
                <div class="rank-chapter">{{ $rank->chapter ? 'CHAPTER ' . $rank->chapter : 'CHAPTER -' }}</div>
                <div class="rank-threshold">Threshold : {{ number_format($rank->xp_threshold) }} XP</div>
            </form>
        @endforeach
    </div>

    @if($user->role === 'ADMIN')
        <a href="{{ route('admin.ranks.index') }}" class="fab-btn">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </a>
    @endif
</div>
@endsection
