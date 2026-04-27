import 'package:flutter/material.dart';
import '../models/daily_task_model.dart';
import '../services/api_service.dart';

/// Bottom sheet form for creating / editing a Daily Task (admin only).
class DailyTaskFormSheet extends StatefulWidget {
  final DailyTaskModel? task; // null = create mode

  const DailyTaskFormSheet({super.key, this.task});

  @override
  State<DailyTaskFormSheet> createState() => _DailyTaskFormSheetState();
}

class _DailyTaskFormSheetState extends State<DailyTaskFormSheet> {
  static const _cyan = Color(0xFF00FBFF);
  static const _dark = Color(0xFF0D1114);
  static const _card = Color(0xFF161C1F);
  static const _border = Color(0xFF252D30);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _xpCtrl = TextEditingController();

  String _selectedType = 'FINISH_LESSONS';
  bool _isActive = true;
  bool _loading = false;

  final List<Map<String, String>> _taskTypes = [
    {'value': 'FINISH_LESSONS', 'label': 'Complete Quiz (menyelesaikan tugas)'},
    {'value': 'GAIN_XP', 'label': 'Gain XP'},
    {'value': 'READ_ARTICLE', 'label': 'Read Article'},
    {'value': 'LAB_EXPERIMENT', 'label': 'Lab Experiment'},
    {'value': 'DAILY_LOGIN', 'label': 'Daily Login'},
  ];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _nameCtrl.text = t.taskName;
      _descCtrl.text = t.description ?? '';
      _targetCtrl.text = t.targetValue.toString();
      _xpCtrl.text = t.xpReward.toString();
      _selectedType = t.taskType;
      _isActive = t.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'task_name': _nameCtrl.text.trim(),
      'task_type': _selectedType,
      'description': _descCtrl.text.trim(),
      'target_value': int.parse(_targetCtrl.text.trim()),
      'xp_reward': int.parse(_xpCtrl.text.trim()),
      'is_active': _isActive,
    };

    final api = ApiService();
    bool ok;
    if (_isEditing) {
      ok = await api.updateDailyTask(widget.task!.id, data);
    } else {
      ok = await api.createDailyTask(data);
    }

    setState(() => _loading = false);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan task. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  const Icon(Icons.science_outlined, color: _cyan, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    _isEditing ? 'Edit Daily Task' : 'Daily Task',
                    style: const TextStyle(
                      color: _cyan,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: const Icon(Icons.close, color: Colors.white38, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Task Name
              _label('TASK NAME'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameCtrl,
                hint: 'Finish 3 Lessons',
                validator: (v) => v == null || v.isEmpty ? 'Task name is required' : null,
              ),
              const SizedBox(height: 20),

              // Task Type
              _label('TASK TYPE'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    dropdownColor: _card,
                    iconEnabledColor: _cyan,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _taskTypes.map((t) {
                      return DropdownMenuItem(
                        value: t['value'],
                        child: Text(t['label']!),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              _label('DESKRIPSI TUGAS'),
              const SizedBox(height: 8),
              _textField(
                controller: _descCtrl,
                hint: 'Selesaikan 3 quiz atau pelajaran hari ini',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Target Value + XP Reward
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('TARGET VALUE'),
                        const SizedBox(height: 8),
                        _textField(
                          controller: _targetCtrl,
                          hint: '3',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (int.tryParse(v) == null) return 'Must be a number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('XP REWARD'),
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            _textField(
                              controller: _xpCtrl,
                              hint: '500',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (int.tryParse(v) == null) return 'Must be a number';
                                return null;
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 14),
                              child: Text(
                                'XP',
                                style: TextStyle(
                                  color: _cyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Contoh: 3 (untuk 3 quiz), 200 (untuk 200 XP)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
              ),
              const SizedBox(height: 24),

              // Active Status toggle
              _toggleRow(
                'Active status',
                _isActive,
                (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _save,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.science_outlined, color: Colors.black),
                  label: Text(
                    _loading ? 'Saving...' : 'SAVE',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF161C1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF252D30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF252D30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cyan, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161C1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252D30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _cyan,
            activeTrackColor: _cyan.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}
