@extends('layouts.app')

@section('title', 'Rank Editor')

@push('styles')
<style>
    .editor-container { padding: 20px; }
    .page-subtitle { font-size: 10px; font-weight: 700; color: var(--cyan); letter-spacing: 0.1em; text-transform: uppercase; margin-bottom: 8px; }
    .page-title { font-size: 20px; font-weight: 500; color: #fff; margin-bottom: 40px; }

    .editor-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 60px; }

    .section-title { font-size: 16px; font-weight: 500; color: var(--cyan); margin-bottom: 24px; text-transform: uppercase; letter-spacing: 0.05em; }

    /* Form */
    .form-group { margin-bottom: 20px; }
    .form-label { display: block; font-size: 10px; font-weight: 700; color: #fff; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px; }
    
    .form-control {
        width: 100%; background: #1a2527; border: none; border-radius: 8px;
        padding: 14px 16px; color: #fff; font-size: 14px; outline: none;
        font-family: inherit;
    }
    
    .upload-area {
        width: 100%; height: 160px; background: #131f21; border: 2px dashed rgba(255,255,255,0.1);
        border-radius: 12px; display: flex; align-items: center; justify-content: center;
        margin-bottom: 30px; cursor: pointer; position: relative; overflow: hidden;
    }
    .upload-area:hover { border-color: rgba(255,255,255,0.3); }
    .upload-icon { color: rgba(255,255,255,0.3); width: 40px; height: 40px; }
    
    #icon-preview {
        position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: contain; display: none; background: #0b1416;
    }

    .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    
    .btn-submit {
        width: 100%; background: #169b9e; color: #fff; border: none; border-radius: 8px;
        padding: 16px; font-size: 14px; font-weight: 600; cursor: pointer; transition: 0.2s;
    }
    .btn-submit:hover { background: #128285; }

    /* List */
    .active-title { color: #fff; font-size: 18px; margin-bottom: 24px; }
    .rank-list-item {
        background: #1a2426; border-radius: 12px; padding: 16px;
        display: flex; align-items: center; gap: 16px; margin-bottom: 12px;
    }
    .list-icon { width: 48px; height: 56px; object-fit: contain; }
    .list-info { flex: 1; }
    .list-name { font-size: 14px; font-weight: 500; color: #fff; margin-bottom: 4px; }
    .list-stats { font-size: 10px; color: rgba(255,255,255,0.6); display: flex; gap: 16px; }
    .list-actions { display: flex; gap: 12px; }
    .action-btn { background: none; border: none; color: rgba(255,255,255,0.6); cursor: pointer; transition: 0.2s; }
    .action-btn:hover { color: #fff; }

</style>
@endpush

@section('content')
<div class="editor-container">
    <div class="page-subtitle">REGISTRY MANAGEMENT</div>
    <div class="page-title">Rank Editor</div>

    @if(session('success'))
        <div style="background: rgba(0,212,212,0.1); color: var(--cyan); padding: 10px; border-radius: 8px; margin-bottom: 20px;">
            {{ session('success') }}
        </div>
    @endif

    <div class="editor-grid">
        <!-- Left: Form -->
        <div>
            <div class="section-title">ADD NEW RANK</div>
            
            <form action="{{ route('admin.ranks.store') }}" method="POST" enctype="multipart/form-data">
                @csrf
                <label class="upload-area" for="icon-upload">
                    <svg class="upload-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <img id="icon-preview" src="" alt="Preview">
                    <input type="file" id="icon-upload" name="icon" style="display: none;" accept="image/*" onchange="previewImage(this)">
                </label>
                
                <div class="form-group">
                    <label class="form-label">RANK NAME</label>
                    <input type="text" name="name" class="form-control" required>
                </div>
                
                <div class="row-2">
                    <div class="form-group">
                        <label class="form-label">CHAPTER LOG</label>
                        <input type="text" name="chapter" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label">XP THRESHOLD</label>
                        <input type="number" name="xp_threshold" class="form-control" required min="0">
                    </div>
                </div>
                
                <button type="submit" class="btn-submit">Forge new rank</button>
            </form>
        </div>
        
        <!-- Right: List -->
        <div>
            <div class="active-title">Active rank</div>
            
            @foreach($ranks as $rank)
            <div class="rank-list-item">
                @if($rank->icon_url)
                    <img src="{{ $rank->icon_url }}" class="list-icon">
                @else
                    <div class="list-icon" style="background:#333; display:flex; align-items:center; justify-content:center; border-radius:8px;">
                        <span style="font-size:10px;">No img</span>
                    </div>
                @endif
                
                <div class="list-info">
                    <div class="list-name">{{ $rank->name }}</div>
                    <div class="list-stats">
                        <span>Ch. {{ $rank->chapter ?? '?' }}</span>
                        <span>{{ number_format($rank->xp_threshold) }} XP</span>
                    </div>
                </div>
                
                <div class="list-actions">
                    <!-- Edit Button could just open a modal or scroll to top and fill form via JS. For simplicity, just an alert or basic implementation. -->
                    <button class="action-btn" onclick="editRank({{ $rank->id }}, '{{ $rank->name }}', '{{ $rank->chapter }}', {{ $rank->xp_threshold }})" title="Edit">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                    </button>
                    
                    <form action="{{ route('admin.ranks.destroy', $rank->id) }}" method="POST" onsubmit="return confirm('Delete this rank?');">
                        @csrf
                        <button type="submit" class="action-btn" title="Delete">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                        </button>
                    </form>
                </div>
            </div>
            @endforeach
        </div>
    </div>
</div>

<!-- Modal for Edit -->
<div id="editModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.8); z-index:1000; align-items:center; justify-content:center;">
    <div style="background:#1a2527; padding:30px; border-radius:16px; width:400px; max-width:90%;">
        <div class="section-title">EDIT RANK</div>
        <form id="editForm" method="POST" enctype="multipart/form-data">
            @csrf
            
            <div class="form-group">
                <label class="form-label">RANK NAME</label>
                <input type="text" name="name" id="edit-name" class="form-control" required>
            </div>
            
            <div class="row-2">
                <div class="form-group">
                    <label class="form-label">CHAPTER LOG</label>
                    <input type="text" name="chapter" id="edit-chapter" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">XP THRESHOLD</label>
                    <input type="number" name="xp_threshold" id="edit-xp" class="form-control" required min="0">
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">NEW ICON (OPTIONAL)</label>
                <input type="file" name="icon" class="form-control" accept="image/*">
            </div>
            
            <div style="display:flex; gap:10px; margin-top:20px;">
                <button type="button" class="btn-submit" style="background:#555;" onclick="document.getElementById('editModal').style.display='none'">Cancel</button>
                <button type="submit" class="btn-submit">Save Changes</button>
            </div>
        </form>
    </div>
</div>

@push('scripts')
<script>
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.getElementById('icon-preview');
                img.src = e.target.result;
                img.style.display = 'block';
            }
            reader.readAsDataURL(input.files[0]);
        }
    }
    
    function editRank(id, name, chapter, xp) {
        document.getElementById('editModal').style.display = 'flex';
        document.getElementById('editForm').action = '/admin/ranks/' + id;
        document.getElementById('edit-name').value = name;
        document.getElementById('edit-chapter').value = chapter;
        document.getElementById('edit-xp').value = xp;
    }
</script>
@endpush
@endsection
