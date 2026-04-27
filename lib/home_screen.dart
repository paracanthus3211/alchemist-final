import 'package:flutter/material.dart';
import 'models/daily_task_model.dart';
import 'models/user_model.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _cyan = Color(0xFF00FBFF);
  static const _lime = Color(0xFFCCFF00);
  static const _card = Color(0xFF111718);

  final _api = ApiService();

  List<DailyTaskModel> _tasks = [];
  bool _loadingTasks = true;
  AppUser? get _user => _api.currentUser;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loadingTasks = true);
    final tasks = await _api.getDailyTasks();
    setState(() {
      _tasks = tasks;
      _loadingTasks = false;
    });
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      showGrid: true,
      removeSafeAreaPadding: true,
      child: RefreshIndicator(
        onRefresh: _loadTasks,
        color: _cyan,
        backgroundColor: _card,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStreakCard(),
              const SizedBox(height: 32),
              _buildLevelProgress(),
              const SizedBox(height: 40),
              _buildContinueReading(),
              const SizedBox(height: 40),
              _buildDailyTasks(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: _cyan, size: 28),
              const SizedBox(width: 8),
              Text(
                (_user?.username.toUpperCase() ?? 'ALCHEMIST'),
                style: const TextStyle(
                  color: _cyan,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _cyan.withValues(alpha: 0.5), width: 1.5),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=alchemist'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STREAK CARD
  // ─────────────────────────────────────────────
  Widget _buildStreakCard() {
    final streak = _user?.currentStreak ?? 7;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STREAK LEARNING',
              style: TextStyle(
                color: _cyan,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: _lime, size: 40),
                const SizedBox(width: 8),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (i) {
                    final isActive = i == 0;
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isActive
                            ? _lime
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _lime.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          i == 0 ? 'S\n$streak' : '·',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white24,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LEVEL PROGRESS
  // ─────────────────────────────────────────────
  Widget _buildLevelProgress() {
    final xp = _user?.totalXp ?? 250;
    final nextXp = 500;
    final pct = (xp / nextXp).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT LEVEL',
            style: TextStyle(
              color: _cyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Master Alchemist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '${(pct * 100).toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: _lime, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const TextSpan(
                    text: ' %',
                    style: TextStyle(color: _lime, fontSize: 14),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_lime, _cyan]),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: _lime.withValues(alpha: 0.3), blurRadius: 10)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallStat(Icons.hub_outlined, '$xp XP'),
              _smallStat(Icons.bolt, '${_user?.currentStreak ?? 0} DAY STREAK'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _lime),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // CONTINUE READING
  // ─────────────────────────────────────────────
  Widget _buildContinueReading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CONTINUE READING',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0),
              ),
              const Icon(Icons.arrow_forward, color: _cyan, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _moduleCard(
                'MODULE 04',
                'Covalent Resonances',
                'Understanding the electron sharing protocols between carbon atoms...',
                'https://images.unsplash.com/photo-1532187875605-2fe35952016a?auto=format&fit=crop&q=80&w=800',
                _cyan,
              ),
              const SizedBox(width: 20),
              _moduleCard(
                'MODULE 05',
                'Noble States',
                'Analyzing why Helium and Neon maintain absolute stability...',
                'https://images.unsplash.com/photo-1614850523296-d8c1af93d400?auto=format&fit=crop&q=80&w=800',
                const Color(0xFF9D50BB),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moduleCard(
      String tag, String title, String desc, String imageUrl, Color tagColor) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(tag,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DAILY TASKS
  // ─────────────────────────────────────────────
  Widget _buildDailyTasks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAILY TASK',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                '$_completedCount / ${_tasks.length} COMPLETED',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loadingTasks)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: _cyan),
              ),
            )
          else if (_tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.task_alt, color: Colors.white12, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'No daily tasks today.',
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
                padding: EdgeInsets.only(bottom: i < _tasks.length - 1 ? 12 : 0),
                child: _taskTile(task),
              );
            }),
        ],
      ),
    );
  }

  Widget _taskTile(DailyTaskModel task) {
    IconData icon;
    switch (task.taskType) {
      case 'GAIN_XP':
        icon = Icons.bolt;
        break;
      case 'READ_ARTICLE':
        icon = Icons.menu_book_rounded;
        break;
      case 'LAB_EXPERIMENT':
        icon = Icons.science_outlined;
        break;
      case 'DAILY_LOGIN':
        icon = Icons.login_rounded;
        break;
      default:
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? _lime.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Check circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? _lime.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              task.isCompleted ? Icons.check_circle : icon,
              color: task.isCompleted ? _lime : Colors.white24,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskName.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  task.description ?? task.taskTypeLabel,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '+${task.xpReward}xp',
            style: TextStyle(
              color: task.isCompleted ? _lime : Colors.white24,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
