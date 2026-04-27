import 'package:flutter/material.dart';
import 'models/daily_task_model.dart';
import 'services/api_service.dart';
import 'daily_task_form_sheet.dart';

/// Admin-only screen: "Daily Research Tasks" management panel (Lab Operations view).
class DailyTaskManagementScreen extends StatefulWidget {
  const DailyTaskManagementScreen({super.key});

  @override
  State<DailyTaskManagementScreen> createState() =>
      _DailyTaskManagementScreenState();
}

class _DailyTaskManagementScreenState
    extends State<DailyTaskManagementScreen> {
  static const _cyan = Color(0xFF00FBFF);
  static const _lime = Color(0xFFCCFF00);
  static const _dark = Color(0xFF0A0E10);
  static const _card = Color(0xFF111718);
  static const _cardBorder = Color(0xFF1E2628);

  final _api = ApiService();

  List<DailyTaskModel> _tasks = [];
  Map<String, int> _stats = {'templates': 0, 'active': 0, 'inactive': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _api.getDailyTasks(),
      _api.getDailyTaskStats(),
    ]);
    setState(() {
      _tasks = results[0] as List<DailyTaskModel>;
      _stats = results[1] as Map<String, int>;
      _loading = false;
    });
  }

  Future<void> _openForm([DailyTaskModel? task]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyTaskFormSheet(task: task),
    );
    if (result == true) _load();
  }

  Future<void> _delete(DailyTaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161C1F),
        title: const Text('Hapus Task?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin ingin menghapus "${task.taskName}"?',
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFFF4F4F))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _api.deleteDailyTask(task.id);
      if (ok) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _cyan))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _cyan,
                      backgroundColor: _card,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 24),
                            _buildStatsGrid(),
                            const SizedBox(height: 28),
                            _buildQueueList(),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Research\nTasks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'PROTOCOL V4.0.2 // SYSTEM SYNCHRONIZED',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final templates = _stats['templates'] ?? 0;
    final active = _stats['active'] ?? 0;
    final inactive = _stats['inactive'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('TEMPLATES', '$templates', '+12% vs last cycle', false)),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('ACTIVE', '$active', 'Running protocols', true, dot: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCardWide('INACTIVE TASKS', '$inactive'),
      ],
    );
  }

  Widget _statCard(String label, String value, String sub, bool highlight,
      {bool dot = false}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF0D1F20) : _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? _cyan.withValues(alpha: 0.3) : _cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (dot) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _cyan,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: highlight ? _cyan : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: TextStyle(
              color: highlight ? _cyan.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCardWide(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt_rounded, color: _lime, size: 20),
            const SizedBox(width: 8),
            const Text(
              'QUEUE LIST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _openForm(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _cyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.black, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'NEW TASK',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_tasks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.science_outlined, color: Colors.white12, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No tasks yet.\nTap "+ NEW TASK" to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_tasks.length, (i) {
            final task = _tasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _taskQueueCard(task),
            );
          }),
      ],
    );
  }

  Widget _taskQueueCard(DailyTaskModel task) {
    final double progress = task.targetValue > 0
        ? (task.currentProgress / task.targetValue).clamp(0.0, 1.0)
        : 0.0;

    Color statusColor;
    String statusLabel;
    if (task.isCompleted) {
      statusColor = Colors.white38;
      statusLabel = 'SYNCHRONIZED';
    } else if (task.isActive) {
      statusColor = _lime;
      statusLabel = 'ACTIVE';
    } else {
      statusColor = Colors.white24;
      statusLabel = 'INACTIVE';
    }

    IconData typeIcon;
    switch (task.taskType) {
      case 'GAIN_XP':
        typeIcon = Icons.bolt;
        break;
      case 'READ_ARTICLE':
        typeIcon = Icons.menu_book_rounded;
        break;
      case 'LAB_EXPERIMENT':
        typeIcon = Icons.science_outlined;
        break;
      case 'DAILY_LOGIN':
        typeIcon = Icons.login_rounded;
        break;
      default:
        typeIcon = Icons.menu_book_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: task.isActive
                      ? _cyan.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  typeIcon,
                  color: task.isActive ? _cyan : Colors.white38,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.taskName,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.white38 : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: () => _openForm(task),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: Colors.white38, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              GestureDetector(
                onTap: () => _delete(task),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: task.isCompleted ? 1.0 : progress,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                task.isCompleted ? Colors.white24 : _cyan,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                task.isCompleted
                    ? 'COMPLETED'
                    : '${task.currentProgress}/${task.targetValue} UNITS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
