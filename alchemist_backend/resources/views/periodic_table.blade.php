@extends('layouts.app')

@section('title', 'Periodic Table')

@push('styles')
<style>
    /* Background gelap modern */
    html, body {
        overflow-y: auto !important;
        overflow-x: hidden;
        height: auto !important;
        min-height: 100%;
        background: #0d1117 !important;
    }

    .periodic-container {
        width: calc(100% - 260px); 
        margin-left: 260px;        
        max-width: 100%;
        overflow: visible !important; 
        display: flex;
        flex-direction: column;
        padding: 20px 30px 60px 10px;  
        box-sizing: border-box;
        position: relative;
    }

    .periodic-header {
        display: flex;
        align-items: center;
        gap: 20px;
        margin-bottom: 30px;
    }

    .periodic-logo {
        
    }

    .periodic-logo img {
        
    }

    .periodic-title {
        font-size: 32px;
        font-weight: 600;
        color: #ffffff;
        letter-spacing: 0.01em;
    }

    .periodic-legend {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-bottom: 30px;
        padding: 16px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 8px;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 11px;
        color: rgba(255, 255, 255, 0.7);
        padding: 4px 8px;
        background: rgba(255, 255, 255, 0.02);
        border-radius: 4px;
    }

    .legend-color {
        width: 24px;
        height: 24px;
        border-radius: 4px;
        flex-shrink: 0;
    }

    .table-wrapper {
        overflow-x: auto !important;   
        overflow-y: visible !important; 
        display: block;
        width: 100%;
        clear: both;
        padding: 20px 0;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: thin;
        scrollbar-color: rgba(0, 212, 212, 0.6) rgba(255, 255, 255, 0.05);
    }

    .table-wrapper::-webkit-scrollbar {
        height: 8px;
    }

    .table-wrapper::-webkit-scrollbar-track {
        background: rgba(255, 255, 255, 0.05);
        border-radius: 10px;
    }

    .table-wrapper::-webkit-scrollbar-thumb {
        background: rgba(0, 212, 212, 0.6);
        border-radius: 10px;
    }

    /* Grid dengan periode dan grup labels */
    .periodic-table-container {
        display: flex;
        gap: 8px;
    }

    .period-labels {
        display: flex;
        flex-direction: column;
        gap: 4px;
        padding-top: 40px;
    }

    .period-label {
        height: 55px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 11px;
        color: rgba(255, 255, 255, 0.5);
        font-weight: 600;
        width: 30px;
    }

    .table-with-groups {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .group-labels {
        display: grid;
        grid-template-columns: repeat(18, 55px);
        gap: 4px;
        margin-bottom: 4px;
    }

    .group-label {
        text-align: center;
        font-size: 11px;
        color: rgba(255, 255, 255, 0.5);
        font-weight: 600;
    }

    .periodic-table {
        display: grid;
        grid-template-columns: repeat(18, 55px);
        gap: 4px; 
        width: max-content; 
        margin: 0; 
    }

    .element {
        width: 55px;
        height: 55px;
        border-radius: 6px;
        display: flex;
        flex-direction: column;
        cursor: pointer; 
        border: 1px solid rgba(255, 255, 255, 0.1);
        padding: 4px; 
        box-sizing: border-box;
        user-select: none;
        transition: all 0.2s ease;
    }

    .element:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        border-color: rgba(255, 255, 255, 0.3); 
    }

    .element-content {
        display: flex;
        flex-direction: column;
        width: 100%;
        height: 100%;
        justify-content: space-between;
    }

    .element-header {
        display: flex;
        justify-content: space-between;
        width: 100%;
    }

    .element-number {
        font-size: 8px;
        font-weight: 600;
        opacity: 0.8;
    }

    .element-mass {
        font-size: 6px;
        opacity: 0.7;
    }

    .element-symbol {
        font-size: 18px; 
        font-weight: 700;
        text-align: center;
        line-height: 1;
        margin: 2px 0;
    }

    .element-name {
        font-size: 7px; 
        text-align: center;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        opacity: 0.9;
    }

    /* Warna Kategori Elemen - Sesuai Desain */
    .alkali-metal { background: #3d5a80; color: #fff; }
    .alkaline-earth { background: #2b4c7e; color: #fff; }
    .transition-metal { background: #1a7f8e; color: #fff; }
    .lanthanide { background: #0d9488; color: #fff; }
    .actinide { background: #10b981; color: #000; }
    .metalloid { background: #84a98c; color: #000; }
    .nonmetal { background: #8b6f47; color: #fff; }
    .halogen { background: #d4a574; color: #000; }
    .noble-gas { background: #e879f9; color: #000; }
    .unknown { background: #6b7280; color: #fff; }

    .empty {
        background: transparent;
        border: none;
        pointer-events: none;
    }

    .periodic-table .space-row {
        grid-column: span 18;
        height: 8px;
    }

    /* Floating Add Button */
    .floating-add-btn {
        position: fixed;
        bottom: 40px;
        right: 40px;
        width: 56px;
        height: 56px;
        background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 4px 20px rgba(6, 182, 212, 0.4);
        transition: all 0.3s ease;
        z-index: 1000;
        border: none;
    }

    .floating-add-btn:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 30px rgba(6, 182, 212, 0.6);
    }

    .floating-add-btn::before {
        content: '+';
        font-size: 32px;
        font-weight: 300;
        color: #ffffff;
        line-height: 1;
    }

    @media (max-width: 768px) {
        .periodic-container {
            width: 100%;
            margin-left: 0;
            padding-left: 15px;
            padding-right: 15px;
        }
        
        .floating-add-btn {
            bottom: 20px;
            right: 20px;
        }
    }
</style>
@endpush

<div class="periodic-container">
    <div class="table-wrapper">">
        <div class="periodic-logo">
            
        </div>
        <div>
            <h1 class="periodic-title">Periodic Table</h1>
        </div>
    </div>

    <div class="periodic-legend">
        <div class="legend-item"><div class="legend-color alkali-metal"></div><span>Alkali Metal</span></div>
        <div class="legend-item"><div class="legend-color alkaline-earth"></div><span>Alkaline Earth</span></div>
        <div class="legend-item"><div class="legend-color transition-metal"></div><span>Transition Metal</span></div>
        <div class="legend-item"><div class="legend-color metalloid"></div><span>Metalloid</span></div>
        <div class="legend-item"><div class="legend-color nonmetal"></div><span>Nonmetal</span></div>
        <div class="legend-item"><div class="legend-color halogen"></div><span>Halogen</span></div>
        <div class="legend-item"><div class="legend-color noble-gas"></div><span>Noble Gas</span></div>
        <div class="legend-item"><div class="legend-color lanthanide"></div><span>Lanthanide</span></div>
        <div class="legend-item"><div class="legend-color actinide"></div><span>Actinide</span></div>
    </div>

    <div class="table-wrapper">
        <div class="periodic-table-container">
            <div class="period-labels">
                <div class="period-label">1</div>
                <div class="period-label">2</div>
                <div class="period-label">3</div>
                <div class="period-label">4</div>
                <div class="period-label">5</div>
                <div class="period-label">6</div>
                <div class="period-label">7</div>
            </div>
            <div class="table-with-groups">
                <div class="group-labels">
                    <div class="group-label">1</div>
                    <div class="group-label">2</div>
                    <div class="group-label">3</div>
                    <div class="group-label">4</div>
                    <div class="group-label">5</div>
                    <div class="group-label">6</div>
                    <div class="group-label">7</div>
                    <div class="group-label">8</div>
                    <div class="group-label">9</div>
                    <div class="group-label">10</div>
                    <div class="group-label">11</div>
                    <div class="group-label">12</div>
                    <div class="group-label">13</div>
                    <div class="group-label">14</div>
                    <div class="group-label">15</div>
                    <div class="group-label">16</div>
                    <div class="group-label">17</div>
                    <div class="group-label">18</div>
                </div>
                <div class="periodic-table" id="periodicTable"></div>
            </div>
        </div>
    </div>

    <!-- Floating Add Button -->
    <button class="floating-add-btn" onclick="alert('Add new element functionality')"></button>
</div>

@push('scripts')
<script>
document.addEventListener("DOMContentLoaded", function() {
    const elements = [
        // Baris 1
        { number: 1, symbol: "H", name: "Hydrogen", mass: "1.008", category: "nonmetal" },
        { category: "empty", span: 16 },
        { number: 2, symbol: "He", name: "Helium", mass: "4.0026", category: "noble-gas" },

        // Baris 2
        { number: 3, symbol: "Li", name: "Lithium", mass: "6.94", category: "alkali-metal" },
        { number: 4, symbol: "Be", name: "Beryllium", mass: "9.0122", category: "alkaline-earth" },
        { category: "empty", span: 10 },
        { number: 5, symbol: "B", name: "Boron", mass: "10.81", category: "metalloid" },
        { number: 6, symbol: "C", name: "Carbon", mass: "12.011", category: "nonmetal" },
        { number: 7, symbol: "N", name: "Nitrogen", mass: "14.007", category: "nonmetal" },
        { number: 8, symbol: "O", name: "Oxygen", mass: "15.999", category: "nonmetal" },
        { number: 9, symbol: "F", name: "Fluorine", mass: "18.998", category: "halogen" },
        { number: 10, symbol: "Ne", name: "Neon", mass: "20.180", category: "noble-gas" },

        // Baris 3
        { number: 11, symbol: "Na", name: "Sodium", mass: "22.990", category: "alkali-metal" },
        { number: 12, symbol: "Mg", name: "Magnesium", mass: "24.305", category: "alkaline-earth" },
        { category: "empty", span: 10 },
        { number: 13, symbol: "Al", name: "Aluminium", mass: "26.982", category: "transition-metal" },
        { number: 14, symbol: "Si", name: "Silicon", mass: "28.085", category: "metalloid" },
        { number: 15, symbol: "P", name: "Phosphorus", mass: "30.974", category: "nonmetal" },
        { number: 16, symbol: "S", name: "Sulfur", mass: "32.06", category: "nonmetal" },
        { number: 17, symbol: "Cl", name: "Chlorine", mass: "35.45", category: "halogen" },
        { number: 18, symbol: "Ar", name: "Argon", mass: "39.948", category: "noble-gas" },

        // Baris 4
        { number: 19, symbol: "K", name: "Potassium", mass: "39.098", category: "alkali-metal" },
        { number: 20, symbol: "Ca", name: "Calcium", mass: "40.078", category: "alkaline-earth" },
        { number: 21, symbol: "Sc", name: "Scandium", mass: "44.956", category: "transition-metal" },
        { number: 22, symbol: "Ti", name: "Titanium", mass: "47.867", category: "transition-metal" },
        { number: 23, symbol: "V", name: "Vanadium", mass: "50.942", category: "transition-metal" },
        { number: 24, symbol: "Cr", name: "Chromium", mass: "51.996", category: "transition-metal" },
        { number: 25, symbol: "Mn", name: "Manganese", mass: "54.938", category: "transition-metal" },
        { number: 26, symbol: "Fe", name: "Iron", mass: "55.845", category: "transition-metal" },
        { number: 27, symbol: "Co", name: "Cobalt", mass: "58.933", category: "transition-metal" },
        { number: 28, symbol: "Ni", name: "Nickel", mass: "58.693", category: "transition-metal" },
        { number: 29, symbol: "Cu", name: "Copper", mass: "63.546", category: "transition-metal" },
        { number: 30, symbol: "Zn", name: "Zinc", mass: "65.38", category: "transition-metal" },
        { number: 31, symbol: "Ga", name: "Gallium", mass: "69.723", category: "transition-metal" },
        { number: 32, symbol: "Ge", name: "Germanium", mass: "72.630", category: "metalloid" },
        { number: 33, symbol: "As", name: "Arsenic", mass: "74.922", category: "metalloid" },
        { number: 34, symbol: "Se", name: "Selenium", mass: "78.971", category: "nonmetal" },
        { number: 35, symbol: "Br", name: "Bromine", mass: "79.904", category: "halogen" },
        { number: 36, symbol: "Kr", name: "Krypton", mass: "83.798", category: "noble-gas" },

        // Baris 5
        { number: 37, symbol: "Rb", name: "Rubidium", mass: "85.468", category: "alkali-metal" },
        { number: 38, symbol: "Sr", name: "Strontium", mass: "87.62", category: "alkaline-earth" },
        { number: 39, symbol: "Y", name: "Yttrium", mass: "88.906", category: "transition-metal" },
        { number: 40, symbol: "Zr", name: "Zirconium", mass: "91.224", category: "transition-metal" },
        { number: 41, symbol: "Nb", name: "Niobium", mass: "92.906", category: "transition-metal" },
        { number: 42, symbol: "Mo", name: "Molybdenum", mass: "95.95", category: "transition-metal" },
        { number: 43, symbol: "Tc", name: "Technetium", mass: "(98)", category: "transition-metal" },
        { number: 44, symbol: "Ru", name: "Ruthenium", mass: "101.07", category: "transition-metal" },
        { number: 45, symbol: "Rh", name: "Rhodium", mass: "102.91", category: "transition-metal" },
        { number: 46, symbol: "Pd", name: "Palladium", mass: "106.42", category: "transition-metal" },
        { number: 47, symbol: "Ag", name: "Silver", mass: "107.87", category: "transition-metal" },
        { number: 48, symbol: "Cd", name: "Cadmium", mass: "112.41", category: "transition-metal" },
        { number: 49, symbol: "In", name: "Indium", mass: "114.82", category: "transition-metal" },
        { number: 50, symbol: "Sn", name: "Tin", mass: "118.71", category: "transition-metal" },
        { number: 51, symbol: "Sb", name: "Antimony", mass: "121.76", category: "metalloid" },
        { number: 52, symbol: "Te", name: "Tellurium", mass: "127.60", category: "metalloid" },
        { number: 53, symbol: "I", name: "Iodine", mass: "126.90", category: "halogen" },
        { number: 54, symbol: "Xe", name: "Xenon", mass: "131.29", category: "noble-gas" },

        // Baris 6 (SUDAH DIHAPUS: Kotak placeholder abu-abu diganti otomatis ke elemen asli nomor berikutnya)
        { number: 55, symbol: "Cs", name: "Cesium", mass: "132.91", category: "alkali-metal" },
        { number: 56, symbol: "Ba", name: "Barium", mass: "137.33", category: "alkaline-earth" },
        { number: 72, symbol: "Hf", name: "Hafnium", mass: "178.49", category: "transition-metal" },
        { number: 73, symbol: "Ta", name: "Tantalum", mass: "180.95", category: "transition-metal" },
        { number: 74, symbol: "W", name: "Tungsten", mass: "183.84", category: "transition-metal" },
        { number: 75, symbol: "Re", name: "Rhenium", mass: "186.21", category: "transition-metal" },
        { number: 76, symbol: "Os", name: "Osmium", mass: "190.23", category: "transition-metal" },
        { number: 77, symbol: "Ir", name: "Iridium", mass: "192.22", category: "transition-metal" },
        { number: 78, symbol: "Pt", name: "Platinum", mass: "195.08", category: "transition-metal" },
        { number: 79, symbol: "Au", name: "Gold", mass: "196.97", category: "transition-metal" },
        { number: 80, symbol: "Hg", name: "Mercury", mass: "200.59", category: "transition-metal" },
        { number: 81, symbol: "Tl", name: "Thallium", mass: "204.38", category: "transition-metal" },
        { number: 82, symbol: "Pb", name: "Lead", mass: "207.2", category: "transition-metal" },
        { number: 83, symbol: "Bi", name: "Bismuth", mass: "208.98", category: "transition-metal" },
        { number: 84, symbol: "Po", name: "Polonium", mass: "(209)", category: "metalloid" },
        { number: 85, symbol: "At", name: "Astatine", mass: "(210)", category: "halogen" },
        { number: 86, symbol: "Rn", name: "Radon", mass: "(222)", category: "noble-gas" },

        // Baris 7 (SUDAH DIHAPUS: Placeholder Actinides abu-abu dihilangkan)
        { number: 87, symbol: "Fr", name: "Francium", mass: "(223)", category: "alkali-metal" },
        { number: 88, symbol: "Ra", name: "Radium", mass: "(226)", category: "alkaline-earth" },
        { number: 104, symbol: "Rf", name: "Rutherfordium", mass: "(267)", category: "transition-metal" },
        { number: 105, symbol: "Db", name: "Dubnium", mass: "(268)", category: "transition-metal" },
        { number: 106, symbol: "Sg", name: "Seaborgium", mass: "(269)", category: "transition-metal" },
        { number: 107, symbol: "Bh", name: "Bohrium", mass: "(270)", category: "transition-metal" },
        { number: 108, symbol: "Hs", name: "Hassium", mass: "(269)", category: "transition-metal" },
        { number: 109, symbol: "Mt", name: "Meitnerium", mass: "(278)", category: "unknown" },
        { number: 110, symbol: "Ds", name: "Darmstadtium", mass: "(281)", category: "unknown" },
        { number: 111, symbol: "Rg", name: "Roentgenium", mass: "(282)", category: "unknown" },
        { number: 112, symbol: "Cn", name: "Copernicium", mass: "(285)", category: "transition-metal" },
        { number: 113, symbol: "Nh", name: "Nihonium", mass: "(286)", category: "unknown" },
        { number: 114, symbol: "Fl", name: "Flerovium", mass: "(289)", category: "unknown" },
        { number: 115, symbol: "Mc", name: "Moscovium", mass: "(290)", category: "unknown" },
        { number: 116, symbol: "Lv", name: "Livermorium", mass: "(293)", category: "unknown" },
        { number: 117, symbol: "Ts", name: "Tennessine", mass: "(294)", category: "unknown" },
        { number: 118, symbol: "Og", name: "Oganesson", mass: "(294)", category: "unknown" },

        // Spasi Pemisah Tipis ke Lanthanide Bawah
        { category: "space" },

        // Baris Lanthanides (Bawah) - Penyesuaian span kosong di awal baris agar presisi
        { category: "empty", span: 2 },
        { number: 57, symbol: "La", name: "Lanthanum", mass: "138.91", category: "lanthanide" },
        { number: 58, symbol: "Ce", name: "Cerium", mass: "140.12", category: "lanthanide" },
        { number: 59, symbol: "Pr", name: "Praseodymium", mass: "140.91", category: "lanthanide" },
        { number: 60, symbol: "Nd", name: "Neodymium", mass: "144.24", category: "lanthanide" },
        { number: 61, symbol: "Pm", name: "Promethium", mass: "(145)", category: "lanthanide" },
        { number: 62, symbol: "Sm", name: "Samarium", mass: "150.36", category: "lanthanide" },
        { number: 63, symbol: "Eu", name: "Europium", mass: "151.96", category: "lanthanide" },
        { number: 64, symbol: "Gd", name: "Gadolinium", mass: "157.25", category: "lanthanide" },
        { number: 65, symbol: "Tb", name: "Terbium", mass: "158.93", category: "lanthanide" },
        { number: 66, symbol: "Dy", name: "Dysprosium", mass: "162.50", category: "lanthanide" },
        { number: 67, symbol: "Ho", name: "Holmium", mass: "164.93", category: "lanthanide" },
        { number: 68, symbol: "Er", name: "Erbium", mass: "167.26", category: "lanthanide" },
        { number: 69, symbol: "Tm", name: "Thulium", mass: "168.93", category: "lanthanide" },
        { number: 70, symbol: "Yb", name: "Ytterbium", mass: "173.05", category: "lanthanide" },
        { number: 71, symbol: "Lu", name: "Lutetium", mass: "174.97", category: "lanthanide" },

        // Baris Actinides (Bawah)
        { category: "empty", span: 2 },
        { number: 89, symbol: "Ac", name: "Actinium", mass: "(227)", category: "actinide" },
        { number: 90, symbol: "Th", name: "Thorium", mass: "232.04", category: "actinide" },
        { number: 91, symbol: "Pa", name: "Protactinium", mass: "231.04", category: "actinide" },
        { number: 92, symbol: "U", name: "Uranium", mass: "238.03", category: "actinide" },
        { number: 93, symbol: "Np", name: "Neptunium", mass: "(237)", category: "actinide" },
        { number: 94, symbol: "Pu", name: "Plutonium", mass: "(244)", category: "actinide" },
        { number: 95, symbol: "Am", name: "Americium", mass: "(243)", category: "actinide" },
        { number: 96, symbol: "Cm", name: "Curium", mass: "(247)", category: "actinide" },
        { number: 97, symbol: "Bk", name: "Berkelium", mass: "(247)", category: "actinide" },
        { number: 98, symbol: "Cf", name: "Californium", mass: "(251)", category: "actinide" },
        { number: 99, symbol: "Es", name: "Einsteinium", mass: "(252)", category: "actinide" },
        { number: 100, symbol: "Fm", name: "Fermium", mass: "(257)", category: "actinide" },
        { number: 101, symbol: "Md", name: "Mendelevium", mass: "(258)", category: "actinide" },
        { number: 102, symbol: "No", name: "Nobelium", mass: "(259)", category: "actinide" },
        { number: 103, symbol: "Lr", name: "Lawrencium", mass: "(262)", category: "actinide" },
    ];

    const container = document.getElementById("periodicTable");

    elements.forEach(el => {
        if (el.category === "empty") {
            for (let i = 0; i < (el.span || 1); i++) {
                const emptyDiv = document.createElement("div");
                emptyDiv.className = "empty";
                container.appendChild(emptyDiv);
            }
        } else if (el.category === "space") {
            const spaceDiv = document.createElement("div");
            spaceDiv.className = "space-row";
            container.appendChild(spaceDiv);
        } else {
            const elementDiv = document.createElement("div");
            elementDiv.className = `element ${el.category}`;
            
            elementDiv.innerHTML = `
                <div class="element-content">
                    <div class="element-header">
                        <span class="element-number">${el.number || ''}</span>
                        <span class="element-mass">${el.mass}</span>
                    </div>
                    <div class="element-symbol">${el.symbol}</div>
                    <div class="element-name">${el.name}</div>
                </div>
            `;
            container.appendChild(elementDiv);
        }
    });
});
</script>
@endpush