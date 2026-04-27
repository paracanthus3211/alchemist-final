import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'widgets/background_wrapper.dart';
import 'services/api_service.dart';
import 'admin/lab_curricula_screen.dart';
import 'quiz/quiz_session_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurriculum();
  }

  Future<void> _fetchCurriculum() async {
    final chapters = await ApiService().getCurriculum();
    if (mounted) {
      setState(() {
        _chapters = chapters;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _getActiveChapter() {
    if (_chapters.isEmpty) return null;
    return _chapters.firstWhere(
      (ch) => (ch['chapter_progress'] ?? 0) < 100,
      orElse: () => _chapters.last,
    );
  }

  String _getCurrentLevelDisplayName() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return 'Apprentice';
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => (l['progress'] ?? 0) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    if (activeLevel == null) return 'Expert';
    return activeLevel['name'] ?? 'Apprentice';
  }

  int _getCurrentLevelProgress() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return 0;
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => (l['progress'] ?? 0) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    return activeLevel?['progress'] ?? 0;
  }

  String _getCurrentLevelInfo() {
    final activeChapter = _getActiveChapter();
    if (activeChapter == null) return '0/0 XP';
    
    final levels = (activeChapter['levels'] as List?) ?? [];
    final activeLevel = levels.firstWhere(
      (l) => (l['progress'] ?? 0) < 100,
      orElse: () => levels.isNotEmpty ? levels.last : null,
    );
    
    if (activeLevel == null) return 'Maxed XP';
    return '${activeLevel['user_xp'] ?? 0}/${activeLevel['total_xp'] ?? 0} XP';
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const accentLime = Color(0xFFCCFF00);
    const darkBg = Color(0xFF050F10);
    final user = ApiService().currentUser;
    final isAdmin = user?.isAdmin ?? false;

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
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // --- TOP HEADER: PARACANTHUS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.science_outlined, color: primaryCyan, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              'PARACANTHUS',
                              style: TextStyle(
                                color: primaryCyan.withOpacity(0.8),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- CIRCULAR PROGRESS ---
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CustomPaint(
                            painter: CircularProgressPainter(
                              progress: (_getActiveChapter()?['chapter_progress'] ?? 0) / 100,
                              color: accentLime,
                              backgroundColor: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_getActiveChapter()?['chapter_progress'] ?? 0}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${_getActiveChapter()?['title']?.toUpperCase() ?? 'CHAPTER'}\nPROGRESS LEARNING',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- STATS CARDS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _statCard('CURRENT XP', '${user?.totalXp ?? 0}', primaryCyan),
                        const SizedBox(width: 16),
                        _statCard('STREAK', '${user?.currentStreak ?? 0} Days', accentLime),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- CURRENT LEVEL BAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT LEVEL',
                          style: TextStyle(
                            color: primaryCyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Level ${_chapters.isNotEmpty ? 1 : 0} - ${_getCurrentLevelDisplayName()}',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_getCurrentLevelProgress()}%',
                              style: const TextStyle(color: accentLime, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (_getCurrentLevelProgress() / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [accentLime, primaryCyan]),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 10),
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
                            _smallStat(Icons.hub_outlined, _getCurrentLevelInfo()),
                            _smallStat(Icons.bolt, '${user?.currentStreak ?? 0} DAY STREAK'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // --- DYNAMIC CURRICULUM MAP ---
                  ..._chapters.map((chapter) {
                    final levels = (chapter['levels'] as List?) ?? [];
                    return Column(
                      children: [
                        const SizedBox(height: 30),
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
                                  final isDone = (lvl['progress'] ?? 0) >= 100;
                                  final isActive = (lvl['progress'] ?? 0) > 0 && (lvl['progress'] ?? 0) < 100;
                                  final isChapterLocked = chapter['is_locked'] == true;
                                  final isLevelLocked = lvl['is_locked'] == true || isChapterLocked;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 60),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isLevelLocked) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.lock, color: Colors.white, size: 16),
                                                  const SizedBox(width: 12),
                                                  Text(isChapterLocked 
                                                    ? 'Chapter ini terkunci! Butuh ${chapter['xp_threshold']} XP.' 
                                                    : 'XP Anda belum cukup! Butuh ${lvl['xp_required']} XP untuk level ini.'),
                                                ],
                                              ),
                                              backgroundColor: Colors.redAccent,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QuizSessionScreen(
                                              questions: lvl['questions'] ?? [],
                                              levelId: lvl['id'] ?? 0,
                                              levelName: lvl['name'] ?? 'Level',
                                            ),
                                          ),
                                        ).then((_) => _fetchCurriculum());
                                      },
                                      child: _hexNodeWithLabel(
                                        lvl['name']?.toUpperCase() ?? 'UNTITLED', 
                                        'LVL ${lvl['order_index'] ?? (index + 1)}', 
                                        isDone ? accentLime : (isActive ? primaryCyan : (isLevelLocked ? Colors.redAccent.withOpacity(0.3) : Colors.white24)), 
                                        isLeft ? Alignment.centerLeft : Alignment.centerRight, 
                                        isDone,
                                        isActive: isActive,
                                        iconUrl: lvl['icon_url'],
                                        isLocked: isLevelLocked,
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

  Widget _smallStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFCCFF00)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _hexNodeWithLabel(String label, String lvl, Color color, Alignment alignment, bool isDone, {bool isActive = false, bool isLocked = false, bool isSpecial = false, String? iconUrl}) {
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              SizedBox(
                width: 100,
                height: 110,
                child: CustomPaint(
                  painter: HexagonPainter(
                    color: color,
                    isFill: isDone || isActive,
                    glow: isActive,
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
                              if (isLocked) const Icon(Icons.lock_outline, color: Colors.redAccent, size: 24),
                              if (!isDone && !isActive && !isLocked) const Icon(Icons.lock_outline, color: Colors.white24, size: 24),
                              if (!isSpecial) ...[
                                const SizedBox(height: 4),
                                Text(
                                  lvl,
                                  style: TextStyle(
                                    color: isDone || isActive ? Colors.black.withOpacity(0.7) : (isLocked ? Colors.redAccent.withOpacity(0.5) : Colors.white24),
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

  HexagonPainter({required this.color, required this.isFill, this.glow = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (math.pi / 180) * (60 * i - 30);
      double x = cx + radius * math.cos(angle);
      double y = cy + radius * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();

    if (glow) {
      canvas.drawPath(path, Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    }

    if (isFill) {
      canvas.drawPath(path, Paint()..color = color);
    } else {
      canvas.drawPath(path, Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

