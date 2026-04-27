import 'package:flutter/material.dart';

class VirtualLabScreen extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final Function(int index) onOptionSelected;
  final Function(bool isCorrectMix) onMixChanged;

  const VirtualLabScreen({
    super.key, 
    required this.questionData, 
    required this.onOptionSelected,
    required this.onMixChanged,
  });

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen> {
  String? _selectedA;
  String? _selectedB;
  bool _isMixed = false;
  int? _selectedOptionIndex;
  String _activeBeaker = 'A';

  bool _compareChemical(String? currentId, String? expectedFullString) {
    if (currentId == null || expectedFullString == null) return false;
    
    final current = currentId.toLowerCase();
    final expected = expectedFullString.toLowerCase();
    
    // Check for exact match
    if (current == expected) return true;
    
    // Check if the expected string contains the current ID as a distinct chemical symbol/name
    // (Handles "HCl (Asam Klorida)" matching "hcl")
    if (expected.contains(current)) {
      // Basic check: Ensure it's not just a partial match of a longer word
      // e.g., 'h' matching 'hcl'. We know our IDs are things like 'hcl', 'naoh', etc.
      return true; 
    }
    
    return false;
  }

  bool _isCorrectMix() {
    final config = widget.questionData['lab_practice_config'];
    if (config == null) return false;
    
    final expectedA = config['beaker_a_chemical']?.toString();
    final expectedB = config['beaker_b_chemical']?.toString();
    
    return (_compareChemical(_selectedA, expectedA) && _compareChemical(_selectedB, expectedB)) ||
           (_compareChemical(_selectedA, expectedB) && _compareChemical(_selectedB, expectedA));
  }

  final Map<String, dynamic> _chemicals = {
    'hcl': {'name': 'HCl', 'fullName': 'Asam Klorida', 'color': Color(0xFFFF6B6B)},
    'naoh': {'name': 'NaOH', 'fullName': 'Natrium Hidroksida', 'color': Color(0xFF4DABF7)},
    'agno3': {'name': 'AgNO₃', 'fullName': 'Perak Nitrat', 'color': Color(0xFFE9ECEF)},
    'nacl': {'name': 'NaCl', 'fullName': 'Natrium Klorida', 'color': Color(0xFFADB5BD)},
    'zn': {'name': 'Zn', 'fullName': 'Seng', 'color': Color(0xFFCED4DA)},
    'h2so4': {'name': 'H₂SO₄', 'fullName': 'Asam Sulfat', 'color': Color(0xFFFF922B)},
    'cuso4': {'name': 'CuSO₄', 'fullName': 'Tembaga Sulfat', 'color': Color(0xFF69DB7E)},
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(),
          const SizedBox(height: 24),
          _buildLabWorkbench(),
          const SizedBox(height: 24),
          _buildInventory(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          if (_isMixed) ...[
            _buildReactionResult(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PILIH JAWABAN YANG TEPAT:',
                  style: TextStyle(color: Color(0xFF00FBFF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOptionsList(),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFCCFF00).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('LAB TASK', style: TextStyle(color: Color(0xFFCCFF00), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.questionData['question_text'] ?? 'Lakukan eksperimen...',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildLabWorkbench() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('VIRTUAL LABORATORY', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBeaker('BEAKER A', _selectedA, _activeBeaker == 'A', () => setState(() => _activeBeaker = 'A')),
                const SizedBox(width: 12),
                const Icon(Icons.add, color: Color(0xFF00FBFF), size: 20),
                const SizedBox(width: 12),
                _buildBeaker('BEAKER B', _selectedB, _activeBeaker == 'B', () => setState(() => _activeBeaker = 'B')),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Color(0xFFCCFF00), size: 20),
                const SizedBox(width: 12),
                _buildBeaker('BEAKER C', _isMixed ? 'result' : null, false, () {}, isResult: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeaker(String label, String? chemId, bool isActive, VoidCallback onTap, {bool isResult = false}) {
    final chem = chemId != null 
        ? (chemId == 'result' ? {'color': const Color(0xFFCCFF00), 'name': 'HASIL'} : _chemicals[chemId]) 
        : null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: isResult ? 70 : 80,
            height: isResult ? 90 : 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              border: Border.all(color: isActive ? const Color(0xFF00FBFF) : (isResult ? const Color(0xFFCCFF00).withOpacity(0.3) : Colors.white10), width: 2),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Liquid
                if (chem != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: double.infinity,
                    height: isResult ? 65 : 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [chem['color'].withOpacity(0.8), chem['color'].withOpacity(0.4)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                      boxShadow: [BoxShadow(color: chem['color'].withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
                    ),
                    child: isResult ? const Center(child: Icon(Icons.bolt, color: Colors.white70, size: 20)) : null,
                  ),
                // Beaker Gloss
                Positioned(
                  left: 10, top: 10, bottom: 10,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            chem != null ? '${chem['name']} (${chem['fullName']})' : 'KOSONG',
            textAlign: TextAlign.center,
            style: TextStyle(color: chem != null ? const Color(0xFFCCFF00) : Colors.white24, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInventory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CHEMICAL REAGENTS', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _chemicals.entries.map((e) {
            bool isSelected = _selectedA == e.key || _selectedB == e.key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_activeBeaker == 'A') _selectedA = e.key;
                  else _selectedB = e.key;
                  _isMixed = false;
                  widget.onMixChanged(false);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? e.value['color'].withOpacity(0.2) : const Color(0xFF151D1F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? e.value['color'] : Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  e.value['name'],
                  style: TextStyle(color: isSelected ? e.value['color'] : Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (_selectedA != null && _selectedB != null) ? () {
              setState(() => _isMixed = true);
              widget.onMixChanged(_isCorrectMix());
            } : null,
            icon: const Icon(Icons.science),
            label: const Text('MIX & REACT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FBFF),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => setState(() { 
            _selectedA = null; 
            _selectedB = null; 
            _isMixed = false; 
            _selectedOptionIndex = null; 
            widget.onMixChanged(false);
          }),
          icon: const Icon(Icons.refresh, color: Colors.redAccent),
          style: IconButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionResult() {
    final result = _getReactionResult();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151D1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCCFF00).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: const Color(0xFFCCFF00).withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: const Color(0xFFCCFF00), size: 16),
              const SizedBox(width: 8),
              const Text('PERSAMAAN REAKSI (REACTION EQUATION)', style: TextStyle(color: Color(0xFFCCFF00), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          Text(result['equation']!, style: const TextStyle(color: Color(0xFF00FBFF), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HASIL VISUAL (VISUAL RESULT):', style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(result['visual']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getReactionResult() {
    final config = widget.questionData['lab_practice_config'];
    if (config == null) return {'visual': '...', 'equation': '...'};
    
    final expectedA = config['beaker_a_chemical']?.toString();
    final expectedB = config['beaker_b_chemical']?.toString();

    // If it matches the expected reagents of the question
    if ((_compareChemical(_selectedA, expectedA) && _compareChemical(_selectedB, expectedB)) ||
        (_compareChemical(_selectedA, expectedB) && _compareChemical(_selectedB, expectedA))) {
      return {
        'visual': config['expected_visual_result'] ?? 'Larutan bereaksi',
        'equation': config['expected_reaction_equation'] ?? 'Reaction occurs',
      };
    }

    // Default combinations from HTML example
    final mix = [_selectedA ?? '', _selectedB ?? '']..sort();
    final combo = mix.join('+');

    final db = {
      'hcl+naoh': {'visual': '💧 Larutan menjadi bening + sedikit hangat', 'equation': 'HCl + NaOH → NaCl + H₂O'},
      'agno3+nacl': {'visual': '☁️ Terbentuk ENDAPAN PUTIH (AgCl)', 'equation': 'AgNO₃ + NaCl → AgCl↓ + NaNO₃'},
      'hcl+zn': {'visual': '💨 Terbentuk GELEMBUNG GAS HIDROGEN (H₂)', 'equation': 'Zn + 2HCl → ZnCl₂ + H₂↑'},
      'cuso4+zn': {'visual': '🔴 Terbentuk ENDAPAN MERAH TEMBAGA (Cu)', 'equation': 'Zn + CuSO₄ → ZnSO₄ + Cu↓'},
      'h2so4+naoh': {'visual': '💧 Larutan menjadi bening + melepaskan panas', 'equation': 'H₂SO₄ + 2NaOH → Na₂SO₄ + 2H₂O'},
      'agno3+hcl': {'visual': '☁️ Terbentuk ENDAPAN PUTIH (AgCl)', 'equation': 'HCl + AgNO₃ → AgCl↓ + HNO₃'},
      'h2so4+zn': {'visual': '💨 Terbentuk GELEMBUNG GAS HIDROGEN (H₂)', 'equation': 'Zn + H₂SO₄ → ZnSO₄ + H₂↑'},
    };

    if (db.containsKey(combo)) return db[combo]!;

    return {
      'visual': 'Tidak terjadi reaksi yang signifikan',
      'equation': '${_selectedA?.toUpperCase()} + ${_selectedB?.toUpperCase()} → No Reaction',
    };
  }

  Widget _buildOptionsList() {
    final options = widget.questionData['multiple_choice_options'] as List? ?? [];
    return Column(
      children: List.generate(options.length, (index) {
        final opt = options[index];
        bool isSelected = _selectedOptionIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedOptionIndex = index);
            widget.onOptionSelected(index);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151D1F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? const Color(0xFFCCFF00) : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFCCFF00) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    opt['option_label'] ?? String.fromCharCode(65 + index),
                    style: TextStyle(color: isSelected ? Colors.black : const Color(0xFF00FBFF), fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    opt['option_text'] ?? '',
                    style: TextStyle(color: isSelected ? const Color(0xFFCCFF00) : Colors.white70, fontSize: 14),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFCCFF00), size: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}
