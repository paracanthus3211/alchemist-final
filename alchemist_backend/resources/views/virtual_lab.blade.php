@extends('layouts.app')

@section('title', 'Virtual Lab — Alchemist')

@section('content')
<style>
    /* ── DASHBOARD THEME RESETS & FONTS ── */
    :root {
        --lab-bg: #090d10;
        --card-bg: #11161a;
        --accent-cyan: #00d4d4;
        --accent-lime: #b8f400;
        --accent-purple: #d896ff;
        --accent-orange: #ff9f1c;
        --accent-red: #ff4d4d;
        --text-muted: #6b7c85;
        --border-color: rgba(255, 255, 255, 0.05);
    }

    body {
        background-color: var(--lab-bg);
        color: #fff;
    }

    .vl-wrap {
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 24px;
        font-family: 'Inter', sans-serif;
    }

    /* ── TOP HEADER AREA ── */
    .vl-head {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        margin-bottom: 32px;
    }

    .vl-title-group .vl-title {
        font-size: 16px;
        font-weight: 500;
        color: var(--accent-lime);
        margin-bottom: 4px;
    }

    .vl-title-group .vl-subtitle {
        font-size: 20px;
        font-weight: 400;
        color: var(--accent-cyan);
    }

    .vl-title-group .vl-subtitle span {
        color: #fff;
        opacity: 0.8;
    }

    .vl-xp-badge {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 18px;
        font-weight: 600;
        color: #fff;
    }

    .vl-xp-badge svg {
        color: var(--accent-cyan);
        width: 24px;
        height: 24px;
    }

    /* ── TWO-COLUMN MAIN GRID ── */
    .vl-grid {
        display: grid;
        grid-template-columns: 1.3fr 0.7fr;
        gap: 24px;
        align-items: start;
    }

    @media (max-width: 980px) {
        .vl-grid {
            grid-template-columns: 1fr;
        }
    }

    /* ── LEFT COLUMN: MAIN WORKSPACE ── */
    .workspace-area {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 32px;
        padding: 20px 0;
    }

    .beakers-row {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 24px;
        width: 100%;
    }

    /* Beaker Component Design */
    .beaker-box-wrap {
        display: flex;
        flex-direction: column;
        align-items: center;
        width: 130px;
    }

    .beaker-frame {
        position: relative;
        width: 130px;
        height: 130px;
        background: rgba(255, 255, 255, 0.03);
        border: 2px solid rgba(255, 255, 255, 0.1);
        border-radius: 16px 16px 28px 28px;
        cursor: pointer;
        overflow: hidden;
        transition: all 0.2s ease;
    }

    .beaker-frame::before {
        content: '';
        position: absolute;
        top: 8px;
        left: 50%;
        transform: translateX(-50%);
        width: 110px;
        height: 2px;
        background: rgba(255, 255, 255, 0.2);
        border-radius: 99px;
    }

    .beaker-frame.active {
        border-color: var(--accent-cyan);
        box-shadow: 0 0 15px rgba(0, 212, 212, 0.2);
        background: rgba(0, 212, 212, 0.02);
    }

    /* Liquid Rendering System */
    .beaker-liquid {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 0;
        background: transparent;
        transition: height 0.3s cubic-bezier(0.4, 0, 0.2, 1), background 0.3s ease;
        opacity: 0.45;
    }

    .beaker-label-top {
        font-size: 11px;
        font-weight: 600;
        color: var(--text-muted);
        margin-bottom: 8px;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .beaker-meta-bottom {
        margin-top: 12px;
        text-align: center;
    }

    .beaker-meta-bottom .amt {
        font-size: 12px;
        font-weight: 500;
        color: var(--text-muted);
    }

    .beaker-meta-bottom .chem {
        font-size: 13px;
        font-weight: 600;
        color: #fff;
        margin-top: 2px;
    }

    /* Tubes Section */
    .tubes-row {
        display: flex;
        gap: 16px;
        justify-content: center;
        margin-top: 10px;
    }

    .tube-box-wrap {
        display: flex;
        flex-direction: column;
        align-items: center;
        width: 76px;
    }

    .tube-frame {
        position: relative;
        width: 76px;
        height: 120px;
        background: rgba(255, 255, 255, 0.03);
        border: 2px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px 12px 24px 24px;
        cursor: pointer;
        overflow: hidden;
        transition: all 0.2s ease;
    }

    .tube-frame.selected {
        border-color: var(--accent-orange);
        box-shadow: 0 0 12px rgba(255, 159, 28, 0.2);
    }

    .tube-liquid {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 0;
        background: transparent;
        transition: height 0.3s cubic-bezier(0.4, 0, 0.2, 1), background 0.3s ease;
        opacity: 0.45;
    }

    .tube-meta-bottom {
        font-size: 11px;
        font-weight: 500;
        color: var(--text-muted);
        margin-top: 8px;
    }

    /* Bunsen Burner Graphic Accent */
    .bunsen-burner-graphic {
        width: 100px;
        height: auto;
        margin-top: 10px;
        display: block;
    }

    /* ── SOLID ACTION CONTROLS (3D PRESSABLE) ── */
    .controls-panel {
        display: flex;
        gap: 12px;
        justify-content: center;
        align-items: center;
        margin-top: 10px;
        padding-bottom: 6px; /* Memberi ruang gerak translasi vertikal tombol */
    }

    .action-btn {
        border: none;
        border-radius: 8px;
        padding: 10px 20px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #fff;
        cursor: pointer;
        position: relative;
        
        /* State awal: efek timbul datar */
        transform: translateY(0);
        transition: transform 0.05s ease, box-shadow 0.05s ease, opacity 0.2s ease;
    }

    /* Warna Tombol & Bayangan 3D Tebal di Bawah */
    .btn-lime { 
        background-color: var(--accent-lime); 
        box-shadow: 0 5px 0 #8cbd00; 
    }
    .btn-purple { 
        background-color: var(--accent-purple); 
        box-shadow: 0 5px 0 #a256cc; 
    }
    .btn-cyan { 
        background-color: var(--accent-cyan); 
        box-shadow: 0 5px 0 #009999; 
    }
    .btn-orange { 
        background-color: var(--accent-orange); 
        box-shadow: 0 5px 0 #cc7a00; 
    }
    .btn-red { 
        background-color: var(--accent-red); 
        box-shadow: 0 5px 0 #cc2424; 
    }

    /* Efek Mendelep/Melosot Kedalam Saat Diklik Aktif */
    .action-btn:active {
        transform: translateY(4px); /* Tombol turun kebawah sejauh 4px */
        box-shadow: 0 1px 0 rgba(0, 0, 0, 0.2); /* Bayangan menipis seolah menempel lantai */
    }

    /* Aturan Khusus Saat Disabled */
    .action-btn:disabled {
        opacity: 0.3;
        cursor: not-allowed;
        transform: translateY(4px);
        box-shadow: none;
    }

    /* Output Logger Display */
    .logger-panel {
        width: 100%;
        max-width: 500px;
        background: rgba(255, 255, 255, 0.02);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        padding: 24px;
        text-align: center;
        margin-top: 16px;
    }

    .logger-panel .eq {
        font-size: 15px;
        font-weight: 500;
        color: #fff;
        margin-bottom: 8px;
    }

    .logger-panel .desc {
        font-size: 13px;
        color: var(--text-muted);
        line-height: 1.4;
        margin-bottom: 14px;
    }

    .logger-panel .badge-status {
        display: inline-block;
        background: rgba(0, 212, 212, 0.08);
        color: var(--accent-cyan);
        font-size: 11px;
        font-weight: 600;
        padding: 4px 12px;
        border-radius: 6px;
    }

    /* ── RIGHT COLUMN: INVENTORY GRID CARD ── */
    .inventory-card {
        background: var(--card-bg);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        padding: 24px;
    }

    .inventory-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;
        margin-top: 16px;
        max-height: 560px;
        overflow-y: auto;
        padding-right: 4px;
    }

    /* Custom Scrollbar for Inventory Container */
    .inventory-grid::-webkit-scrollbar { width: 4px; }
    .inventory-grid::-webkit-scrollbar-track { background: transparent; }
    .inventory-grid::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 4px; }

    .chem-node {
        background: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.04);
        border-radius: 12px;
        padding: 12px;
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;
        transition: border-color 0.2s, background 0.2s;
    }

    .chem-node:hover {
        background: rgba(255, 255, 255, 0.04);
    }

    .chem-node.selected {
        border-color: var(--accent-cyan);
        background: rgba(0, 212, 212, 0.02);
    }

    .chem-color-indicator {
        width: 36px;
        height: 36px;
        border-radius: 8px;
        flex-shrink: 0;
    }

    .chem-info-block {
        display: flex;
        flex-direction: column;
        min-width: 0;
    }

    .chem-info-block .formula {
        font-size: 13px;
        font-weight: 600;
        color: #fff;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .chem-info-block .volume {
        font-size: 11px;
        color: var(--text-muted);
        margin-top: 2px;
    }

    .toast {
        position: fixed;
        left: 50%;
        transform: translateX(-50%);
        bottom: 32px;
        background: #11161a;
        border: 1px solid var(--accent-cyan);
        color: #fff;
        padding: 10px 20px;
        border-radius: 8px;
        font-size: 13px;
        z-index: 9999;
        display: none;
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
    }
</style>

<div class="vl-wrap">
    <div class="vl-head">
        <div class="vl-title-group">
            <h1 class="vl-title">Alchemist virtual lab</h1>
            <h2 class="vl-subtitle">22 chemicals | <span>mix, Heat & calculate Molar mass!</span></h2>
        </div>
        <div class="vl-xp-badge">
            <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
            </svg>
            <span id="vl-xp">{{ (int) $userXp }}</span>
        </div>
    </div>

    <div class="vl-grid">
        
        <div class="workspace-area">
            
            <div class="beakers-row">
                <div class="beaker-box-wrap">
                    <span class="beaker-label-top">Beaker A</span>
                    <div class="beaker-frame active" id="beakerA" onclick="selectBeaker('A')">
                        <div class="beaker-liquid" id="liqA"></div>
                    </div>
                    <div class="beaker-meta-bottom">
                        <div class="amt" id="amtA">0 ml</div>
                        <div class="chem" id="chemA">EMPTY</div>
                    </div>
                </div>

                <div class="beaker-box-wrap">
                    <span class="beaker-label-top">Beaker B</span>
                    <div class="beaker-frame" id="beakerB" onclick="selectBeaker('B')">
                        <div class="beaker-liquid" id="liqB"></div>
                    </div>
                    <div class="beaker-meta-bottom">
                        <div class="amt" id="amtB">0 ml</div>
                        <div class="chem" id="chemB">EMPTY</div>
                    </div>
                </div>
            </div>

            <div class="tubes-row">
                <div class="tube-box-wrap">
                    <div class="tube-frame" id="tube0" onclick="selectTube(0)">
                        <div class="tube-liquid" id="tubeLiq0"></div>
                    </div>
                    <div class="tube-meta-bottom" id="tubeLabel0">Tube 1</div>
                </div>
                <div class="tube-box-wrap">
                    <div class="tube-frame" id="tube1" onclick="selectTube(1)">
                        <div class="tube-liquid" id="tubeLiq1"></div>
                    </div>
                    <div class="tube-meta-bottom" id="tubeLabel1">Tube 2</div>
                </div>
                <div class="tube-box-wrap">
                    <div class="tube-frame" id="tube2" onclick="selectTube(2)">
                        <div class="tube-liquid" id="tubeLiq2"></div>
                    </div>
                    <div class="tube-meta-bottom" id="tubeLabel2">Tube 3</div>
                </div>
            </div>

            <img src="{{ asset('images/bunser_burner.png') }}" alt="Bunsen Burner" class="bunsen-burner-graphic">

            <div class="controls-panel">
                <button class="action-btn btn-lime" id="btnReact" onclick="reactNow()">React</button>
                <button class="action-btn btn-purple" id="btnAdd" onclick="addToBeaker()">Add</button>
                <button class="action-btn btn-cyan" id="btnTransfer" onclick="transferToTube()">Transfer</button>
                <button class="action-btn btn-orange" id="btnBurn" onclick="burnTube()">Burn</button>
                <button class="action-btn btn-red" onclick="resetLab()">Reset</button>
            </div>

            <div class="logger-panel">
                <div class="eq" id="eq">HCl + NaOH = NaCl + H₂O</div>
                <div class="desc" id="desc">Netralisasi! Asam + Basa menghasilkan garam dan air</div>
                <span class="badge-status" id="rtype">Neutralization</span>
            </div>

        </div>

        <div class="inventory-card">
            <div class="inventory-grid" id="inv"></div>
        </div>

    </div>
</div>

<div class="toast" id="toast"></div>

<script>
    const CSRF = @json(csrf_token());
    let activeBeaker = 'A';
    let selectedChemical = null;
    
    let beakerA = { id: null, amount: 0, color: null };
    let beakerB = { id: null, amount: 0, color: null };
    let tubes = [
        { id: null, amount: 0, color: null },
        { id: null, amount: 0, color: null },
        { id: null, amount: 0, color: null },
    ];
    let selectedTubeIndex = null;

    const chemicals = {
        hcl:     { id:'hcl',    name:'HCl',      full:'Asam Klorida',          type:'Acid',  color:'#a34e36' },
        h2so4:   { id:'h2so4',  name:'H₂SO₄',    full:'Asam Sulfat',           type:'Acid',  color:'#d66f00' },
        hn03:    { id:'hn03',   name:'HNO3',     full:'Asam Nitrat',           type:'Acid',  color:'#ff9f1c' },
        ch3cooh: { id:'ch3cooh',name:'CH3COOH',  full:'Asam Asetat',           type:'Acid',  color:'#ffd166' },
        naoh:    { id:'naoh',   name:'NaOH',     full:'Natrium Hidroksida',    type:'Base',  color:'#06d6a0' },
        koh:     { id:'koh',    name:'KOH',      full:'Kalium Hidroksida',     type:'Base',  color:'#118ab2' },
        nh3:     { id:'nh3',    name:'NH₃',      full:'Amonia',                type:'Base',  color:'#a5d8ff' },
        nacl:    { id:'nacl',   name:'NaCl',     full:'Natrium Klorida',       type:'Salt',  color:'#b5b5b5' },
        kcl:     { id:'kcl',    name:'KCl',      full:'Kalium Klorida',        type:'Salt',  color:'#949494' },
        cacl2:   { id:'cacl2',  name:'CaCl2',    full:'Kalsium Klorida',       type:'Salt',  color:'#e0e0e0' },
        mgso4:   { id:'mgso4',  name:'MgSO4',    full:'Magnesium Sulfat',      type:'Salt',  color:'#ffffff' },
        na2co3:  { id:'na2co3', name:'Na₂CO₃',    full:'Natrium Karbonat',      type:'Salt',  color:'#f1f1f1' },
        zn:      { id:'zn',     name:'Zn',       full:'Seng',                  type:'Metal', color:'#7a8a99' },
        mg:      { id:'mg',     name:'Mg',       full:'Magnesium',             type:'Metal', color:'#cbd5e1' },
        al:      { id:'al',     name:'Al',       full:'Aluminium',             type:'Metal', color:'#e2e8f0' },
        fe:      { id:'fe',     name:'Fe',       full:'Besi',                  type:'Metal', color:'#475569' },
        caco3:   { id:'caco3',  name:'CaCO₃',    full:'Kalsium Karbonat',      type:'Carbonate', color:'#b4c6d4' },
        agno3:   { id:'agno3',  name:'AgNO₃',    full:'Perak Nitrat',          type:'Salt',  color:'#94a3b8' },
        pbno3:   { id:'pbno3',  name:'Pb(NO₃)₂',  full:'Timbal(II) Nitrat',     type:'Salt',  color:'#94a3b8' },
        ki:      { id:'ki',     name:'KI',       full:'Kalium Iodida',         type:'Salt',  color:'#f8f9fa' },
        cuso4:   { id:'cuso4',  name:'CuSO₄',    full:'Tembaga(II) Sulfat',    type:'Salt',  color:'#00e676' },
        fecl3:   { id:'fecl3',  name:'FeCl₃',    full:'Besi(III) Klorida',     type:'Salt',  color:'#ff5252' },
    };

    const reactions = {
        'hcl+naoh':   { eq:'HCl + NaOH → NaCl + H₂O', desc:'Netralisasi: Asam + Basa → Garam + Air.', type:'Neutralization', product:'nacl', color:'#b5b5b5' },
        'h2so4+naoh': { eq:'H₂SO₄ + 2NaOH → Na₂SO₄ + 2/H₂O', desc:'Netralisasi: Reaksi antara asam kuat dan basa kuat.', type:'Neutralization', product:'mgso4', color:'#ffffff' },
        'hcl+zn':     { eq:'2HCl + Zn → ZnCl₂ + H₂↑', desc:'Redoks (Logam + Asam): Menghasilkan gas hidrogen.', type:'Redox', product:'zn', color:'#7a8a99' },
        'hcl+mg':     { eq:'2HCl + Mg → MgCl₂ + H₂↑', desc:'Redoks (Logam + Asam): Reaksi hebat menghasilkan gas hidrogen.', type:'Redox', product:'mg', color:'#cbd5e1' },
        'caco3+hcl':  { eq:'2HCl + CaCO₃ → CaCl₂ + CO₂↑ + H₂O', desc:'Pembentukan Gas: Asam melarutkan batu kapur, menghasilkan CO₂.', type:'Gas Formation', product:'cacl2', color:'#e0e0e0' },
        'hcl+na2co3': { eq:'2HCl + Na₂CO₃ → 2NaCl + CO₂↑ + H₂O', desc:'Pembentukan Gas: Asam bereaksi dengan karbonat, menghasilkan CO₂.', type:'Gas Formation', product:'nacl', color:'#b5b5b5' },
        'agno3+nacl': { eq:'AgNO₃ + NaCl → AgCl↓ + NaNO₃', desc:'Pengendapan: Endapan putih Perak Klorida.', type:'Precipitation', product:'agno3', color:'#94a3b8' },
        'agno3+kcl':  { eq:'AgNO₃ + KCl → AgCl↓ + KNO₃', desc:'Pengendapan: Endapan putih Perak Klorida.', type:'Precipitation', product:'agno3', color:'#94a3b8' },
        'ki+pbno3':   { eq:'Pb(NO₃)₂ + 2KI → PbI₂↓ + 2KNO₃', desc:'Pengendapan: Endapan kuning cerah Timbal Iodida.', type:'Precipitation', product:'ki', color:'#f8f9fa' },
        'cuso4+naoh': { eq:'CuSO₄ + 2NaOH → Cu(OH)₂↓ + Na₂SO₄', desc:'Pengendapan: Endapan biru Tembaga(II) Hidroksida.', type:'Precipitation', product:'cuso4', color:'#00e676' },
        'fecl3+naoh': { eq:'FeCl₃ + 3NaOH → Fe(OH)₃↓ + 3NaCl', desc:'Pengendapan: Endapan coklat Besi(III) Hidroksida.', type:'Precipitation', product:'fecl3', color:'#ff5252' },
        'cuso4+zn':   { eq:'Zn + CuSO₄ → ZnSO₄ + Cu↓', desc:'Redoks (Pendesakan): Seng mengusir tembaga.', type:'Redox', product:'fe', color:'#475569' },
        'hcl+nh3':    { eq:'NH₃ + HCl → NH₄Cl', desc:'Reaksi Gas: Menghasilkan asap putih padatan Amonium Klorida.', type:'Gas Reaction', product:'nh3', color:'#a5d8ff' },
    };

    function toast(msg){
        const el = document.getElementById('toast');
        el.innerText = msg;
        el.style.display = 'block';
        clearTimeout(window.__t);
        window.__t = setTimeout(() => el.style.display = 'none', 1800);
    }

    function renderInventory(){
        const inv = document.getElementById('inv');
        inv.innerHTML = '';
        Object.values(chemicals).forEach(ch => {
            const node = document.createElement('div');
            node.className = 'chem-node' + (selectedChemical === ch.id ? ' selected' : '');
            node.onclick = () => { selectedChemical = ch.id; renderInventory(); toast(`Selected: ${ch.name}`); };
            
            node.innerHTML = `
                <div class="chem-color-indicator" style="background-color: ${ch.color}"></div>
                <div class="chem-info-block">
                    <div class="formula">${ch.name}</div>
                    <div class="volume">100 ml</div>
                </div>
            `;
            inv.appendChild(node);
        });
    }

    function setBeakerUI(which, data){
        const frame = document.getElementById(which === 'A' ? 'beakerA' : 'beakerB');
        const liq = document.getElementById(which === 'A' ? 'liqA' : 'liqB');
        const amt = document.getElementById(which === 'A' ? 'amtA' : 'amtB');
        const chem = document.getElementById(which === 'A' ? 'chemA' : 'chemB');

        const has = data && data.id && data.amount > 0;
        
        liq.style.height = has ? `${(data.amount / 100) * 100}%` : '0%';
        liq.style.background = has ? data.color : 'transparent';
        amt.innerText = `${data.amount || 0} ml`;
        chem.innerText = has ? chemicals[data.id].name : 'EMPTY';
    }

    function selectBeaker(which){
        activeBeaker = which;
        document.getElementById('beakerA').classList.toggle('active', which === 'A');
        document.getElementById('beakerB').classList.toggle('active', which === 'B');
        toast(`Active Container: Beaker ${which}`);
    }

    function addToBeaker(){
        if (!selectedChemical) return toast('Select a chemical node first!');
        const target = activeBeaker === 'A' ? beakerA : beakerB;
        if (target.id && target.id !== selectedChemical) {
            return toast('⚠️ Beaker full. Reset laboratory required.');
        }
        target.id = selectedChemical;
        target.amount = Math.min(100, (target.amount || 0) + 10);
        target.color = chemicals[selectedChemical].color;
        setBeakerUI(activeBeaker, target);
    }

    function transferToTube(){
        const source = activeBeaker === 'A' ? beakerA : beakerB;
        if (!source.id || source.amount <= 0) return toast('Selected beaker container is empty!');
        const emptyIdx = tubes.findIndex(t => !t.id);
        if (emptyIdx === -1) return toast('All tubes allocated! Burn to clear space.');

        tubes[emptyIdx] = { id: source.id, amount: source.amount, color: source.color };
        setTubeUI(emptyIdx);
        toast(`Transferred to Tube ${emptyIdx+1}`);

        source.id = null; source.amount = 0; source.color = null;
        setBeakerUI(activeBeaker, source);
    }

    function setTubeUI(idx){
        const t = tubes[idx];
        const el = document.getElementById(`tube${idx}`);
        const liq = document.getElementById(`tubeLiq${idx}`);
        const has = t && t.id && t.amount > 0;
        
        liq.style.height = has ? `${(t.amount / 100) * 100}%` : '0%';
        liq.style.background = has ? t.color : 'transparent';
    }

    function selectTube(idx){
        selectedTubeIndex = idx;
        [0,1,2].forEach(i => document.getElementById(`tube${i}`).classList.toggle('selected', i===idx));
        toast(`Selected Tube ${idx+1}`);
    }

    async function awardReactionXp(key){
        const res = await fetch("{{ route('virtual_lab.reaction') }}", {
            method: 'POST',
            headers: {'Content-Type':'application/json','X-CSRF-TOKEN':CSRF,'Accept':'application/json'},
            body: JSON.stringify({reaction_key: key})
        });
        if (!res.ok) return null;
        return await res.json();
    }

    async function reactNow(){
        if (!beakerA.id || !beakerB.id) return toast('Fill both Beaker A and Beaker B!');

        const key = [beakerA.id, beakerB.id].sort().join('+');
        const result = reactions[key];
        
        if (!result){
            document.getElementById('eq').innerText = 'No Reaction';
            document.getElementById('desc').innerText = 'This chemical compound pairing does not trigger standard processes.';
            document.getElementById('rtype').innerText = 'Failed';
            return toast('No active synthesis recorded.');
        }

        document.getElementById('eq').innerText = result.eq;
        document.getElementById('desc').innerText = result.desc;
        document.getElementById('rtype').innerText = result.type;
        
        const producedAmount = Math.min(beakerA.amount, beakerB.amount) || 10;
        const emptyIdx = tubes.findIndex(t => !t.id);
        
        if (emptyIdx !== -1){
            tubes[emptyIdx] = { id: result.product, amount: producedAmount, color: result.color };
            setTubeUI(emptyIdx);
        }

        beakerA = { id: null, amount: 0, color: null };
        beakerB = { id: null, amount: 0, color: null };
        setBeakerUI('A', beakerA);
        setBeakerUI('B', beakerB);
        selectBeaker('A');

        try{
            const data = await awardReactionXp(key);
            if (data && typeof data.total_xp !== 'undefined'){
                document.getElementById('vl-xp').innerText = data.total_xp;
                if (data.xp_added > 0) toast('⭐ +25 XP! New synthesis added!');
            }
        } catch(e) {}
    }

    function burnTube(){
        if (selectedTubeIndex === null) return toast('Select a tube to burn!');
        if (!tubes[selectedTubeIndex].id) return toast('Target tube is empty.');
        tubes[selectedTubeIndex] = { id: null, amount: 0, color: null };
        setTubeUI(selectedTubeIndex);
        toast('🔥 Volatiles vaporized (Tube cleared)');
    }

    function resetLab(){
        beakerA = { id: null, amount: 0, color: null };
        beakerB = { id: null, amount: 0, color: null };
        tubes = [
            { id: null, amount: 0, color: null },
            { id: null, amount: 0, color: null },
            { id: null, amount: 0, color: null },
        ];
        setBeakerUI('A', beakerA);
        setBeakerUI('B', beakerB);
        [0,1,2].forEach(setTubeUI);
        selectedTubeIndex = null;
        [0,1,2].forEach(i => document.getElementById(`tube${i}`).classList.remove('selected'));
        toast('Laboratory system reset complete.');
    }

    // INIT
    renderInventory();
    selectBeaker('A');
    setBeakerUI('A', beakerA);
    setBeakerUI('B', beakerB);
    [0,1,2].forEach(setTubeUI);
</script>
@endsection