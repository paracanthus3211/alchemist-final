import 'package:flutter/material.dart';
import '../models/daily_task_model.dart';
import '../services/api_service.dart';

class DailyTaskFormSheet extends StatefulWidget {
  final DailyTaskModel? task;
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
  List<Map<String, dynamic>> _stages = [
    {'target': 1, 'reward': 15}
  ];
  bool _isActive = true;
  bool _loading = false;

  final List<Map<String, String>> _taskTypes = [
    {'value': 'FINISH_LESSONS', 'label': 'Complete Quiz'},
    {'value': 'GAIN_XP', 'label': 'Gain XP'},
    {'value': 'READ_ARTICLE', 'label': 'Read Article'},
    {'value': 'LAB_EXPERIMENT', 'label': 'Lab Experiment'},
    {'value': 'DAILY_LOGIN', 'label': 'Daily Login'},
    {'value': 'SCORE', 'label': 'Quiz Score'},
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
      if (t.stages != null && t.stages!.isNotEmpty) {
        _stages = List<Map<String, dynamic>>.from(t.stages!);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _targetCtrl.dispose(); _xpCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'task_name': _nameCtrl.text.trim(),
      'task_type': _selectedType,
      'description': _descCtrl.text.trim(),
      'target_value': _stages.isNotEmpty ? _stages.last['target'] : 1,
      'xp_reward': _stages.isNotEmpty ? _stages.fold(0, (sum, s) => sum + (s['reward'] as int)) : 0,
      'is_active': _isActive,
      'stages': _stages,
    };
    final api = ApiService();
    bool ok = _isEditing ? await api.updateDailyTask(widget.task!.id, data) : await api.createDailyTask(data);
    setState(() => _loading = false);
    if (mounted && ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _dark, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _label('TASK NAME'),
              TextFormField(controller: _nameCtrl, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              _label('TASK TYPE'),
              DropdownButton<String>(
                value: _selectedType,
                isExpanded: true,
                dropdownColor: _card,
                items: _taskTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 20),
              _label('STAGES'),
              ...List.generate(_stages.length, (index) => Row(
                children: [
                  Expanded(child: TextFormField(
                    initialValue: _stages[index]['target'].toString(),
                    onChanged: (v) => _stages[index]['target'] = int.tryParse(v) ?? 0,
                    decoration: const InputDecoration(labelText: 'Target', labelStyle: TextStyle(color: Colors.white54)),
                    style: const TextStyle(color: Colors.white),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(
                    initialValue: _stages[index]['reward'].toString(),
                    onChanged: (v) => _stages[index]['reward'] = int.tryParse(v) ?? 0,
                    decoration: const InputDecoration(labelText: 'XP', labelStyle: TextStyle(color: Colors.white54)),
                    style: const TextStyle(color: Colors.white),
                  )),
                  IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: () => setState(() => _stages.removeAt(index))),
                ],
              )),
              TextButton(onPressed: () => setState(() => _stages.add({'target': 0, 'reward': 0})), child: const Text('ADD STAGE')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: Text(_loading ? 'SAVING...' : 'SAVE')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: _cyan, fontSize: 12, fontWeight: FontWeight.bold));
}
