@extends('layouts.app')

@section('content')
<div class="friends-container">
    
    <!-- Tab Controls -->
    <div class="friends-tabs-wrapper">
        <div class="friends-tabs">
            <button class="f-tab-btn" id="tab-add" onclick="switchTab('add')">ADD FRIENDS</button>
            <button class="f-tab-btn active" id="tab-yours" onclick="switchTab('yours')">YOUR FRIENDS</button>
            <button class="f-tab-btn" id="tab-requests" onclick="switchTab('requests')">REQUEST</button>
        </div>
    </div>

    <!-- ADD FRIENDS TAB -->
    <div id="content-add" class="f-tab-content" style="display: none;">
        <div class="search-bar-container">
            <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="var(--cyan, #00d4d4)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input type="text" id="search-input" class="search-input" placeholder="Search" onkeyup="debounceSearch()">
        </div>
        <div id="add-list" class="user-list">
            <!-- Populated via JS -->
        </div>
    </div>

    <!-- YOUR FRIENDS TAB -->
    <div id="content-yours" class="f-tab-content">
        <div id="yours-list" class="user-list">
            <!-- Populated via JS -->
        </div>
    </div>

    <!-- REQUESTS TAB -->
    <div id="content-requests" class="f-tab-content" style="display: none;">
        <div id="requests-list" class="requests-grid">
            <!-- Populated via JS -->
        </div>
    </div>

</div>

@endsection

@push('styles')
<style>
    .friends-container {
        padding: 40px;
        color: #fff;
        max-width: 900px;
        margin: 0 auto;
    }

    /* TABS */
    .friends-tabs-wrapper {
        display: flex;
        justify-content: center;
        margin-bottom: 40px;
    }

    .friends-tabs {
        display: flex;
        background: #1e292b;
        border-radius: 30px;
        padding: 4px;
        width: 100%;
        max-width: 600px;
    }

    .f-tab-btn {
        flex: 1;
        background: transparent;
        border: none;
        color: #6b7280;
        padding: 12px 20px;
        border-radius: 26px;
        font-family: 'Space Grotesk', sans-serif;
        font-weight: 500;
        font-size: 13px;
        letter-spacing: 1px;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .f-tab-btn.active {
        background: #004d4d; /* Dark cyan */
        color: var(--cyan, #00d4d4);
    }

    /* Request notification badge on tab button */
    .req-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: #ff4d4d;
        color: #fff;
        font-size: 10px;
        font-weight: 700;
        min-width: 18px;
        height: 18px;
        border-radius: 9px;
        padding: 0 5px;
        margin-left: 6px;
        vertical-align: middle;
        line-height: 1;
    }

    /* SEARCH BAR */
    .search-bar-container {
        position: relative;
        margin-bottom: 24px;
    }

    .search-input {
        width: 100%;
        background: #1a2527;
        border: 1px solid #2a3739;
        border-radius: 12px;
        padding: 16px 20px 16px 50px;
        color: #fff;
        font-family: 'Inter', sans-serif;
        font-size: 15px;
        outline: none;
        transition: border-color 0.3s ease;
    }

    .search-input:focus {
        border-color: var(--cyan, #00d4d4);
    }

    .search-input::placeholder {
        color: #6b7280;
    }

    .search-icon {
        position: absolute;
        left: 20px;
        top: 50%;
        transform: translateY(-50%);
        width: 20px;
        height: 20px;
    }

    /* USER LIST (Bars) */
    .user-list {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .user-bar {
        display: flex;
        align-items: center;
        background: #1a2527;
        border-radius: 12px;
        padding: 16px 24px;
        transition: transform 0.2s ease, background 0.2s ease;
    }

    .user-bar:hover {
        background: #202e30;
        transform: translateY(-2px);
    }

    /* Avatar & Rank */
    .avatar-wrapper {
        position: relative;
        width: 56px;
        height: 56px;
        margin-right: 24px;
        flex-shrink: 0;
    }

    .avatar-img {
        width: 100%;
        height: 100%;
        border-radius: 50%;
        object-fit: cover;
        background: #ccc;
    }

    .rank-badge {
        position: absolute;
        bottom: -4px;
        right: -4px;
        width: 24px;
        height: 24px;
        background: #2a3739; /* Fallback */
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 4px;
    }

    .rank-badge img {
        width: 100%;
        height: 100%;
        object-fit: contain;
    }

    /* User Info */
    .user-info {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .u-name {
        font-family: 'Inter', sans-serif;
        font-size: 16px;
        font-weight: 500;
        color: #fff;
    }

    .u-meta {
        font-family: 'Inter', sans-serif;
        font-size: 10px;
        font-weight: 600;
        color: #6b7280;
        letter-spacing: 0.5px;
        text-transform: uppercase;
    }

    /* XP & Action */
    .xp-block {
        text-align: right;
        margin-right: 32px;
    }

    .xp-value {
        font-family: 'Inter', sans-serif;
        font-size: 16px;
        font-weight: 600;
        color: var(--cyan, #00d4d4);
    }

    .xp-label {
        font-family: 'Inter', sans-serif;
        font-size: 10px;
        color: #6b7280;
        margin-top: 2px;
    }

    .action-btn {
        background: none;
        border: none;
        cursor: pointer;
        padding: 8px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.2s ease;
        color: var(--cyan, #00d4d4);
    }

    .action-btn:hover {
        background: rgba(0, 212, 212, 0.1);
    }

    .action-btn svg {
        width: 24px;
        height: 24px;
    }

    .unfriend-btn {
        background: none;
        border: none;
        cursor: pointer;
        padding: 8px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.2s ease;
        color: #ff4d4d;
        flex-shrink: 0;
    }

    .unfriend-btn:hover {
        background: rgba(255, 77, 77, 0.12);
    }

    .unfriend-btn svg {
        width: 22px;
        height: 22px;
    }

    /* REQUESTS CARDS */
    .requests-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 24px;
    }

    .request-card {
        background: #1a2527;
        border-radius: 16px;
        padding: 32px 24px;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
    }

    .request-card .avatar-wrapper {
        width: 72px;
        height: 72px;
        margin-right: 0;
        margin-bottom: 16px;
    }

    .request-card .rank-badge {
        width: 28px;
        height: 28px;
        bottom: -2px;
        right: -2px;
    }

    .request-card .u-name {
        font-size: 20px;
        margin-bottom: 4px;
    }

    .request-card .u-meta {
        font-size: 12px;
        margin-bottom: 16px;
    }

    .request-time {
        font-family: 'Inter', sans-serif;
        font-size: 13px;
        color: #9ca3af;
        margin-bottom: 24px;
    }

    .req-actions {
        display: flex;
        gap: 16px;
        width: 100%;
    }

    .btn-accept {
        flex: 1;
        background: var(--cyan, #00d4d4);
        color: #0f172a;
        border: none;
        border-radius: 12px;
        padding: 12px 0;
        font-family: 'Inter', sans-serif;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: opacity 0.2s;
    }

    .btn-accept:hover {
        opacity: 0.9;
    }

    .btn-ignore {
        flex: 1;
        background: #1e292b;
        color: #fff;
        border: none; /* Changed to none matching screenshot closely */
        border-radius: 12px;
        padding: 12px 0;
        font-family: 'Inter', sans-serif;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: background 0.2s;
    }

    .btn-ignore:hover {
        background: #2a3739;
    }

    /* Loading state */
    .loading-text {
        text-align: center;
        color: #6b7280;
        padding: 20px;
        font-family: 'Inter', sans-serif;
    }
</style>
@endpush

@push('scripts')
<script>
    // State
    let currentTab = 'yours';
    let searchTimeout = null;

    // Elements
    const tabBtns = {
        add: document.getElementById('tab-add'),
        yours: document.getElementById('tab-yours'),
        requests: document.getElementById('tab-requests')
    };
    
    const tabContents = {
        add: document.getElementById('content-add'),
        yours: document.getElementById('content-yours'),
        requests: document.getElementById('content-requests')
    };

    const lists = {
        add: document.getElementById('add-list'),
        yours: document.getElementById('yours-list'),
        requests: document.getElementById('requests-list')
    };

    const searchInput = document.getElementById('search-input');

    // On Load
    document.addEventListener('DOMContentLoaded', () => {
        loadData('yours'); // Load Yours by default
        pollRequestCount();  // Start polling for incoming requests
    });

    // Poll request count every 10 seconds and update badge
    let requestPollInterval = null;
    function pollRequestCount() {
        checkRequestCount();
        requestPollInterval = setInterval(checkRequestCount, 10000);
    }

    function checkRequestCount() {
        fetch('{{ route("friends.requests") }}', { cache: 'no-store' })
            .then(r => r.json())
            .then(data => {
                if (!data.success) return;
                const count = data.data.length;
                const btn = document.getElementById('tab-requests');
                // Remove old badge if any
                const old = btn.querySelector('.req-badge');
                if (old) old.remove();
                if (count > 0) {
                    const badge = document.createElement('span');
                    badge.className = 'req-badge';
                    badge.textContent = count;
                    btn.appendChild(badge);
                }
                // If currently on requests tab, refresh the list silently
                if (currentTab === 'requests') {
                    renderData('requests', data.data);
                }
            })
            .catch(() => {});
    }

    // Tab Switching
    function switchTab(tab) {
        currentTab = tab;
        
        // Update Buttons
        Object.values(tabBtns).forEach(btn => btn.classList.remove('active'));
        tabBtns[tab].classList.add('active');

        // Update Content
        Object.values(tabContents).forEach(content => content.style.display = 'none');
        tabContents[tab].style.display = 'block';

        // Load Data
        loadData(tab);
    }

    // Load Data based on tab
    function loadData(tab) {
        lists[tab].innerHTML = '<div class="loading-text">Loading...</div>';
        
        let url = '';
        if (tab === 'yours') url = '{{ route("friends.list") }}';
        else if (tab === 'requests') url = '{{ route("friends.requests") }}';
        else if (tab === 'add') {
            const query = searchInput.value.trim();
            url = '{{ route("friends.search") }}?q=' + encodeURIComponent(query);
        }

        fetch(url, { cache: 'no-store' })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    renderData(tab, data.data);
                } else {
                    lists[tab].innerHTML = '<div class="loading-text">Error loading data.</div>';
                }
            })
            .catch(err => {
                console.error(err);
                lists[tab].innerHTML = '<div class="loading-text">Error loading data.</div>';
            });
    }

    // Debounced Search for Add tab
    function debounceSearch() {
        if (searchTimeout) clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            if (currentTab === 'add') {
                loadData('add');
            }
        }, 300);
    }

    // Format Number (e.g. 2550 -> 2,550)
    function formatNumber(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    // Render Data
    function renderData(tab, users) {
        const container = lists[tab];
        container.innerHTML = '';

        if (users.length === 0) {
            container.innerHTML = '<div class="loading-text">No users found.</div>';
            return;
        }

        users.forEach(user => {
            if (tab === 'requests') {
                container.appendChild(createRequestCard(user));
            } else {
                container.appendChild(createUserBar(user, tab));
            }
        });
    }

    // HTML Generator for User Bar (Add & Yours)
    function createUserBar(user, tab) {
        const div = document.createElement('div');
        div.className = 'user-bar';
        div.style.cursor = 'pointer';
        div.onclick = () => { window.location.href = `/profile/${user.id}`; };

        // Rank Badge HTML
        const rankHtml = user.rank_icon_url 
            ? `<div class="rank-badge"><img src="${user.rank_icon_url}" alt="Rank"></div>`
            : '';
        
        // Action Button
        let actionHtml = '';
        if (tab === 'add' && user.friendship_status !== 'accepted' && user.friendship_status !== 'pending' && user.friendship_status !== 'requested_to_me') {
            actionHtml = `
                <button class="action-btn" onclick="event.stopPropagation(); sendRequest(${user.id}, this)">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="8.5" cy="7" r="4"></circle>
                        <line x1="20" y1="8" x2="20" y2="14"></line>
                        <line x1="23" y1="11" x2="17" y2="11"></line>
                    </svg>
                </button>
            `;
        } else if (tab === 'add' && user.friendship_status === 'pending') {
            actionHtml = `<span class="u-meta" style="margin-right: 16px;">Requested</span>`;
        } else if (tab === 'yours') {
            actionHtml = `
                <button class="unfriend-btn" onclick="event.stopPropagation(); unfriend(${user.id}, this)" title="Unfriend">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="8.5" cy="7" r="4"></circle>
                        <line x1="23" y1="11" x2="17" y2="11"></line>
                    </svg>
                </button>
            `;
        }

        div.innerHTML = `
            <div class="avatar-wrapper">
                <img src="${user.avatar_url}" alt="${user.username}" class="avatar-img">
                ${rankHtml}
            </div>
            <div class="user-info">
                <div class="u-name">${user.username}</div>
                <div class="u-meta">${user.rank_title} &nbsp;&bull;&nbsp; ${user.chapter_title}</div>
            </div>
            <div class="xp-block">
                <div class="xp-value">${formatNumber(user.xp)}</div>
                <div class="xp-label">XP</div>
            </div>
            ${actionHtml}
        `;
        return div;
    }

    // HTML Generator for Request Card
    function createRequestCard(user) {
        const div = document.createElement('div');
        div.className = 'request-card';

        const rankHtml = user.rank_icon_url 
            ? `<div class="rank-badge"><img src="${user.rank_icon_url}" alt="Rank"></div>`
            : '';

        div.innerHTML = `
            <div class="avatar-wrapper">
                <img src="${user.avatar_url}" alt="${user.username}" class="avatar-img">
                ${rankHtml}
            </div>
            <div class="u-name">${user.username}</div>
            <div class="u-meta">${user.rank_title}</div>
            <div class="request-time">Requested ${user.requested_at}</div>
            
            <div class="req-actions">
                <button class="btn-accept" onclick="acceptRequest(${user.id}, this)">Accept</button>
                <button class="btn-ignore" onclick="ignoreRequest(${user.id}, this)">Ignore</button>
            </div>
        `;
        return div;
    }

    // API Actions
    function sendRequest(id, btnElement) {
        fetch(`{{ url('/friends/request') }}/${id}`, {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json'
            }
        })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                btnElement.outerHTML = `<span class="u-meta" style="margin-right: 16px;">Requested</span>`;
            }
        });
    }

    function acceptRequest(id, btnElement) {
        fetch(`{{ url('/friends/accept') }}/${id}`, {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json'
            }
        })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                // Remove card
                btnElement.closest('.request-card').remove();
            }
        });
    }

    function ignoreRequest(id, btnElement) {
        fetch(`{{ url('/friends/ignore') }}/${id}`, {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json'
            }
        })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                // Remove card
                btnElement.closest('.request-card').remove();
            }
        });
    }

    function unfriend(id, btnElement) {
        if (!confirm('Remove this friend?')) return;
        fetch(`{{ url('/friends/unfriend') }}/${id}`, {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json'
            }
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                btnElement.closest('.user-bar').remove();
            }
        });
    }
</script>
@endpush
