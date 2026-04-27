import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/background_wrapper.dart';

class EditQuestionScreen extends StatefulWidget {
  final int levelId;
  final int nextOrder;
  final Map<String, dynamic>? initialData;
  const EditQuestionScreen({super.key, required this.levelId, required this.nextOrder, this.initialData});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  int _activeTabIndex = 0; 
  final List<String> _tabs = ['PILIHAN GANDA', 'SUSUN KALIMAT', 'LAB PRACTICE'];
  final List<IconData> _tabIcons = [Icons.quiz_outlined, Icons.sort_outlined, Icons.science_outlined];
  
  bool _isSaving = false;

  Future<void> _saveQuestion() async {
    setState(() => _isSaving = true);
    
    final type = ['MULTIPLE_CHOICE', 'SENTENCE_ARRANGEMENT', 'LAB_PRACTICE'][_activeTabIndex];
    
    final data = {
      'level_id': widget.levelId,
      'type': type,
      'question_text': type == 'SENTENCE_ARRANGEMENT' ? _narrativeCtrl.text : _questionCtrl.text,
      'xp_reward': int.tryParse(_xpCtrl.text) ?? 500,
      'explanation': _discussionCtrl.text,
      'order_index': widget.initialData?['order_index'] ?? widget.nextOrder,
    };

    if (type == 'MULTIPLE_CHOICE' || type == 'LAB_PRACTICE') {
      data['options'] = [
        {'option_label': 'A', 'option_text': _optACtrl.text, 'is_correct': _correctAnswer.contains('Option A')},
        {'option_label': 'B', 'option_text': _optBCtrl.text, 'is_correct': _correctAnswer.contains('Option B')},
        {'option_label': 'C', 'option_text': _optCCtrl.text, 'is_correct': _correctAnswer.contains('Option C')},
        {'option_label': 'D', 'option_text': _optDCtrl.text, 'is_correct': _correctAnswer.contains('Option D')},
      ];
    } 
    
    if (type == 'SENTENCE_ARRANGEMENT') {
      data['words'] = _wordsCtrl.text;
      data['correct_order'] = _orderCtrl.text;
    } else if (type == 'LAB_PRACTICE') {
      data['beaker_a'] = _beakerA;
      data['beaker_b'] = _beakerB;
      data['visual_result'] = _visualResultCtrl.text;
      data['reaction_equation'] = _equationCtrl.text;
    }

    bool success;
    if (widget.initialData != null) {
      success = await ApiService().updateQuestion(widget.initialData!['id'], data);
    } else {
      success = await ApiService().createQuestion(data);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save question')));
      }
    }
  }
  
  // Chemicals list
  final List<String> _chemicals = ['HCl (Asam Klorida)', 'NaOH (Asam Klorida)', 'AgNO3', 'NaCl', 'Zn', 'H2SO4', 'CuSO4'];

  // Controllers
  final _questionCtrl = TextEditingController();
  final _xpCtrl = TextEditingController(text: "500");
  final _discussionCtrl = TextEditingController();
  
  // Pilihan Ganda
  final _optACtrl = TextEditingController();
  final _optBCtrl = TextEditingController();
  final _optCCtrl = TextEditingController();
  final _optDCtrl = TextEditingController();
  String _correctAnswer = "Option A";

  // Susun Kalimat
  final _narrativeCtrl = TextEditingController();
  final _wordsCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  final _verificationCtrl = TextEditingController();

  // Lab Practice
  String _beakerA = "HCl (Asam Klorida)";
  String _beakerB = "NaOH (Asam Klorida)";
  final _visualResultCtrl = TextEditingController();
  final _equationCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const darkBg = Color(0xFF050F10);

    return Scaffold(
      backgroundColor: darkBg,
      body: BackgroundWrapper(
        showGrid: false,
        removeSafeAreaPadding: true,
        child: Column(
          children: [
            _buildHeader(primaryCyan),
            _buildTabSelector(primaryCyan),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildActiveForm(primaryCyan),
              ),
            ),
            _buildFooterActions(primaryCyan),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close, color: Color(0xFF00FBFF)), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 8),
          Text('EDIT QUESTION', style: TextStyle(color: primaryCyan, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildTabSelector(Color primaryCyan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isActive = _activeTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? Border.all(color: Colors.white10) : null,
                ),
                child: Column(
                  children: [
                    Icon(_tabIcons[index], color: isActive ? primaryCyan : Colors.white24, size: 20),
                    const SizedBox(height: 4),
                    Text(_tabs[index], textAlign: TextAlign.center, style: TextStyle(color: isActive ? primaryCyan : Colors.white24, fontSize: 9, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveForm(Color primaryCyan) {
    if (_activeTabIndex == 0) return _buildPilihanGandaForm(primaryCyan);
    if (_activeTabIndex == 1) return _buildSusunKalimatForm(primaryCyan);
    return _buildLabPracticeForm(primaryCyan);
  }

  Widget _buildPilihanGandaForm(Color primaryCyan) {
    return Column(
      children: [
        _buildSection(title: 'QUESTION', icon: Icons.psychology_outlined, child: _buildLargeInput(_questionCtrl, 'Type your scientific inquiry here...')),
        const SizedBox(height: 24),
        _buildSection(title: 'MOLECULAR VARIANTS (CHOICES)', child: Column(
          children: [
            _buildChoiceRow('A', _optACtrl, primaryCyan),
            _buildChoiceRow('B', _optBCtrl, primaryCyan),
            _buildChoiceRow('C', _optCCtrl, primaryCyan),
            _buildChoiceRow('D', _optDCtrl, primaryCyan),
          ],
        )),
        const SizedBox(height: 24),
        _buildSection(title: 'SCIENTIFIC DISCUSSION (PEMBAHASAN)', titleColor: const Color(0xFFCCFF00), child: _buildLargeInput(_discussionCtrl, 'Explain the logic behind the reaction...')),
        const SizedBox(height: 24),
        _buildReactionParams(primaryCyan),
      ],
    );
  }

  Widget _buildSusunKalimatForm(Color primaryCyan) {
    return Column(
      children: [
        _buildSection(title: 'QUESTION NARRATIVE', icon: Icons.anchor, child: _buildLargeInput(_narrativeCtrl, 'Arrange the following elements...')),
        const SizedBox(height: 20),
        _buildSection(title: 'AVAILABLE WORDS (ELEMENTS)', icon: Icons.grid_view, titleColor: const Color(0xFFCCFF00), child: _buildLargeInput(_wordsCtrl, 'ikatan, atom, berbagi...')),
        const SizedBox(height: 20),
        _buildSection(title: 'CORRECT ORDER (INDEX)', icon: Icons.menu, child: _buildLargeInput(_orderCtrl, '4, 0, 5...')),
        const SizedBox(height: 20),
        _buildSection(title: 'CORRECT SENTENCE VERIFICATION', icon: Icons.spellcheck, child: _buildLargeInput(_verificationCtrl, 'Verification sentence...', textColor: primaryCyan)),
        const SizedBox(height: 20),
        _buildSection(title: 'SCIENTIFIC DISCUSSION (PEMBAHASAN)', titleColor: const Color(0xFFCCFF00), child: _buildLargeInput(_discussionCtrl, 'Explain the logic...')),
        const SizedBox(height: 24),
        _buildXPSection(primaryCyan),
      ],
    );
  }

  Widget _buildLabPracticeForm(Color primaryCyan) {
    return Column(
      children: [
        _buildSection(title: 'INITIAL INPUT / PERTANYAAN', child: _buildLargeInput(_questionCtrl, 'Contoh: Lakukan eksperimen...')),
        const SizedBox(height: 16),
        _buildDropdownSection('BAHAN BEAKER A', _beakerA, (v) => setState(() => _beakerA = v!)),
        const SizedBox(height: 16),
        _buildDropdownSection('BAHAN BEAKER B', _beakerB, (v) => setState(() => _beakerB = v!)),
        const SizedBox(height: 16),
        _buildSection(title: 'HASIL VISUAL (VISUAL RESULT)', child: _buildLargeInput(_visualResultCtrl, 'Misal: Cairan berubah menjadi merah muda')),
        const SizedBox(height: 16),
        _buildSection(title: 'PERSAMAAN REAKSI (REACTION EQUATION)', titleColor: const Color(0xFFCCFF00), child: _buildLargeInput(_equationCtrl, 'HCl + NaOH -> NaCl + H2O')),
        const SizedBox(height: 24),
        _buildSection(title: 'OPSI JAWABAN', child: Column(
          children: [
            _buildChoiceRow('A', _optACtrl, primaryCyan),
            _buildChoiceRow('B', _optBCtrl, primaryCyan),
            _buildChoiceRow('C', _optCCtrl, primaryCyan),
            _buildChoiceRow('D', _optDCtrl, primaryCyan),
          ],
        )),
        const SizedBox(height: 24),
        _buildSection(title: 'JAWABAN BENAR', icon: Icons.check_circle_outline, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _correctAnswer, isExpanded: true, dropdownColor: const Color(0xFF151D1F), style: const TextStyle(color: Colors.white70),
              items: ['Option A', 'Option B', 'Option C', 'Option D'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _correctAnswer = v!),
            ),
          ),
        )),
        const SizedBox(height: 24),
        _buildXPSection(primaryCyan),
        const SizedBox(height: 24),
        _buildSection(title: 'PEMBAHASAN (DISCUSSION)', titleColor: const Color(0xFFCCFF00), child: _buildLargeInput(_discussionCtrl, 'Berikan penjelasan detail tentang reaksi ini...')),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child, IconData? icon, Color titleColor = const Color(0xFF00FBFF)}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF151D1F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: titleColor, size: 14), const SizedBox(width: 8)],
              Text(title, style: TextStyle(color: titleColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLargeInput(TextEditingController ctrl, String hint, {Color? textColor, int maxLines = 3}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: textColor ?? Colors.white70, fontSize: 14),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white10), border: InputBorder.none),
      ),
    );
  }

  Widget _buildChoiceRow(String label, TextEditingController ctrl, Color primaryCyan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F0), borderRadius: BorderRadius.circular(8)),
              child: TextField(controller: ctrl, style: const TextStyle(color: Colors.black87), decoration: const InputDecoration(border: InputBorder.none)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection(String title, String value, void Function(String?) onChanged) {
    return _buildSection(title: title, icon: Icons.science_outlined, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: const Color(0xFF151D1F), style: const TextStyle(color: Colors.white70),
          items: _chemicals.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged,
        ),
      ),
    ));
  }

  Widget _buildReactionParams(Color primaryCyan) {
    return _buildSection(title: 'Reaction Parameters', icon: Icons.tune, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('JAWABAN YANG BENAR', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _correctAnswer, isExpanded: true, dropdownColor: const Color(0xFF151D1F), style: const TextStyle(color: Colors.white70),
              items: ['Option A', 'Option B', 'Option C', 'Option D'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _correctAnswer = v!),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('XP REWARD POTENTIAL', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildXPInput(primaryCyan),
      ],
    ));
  }

  Widget _buildXPSection(Color primaryCyan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [Icon(Icons.bolt, color: Color(0xFFCCFF00), size: 14), SizedBox(width: 8), Text('XP REWARD', style: TextStyle(color: Color(0xFFCCFF00), fontSize: 10, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 12),
        _buildXPInput(primaryCyan),
      ],
    );
  }

  Widget _buildXPInput(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Color(0xFFCCFF00)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _xpCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18), decoration: const InputDecoration(border: InputBorder.none))),
          const Text('XP', style: TextStyle(color: Color(0xFFCCFF00), fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final q = widget.initialData!;
      _questionCtrl.text = q['question_text'] ?? '';
      _xpCtrl.text = (q['xp_reward'] ?? 500).toString();
      _discussionCtrl.text = q['explanation'] ?? '';
      
      _activeTabIndex = ['MULTIPLE_CHOICE', 'SENTENCE_ARRANGEMENT', 'LAB_PRACTICE'].indexOf(q['type'] ?? 'MULTIPLE_CHOICE');

      if (q['type'] == 'MULTIPLE_CHOICE' && q['multiple_choice_options'] != null) {
        final opts = q['multiple_choice_options'] as List;
        for (var opt in opts) {
          if (opt['option_label'] == 'A') _optACtrl.text = opt['option_text'] ?? '';
          if (opt['option_label'] == 'B') _optBCtrl.text = opt['option_text'] ?? '';
          if (opt['option_label'] == 'C') _optCCtrl.text = opt['option_text'] ?? '';
          if (opt['option_label'] == 'D') _optDCtrl.text = opt['option_text'] ?? '';
          if (opt['is_correct'] == true || opt['is_correct'] == 1) {
            _correctAnswer = 'Option ${opt['option_label']}';
          }
        }
      } else if (q['type'] == 'SENTENCE_ARRANGEMENT') {
        _narrativeCtrl.text = q['question_text'] ?? '';
        if (q['sentence_arrangement_words'] != null) {
          final words = (q['sentence_arrangement_words'] as List).map((e) => e['word_text']).join(', ');
          _wordsCtrl.text = words;
          
          final order = (q['sentence_arrangement_words'] as List)
            .map((e) => e['correct_order_index'].toString())
            .join(', ');
          _orderCtrl.text = order;
        }
      } else if (q['type'] == 'LAB_PRACTICE' && q['lab_practice_config'] != null) {
        final config = q['lab_practice_config'];
        _beakerA = config['beaker_a_chemical'] ?? _chemicals[0];
        _beakerB = config['beaker_b_chemical'] ?? _chemicals[1];
        _visualResultCtrl.text = config['expected_visual_result'] ?? '';
        _equationCtrl.text = config['expected_reaction_equation'] ?? '';
        
        if (q['multiple_choice_options'] != null) {
          final opts = q['multiple_choice_options'] as List;
          for (var opt in opts) {
            if (opt['option_label'] == 'A') _optACtrl.text = opt['option_text'] ?? '';
            if (opt['option_label'] == 'B') _optBCtrl.text = opt['option_text'] ?? '';
            if (opt['option_label'] == 'C') _optCCtrl.text = opt['option_text'] ?? '';
            if (opt['option_label'] == 'D') _optDCtrl.text = opt['option_text'] ?? '';
            if (opt['is_correct'] == true || opt['is_correct'] == 1) {
              _correctAnswer = 'Option ${opt['option_label']}';
            }
          }
        }
      }
    }
  }

  Widget _buildFooterActions(Color primaryCyan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      child: Row(
        children: [
          Expanded(child: SizedBox(height: 56, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A3436), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
          const SizedBox(width: 16),
          Expanded(
            flex: 2, 
            child: Container(
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))]), 
              child: SizedBox(
                height: 56, 
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuestion, 
                  style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('SIMPAN SOAL ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)), Icon(Icons.save_outlined, color: Colors.black, size: 20)])
                )
              )
            )
          ),
        ],
      ),
    );
  }
}
