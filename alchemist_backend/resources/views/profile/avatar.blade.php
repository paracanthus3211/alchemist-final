@extends('layouts.app')

@push('styles')
<style>
    .avatar-page {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: calc(100vh - 40px);
        background: #0f172a;
        font-family: 'Inter', sans-serif;
    }

    .page-title {
        color: var(--cyan, #00d4d4);
        font-family: 'Space Grotesk', sans-serif;
        font-size: 14px;
        font-weight: 700;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        margin-bottom: 40px;
    }

    /* Carousel */
    .carousel-container {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 60px;
        margin-bottom: 40px;
    }

    .nav-btn {
        background: none;
        border: none;
        color: #fff;
        cursor: pointer;
        padding: 20px;
        transition: transform 0.2s ease, opacity 0.2s ease;
    }

    .nav-btn:hover {
        transform: scale(1.1);
        opacity: 0.8;
    }

    .nav-btn svg {
        width: 32px;
        height: 32px;
    }

    .avatar-preview-wrap {
        width: 260px;
        height: 260px;
        border-radius: 50%;
        background-color: #0b498f; /* Default bg */
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        border: 4px solid rgba(255,255,255,0.1);
        transition: background-color 0.3s ease;
    }

    .avatar-preview-wrap img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    /* Info */
    .indicators {
        display: flex;
        gap: 12px;
        margin-bottom: 30px;
    }

    .indicator-dash {
        width: 32px;
        height: 4px;
        background: #475569;
        border-radius: 2px;
    }
    
    .indicator-dash.active {
        background: #94a3b8;
    }

    .avatar-name {
        color: var(--cyan, #00d4d4);
        font-family: 'Space Grotesk', sans-serif;
        font-size: 20px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 12px;
    }

    .avatar-desc {
        color: #fff;
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
        text-align: center;
        max-width: 300px;
        line-height: 1.6;
        margin-bottom: 24px;
    }

    .rarity-badge {
        background: var(--lime, #b8f400);
        color: #000;
        padding: 6px 24px;
        border-radius: 20px;
        font-family: 'Space Grotesk', sans-serif;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 40px;
    }

    /* Colors */
    .color-picker {
        display: grid;
        grid-template-columns: repeat(6, 1fr);
        gap: 12px;
        margin-bottom: 50px;
        justify-content: center;
    }

    .color-swatch {
        width: 36px;
        height: 36px;
        border-radius: 8px;
        cursor: pointer;
        border: 2px solid transparent;
        transition: transform 0.2s;
    }

    .color-swatch:hover {
        transform: scale(1.1);
    }

    .color-swatch.active {
        border-color: #fff;
        transform: scale(1.1);
    }

    /* Actions */
    .action-buttons {
        display: flex;
        gap: 20px;
    }

    .btn {
        padding: 16px 40px;
        border-radius: 12px;
        font-family: 'Space Grotesk', sans-serif;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        cursor: pointer;
        border: none;
        transition: opacity 0.2s;
    }

    .btn:hover {
        opacity: 0.9;
    }

    .btn-cancel {
        background: #475f65; /* Dark grayish cyan */
        color: #fff;
    }

    .btn-save {
        background: #4b8b8b; /* Desaturated cyan */
        color: #000;
    }

</style>
@endpush

@section('content')
<div class="avatar-page">
    <div class="page-title">CHANGE AVATAR</div>

    @if($avatars->isEmpty())
        <div style="color: white; margin-bottom: 40px;">No avatars available.</div>
    @else
        <div class="carousel-container">
            <button class="nav-btn" onclick="prevAvatar()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="15 18 9 12 15 6"></polyline>
                </svg>
            </button>

            <div class="avatar-preview-wrap" id="avatar-bg">
                <img id="avatar-img" src="" alt="Avatar">
            </div>

            <button class="nav-btn" onclick="nextAvatar()">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="9 18 15 12 9 6"></polyline>
                </svg>
            </button>
        </div>

        <div class="indicators" id="indicators">
            <!-- Populated via JS -->
        </div>

        <div class="avatar-name" id="avatar-name"></div>
        <div class="avatar-desc" id="avatar-desc"></div>
        <div class="rarity-badge" id="avatar-rarity"></div>

        <div class="color-picker" id="color-picker">
            <!-- Colors based on screenshot: cyan, orange, slate, purple, lime, red, yellow, blue -->
            <div class="color-swatch" style="background: #00d4d4;" onclick="selectColor('#00d4d4', this)"></div>
            <div class="color-swatch" style="background: #f97316;" onclick="selectColor('#f97316', this)"></div>
            <div class="color-swatch" style="background: #334155;" onclick="selectColor('#334155', this)"></div>
            <div class="color-swatch" style="background: #a855f7;" onclick="selectColor('#a855f7', this)"></div>
            <div class="color-swatch" style="background: #b8f400;" onclick="selectColor('#b8f400', this)"></div>
            <div class="color-swatch" style="background: #ef4444;" onclick="selectColor('#ef4444', this)"></div>
            <div class="color-swatch" style="background: #eab308;" onclick="selectColor('#eab308', this)"></div>
            <div class="color-swatch" style="background: #0b498f;" onclick="selectColor('#0b498f', this)"></div>
        </div>

        <form action="{{ route('profile.avatar.save') }}" method="POST" id="avatarForm">
            @csrf
            <input type="hidden" name="avatar_id" id="input-avatar-id">
            <input type="hidden" name="bg_color" id="input-bg-color">
            
            <div class="action-buttons">
                <a href="{{ route('profile') }}" class="btn btn-cancel" style="text-decoration: none; display: inline-block;">CANCEL</a>
                <button type="submit" class="btn btn-save">SAVE AVATAR</button>
            </div>
        </form>
    @endif
</div>

@push('scripts')
<script>
    const avatars = @json($avatars);
    let currentIndex = 0;
    
    // Default color or user's current color
    let selectedColor = '{{ $user->profile_bg_color ?? "#0b498f" }}';
    
    // Find initial avatar index
    const equippedId = {{ $user->equipped_avatar_id ?? 0 }};
    if (equippedId && avatars.length > 0) {
        const idx = avatars.findIndex(a => a.id === equippedId);
        if (idx !== -1) currentIndex = idx;
    }

    document.addEventListener('DOMContentLoaded', () => {
        if (avatars.length > 0) {
            initIndicators();
            updateUI();
            
            // Set initial color swatch active
            const swatches = document.querySelectorAll('.color-swatch');
            let found = false;
            swatches.forEach(s => {
                // Convert rgb to hex for comparison if needed, but style.backgroundColor returns rgb
                // Simple matching by style string content:
                if (s.getAttribute('style').includes(selectedColor)) {
                    s.classList.add('active');
                    found = true;
                }
            });
            // Fallback if custom color
            if(!found && swatches.length > 0) {
                swatches[0].classList.add('active');
                selectedColor = '#00d4d4'; // default
            }
            
            document.getElementById('input-bg-color').value = selectedColor;
            document.getElementById('avatar-bg').style.backgroundColor = selectedColor;
        }
    });

    function initIndicators() {
        const container = document.getElementById('indicators');
        // Let's show max 4 dots like the screenshot, representing pages or just simple dots
        const numDots = Math.min(avatars.length, 4);
        for(let i = 0; i < numDots; i++) {
            const dot = document.createElement('div');
            dot.className = 'indicator-dash';
            container.appendChild(dot);
        }
    }

    function updateUI() {
        if (avatars.length === 0) return;
        const avatar = avatars[currentIndex];

        document.getElementById('avatar-img').src = avatar.image_url || '/images/default_avatar.png';
        document.getElementById('avatar-name').innerText = avatar.name;
        document.getElementById('avatar-desc').innerText = avatar.description || 'MYSTERIOUS ALCHEMIST';
        
        const rarityEl = document.getElementById('avatar-rarity');
        rarityEl.innerText = avatar.rarity || 'COMMON';
        
        // Rarity colors
        let rColor = '#b8f400'; // common lime
        if(avatar.rarity === 'rare') rColor = '#00d4d4';
        if(avatar.rarity === 'epic') rColor = '#a855f7';
        if(avatar.rarity === 'legendary') rColor = '#f97316';
        rarityEl.style.backgroundColor = rColor;
        
        // Update input
        document.getElementById('input-avatar-id').value = avatar.id;

        // Update indicators
        const dots = document.querySelectorAll('.indicator-dash');
        dots.forEach(d => d.classList.remove('active'));
        if (dots.length > 0) {
            const dotIndex = currentIndex % dots.length;
            dots[dotIndex].classList.add('active');
        }
    }

    function prevAvatar() {
        currentIndex--;
        if (currentIndex < 0) currentIndex = avatars.length - 1;
        updateUI();
    }

    function nextAvatar() {
        currentIndex++;
        if (currentIndex >= avatars.length) currentIndex = 0;
        updateUI();
    }

    function selectColor(hex, el) {
        selectedColor = hex;
        document.getElementById('avatar-bg').style.backgroundColor = hex;
        document.getElementById('input-bg-color').value = hex;

        document.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
        el.classList.add('active');
    }
</script>
@endpush
@endsection
