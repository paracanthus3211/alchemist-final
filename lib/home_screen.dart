import 'package:flutter/material.dart';
import 'article_view_screen.dart';
import 'models/daily_task_model.dart';
import 'models/user_model.dart';
import 'services/api_service.dart';
import 'services/settings_service.dart';
import 'widgets/background_wrapper.dart';
import 'widgets/animated_progress_bar.dart';
import 'quiz_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
  List<dynamic> _ranks = [];
  dynamic _currentRank;
  dynamic _displayRank;
  dynamic _nextRank;
  List<dynamic> _history = [];
  List<dynamic> _chapters = [];
  bool _loadingTasks = true;
  bool _loadingRanks = true;
  bool _loadingHistory = true;
  bool _loadingChapters = true;
  AppUser? get _user => _api.currentUser;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadRanks();
    _loadHistory();
    _loadChapters();
    ApiService().addListener(_onUserUpdated);
    SettingsService().addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _onUserUpdated() {
    if (mounted) {
      setState(() {});
      _loadTasks();
      _loadRanks();
      _loadHistory(); // Refresh daftar bacaan secara otomatis
      _loadChapters();
    }
  }

  @override
  void dispose() {
    ApiService().removeListener(_onUserUpdated);
    SettingsService().removeListener(_onSettingsChanged);
    super.dispose();
  }

  Future<void> _loadChapters() async {
    if (!mounted) return;
    setState(() => _loadingChapters = true);
    final chapters = await _api.getCurriculum();
    if (mounted) {
      setState(() {
        _chapters = chapters;
        _loadingChapters = false;
      });
    }
  }

  String _t(String key) => SettingsService().t(key);

  Future<void> _loadRanks() async {
    setState(() => _loadingRanks = true);
    final ranks = await _api.getRanks();
    if (mounted) {
      setState(() {
        _ranks = ranks;
        final xp = _user?.totalXp ?? 0;
        _currentRank = _ranks.lastWhere((r) => (r['xp_threshold'] ?? 0) <= xp, orElse: () => null);
        _displayRank = _currentRank;
        
        // If user has a selected rank, use that for the display icon
        if (_user?.selectedRankId != null) {
          final selected = _ranks.firstWhere((r) => r['id'].toString() == _user?.selectedRankId.toString(), orElse: () => null);
          if (selected != null) {
             _displayRank = selected;
          }
        }
        
        final idx = _currentRank != null ? _ranks.indexOf(_currentRank) : -1;
        if (idx != -1 && idx < _ranks.length - 1) {
          _nextRank = _ranks[idx + 1];
        } else if (idx == -1 && _ranks.isNotEmpty) {
          _nextRank = _ranks.first;
        }
        _loadingRanks = false;
      });
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _loadingTasks = true);
    final tasks = await _api.getDailyTasks();
    setState(() {
      _tasks = tasks;
      _loadingTasks = false;
    });
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    final history = await _api.getReadingHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loadingHistory = false;
      });
    }
  }

  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return null;
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _api.getCurrentUser(),
      _loadTasks(),
      _loadRanks(),
      _loadHistory(),
      _loadChapters(),
    ]);
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      showGrid: true,
      removeSafeAreaPadding: true,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: _cyan,
        backgroundColor: _card,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeStickyHeaderDelegate(
                child: _buildHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12), // Reduced since header has padding
                  _buildStreakCard(),
                  const SizedBox(height: 16),
                  _buildLevelProgress(),
                  const SizedBox(height: 40),
                  _buildContinueReading(),
                  const SizedBox(height: 40),
                  _buildDailyTasks(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: ValueKey(ApiService.getAvatarUrl(_user?.avatarUrl, fallbackSeed: _user?.username)),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _parseColor(_user?.profileBgColor) ?? Colors.transparent,
                  image: DecorationImage(
                    image: NetworkImage(ApiService.getAvatarUrl(_user?.avatarUrl, fallbackSeed: _user?.username)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (_displayRank != null && _displayRank!['icon_url'] != null)
                Positioned(
                  bottom: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFF0D1213), shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: _cyan,
                      backgroundImage: _displayRank!['icon_url'].startsWith('http') 
                        ? NetworkImage(_displayRank!['icon_url']) 
                        : null,
                      child: _displayRank!['icon_url'].startsWith('http') 
                        ? null 
                        : const Icon(Icons.shield, size: 10, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STREAK CARD
  // ─────────────────────────────────────────────
  Widget _buildStreakCard() {
    final streak = _user?.streakCount ?? 0;
    final lastStudy = _user?.lastStudyAt;
    final today = DateTime.now();
    
    // Check if studied today
    final studiedToday = lastStudy != null && 
        lastStudy.year == today.year && 
        lastStudy.month == today.month && 
        lastStudy.day == today.day;

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
            Text(
              _t('streak'),
              style: TextStyle(
                color: _cyan,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bagian Kiri: Icon + Angka
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/streak.png', width: 36, height: 36, color: streak > 0 ? null : Colors.white12, colorBlendMode: streak > 0 ? null : BlendMode.modulate),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: TextStyle(
                        color: streak > 0 ? Colors.white : Colors.white24,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                
                // Bagian Kanan: Hari (Pake FittedBox biar auto-kecil kalo gak muat)
                Flexible(
                  child: FittedBox(
                    child: Row(
                      children: List.generate(7, (i) {
                        final date = today.subtract(Duration(days: 6 - i));
                        final dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
                        final dayLabel = dayNames[date.weekday % 7];
                        final isToday = i == 6;
                        final isActive = isToday;

                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 24, 
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive ? _lime : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayLabel,
                                style: TextStyle(
                                  color: isActive ? Colors.black : Colors.white38,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isToday ? '$streak' : '·',
                                style: TextStyle(
                                  color: isActive ? Colors.black : Colors.white24,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CHAPTER BANNER (press-to-quiz)
  // ─────────────────────────────────────────────
  Map<String, dynamic>? _getActiveChapter() {
    if (_chapters.isEmpty) return null;
    return _chapters.firstWhere(
      (ch) => ApiService.toInt(ch['chapter_progress']) < 100,
      orElse: () => _chapters.last,
    );
  }

  String _getActiveLevelDisplayName() {
    final activeCh = _getActiveChapter();
    if (activeCh == null) return '';
    final levels = (activeCh['levels'] as List?) ?? [];
    final activeLvl = levels.firstWhere(
      (l) => ApiService.toInt(l['progress']) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    return activeLvl?['name'] ?? '';
  }

  int _getChapterEarnedXp() {
    final activeCh = _getActiveChapter();
    if (activeCh == null) return 0;
    final levels = (activeCh['levels'] as List?) ?? [];
    int total = 0;
    for (var l in levels) {
      total += ApiService.toInt(l['user_xp']);
    }
    return total;
  }

  int _getChapterTotalXp() {
    final activeCh = _getActiveChapter();
    if (activeCh == null) return 0;
    final levels = (activeCh['levels'] as List?) ?? [];
    int total = 0;
    for (var l in levels) {
      total += ApiService.toInt(l['total_xp']);
    }
    return total;
  }

  // ─────────────────────────────────────────────
  // CHAPTER BANNER (press-to-quiz)
  // ─────────────────────────────────────────────
  Widget _buildLevelProgress() {
    if (_loadingChapters) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Center(child: CircularProgressIndicator(color: _cyan)),
      );
    }

    final activeChapter = _getActiveChapter();
    final String chapterColorHex = activeChapter?['icon_emoji'] ?? '#00FBFF';
    Color chapterColor = _cyan;
    if (chapterColorHex.startsWith('#')) {
      try {
        chapterColor = Color(int.parse(chapterColorHex.replaceFirst('#', 'FF'), radix: 16));
      } catch (_) {}
    }

    final progressVal = ((activeChapter?['chapter_progress'] ?? 0) / 100).clamp(0.0, 1.0).toDouble();
    final baseColor = Color.lerp(chapterColor, Colors.black, 0.82) ?? const Color(0xFF0F1B1D);
    final shadowColor = Color.lerp(chapterColor, Colors.black, 0.90) ?? const Color(0xFF071011);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _Tactile3DButton(
        baseColor: baseColor,
        shadowColor: shadowColor,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chapter ${activeChapter?['order_index'] ?? 1} - ${activeChapter?['title'] ?? ''}',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getActiveLevelDisplayName(),
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${activeChapter?['chapter_progress'] ?? 0} %',
                    style: GoogleFonts.spaceGrotesk(
                      color: chapterColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              AnimatedProgressBar(
                value: progressVal,
                height: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundGradient: LinearGradient(colors: [chapterColor, chapterColor]),
                boxShadow: [BoxShadow(color: chapterColor.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.bolt, color: chapterColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_getChapterEarnedXp()}/${_getChapterTotalXp()} XP',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
              Text(
                _t('continue_reading'),
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
          height: 480, // Increased height for the new design
          child: _loadingHistory 
            ? const Center(child: CircularProgressIndicator(color: _cyan))
            : _history.isEmpty 
              ? Center(child: Text('No reading history', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))))
              : ListView.builder(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _moduleCard(item, _cyan),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _moduleCard(dynamic item, Color tagColor) {
    final article = item['article'] ?? item;
    final title = article['title'] ?? 'Untitled';
    final desc = article['description'] ?? '';
    final imageUrl = article['thumbnail_url'] ?? 'https://picsum.photos/id/101/600/800';
    final tag = article['category']?.toString().toUpperCase() ?? 'RESEARCH';
    final articleId = article['id'];

    double cardWidth = MediaQuery.of(context).size.width * 0.8;
    if (cardWidth > 320) cardWidth = 320;
    
    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFCFFFFF),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.2,
              shadows: [Shadow(color: Color(0xFF00FBFF), blurRadius: 10)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          // Read Button
          _ImageButton(
            image1: 'assets/read_article1.png',
            image2: 'assets/read_article2.png',
            onTap: () {
              if (articleId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticleViewScreen(articleId: articleId)),
                ).then((_) => _loadHistory());
              }
            },
          ),
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
              Text(
                _t('daily_task'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              Row(
                children: [
                  Text(
                    '$_completedCount / ${_tasks.length} COMPLETED',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w800),
                  ),
                  if (_api.currentUser?.role == UserRole.admin) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final newTasks = await _api.regenerateDailyTasks();
                        if (newTasks.isNotEmpty) {
                          setState(() => _tasks = newTasks);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tasks reshuffled!')),
                          );
                        }
                      },
                      child: Icon(Icons.refresh_rounded, color: _cyan, size: 16),
                    ),
                  ],
                ],
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
    final progress = (task.currentProgress / task.targetValue).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          // Left Side: Title + Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.taskName.toUpperCase(),
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Progress Bar
                AnimatedProgressBar(
                  value: progress,
                  height: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundGradient: const LinearGradient(colors: [_lime, _cyan]),
                ),
                const SizedBox(height: 6),
                // Progress Label
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${task.currentProgress}/${task.targetValue} UNITS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right Side: Gift + Reward (Fixed width to prevent squashing)
          SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/gift.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.card_giftcard, color: _lime, size: 40),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${task.xpReward}xp',
                  style: const TextStyle(
                    color: _lime,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageButton extends StatefulWidget {
  final String image1;
  final String image2;
  final VoidCallback onTap;

  const _ImageButton({
    required this.image1,
    required this.image2,
    required this.onTap,
  });

  @override
  State<_ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<_ImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        height: 60,
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          _isPressed ? widget.image2 : widget.image1,
          width: double.infinity,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _HomeStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _HomeStickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 84.0;
  @override
  double get maxExtent => 84.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF050F10), // Matching the background
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_HomeStickyHeaderDelegate oldDelegate) => true;
}

// ─────────────────────────────────────────────
// Pressable Banner — physical press-down effect
// ─────────────────────────────────────────────
class _PressableBanner extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableBanner({required this.child, required this.onTap});

  @override
  State<_PressableBanner> createState() => _PressableBannerState();
}

class _PressableBannerState extends State<_PressableBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Banner Image Button — switches between banner.png and banner_close.png
// ─────────────────────────────────────────────
class _BannerImageButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BannerImageButton({required this.onTap});

  @override
  State<_BannerImageButton> createState() => _BannerImageButtonState();
}

class _BannerImageButtonState extends State<_BannerImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Image.asset(
        _isPressed ? 'assets/banner_close.png' : 'assets/banner.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF0D2422),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.5)),
          ),
          child: const Center(
            child: Text('TAP TO PLAY QUIZ',
              style: TextStyle(color: Color(0xFF00FBFF), fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tactile 3D Button wrapper - creates 3D press-down effect
// ─────────────────────────────────────────────
class _Tactile3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color baseColor;
  final Color shadowColor;
  final double depth;
  final BorderRadius borderRadius;

  const _Tactile3DButton({
    required this.child,
    required this.onTap,
    required this.baseColor,
    required this.shadowColor,
    this.depth = 6.0,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
  });

  @override
  State<_Tactile3DButton> createState() => _Tactile3DButtonState();
}

class _Tactile3DButtonState extends State<_Tactile3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(
          top: _isPressed ? widget.depth : 0.0,
          bottom: _isPressed ? 0.0 : widget.depth,
        ),
        decoration: BoxDecoration(
          color: widget.baseColor,
          borderRadius: widget.borderRadius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, widget.depth),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
