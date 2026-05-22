import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'widgets/background_wrapper.dart';
import 'widgets/animated_progress_bar.dart';
import 'services/api_service.dart';
import 'admin/lab_curricula_screen.dart';
import 'quiz/quiz_session_screen.dart';
import 'quiz/loading_screen.dart';
import 'models/user_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> _chapters = [];
  bool _isLoading = true;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();
  int? _activeLevelId;
  int _visibleChapterIndex = 0;
  List<double> _chapterOffsets = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCurriculum();
  }



  void _onScroll() {
    if (_chapterOffsets.isEmpty) return;
    double offset = _scrollController.offset;
    int newIndex = 0;
    for (int i = 0; i < _chapterOffsets.length; i++) {
      if (offset >= _chapterOffsets[i] - 100) { 
        newIndex = i;
      }
    }
    if (newIndex != _visibleChapterIndex && newIndex >= 0 && newIndex < _chapters.length) {
      setState(() {
        _visibleChapterIndex = newIndex;
      });
    }
  }

  void _calculateOffsets() {
    _chapterOffsets.clear();
    double currentOffset = 0.0;
    for (var ch in _chapters) {
      _chapterOffsets.add(currentOffset);
      final levels = (ch['levels'] as List?) ?? [];
      final chapterHeight = 74.0 + (levels.length * 170.0);
      currentOffset += chapterHeight;
    }
  }

  Future<void> _fetchCurriculum() async {
    final chapters = await ApiService().getCurriculum();
    if (mounted) {
      setState(() {
        _chapters = chapters;
        _isLoading = false;
        _calculateOffsets();
        final activeIndex = _chapters.indexWhere((ch) => ApiService.toInt(ch['chapter_progress']) < 100);
        _visibleChapterIndex = activeIndex >= 0 ? activeIndex : (_chapters.isNotEmpty ? _chapters.length - 1 : 0);
      });
    }
  }

  Map<String, dynamic>? _getDisplayedChapter() {
    if (_chapters.isEmpty) return null;
    if (_visibleChapterIndex >= 0 && _visibleChapterIndex < _chapters.length) {
      return _chapters[_visibleChapterIndex];
    }
    return _chapters.first;
  }

  Map<String, dynamic>? _getActiveChapter() {
    if (_chapters.isEmpty) return null;
    return _chapters.firstWhere(
      (ch) => ApiService.toInt(ch['chapter_progress']) < 100,
      orElse: () => _chapters.last,
    );
  }

  String _getCurrentLevelDisplayName() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return 'Apprentice';
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => ApiService.toInt(l['progress']) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    if (activeLevel == null) return 'Expert';
    return activeLevel['name'] ?? 'Apprentice';
  }

  String _getDisplayedLevelDisplayName() {
    final dispChapter = _getDisplayedChapter();
    if (dispChapter == null) return '';
    
    final levels = (dispChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => ApiService.toInt(l['progress']) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    if (activeLevel == null) return 'Expert';
    return activeLevel['name'] ?? '';
  }

  int _getCurrentLevelNumber() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return 0;
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => ApiService.toInt(l['progress']) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    return ApiService.toInt(activeLevel?['order_index'] ?? 1);
  }

  int _getCurrentLevelProgress() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return 0;
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => ApiService.toInt(l['progress']) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    return ApiService.toInt(activeLevel?['progress']);
  }

  String _getCurrentLevelInfo() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return '0/0 XP';
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => ApiService.toInt(l['progress']) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    if (activeLevel == null) return 'Maxed XP';
    return '${activeLevel['user_xp'] ?? 0}/${activeLevel['total_xp'] ?? 0} XP';
  }

  int _getChapterEarnedXp() {
    final activeChapter = _getDisplayedChapter();
    if (activeChapter == null) return 0;
    final levels = (activeChapter['levels'] as List?) ?? [];
    int total = 0;
    for (var l in levels) {
      total += ApiService.toInt(l['user_xp']);
    }
    return total;
  }

  int _getChapterTotalXp() {
    final activeChapter = _getDisplayedChapter();
    if (activeChapter == null) return 0;
    final levels = (activeChapter['levels'] as List?) ?? [];
    int total = 0;
    for (var l in levels) {
      total += ApiService.toInt(l['total_xp']);
    }
    return total;
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

  String _getAvatarUrl(AppUser? user) {
    if (user == null || user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      return 'https://i.pravatar.cc/150?u=${user?.username ?? 'alchemist'}';
    }
    String url = user.avatarUrl!;
    if (!url.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      return '$baseUrl/$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const accentLime = Color(0xFFCCFF00);
    const darkBg = Color(0xFF050F10);
    final user = ApiService().currentUser;
    final isAdmin = user?.isAdmin ?? false;

    final displayedChapter = _getDisplayedChapter();
    final String chapterColorHex = displayedChapter?['icon_emoji'] ?? '#00FBFF';
    Color chapterColor = primaryCyan;
    if (chapterColorHex.startsWith('#')) {
      try {
        chapterColor = Color(int.parse(chapterColorHex.replaceFirst('#', 'FF'), radix: 16));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabCurriculaScreen()),
          ).then((_) => _fetchCurriculum());
        },
        backgroundColor: const Color(0xFF001A26),
        shape: const CircleBorder(side: BorderSide(color: primaryCyan, width: 2)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ) : null,
      body: BackgroundWrapper(
        showGrid: true,
        removeSafeAreaPadding: true,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryCyan))
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Combined Sticky Header: Profile + Level Banner
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    height: 235,
                    child: Column(
                      children: [
                        // --- PROFILE ROW ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Row(
                            children: [
                              Text(
                                (user?.username ?? 'ALCHEMIST').toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  color: primaryCyan,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Spacer(),
                              // Streak
                              Row(
                                children: [
                                  Image.asset('assets/streak.png', width: 20, height: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user?.streakCount ?? 0} DAY STREAK',
                                    style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // XP
                              Row(
                                children: [
                                  Image.asset('assets/xp.png', width: 20, height: 20),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${user?.totalXp ?? 0}',
                                    style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Avatar
                              // Avatar
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: _parseColor(user?.profileBgColor) ?? Colors.transparent,
                                backgroundImage: NetworkImage(_getAvatarUrl(user)),
                              ),
                            ],
                          ),
                        ),
                        
                        // --- CHAPTER DATA DISPLAY (DYNAMIC TINTED STYLING) ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color.lerp(chapterColor, Colors.black, 0.82) ?? const Color(0xFF0F1B1D),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.03)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.lerp(chapterColor, Colors.black, 0.90) ?? const Color(0xFF071011),
                                  offset: const Offset(0, 6),
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Chapter ${_getDisplayedChapter()?['order_index'] ?? 1} - ${displayedChapter?['title'] ?? ''}',
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
                                      _getDisplayedLevelDisplayName(),
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${_getDisplayedChapter()?['chapter_progress'] ?? 0} %',
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
                                  value: ((_getDisplayedChapter()?['chapter_progress'] ?? 0) / 100).clamp(0.0, 1.0),
                                  height: 7,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  foregroundGradient: LinearGradient(colors: [chapterColor, chapterColor]),
                                  boxShadow: [BoxShadow(color: chapterColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
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
                      ],
                    ),
                  ),
                ),

                // 3. Map Part (Scrollable)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ..._chapters.asMap().entries.map((entry) {
                        final chapterIndex = entry.key;
                        final chapter = entry.value;
                        final levels = (chapter['levels'] as List?) ?? [];
                        final String nodeColorHex = chapter['icon_emoji'] ?? '#00FBFF';
                        Color nodeColor = const Color(0xFF00FBFF);
                        if (nodeColorHex.startsWith('#')) {
                          try {
                            nodeColor = Color(int.parse(nodeColorHex.replaceFirst('#', 'FF'), radix: 16));
                          } catch (_) {}
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            // CHAPTER DIVIDER
                            Row(
                              children: [
                                const Expanded(child: Divider(color: Colors.white24)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    chapter['title']?.toLowerCase() ?? 'untitled chapter',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w300),
                                  ),
                                ),
                                const Expanded(child: Divider(color: Colors.white24)),
                              ],
                            ),
                            const SizedBox(height: 40),
                            // HEXAGON MAP FOR THIS CHAPTER
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  CustomPaint(
                                    size: Size(double.infinity, levels.length * 160.0),
                                    painter: DashLinePainter(pointsCount: levels.length),
                                  ),
                                  Column(
                                    children: List.generate(levels.length, (index) {
                                      final lvl = levels[index];
                                      final isLeft = index % 2 == 0;
                                      final isDone = ApiService.toInt(lvl['progress']) >= 100;
                                      final isActive = ApiService.toInt(lvl['progress']) > 0 && ApiService.toInt(lvl['progress']) < 100;
                                      final isChapterLocked = chapter['is_locked'] == true;
                                      
                                      bool isPrevDone = true;
                                      if (index > 0) {
                                        final prevLvl = levels[index - 1];
                                        isPrevDone = ApiService.toInt(prevLvl['progress']) >= 100;
                                      } else if (chapterIndex > 0) {
                                        final prevChapter = _chapters[chapterIndex - 1];
                                        final prevChapterLevels = (prevChapter['levels'] as List?) ?? [];
                                        if (prevChapterLevels.isNotEmpty) {
                                          final prevLvl = prevChapterLevels.last;
                                          isPrevDone = ApiService.toInt(prevLvl['progress']) >= 100;
                                        }
                                      }
                                      
                                      final int xpThreshold = ApiService.toInt(lvl['xp_threshold'] ?? lvl['xp_required']);
                                      final int userXp = ApiService().currentUser?.totalXp ?? 0;
                                      
                                      final isLevelLocked = isChapterLocked || 
                                          lvl['is_locked'] == true || 
                                          !isPrevDone || 
                                          (xpThreshold > 0 && userXp < xpThreshold);
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 60),
                                        child: _HexPressable(
                                          onTap: (context) {
                                            Scrollable.ensureVisible(
                                              context,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeInOut,
                                              alignment: 0.3,
                                            );
                                            _showLevelPopup(context, lvl, chapter['title'] ?? 'Chapter', levels.length, isLevelLocked, isPrevDone, nodeColor, chapter['is_locked'] == true, isLeft);
                                          },
                                          builder: (isPressed) => _hexNodeWithLabel(
                                            lvl['name']?.toUpperCase() ?? 'UNTITLED', 
                                            'LVL ${ApiService.toInt(lvl['order_index'] ?? (index + 1))}', 
                                            isLevelLocked ? const Color(0xFF2D3234) : nodeColor, 
                                            isLeft ? Alignment.centerLeft : Alignment.centerRight, 
                                            isDone,
                                            isActive: isActive,
                                            iconUrl: lvl['icon_url'],
                                            isLocked: isLevelLocked,
                                            link: _activeLevelId == lvl['id'] ? _layerLink : LayerLink(),
                                            isPressed: isPressed,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1618),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallStat(String assetPath, String text) {
    return Row(
      children: [
        Image.asset(assetPath, width: 20, height: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _hexNodeWithLabel(String label, String lvl, Color color, Alignment alignment, bool isDone, {bool isActive = false, bool isLocked = false, bool isSpecial = false, String? iconUrl, LayerLink? link, bool isPressed = false}) {
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              CompositedTransformTarget(
                link: link ?? LayerLink(),
                child: SizedBox(
                  width: 100,
                  height: 110,
                  child: CustomPaint(
                    painter: HexagonPainter(
                      color: color,
                      isFill: isDone || isActive || isLocked || !isLocked,
                      glow: isActive,
                      isPressed: isPressed,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      padding: EdgeInsets.only(
                        top: isPressed ? 7.0 : 0.0,
                        bottom: isPressed ? 0.0 : 7.0,
                      ),
                      child: Center(
                        child: isSpecial 
                          ? const Icon(Icons.stars_rounded, color: Colors.white24, size: 40)
                          : (iconUrl != null && iconUrl.isNotEmpty) 
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.network(
                                  iconUrl, 
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.red),
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isDone) const Icon(Icons.check, color: Colors.black, size: 24),
                                  if (isActive) const Icon(Icons.bolt_rounded, color: Colors.black, size: 32),
                                  if (isLocked) const Icon(Icons.lock_outline, color: Colors.white70, size: 24),
                                  if (!isDone && !isActive && !isLocked) const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 32),
                                  if (!isSpecial) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      lvl,
                                      style: TextStyle(
                                        color: isDone || isActive || !isLocked ? Colors.black.withOpacity(0.7) : Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isActive)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8)],
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: isDone || isActive ? color : Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2
            ),
          ),
        ],
      ),
    );
  }
  void _showLevelPopup(BuildContext context, dynamic lvl, String chapterTitle, int totalLevels, bool isLevelLocked, bool isPrevDone, Color themeColor, bool isChapterLocked, bool isLeft) {
    _hideLevelPopup();

    setState(() {
      _activeLevelId = ApiService.toInt(lvl['id']);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final screenWidth = MediaQuery.of(context).size.width;
      final double calculatedWidth = screenWidth - 40.0;
      final double popupWidth = calculatedWidth > 400.0 ? 400.0 : calculatedWidth;
      
      double followerOffsetX;
      double triangleX;
      
      if (isLeft) {
        followerOffsetX = -20.0;
        triangleX = 50.0 - followerOffsetX;
      } else {
        followerOffsetX = 120.0 - popupWidth;
        triangleX = 50.0 - followerOffsetX;
      }

      final int xpThreshold = (lvl['xp_threshold'] ?? lvl['xp_required'] ?? 0) as int;
      final int userXp = ApiService().currentUser?.totalXp ?? 0;
      
      _overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            GestureDetector(
              onTap: _hideLevelPopup,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(followerOffsetX, 110), 
              child: Material(
                color: Colors.transparent,
                child: LevelInfoPopup(
                      chapterTitle: chapterTitle,
                      levelName: lvl['name'] ?? 'Untitled',
                      orderIndex: ApiService.toInt(lvl['order_index'] ?? 1),
                      totalLevelsInChapter: totalLevels,
                      isLocked: isLevelLocked,
                      xpThreshold: xpThreshold,
                      userXp: userXp,
                      isPrevDone: isPrevDone,
                      popupWidth: popupWidth,
                      triangleX: triangleX,
                      themeColor: themeColor,
                      onStart: isLevelLocked ? null : () {
                    _hideLevelPopup();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => QuizLoadingScreen(
                          onLoadingComplete: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => QuizSessionScreen(
                                  questions: lvl['questions'] ?? [],
                                  levelId: ApiService.toInt(lvl['id']),
                                  levelName: lvl['name'] ?? 'Level',
                                  timerLimit: ApiService.toInt(lvl['timer_limit']),
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeOutCubic;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  return SlideTransition(position: animation.drive(tween), child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                              ),
                            );
                          },
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(position: animation.drive(tween), child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 600),
                      ),
                    ).then((_) => _fetchCurriculum());
                  },
                ),
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  void _hideLevelPopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _activeLevelId = null;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _hideLevelPopup();
    super.dispose();
  }
}

class LevelInfoPopup extends StatefulWidget {
  final String chapterTitle;
  final String levelName;
  final int orderIndex;
  final int totalLevelsInChapter;
  final double popupWidth;
  final double triangleX;
  final VoidCallback? onStart;
  final bool isLocked;
  final int xpThreshold;
  final int userXp;
  final bool isPrevDone;
  final Color themeColor;

  const LevelInfoPopup({
    super.key,
    required this.chapterTitle,
    required this.levelName,
    required this.orderIndex,
    required this.totalLevelsInChapter,
    required this.popupWidth,
    required this.triangleX,
    required this.onStart,
    this.isLocked = false,
    this.xpThreshold = 0,
    this.userXp = 0,
    this.isPrevDone = true,
    this.themeColor = const Color(0xFF00FBFF),
  });

  @override
  State<LevelInfoPopup> createState() => _LevelInfoPopupState();
}

class _LevelInfoPopupState extends State<LevelInfoPopup> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeIn,
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final tealColor = widget.themeColor;
    // Use gray color for banner when level is locked
    final bannerColor = widget.isLocked ? const Color(0xFF757575) : tealColor;
    
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: widget.popupWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Triangular Pointer pointing UP (Dynamic position)
              Padding(
                padding: EdgeInsets.only(left: widget.triangleX - 15), // -15 for half width of triangle
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomPaint(
                    size: const Size(30, 25),
                    painter: TrianglePainter(color: bannerColor, pointingUp: true),
                  ),
                ),
              ),
              // Bubble Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bannerColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CHAPTER ${widget.orderIndex} ${widget.chapterTitle.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.orderIndex} OUT OF ${widget.totalLevelsInChapter} LEVEL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.levelName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (widget.isLocked) ...[
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final bool needsXp = widget.xpThreshold > 0 && widget.userXp < widget.xpThreshold;
                      final bool needsPrev = !widget.isPrevDone;
                      
                      if (needsXp && needsPrev) {
                        return Column(
                          children: [
                            Text(
                              'REACH ${widget.xpThreshold} XP TO OPEN THIS LEVEL &',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600, letterSpacing: 0.5, decoration: TextDecoration.none),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'UNLOCK PREVIOUS LEVEL',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600, letterSpacing: 0.5, decoration: TextDecoration.none),
                            ),
                          ],
                        );
                      } else if (needsXp) {
                        return Text(
                          'REACH ${widget.xpThreshold} XP TO OPEN THIS LEVEL',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600, letterSpacing: 0.5, decoration: TextDecoration.none),
                        );
                      } else if (needsPrev) {
                        return const Text(
                          'UNLOCK PREVIOUS LEVEL',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600, letterSpacing: 0.5, decoration: TextDecoration.none),
                        );
                      } else {
                        return const Text(
                          'LEVEL LOCKED',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600, letterSpacing: 0.5, decoration: TextDecoration.none),
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // Button based on PNG designs
                widget.isLocked
                  // ── LOCKED STATE ───────────────────────────────
                  ? Container(
                      width: widget.popupWidth * 0.85,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(bottom: BorderSide(color: tealColor.withOpacity(0.5), width: 4)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomPaint(
                              size: const Size(double.infinity, 30),
                              painter: GlossyStripesPainter(opacity: 0.15, color: tealColor),
                            ),
                          ),
                          const Icon(Icons.lock_outline, color: Colors.grey, size: 14),
                        ],
                      ),
                    )
                  // ── UNLOCKED STATE ─────────────────────────────
                  : GestureDetector(
                      onTapDown: (_) => setState(() => _isPressed = true),
                      onTapUp: (_) => setState(() => _isPressed = false),
                      onTapCancel: () => setState(() => _isPressed = false),
                      onTap: widget.onStart,
                      child: Container(
                        width: widget.popupWidth * 0.85,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: !_isPressed 
                            ? Border(bottom: BorderSide(color: tealColor.withOpacity(0.5), width: 4))
                            : null,
                          boxShadow: [
                            if (!_isPressed) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CustomPaint(
                                size: const Size(double.infinity, 30),
                                painter: GlossyStripesPainter(opacity: _isPressed ? 0.08 : 0.15, color: tealColor),
                              ),
                            ),
                            Text(
                              'START LESSON',
                              style: TextStyle(
                                color: tealColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
}
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointingUp;
  TrianglePainter({required this.color, this.pointingUp = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointingUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GlossyStripesPainter extends CustomPainter {
  final double opacity;
  final Color color;
  GlossyStripesPainter({this.opacity = 0.12, this.color = const Color(0xFF00FBFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double i = -size.height * 2; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlossyStripesPainter oldDelegate) => oldDelegate.opacity != opacity;
}


class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _StickyHeaderDelegate({required this.child, this.height = 180.0});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: const Color(0xFF050F10),
      elevation: 0, // Keep it flat but as a Material layer
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) => true;
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({required this.progress, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final bool isFill;
  final bool glow;
  final bool isPressed;
  static const double _depth = 7.0;

  HexagonPainter({required this.color, required this.isFill, this.glow = false, this.isPressed = false});

  List<Offset> _hexPoints(double cx, double cy, double radius, double dy) {
    return List.generate(6, (i) {
      final angle = (math.pi / 180) * (60 * i - 30);
      return Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle) + dy);
    });
  }

  Path _buildPath(List<Offset> pts) {
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      if (i == 0) path.moveTo(pts[i].dx, pts[i].dy);
      else path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - _depth / 2;
    final radius = size.width / 2 - 2;
    final topDy = isPressed ? _depth : 0.0;

    // Bottom depth face (only for filled hexagons)
    if (isFill) {
      final bottomPath = _buildPath(_hexPoints(cx, cy, radius, _depth));
      final hsl = HSLColor.fromColor(color);
      final darkColor = hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();
      canvas.drawPath(bottomPath, Paint()..color = darkColor);
    }

    // Top face
    final topPath = _buildPath(_hexPoints(cx, cy, radius, topDy));

    if (glow && !isPressed) {
      canvas.drawPath(topPath, Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }

    if (isFill) {
      canvas.drawPath(topPath, Paint()..color = color);
    } else {
      canvas.drawPath(topPath, Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) =>
    oldDelegate.isPressed != isPressed ||
    oldDelegate.color != color ||
    oldDelegate.isFill != isFill;
}

class DashLinePainter extends CustomPainter {
  final int pointsCount;
  DashLinePainter({required this.pointsCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (pointsCount < 2) return;

    final paint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < pointsCount; i++) {
      final y = 60.0 + (i * 160.0);
      final x = (i % 2 == 0) ? size.width * 0.25 : size.width * 0.75;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevY = 60.0 + ((i-1) * 160.0);
        final prevX = ((i-1) % 2 == 0) ? size.width * 0.25 : size.width * 0.75;
        path.quadraticBezierTo(size.width * 0.5, (y + prevY) / 2, x, y);
      }
    }

    final dashPath = _dashPath(path, 10, 8);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path source, double dashWidth, double dashSpace) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stateful wrapper that tracks press state and passes isPressed to the builder.
class _HexPressable extends StatefulWidget {
  final void Function(BuildContext context) onTap;
  final Widget Function(bool isPressed) builder;
  const _HexPressable({required this.onTap, required this.builder});
  @override
  State<_HexPressable> createState() => _HexPressableState();
}

class _HexPressableState extends State<_HexPressable> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => widget.onTap(context),
      child: widget.builder(_isPressed),
    );
  }
}
