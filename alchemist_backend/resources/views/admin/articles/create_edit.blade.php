@extends('layouts.app')

@section('title', (isset($article) ? 'Edit Article' : 'Add Article') . ' — Alchemist')

@push('styles')
<style>
    :root {
        --bg-color: #080d0e;
        --panel-bg: rgba(13, 28, 30, 0.6);
        --panel-border: rgba(0, 212, 212, 0.12);
        --input-bg: #112022;
        --neon-cyan: #00d4d4;
        --neon-glow: 0 0 15px rgba(0, 212, 212, 0.35);
        --lime: #b8f400;
        --danger: #ff4646;
    }

    .editor-wrapper {
        display: grid;
        grid-template-columns: 1.2fr 0.8fr;
        gap: 32px;
        max-width: 1200px;
        margin: 0 auto;
        padding-bottom: 80px;
    }

    @media (max-width: 992px) {
        .editor-wrapper {
            grid-template-columns: 1fr;
        }
    }

    /* ── PANELS ── */
    .glass-panel {
        background: var(--panel-bg);
        border: 1px solid var(--panel-border);
        border-radius: 20px;
        padding: 32px;
        backdrop-filter: blur(12px);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    }

    .panel-title {
        font-family: 'Space Grotesk', sans-serif;
        font-size: 24px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #fff;
        margin-bottom: 8px;
    }

    .panel-subtitle {
        font-size: 13px;
        color: rgba(255, 255, 255, 0.5);
        margin-bottom: 24px;
    }

    /* ── FORMS ── */
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 8px;
        margin-bottom: 20px;
    }

    .form-label {
        font-size: 11px;
        font-weight: 700;
        color: rgba(255, 255, 255, 0.6);
        text-transform: uppercase;
        letter-spacing: 0.1em;
    }

    .form-control {
        background: var(--input-bg);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 14px 18px;
        color: #fff;
        font-size: 14.5px;
        font-family: 'Inter', sans-serif;
        outline: none;
        transition: all 0.2s ease;
    }

    .form-control:focus {
        border-color: var(--neon-cyan);
        box-shadow: 0 0 10px rgba(0, 212, 212, 0.15);
    }

    textarea.form-control {
        resize: vertical;
        min-height: 100px;
    }

    .form-row-2 {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    /* ── THUMBNAIL PREVIEW ── */
    .thumbnail-upload-box {
        display: flex;
        gap: 20px;
        align-items: center;
        background: rgba(0, 0, 0, 0.15);
        padding: 16px;
        border-radius: 14px;
        border: 1px dashed rgba(255, 255, 255, 0.1);
    }

    .thumb-preview {
        width: 90px;
        height: 90px;
        border-radius: 10px;
        background: #111;
        object-fit: cover;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        border: 1px solid rgba(255, 255, 255, 0.05);
        flex-shrink: 0;
    }

    /* ── BLOCK BUILDER ITEMS ── */
    .blocks-container {
        display: flex;
        flex-direction: column;
        gap: 16px;
        margin-bottom: 24px;
    }

    .block-card {
        background: rgba(17, 34, 36, 0.95);
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 14px;
        padding: 20px;
        position: relative;
        transition: transform 0.2s, box-shadow 0.2s;
        cursor: grab;
    }

    .block-card:active {
        cursor: grabbing;
    }

    .block-card.dragging {
        opacity: 0.4;
        border: 1px dashed var(--neon-cyan);
    }

    .block-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 14px;
        user-select: none;
    }

    .block-title-box {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .drag-handle {
        color: rgba(255, 255, 255, 0.2);
        font-size: 16px;
        cursor: grab;
    }

    .block-type-badge {
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        color: var(--neon-cyan);
        background: rgba(0, 212, 212, 0.08);
        padding: 4px 10px;
        border-radius: 99px;
        letter-spacing: 0.05em;
    }

    .btn-delete-block {
        background: none;
        border: none;
        color: var(--danger);
        cursor: pointer;
        opacity: 0.6;
        transition: 0.2s;
    }

    .btn-delete-block:hover {
        opacity: 1.0;
        transform: scale(1.1);
    }

    /* ── CONTROLS INSIDE BLOCKS ── */
    .text-properties {
        display: flex;
        align-items: center;
        gap: 20px;
        margin-top: 14px;
        background: rgba(0, 0, 0, 0.15);
        padding: 10px 16px;
        border-radius: 8px;
    }

    .font-size-slider-box {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 1;
    }

    .bold-toggle-btn {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: #fff;
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        transition: 0.2s;
    }

    .bold-toggle-btn.active {
        background: var(--neon-cyan);
        color: #000;
        border-color: var(--neon-cyan);
    }

    /* ── TABLE BLOCK EDITOR ── */
    .table-editor-wrapper {
        background: rgba(0, 0, 0, 0.2);
        border-radius: 10px;
        padding: 12px;
        overflow-x: auto;
        margin-bottom: 12px;
    }

    .builder-table {
        width: 100%;
        border-collapse: collapse;
    }

    .builder-table th, .builder-table td {
        padding: 6px;
        border: 1px solid rgba(255, 255, 255, 0.05);
    }

    .builder-table input {
        background: var(--input-bg);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: #fff;
        padding: 6px 10px;
        border-radius: 6px;
        font-size: 13px;
        width: 100%;
        outline: none;
    }

    .builder-table input:focus {
        border-color: var(--neon-cyan);
    }

    .table-controls {
        display: flex;
        gap: 8px;
        margin-top: 8px;
    }

    .btn-table-action {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: rgba(255,255,255,0.7);
        font-size: 11px;
        font-weight: 700;
        padding: 6px 12px;
        border-radius: 6px;
        cursor: pointer;
        transition: 0.2s;
    }

    .btn-table-action:hover {
        background: rgba(255,255,255,0.1);
        color: #fff;
    }

    .btn-table-action.danger:hover {
        background: rgba(255, 70, 70, 0.15);
        color: var(--danger);
        border-color: rgba(255, 70, 70, 0.3);
    }

    /* ── ADD BLOCK BUTTONS (DASHED OUTLINE OPTION) ── */
    .block-addition-panel {
        border: 2px dashed rgba(0, 212, 212, 0.2);
        border-radius: 16px;
        padding: 24px;
        text-align: center;
        background: rgba(0, 212, 212, 0.01);
        margin-bottom: 24px;
    }

    .add-block-buttons {
        display: flex;
        gap: 16px;
        justify-content: center;
        margin-bottom: 12px;
    }

    .btn-add-block-type {
        flex: 1;
        max-width: 130px;
        background: #0d2224;
        border: 1px solid rgba(0, 212, 212, 0.25);
        color: var(--neon-cyan);
        padding: 12px 0;
        border-radius: 10px;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        transition: 0.2s;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
    }

    .btn-add-block-type:hover {
        background: var(--neon-cyan);
        color: #000;
        border-color: var(--neon-cyan);
        box-shadow: var(--neon-glow);
    }

    .drag-helper-text {
        font-size: 11px;
        color: rgba(255, 255, 255, 0.4);
    }

    /* ── PREVIEW ARTICLE CARD ── */
    .sticky-preview {
        position: sticky;
        top: 24px;
    }

    .preview-container {
        background: #071a1c;
        border: 2px solid rgba(0, 212, 212, 0.2);
        border-radius: 20px;
        padding: 24px;
        min-height: 400px;
        box-shadow: inset 0 0 20px rgba(0, 212, 212, 0.05);
    }

    .preview-placeholder {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 350px;
        color: rgba(255, 255, 255, 0.35);
        text-align: center;
        gap: 16px;
    }

    .preview-placeholder .wireframe-shape {
        width: 140px;
        height: 140px;
        border: 2px dashed rgba(255, 255, 255, 0.15);
        border-radius: 14px;
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .preview-placeholder .circle {
        width: 60px;
        height: 60px;
        border: 2px dashed rgba(255, 255, 255, 0.15);
        border-radius: 50%;
        position: absolute;
        left: -20px;
        top: 30px;
    }

    .preview-placeholder .diamond {
        width: 80px;
        height: 80px;
        border: 2px dashed rgba(255, 255, 255, 0.15);
        transform: rotate(45deg);
        position: absolute;
        right: -30px;
        top: 20px;
    }

    .preview-content {
        display: flex;
        flex-direction: column;
        gap: 20px;
        font-family: 'Inter', sans-serif;
    }

    .preview-header-meta {
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        padding-bottom: 16px;
    }

    .preview-title {
        font-family: 'Space Grotesk', sans-serif;
        font-size: 24px;
        font-weight: 700;
        color: #fff;
        line-height: 1.3;
    }

    .preview-badge-row {
        display: flex;
        gap: 8px;
        margin-top: 10px;
    }

    .preview-badge {
        font-size: 9px;
        font-weight: 700;
        text-transform: uppercase;
        padding: 3px 8px;
        border-radius: 4px;
        letter-spacing: 0.05em;
    }

    .preview-badge.category {
        background: var(--neon-cyan);
        color: #000;
    }

    .preview-badge.difficulty {
        background: rgba(255, 255, 255, 0.08);
        color: rgba(255, 255, 255, 0.7);
        border: 1px solid rgba(255, 255, 255, 0.1);
    }

    .preview-thumb {
        width: 100%;
        height: 180px;
        border-radius: 12px;
        object-fit: cover;
        margin-top: 14px;
        background: #111;
        border: 1px solid rgba(255, 255, 255, 0.05);
    }

    /* Preview blocks rendering */
    .preview-block-text {
        color: rgba(255, 255, 255, 0.85);
        line-height: 1.6;
        word-break: break-word;
        white-space: pre-wrap;
    }

    .preview-block-image {
        width: 100%;
        border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.05);
        object-fit: cover;
    }

    .preview-block-table {
        width: 100%;
        border-collapse: collapse;
        margin: 8px 0;
    }

    .preview-block-table th, .preview-block-table td {
        padding: 10px 12px;
        border: 1px solid rgba(255,255,255,0.08);
        font-size: 13.5px;
        text-align: left;
    }

    .preview-block-table th {
        background: rgba(255,255,255,0.03);
        color: var(--neon-cyan);
        font-weight: 700;
    }

    .preview-block-table td {
        color: rgba(255,255,255,0.8);
    }

    /* ── SAVE BUTTON ── */
    .btn-save-article {
        background: var(--neon-cyan);
        color: #000;
        font-family: 'Space Grotesk', sans-serif;
        font-size: 15px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.15em;
        width: 100%;
        padding: 20px 0;
        border: none;
        border-radius: 99px;
        cursor: pointer;
        margin-top: 32px;
        transition: 0.2s;
        box-shadow: var(--neon-glow);
        text-align: center;
        display: block;
        text-decoration: none;
    }

    .btn-save-article:hover {
        opacity: 0.9;
        transform: translateY(-2px);
        box-shadow: 0 0 25px rgba(0, 212, 212, 0.6);
    }

    .btn-save-article:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
    }

    /* ── FILE UPLOAD HIDDEN ── */
    .file-input-hidden {
        display: none;
    }

    .thumb-btn-change {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: #fff;
        padding: 10px 18px;
        border-radius: 8px;
        font-size: 12.5px;
        font-weight: 600;
        cursor: pointer;
        transition: 0.2s;
    }

    .thumb-btn-change:hover {
        background: rgba(255, 255, 255, 0.10);
    }

    .img-upload-placeholder {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 120px;
        border: 1px dashed rgba(255, 255, 255, 0.15);
        border-radius: 10px;
        cursor: pointer;
        color: rgba(255, 255, 255, 0.5);
        font-size: 12px;
        transition: 0.2s;
        gap: 6px;
    }

    .img-upload-placeholder:hover {
        border-color: var(--neon-cyan);
        color: var(--neon-cyan);
    }

    .uploading-spinner {
        font-size: 12px;
        color: var(--neon-cyan);
    }
</style>
@endpush

@section('content')
<div class="editor-wrapper">

    <!-- LEFT COLUMN: BUILDER FORM -->
    <div>
        <div class="glass-panel" style="margin-bottom: 24px;">
            <h2 class="panel-title">{{ isset($article) ? 'Edit Article' : 'Add Article' }}</h2>
            <div class="panel-subtitle">Konfigurasi metadata utama artikel di bawah ini</div>

            <form id="article-form" onsubmit="submitForm(event)">
                @csrf
                
                <!-- TITLE -->
                <div class="form-group">
                    <label class="form-label">Article Title</label>
                    <input type="text" id="article-title" class="form-control" placeholder="Contoh: Misteri Struktur Inti Atom" value="{{ $article->title ?? '' }}" required>
                </div>

                <!-- DESCRIPTION -->
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea id="article-description" class="form-control" placeholder="Tulis deskripsi singkat tentang materi artikel..." required>{{ $article->description ?? '' }}</textarea>
                </div>

                <!-- CATEGORY & DIFFICULTY LEVEL -->
                <div class="form-row-2">
                    <div class="form-group">
                        <label class="form-label">Category</label>
                        <input type="text" id="article-category" class="form-control" placeholder="Contoh: ATOM" value="{{ $article->category ?? '' }}" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Difficulty Level</label>
                        <select id="article-difficulty" class="form-control" required style="background-color: var(--input-bg); color: #fff;">
                            <option value="Dasar" {{ (isset($article) && $article->difficulty_level === 'Dasar') ? 'selected' : '' }}>Dasar (Beginner)</option>
                            <option value="Menengah" {{ (isset($article) && $article->difficulty_level === 'Menengah') ? 'selected' : '' }}>Menengah (Intermediate)</option>
                            <option value="Sulit" {{ (isset($article) && $article->difficulty_level === 'Sulit') ? 'selected' : '' }}>Sulit (Hard)</option>
                        </select>
                    </div>
                </div>

                <!-- THUMBNAIL -->
                <div class="form-group">
                    <label class="form-label">Article Thumbnail</label>
                    <div class="thumbnail-upload-box">
                        <div id="thumb-preview" class="thumb-preview">
                            @if(isset($article) && $article->thumbnail_url)
                                <img src="{{ $article->thumbnail_url }}" style="width:100%; height:100%; object-fit:cover; border-radius:8px;" id="thumb-preview-img">
                            @else
                                <span id="thumb-preview-placeholder">🧪</span>
                            @endif
                        </div>
                        <div style="flex: 1;">
                            <input type="text" id="article-thumbnail-url" class="form-control" style="margin-bottom: 8px;" placeholder="URL Gambar Thumbnail..." value="{{ $article->thumbnail_url ?? '' }}" required>
                            <button type="button" class="thumb-btn-change" onclick="triggerFileUpload('thumb-file-input')">Upload File</button>
                            <input type="file" id="thumb-file-input" class="file-input-hidden" accept="image/*" onchange="uploadFile(this, 'thumb')">
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <!-- BLOCK MANAGER PANEL -->
        <div class="glass-panel">
            <h3 class="panel-title" style="font-size: 20px; margin-bottom: 4px;">Content Blocks</h3>
            <div class="panel-subtitle" style="margin-bottom: 20px;">Tambahkan teks, gambar, dan tabel untuk menyusun artikel</div>

            <!-- Blocks List -->
            <div id="blocks-list" class="blocks-container">
                <!-- Javascript will inject blocks here -->
            </div>

            <!-- Block Additions dashed area -->
            <div class="block-addition-panel">
                <div class="add-block-buttons">
                    <button type="button" class="btn-add-block-type" onclick="addBlock('text')">Text</button>
                    <button type="button" class="btn-add-block-type" onclick="addBlock('image')">Image</button>
                    <button type="button" class="btn-add-block-type" onclick="addBlock('table')">Table</button>
                </div>
                <div class="drag-helper-text">Drag and drop the content to manage the structure position</div>
            </div>
        </div>
    </div>

    <!-- RIGHT COLUMN: STICKY PREVIEW -->
    <div class="sticky-preview">
        <div class="preview-container">
            <h3 class="panel-title" style="font-size: 16px; border-bottom: 1px solid rgba(255,255,255,0.06); padding-bottom: 12px; margin-bottom: 16px;">Preview Article</h3>
            
            <!-- Default Placeholder -->
            <div id="preview-placeholder-box" class="preview-placeholder">
                <div class="wireframe-shape">
                    <div class="circle"></div>
                    <div class="diamond"></div>
                    🧪
                </div>
                <div style="font-size: 13px; font-weight: 500; line-height: 1.5;">Pratinjau langsung artikel Anda<br><span style="opacity: 0.5;">Akan terupdate otomatis sewaktu Anda mengedit</span></div>
            </div>

            <!-- Active Live Content Rendering -->
            <div id="preview-content-box" class="preview-content" style="display: none;">
                <div class="preview-header-meta">
                    <div id="preview-title" class="preview-title">Judul Artikel</div>
                    <div class="preview-badge-row">
                        <span id="preview-category" class="preview-badge category">KATEGORI</span>
                        <span id="preview-difficulty" class="preview-badge difficulty">Level</span>
                    </div>
                </div>
                <img id="preview-thumbnail" class="preview-thumb" style="display: none;">
                <div id="preview-blocks-rendered">
                    <!-- Dynamic rendering of content blocks -->
                </div>
            </div>
        </div>

        <button type="submit" form="article-form" id="btn-save" class="btn-save-article">SAVE ARTICLE</button>
        <div style="text-align: center; margin-top: 20px;">
            <a href="{{ route('library') }}" style="color: rgba(255,255,255,0.4); text-decoration: none; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; transition: 0.2s;" onmouseover="this.style.color='#fff'" onmouseout="this.style.color='rgba(255,255,255,0.4)'">CANCEL & GO BACK</a>
        </div>
    </div>

</div>
@endsection

@push('scripts')
<script>
    // State of all active article content blocks
    let blocks = [];
    
    // Setup file inputs trigger helper
    function triggerFileUpload(id) {
        document.getElementById(id).click();
    }

    // Escape HTML helper
    function escapeHtml(text) {
        if (!text) return '';
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // Initial load state
    document.addEventListener('DOMContentLoaded', () => {
        // Load initial blocks if editing
        const rawContents = @json($article ? $article->contents : []);
        if (rawContents && rawContents.length > 0) {
            blocks = rawContents.map((item, idx) => {
                let parsedContent = item.content;
                if (item.type === 'text') {
                    try {
                        parsedContent = JSON.parse(item.content);
                        if (typeof parsedContent === 'string' || parsedContent === null) {
                            parsedContent = { text: parsedContent || '', fontSize: 16, fontWeight: 'normal' };
                        }
                    } catch (e) {
                        parsedContent = { text: item.content || '', fontSize: 16, fontWeight: 'normal' };
                    }
                } else if (item.type === 'table') {
                    try {
                        parsedContent = JSON.parse(item.content);
                    } catch (e) {
                        parsedContent = { headers: ['Header 1', 'Header 2'], rows: [['Cell 1', 'Cell 2']] };
                    }
                }
                return {
                    id: 'block_' + idx + '_' + Date.now(),
                    type: item.type,
                    content: parsedContent
                };
            });
        }

        // Add real-time event listeners on basic fields to update preview
        const inputs = ['article-title', 'article-description', 'article-category', 'article-difficulty', 'article-thumbnail-url'];
        inputs.forEach(id => {
            document.getElementById(id).addEventListener('input', updatePreview);
        });
        document.getElementById('article-difficulty').addEventListener('change', updatePreview);

        renderBlocks();
        updatePreview();
    });

    // Add content block
    function addBlock(type) {
        let blockContent = '';
        if (type === 'text') {
            blockContent = { text: '', fontSize: 16, fontWeight: 'normal' };
        } else if (type === 'image') {
            blockContent = '';
        } else if (type === 'table') {
            blockContent = {
                headers: ['Header 1', 'Header 2'],
                rows: [['Cell 1', 'Cell 2']]
            };
        }

        blocks.push({
            id: 'block_' + Date.now() + '_' + Math.random().toString(36).substr(2, 5),
            type: type,
            content: blockContent
        });

        renderBlocks();
        updatePreview();
    }

    // Delete content block
    function deleteBlock(id) {
        blocks = blocks.filter(b => b.id !== id);
        renderBlocks();
        updatePreview();
    }

    // Text Block inputs listener updates
    function updateTextBlock(id, field, value) {
        const idx = blocks.findIndex(b => b.id === id);
        if (idx !== -1) {
            blocks[idx].content[field] = value;
            // Update fontSize UI label directly
            if (field === 'fontSize') {
                const label = document.getElementById(`fontsize-lbl-${id}`);
                if (label) label.textContent = value + 'px';
            }
            updatePreview();
        }
    }

    function toggleTextBold(id) {
        const idx = blocks.findIndex(b => b.id === id);
        if (idx !== -1) {
            const currentWeight = blocks[idx].content.fontWeight;
            const newWeight = currentWeight === 'bold' ? 'normal' : 'bold';
            blocks[idx].content.fontWeight = newWeight;
            
            const btn = document.getElementById(`bold-btn-${id}`);
            if (btn) {
                if (newWeight === 'bold') {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            }
            updatePreview();
        }
    }

    // Table Block inputs listener updates
    function updateTableHeader(blockId, colIdx, value) {
        const idx = blocks.findIndex(b => b.id === blockId);
        if (idx !== -1) {
            blocks[idx].content.headers[colIdx] = value;
            updatePreview();
        }
    }

    function updateTableCell(blockId, rowIdx, colIdx, value) {
        const idx = blocks.findIndex(b => b.id === blockId);
        if (idx !== -1) {
            blocks[idx].content.rows[rowIdx][colIdx] = value;
            updatePreview();
        }
    }

    function addTableRow(blockId) {
        const idx = blocks.findIndex(b => b.id === blockId);
        if (idx !== -1) {
            const numCols = blocks[idx].content.headers.length;
            const newRow = Array(numCols).fill('Cell');
            blocks[idx].content.rows.push(newRow);
            renderBlocks();
            updatePreview();
        }
    }

    function removeTableRow(blockId) {
        const idx = blocks.findIndex(b => b.id === blockId);
        if (idx !== -1 && blocks[idx].content.rows.length > 1) {
            blocks[idx].content.rows.pop();
            renderBlocks();
            updatePreview();
        }
    }

    function addTableCol(blockId) {
        const idx = blocks.findIndex(b => b.id === blockId);
        if (idx !== -1) {
            blocks[idx].content.headers.push('Header');
            blocks[idx].content.rows.forEach(row => row.push('Cell'));
            renderBlocks();
            updatePreview();
        }
    }

    function removeTableCol(blockId) {
        const idx = blocks.findIndex(b => b.id === blockId);
        if (idx !== -1 && blocks[idx].content.headers.length > 1) {
            blocks[idx].content.headers.pop();
            blocks[idx].content.rows.forEach(row => row.pop());
            renderBlocks();
            updatePreview();
        }
    }

    // Upload files handler (Image blocks and Thumbnails)
    function uploadFile(inputElement, type, blockId = null) {
        const file = inputElement.files[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('image', file);

        // Show uploading feedback
        if (type === 'thumb') {
            const preview = document.getElementById('thumb-preview');
            preview.innerHTML = '<span class="uploading-spinner">⏳ UPLOADING...</span>';
        } else if (type === 'block' && blockId) {
            const box = document.getElementById(`upload-box-${blockId}`);
            if (box) box.innerHTML = '<span class="uploading-spinner">⏳ UPLOADING...</span>';
        }

        fetch('{{ route("admin.articles.upload_image") }}', {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        })
        .then(res => {
            if (!res.ok) throw new Error('File upload failed');
            return res.json();
        })
        .then(data => {
            if (data.success && data.url) {
                if (type === 'thumb') {
                    document.getElementById('article-thumbnail-url').value = data.url;
                    const preview = document.getElementById('thumb-preview');
                    preview.innerHTML = `<img src="${data.url}" style="width:100%; height:100%; object-fit:cover; border-radius:8px;">`;
                } else if (type === 'block' && blockId) {
                    const idx = blocks.findIndex(b => b.id === blockId);
                    if (idx !== -1) {
                        blocks[idx].content = data.url;
                        renderBlocks();
                    }
                }
                updatePreview();
            } else {
                alert('Upload failed: ' + (data.message || 'Unknown error'));
                renderBlocks();
            }
        })
        .catch(err => {
            console.error(err);
            alert('Upload failed: server error');
            renderBlocks();
        });
    }

    // Render blocks list in block manager
    function renderBlocks() {
        const container = document.getElementById('blocks-list');
        container.innerHTML = '';

        if (blocks.length === 0) {
            container.innerHTML = `<div style="text-align:center; padding: 20px; color:rgba(255,255,255,0.3); font-size:13px; border:1px dashed rgba(255,255,255,0.05); border-radius:10px;">Belum ada blok konten. Tambahkan block menggunakan pilihan di bawah.</div>`;
            return;
        }

        blocks.forEach((block, idx) => {
            const card = document.createElement('div');
            card.className = 'block-card';
            card.draggable = true;
            card.dataset.id = block.id;

            // Attach drag-drop events to element
            card.addEventListener('dragstart', handleDragStart);
            card.addEventListener('dragover', handleDragOver);
            card.addEventListener('drop', handleDrop);
            card.addEventListener('dragend', handleDragEnd);

            let blockContentHtml = '';

            if (block.type === 'text') {
                blockContentHtml = `
                    <div class="form-group" style="margin-bottom:0">
                        <textarea class="form-control" placeholder="Tulis isi paragraf di sini..." oninput="updateTextBlock('${block.id}', 'text', this.value)" style="min-height:70px">${escapeHtml(block.content.text || '')}</textarea>
                    </div>
                    <div class="text-properties">
                        <div class="font-size-slider-box">
                            <span class="form-label" style="font-size:10px">Size</span>
                            <input type="range" min="12" max="32" value="${block.content.fontSize || 16}" oninput="updateTextBlock('${block.id}', 'fontSize', parseFloat(this.value))" style="flex:1; accent-color:var(--neon-cyan)">
                            <span id="fontsize-lbl-${block.id}" style="font-size:11px; font-weight:700; width:35px; text-align:right">${block.content.fontSize || 16}px</span>
                        </div>
                        <button type="button" id="bold-btn-${block.id}" class="bold-toggle-btn ${block.content.fontWeight === 'bold' ? 'active' : ''}" onclick="toggleTextBold('${block.id}')">B</button>
                    </div>
                `;
            } else if (block.type === 'image') {
                if (block.content) {
                    blockContentHtml = `
                        <div style="display:flex; gap:16px; align-items:center;">
                            <img src="${block.content}" style="width:70px; height:70px; border-radius:8px; object-fit:cover; background:#111; border:1px solid rgba(255,255,255,0.1)">
                            <div style="flex:1">
                                <input type="text" class="form-control" value="${block.content}" readonly style="margin-bottom:8px; font-size:12px; opacity:0.7">
                                <button type="button" class="btn-table-action" onclick="triggerFileUpload('file-input-${block.id}')">Ganti Gambar</button>
                            </div>
                        </div>
                        <input type="file" id="file-input-${block.id}" class="file-input-hidden" accept="image/*" onchange="uploadFile(this, 'block', '${block.id}')">
                    `;
                } else {
                    blockContentHtml = `
                        <div id="upload-box-${block.id}" class="img-upload-placeholder" onclick="triggerFileUpload('file-input-${block.id}')">
                            <span>📷</span>
                            <span>Upload Image Block</span>
                        </div>
                        <input type="file" id="file-input-${block.id}" class="file-input-hidden" accept="image/*" onchange="uploadFile(this, 'block', '${block.id}')">
                    `;
                }
            } else if (block.type === 'table') {
                blockContentHtml = `
                    <div class="table-editor-wrapper">
                        <table class="builder-table">
                            <thead>
                                <tr>
                                    ${block.content.headers.map((h, colIdx) => `
                                        <th>
                                            <input type="text" value="${escapeHtml(h)}" oninput="updateTableHeader('${block.id}', ${colIdx}, this.value)" placeholder="Header">
                                        </th>
                                    `).join('')}
                                </tr>
                            </thead>
                            <tbody>
                                ${block.content.rows.map((row, rowIdx) => `
                                    <tr>
                                        ${row.map((cell, colIdx) => `
                                            <td>
                                                <input type="text" value="${escapeHtml(cell)}" oninput="updateTableCell('${block.id}', ${rowIdx}, ${colIdx}, this.value)" placeholder="Cell">
                                            </td>
                                        `).join('')}
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                    <div class="table-controls">
                        <button type="button" class="btn-table-action" onclick="addTableRow('${block.id}')">+ Row</button>
                        <button type="button" class="btn-table-action" onclick="addTableCol('${block.id}')">+ Column</button>
                        <button type="button" class="btn-table-action danger" onclick="removeTableRow('${block.id}')">- Row</button>
                        <button type="button" class="btn-table-action danger" onclick="removeTableCol('${block.id}')">- Column</button>
                    </div>
                `;
            }

            card.innerHTML = `
                <div class="block-header">
                    <div class="block-title-box">
                        <span class="drag-handle">☰</span>
                        <span class="block-type-badge">${block.type}</span>
                    </div>
                    <button type="button" class="btn-delete-block" onclick="deleteBlock('${block.id}')" title="Hapus block">
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="3 6 5 6 21 6"></polyline>
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        </svg>
                    </button>
                </div>
                <div class="block-body">
                    ${blockContentHtml}
                </div>
            `;

            container.appendChild(card);
        });
    }

    // Reordering drag & drop handlers
    let dragSrcEl = null;

    function handleDragStart(e) {
        this.classList.add('dragging');
        dragSrcEl = this;
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/html', this.innerHTML);
    }

    function handleDragOver(e) {
        if (e.preventDefault) {
            e.preventDefault();
        }
        e.dataTransfer.dropEffect = 'move';
        return false;
    }

    function handleDrop(e) {
        e.stopPropagation();
        if (dragSrcEl !== this) {
            const list = Array.from(document.querySelectorAll('#blocks-list .block-card'));
            const srcIdx = list.indexOf(dragSrcEl);
            const destIdx = list.indexOf(this);

            // Reorder the backing blocks array state
            const targetBlock = blocks[srcIdx];
            blocks.splice(srcIdx, 1);
            blocks.splice(destIdx, 0, targetBlock);

            renderBlocks();
            updatePreview();
        }
        return false;
    }

    function handleDragEnd(e) {
        this.classList.remove('dragging');
    }

    // Dynamic Live Preview Rendering
    function updatePreview() {
        const titleVal = document.getElementById('article-title').value;
        const categoryVal = document.getElementById('article-category').value;
        const difficultyVal = document.getElementById('article-difficulty').value;
        const thumbUrl = document.getElementById('article-thumbnail-url').value;

        const hasAnyContent = titleVal || categoryVal || thumbUrl || blocks.length > 0;

        const placeholder = document.getElementById('preview-placeholder-box');
        const content = document.getElementById('preview-content-box');

        if (!hasAnyContent) {
            placeholder.style.display = 'flex';
            content.style.display = 'none';
            return;
        }

        placeholder.style.display = 'none';
        content.style.display = 'flex';

        // Render basic metadata
        document.getElementById('preview-title').textContent = titleVal || 'Judul Artikel';
        document.getElementById('preview-category').textContent = (categoryVal || 'KATEGORI').toUpperCase();
        document.getElementById('preview-difficulty').textContent = difficultyVal;

        const previewThumb = document.getElementById('preview-thumbnail');
        if (thumbUrl) {
            previewThumb.src = thumbUrl;
            previewThumb.style.display = 'block';
        } else {
            previewThumb.style.display = 'none';
        }

        // Render block contents in preview
        const blocksContainer = document.getElementById('preview-blocks-rendered');
        blocksContainer.innerHTML = '';

        blocks.forEach(block => {
            const blockEl = document.createElement('div');
            blockEl.style.marginBottom = '16px';

            if (block.type === 'text') {
                blockEl.className = 'preview-block-text';
                blockEl.style.fontSize = (block.content.fontSize || 16) + 'px';
                blockEl.style.fontWeight = block.content.fontWeight || 'normal';
                blockEl.textContent = block.content.text || '';
            } else if (block.type === 'image') {
                if (block.content) {
                    const img = document.createElement('img');
                    img.src = block.content;
                    img.className = 'preview-block-image';
                    blockEl.appendChild(img);
                } else {
                    const placeholderDiv = document.createElement('div');
                    placeholderDiv.style.cssText = 'height: 100px; background: rgba(255,255,255,0.02); border: 1px dashed rgba(255,255,255,0.1); border-radius: 8px; display:flex; align-items:center; justify-content:center; color:rgba(255,255,255,0.3); font-size:12px;';
                    placeholderDiv.textContent = '[Image Block]';
                    blockEl.appendChild(placeholderDiv);
                }
            } else if (block.type === 'table') {
                const table = document.createElement('table');
                table.className = 'preview-block-table';

                const thead = document.createElement('thead');
                const headerRow = document.createElement('tr');
                block.content.headers.forEach(h => {
                    const th = document.createElement('th');
                    th.textContent = h;
                    headerRow.appendChild(th);
                });
                thead.appendChild(headerRow);
                table.appendChild(thead);

                const tbody = document.createElement('tbody');
                block.content.rows.forEach(row => {
                    const tr = document.createElement('tr');
                    row.forEach(cell => {
                        const td = document.createElement('td');
                        td.textContent = cell;
                        tr.appendChild(td);
                    });
                    tbody.appendChild(tr);
                });
                table.appendChild(tbody);
                blockEl.appendChild(table);
            }

            blocksContainer.appendChild(blockEl);
        });
    }

    // Submit complete payload to backend
    function submitForm(event) {
        event.preventDefault();

        const title = document.getElementById('article-title').value;
        const description = document.getElementById('article-description').value;
        const category = document.getElementById('article-category').value;
        const difficulty_level = document.getElementById('article-difficulty').value;
        const thumbnail_url = document.getElementById('article-thumbnail-url').value;

        // Perform basic validations
        if (!title || !category || !thumbnail_url) {
            alert('Silakan lengkapi Judul, Kategori, dan Thumbnail Artikel.');
            return;
        }

        if (blocks.length === 0) {
            alert('Artikel harus memiliki minimal satu blok konten.');
            return;
        }

        // Validate image blocks aren't empty
        const hasEmptyImage = blocks.some(b => b.type === 'image' && !b.content);
        if (hasEmptyImage) {
            alert('Ada block gambar yang belum diupload gambarnya.');
            return;
        }

        // Format contents list to match back-end controller format
        const formattedContents = blocks.map(block => {
            return {
                type: block.type,
                content: block.content // Structured array/object for text/table, string URL for image
            };
        });

        const payload = {
            title,
            description,
            category,
            difficulty_level,
            thumbnail_url,
            contents: formattedContents
        };

        const saveBtn = document.getElementById('btn-save');
        saveBtn.disabled = true;
        saveBtn.textContent = 'SAVING ARTICLE...';

        const saveUrl = '{{ isset($article) ? route("admin.articles.update", $article->id) : route("admin.articles.store") }}';

        fetch(saveUrl, {
            method: 'POST',
            body: JSON.stringify(payload),
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            }
        })
        .then(res => {
            if (!res.ok) throw new Error('Network response was not ok');
            return res.json();
        })
        .then(data => {
            if (data.success) {
                alert(data.message || 'Article saved successfully');
                window.location.href = data.redirect || '{{ route("library") }}';
            } else {
                alert('Gagal menyimpan: ' + (data.message || 'Unknown error'));
                saveBtn.disabled = false;
                saveBtn.textContent = 'SAVE ARTICLE';
            }
        })
        .catch(err => {
            console.error(err);
            alert('Gagal menyimpan artikel. Coba periksa kembali data inputan.');
            saveBtn.disabled = false;
            saveBtn.textContent = 'SAVE ARTICLE';
        });
    }
</script>
@endpush
