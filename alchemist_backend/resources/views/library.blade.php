@extends('layouts.app')

@section('title', 'Library — Alchemist')

@push('styles')
    <style>
        :root {
            --bg:       #0c1214; /* Slightly different dark bg for library */
            --search-bg: #072224;
            --btn-teal:  #008888;
        }

        .library-container {
            max-width: 800px; margin: 0 auto; display: flex; flex-direction: column;
        }

        /* ── SEARCH BAR ── */
        .search-bar-form {
            display: flex; align-items: center; width: 100%;
            background: var(--search-bg); border-radius: 12px;
            padding: 16px 20px; margin-bottom: 32px;
        }
        .search-bar-form svg { width: 24px; height: 24px; color: var(--cyan); margin-right: 16px; flex-shrink: 0; }
        .search-input {
            flex: 1; background: transparent; border: none; outline: none;
            color: #fff; font-size: 16px; font-family: 'Space Grotesk', sans-serif;
        }
        .search-input::placeholder { color: rgba(255,255,255,0.5); }

        /* ── CATEGORY PILLS ── */
        .category-pills {
            display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 40px;
            justify-content: center;
        }
        .cat-pill {
            padding: 10px 20px; border-radius: 99px; font-size: 11px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.1em; cursor: pointer;
            text-decoration: none; transition: 0.2s;
            background: rgba(255, 255, 255, 0.05); color: var(--cyan);
        }
        .cat-pill:hover { background: rgba(255, 255, 255, 0.1); }
        .cat-pill.active { background: var(--cyan); color: #000; }

        /* ── ARTICLES LIST ── */
        .articles-list {
            display: flex; flex-direction: column; gap: 40px; padding-bottom: 80px;
        }

        .article-card {
            display: flex; flex-direction: column; gap: 24px;
        }
        .article-img {
            width: 100%; height: 280px; border-radius: 16px; object-fit: cover;
            background: #111; border: 1px solid rgba(255,255,255,0.05);
        }
        .article-title {
            font-size: 28px; font-weight: 700; color: #fff; line-height: 1.3;
            font-family: 'Inter', sans-serif;
        }
        .article-desc {
            font-size: 16px; color: rgba(255,255,255,0.8); line-height: 1.6;
            font-family: 'Inter', sans-serif; font-weight: 500;
        }

        .btn-read {
            display: inline-flex; align-items: center; justify-content: center;
            width: 100%; max-width: 400px;
            background: linear-gradient(90deg, #00d4d4 0%, var(--btn-teal) 100%);
            color: #000; font-size: 14px; font-weight: 800; letter-spacing: 0.15em;
            text-transform: uppercase; padding: 18px 0; border-radius: 12px;
            text-decoration: none; transition: 0.2s; box-shadow: 0 4px 15px rgba(0, 212, 212, 0.2);
        }
        .btn-read:hover { opacity: 0.9; transform: translateY(-2px); }

        .article-divider {
            height: 1px; width: 100%; background: rgba(255,255,255,0.1); margin-top: 40px;
        }

        .bookmark-btn {
            position: absolute; top: 16px; right: 16px; background: rgba(0,0,0,0.6); 
            border: none; border-radius: 50%; width: 44px; height: 44px; 
            display: flex; align-items: center; justify-content: center; 
            cursor: pointer; transition: 0.2s; backdrop-filter: blur(4px); 
            z-index: 5; box-shadow: 0 4px 12px rgba(0,0,0,0.3); outline: none;
        }

        .add-article-btn:hover, .btn-edit-sm:hover {
            background: var(--cyan) !important;
            color: #000 !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0, 212, 212, 0.4);
            border-color: var(--cyan) !important;
        }
        .btn-delete-sm:hover {
            background: rgba(255, 70, 70, 0.2) !important;
            border-color: #ff4646 !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(255, 70, 70, 0.2);
        }
        .bookmark-btn:hover {
            transform: scale(1.1);
            background: rgba(0, 0, 0, 0.85);
        }
        .bookmark-btn:active {
            transform: scale(0.95);
        }
    </style>
@endpush

@section('content')
<div class="library-container">
    
    <!-- SEARCH BAR -->
    <div style="display: flex; gap: 16px; align-items: center; width: 100%; margin-bottom: 32px;">
        <form method="GET" action="{{ route('library') }}" class="search-bar-form" style="margin-bottom: 0; flex: 1;">
            <!-- Preserve category filter when searching -->
            @if($category && $category !== 'all')
                <input type="hidden" name="category" value="{{ $category }}">
            @endif
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input type="text" name="search" class="search-input" placeholder="Search" value="{{ $search }}">
        </form>
        @if(auth()->check() && auth()->user()->role === 'ADMIN')
            <a href="{{ route('admin.articles.create') }}" class="add-article-btn" title="Add Article" style="display: flex; align-items: center; justify-content: center; width: 56px; height: 56px; background: var(--search-bg); border-radius: 12px; border: 1px solid rgba(255,255,255,0.05); color: var(--cyan); text-decoration: none; cursor: pointer; transition: 0.2s; flex-shrink: 0; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
                <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
            </a>
        @endif
    </div>

    <!-- CATEGORIES -->
    <div class="category-pills">
        <a href="{{ route('library', ['category' => 'all', 'search' => $search]) }}" class="cat-pill {{ $category === 'all' ? 'active' : '' }}">ALL RESEARCH</a>
        @foreach($categories as $cat)
            <a href="{{ route('library', ['category' => $cat, 'search' => $search]) }}" class="cat-pill {{ $category === $cat ? 'active' : '' }}">{{ strtoupper($cat) }}</a>
        @endforeach
        <a href="{{ route('library', ['category' => 'bookmarks', 'search' => $search]) }}" class="cat-pill {{ $category === 'bookmarks' ? 'active' : '' }}">⭐ BOOKMARKED</a>
    </div>

    <!-- ARTICLES -->
    <div class="articles-list">
        @forelse($articles as $article)
            <div class="article-card">
                <div class="article-image-wrapper" style="position: relative; width: 100%;">
                    @if($article->thumbnail_url)
                        <img src="{{ $article->thumbnail_url }}" alt="{{ $article->title }}" class="article-img">
                    @else
                        <div class="article-img" style="display:flex; align-items:center; justify-content:center; font-size:48px;">🧪</div>
                    @endif
                    
                    <button class="bookmark-btn" data-article-id="{{ $article->id }}" aria-label="Bookmark article">
                        <svg viewBox="0 0 24 24" class="bookmark-icon" width="20" height="20" style="transition: transform 0.2s ease, fill 0.2s ease;">
                            <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z" 
                                  fill="{{ in_array($article->id, $bookmarkedArticleIds) ? '#00d4d4' : 'none' }}" 
                                  stroke="{{ in_array($article->id, $bookmarkedArticleIds) ? '#00d4d4' : 'rgba(255,255,255,0.8)' }}" 
                                  stroke-width="2"/>
                        </svg>
                    </button>
                </div>
                
                <div class="article-title">{{ $article->title }}</div>
                <div class="article-desc">{{ $article->description }}</div>
                
                <div style="display: flex; gap: 12px; width: 100%;">
                    <a href="/articles/{{ $article->id }}" class="btn-read" style="flex: 1; max-width: none;">READ ARTICLE</a>
                    @if(auth()->check() && auth()->user()->role === 'ADMIN')
                        <a href="{{ route('admin.articles.edit', $article->id) }}" class="btn-edit-sm" title="Edit Article" style="display: flex; align-items: center; justify-content: center; width: 56px; height: 56px; background: rgba(255,255,255,0.05); border-radius: 12px; border: 1px solid rgba(255,255,255,0.1); color: var(--cyan); text-decoration: none; cursor: pointer; transition: 0.2s;">
                            <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 20h9"></path>
                                <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                            </svg>
                        </a>
                        <form method="POST" action="{{ route('admin.articles.destroy', $article->id) }}" onsubmit="return confirm('Are you sure you want to delete this article?');" style="margin: 0;">
                            @csrf
                            <button type="submit" class="btn-delete-sm" title="Delete Article" style="display: flex; align-items: center; justify-content: center; width: 56px; height: 56px; background: rgba(255,70,70,0.1); border-radius: 12px; border: 1px solid rgba(255,70,70,0.2); color: #ff4646; cursor: pointer; transition: 0.2s; outline: none;">
                                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <polyline points="3 6 5 6 21 6"></polyline>
                                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                </svg>
                            </button>
                        </form>
                    @endif
                </div>
                
                @if(!$loop->last)
                    <div class="article-divider"></div>
                @endif
            </div>
        @empty
            <div style="text-align:center; padding: 40px; color: rgba(255,255,255,0.5);">
                {{ $category === 'bookmarks' ? 'No bookmarked articles.' : 'No articles found.' }}
            </div>
        @endforelse
    </div>

</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.bookmark-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const articleId = this.dataset.articleId;
            const iconPath = this.querySelector('path');
            
            // Optimistic Update
            const isBookmarked = iconPath.getAttribute('fill') !== 'none';
            if (isBookmarked) {
                iconPath.setAttribute('fill', 'none');
                iconPath.setAttribute('stroke', 'rgba(255,255,255,0.8)');
            } else {
                iconPath.setAttribute('fill', '#00d4d4');
                iconPath.setAttribute('stroke', '#00d4d4');
            }
            
            fetch(`/articles/${articleId}/bookmark`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                }
            })
            .then(res => {
                if (!res.ok) throw new Error('Failed to toggle bookmark');
                return res.json();
            })
            .then(data => {
                // Ensure UI state matches server response
                if (data.is_bookmarked) {
                    iconPath.setAttribute('fill', '#00d4d4');
                    iconPath.setAttribute('stroke', '#00d4d4');
                } else {
                    iconPath.setAttribute('fill', 'none');
                    iconPath.setAttribute('stroke', 'rgba(255,255,255,0.8)');
                    
                    // If filtering by bookmarks, remove the card immediately
                    const urlParams = new URLSearchParams(window.location.search);
                    if (urlParams.get('category') === 'bookmarks') {
                        const card = btn.closest('.article-card');
                        const divider = card.nextElementSibling;
                        if (divider && divider.classList.contains('article-divider')) {
                            divider.remove();
                        } else {
                            const prevDivider = card.previousElementSibling;
                            if (prevDivider && prevDivider.classList.contains('article-divider')) {
                                prevDivider.remove();
                            }
                        }
                        card.remove();
                        
                        // Check if list is now empty
                        const list = document.querySelector('.articles-list');
                        if (list && list.querySelectorAll('.article-card').length === 0) {
                            list.innerHTML = `<div style="text-align:center; padding: 40px; color: rgba(255,255,255,0.5);">No bookmarked articles.</div>`;
                        }
                    }
                }
                
                // Update sidebar badge
                updateSidebarBookmarkCount(data.count);
            })
            .catch(err => {
                console.error(err);
                // Revert optimistic update
                if (isBookmarked) {
                    iconPath.setAttribute('fill', '#00d4d4');
                    iconPath.setAttribute('stroke', '#00d4d4');
                } else {
                    iconPath.setAttribute('fill', 'none');
                    iconPath.setAttribute('stroke', 'rgba(255,255,255,0.8)');
                }
            });
        });
    });
    
    function updateSidebarBookmarkCount(count) {
        const container = document.getElementById('sidebar-bookmark-icon-container');
        if (!container) return;
        
        if (count > 0) {
            container.innerHTML = `
                <svg viewBox="0 0 24 24" fill="#00d4d4" width="20" height="20" style="opacity: 1;" class="sidebar-bookmark-svg">
                    <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
                </svg>
                <span class="sidebar-bookmark-badge" style="position: absolute; top: -4px; right: -4px; background: #ff4646; color: white; font-size: 8px; font-weight: 900; width: 13px; height: 13px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 4px rgba(0,0,0,0.4); z-index: 2;">${count}</span>
            `;
        } else {
            container.innerHTML = `
                <svg viewBox="0 0 24 24" fill="rgba(255,255,255,0.3)" width="20" height="20" style="opacity: 1;" class="sidebar-bookmark-svg">
                    <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
                </svg>
            `;
        }
    }
});
</script>
@endpush
