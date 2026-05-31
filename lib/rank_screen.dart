import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'profile_screen.dart';
import 'widgets/background_wrapper.dart';
import 'widgets/animated_progress_bar.dart';
import 'rank_hierarchy_screen.dart';
import 'rank_editor_screen.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  String _selectedTime = 'LAST WEEK';
  String _selectedScope = 'GLOBALLY';
  List<dynamic> _users = [];
  List<dynamic> _ranks = [];
  dynamic _currentRankData;
  dynamic _displayRankData;
  List<dynamic> _chapters = [];
  bool _isLoading = true;
  bool _isBannerPressed = false;

  static const _cyan = Color(0xFF00FBFF);
  static const _yellow = Color(0xFFFFD700);
  static const _cardBg = Color(0xFF161D1E);
  static const _bg = Color(0xFF0D1213);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final period = _selectedTime == 'LAST WEEK' ? 'last_week' : _selectedTime == 'LAST MONTH' ? 'last_month' : 'all';
    final scope = _selectedScope == 'FRIENDS' ? 'friends' : 'global';
    final results = await Future.wait<dynamic>([
      api.getLeaderboard(period: period, scope: scope),
      api.getRanks(),
      api.getCurrentUser(),
      api.getCurriculum(),
    ]);
    if (mounted) {
      setState(() {
        _users = results[0] as List;
        _ranks = results[1] as List;
        final user = results[2] as AppUser?;
        final xp = user?.totalXp ?? 0;
        _currentRankData = _ranks.lastWhere(
          (r) => ((r['xp_threshold'] ?? r['min_xp'] ?? r['xp_required'] ?? 0) as int) <= xp,
          orElse: () => null
        );
        _displayRankData = _currentRankData;
        final selectedId = user?.selectedRankId;
        if (selectedId != null) {
          final selected = _ranks.firstWhere((r) => r['id'].toString() == selectedId.toString(), orElse: () => null);
          if (selected != null) {
            final selectedThreshold = (selected['xp_threshold'] ?? selected['min_xp'] ?? selected['xp_required'] ?? 0) as int;
            if (xp >= selectedThreshold) {
              _displayRankData = selected;
            }
          }
        }
        _isLoading = false;
        _chapters = results[3] as List;
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

  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: _bg,
      body: BackgroundWrapper(
        showGrid: true,
        removeSafeAreaPadding: true,
        child: SafeArea(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text((user?.username ?? 'ALCHEMIST').toUpperCase(), style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w300, letterSpacing: 1.5)),
                  const Spacer(),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20, 
                        backgroundColor: _parseColor(user?.profileBgColor) ?? Colors.transparent,
                        backgroundImage: NetworkImage(ApiService.getAvatarUrl(user?.avatarUrl, fallbackSeed: user?.username ?? 'admin')),
                        child: user?.avatarUrl == null ? const Icon(Icons.person, size: 22) : null,
                      ),
                      if (_displayRankData != null && (_displayRankData!['rank_icon_url'] != null || _displayRankData!['icon_url'] != null))
                        Positioned(
                          bottom: -2, right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: _bg, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: _cyan,
                              backgroundImage: (_displayRankData!['rank_icon_url'] ?? _displayRankData!['icon_url']).startsWith('http') 
                                ? NetworkImage(_displayRankData!['rank_icon_url'] ?? _displayRankData!['icon_url']) 
                                : null,
                              child: (_displayRankData!['rank_icon_url'] ?? _displayRankData!['icon_url']).startsWith('http') 
                                ? null 
                                : const Icon(Icons.shield, size: 10, color: Colors.black),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: _cyan,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const Text('LABORATORY LEADERBOARD', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                      const Text('Alchemy Rank', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _timeFilter('LAST WEEK')),
                            Expanded(child: _timeFilter('LAST MONTH')),
                            Expanded(child: _timeFilter('ALL TIME')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _scopeFilter('GLOBALLY'),
                          const SizedBox(width: 24),
                          _scopeFilter('FRIENDS'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildRankBanner(),
                      const SizedBox(height: 32),
                      if (_users.isNotEmpty) _buildRankStair(),
                      const SizedBox(height: 40),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(color: _cyan))
                      else if (_users.length > 3)
                        Container(
                          height: 500,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1213),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                              child: Column(
                                children: _users.asMap().entries.where((e) => e.key > 2).map((entry) {
                                  final u = entry.value;
                                  final isMe = u['id'].toString() == user?.id.toString();
                                  return _leaderboardTile(entry.key + 1, u, isMe);
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      else if (_users.isEmpty)
                        const Padding(padding: EdgeInsets.only(top: 20), child: Text('No data found', style: TextStyle(color: Colors.white24))),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RankEditorScreen())),
              backgroundColor: _cyan,
              child: const Icon(Icons.edit, color: Colors.black),
            )
          : null,
    );
  }

  Widget _timeFilter(String label) {
    final active = _selectedTime == label;
    return GestureDetector(
      onTap: () => setState(() { _selectedTime = label; _fetchData(); }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? _cyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: active ? _cyan : Colors.white38, fontSize: 11, fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _scopeFilter(String label) {
    final active = _selectedScope == label;
    return GestureDetector(
      onTap: () => setState(() { _selectedScope = label; _fetchData(); }),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: active ? _cyan : Colors.white38, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          if (active) Container(width: 60, height: 2, color: _cyan),
          if (!active) const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildRankBanner() {
    final user = ApiService().currentUser;
    final userColor = _parseColor(user?.profileBgColor) ?? _cyan;
    final rankName = (_displayRankData?['name'] ?? 'Unranked').toString().toUpperCase();
    final rankIcon = _displayRankData?['rank_icon_url'] ?? _displayRankData?['icon_url'];
    final totalXp = user?.totalXp ?? 0;
    String chapterSubtitle = 'CHAPTER 1. AHLI ATOM';
    String nextChapterTitle = 'NEXT CHAPTER';
    int chapterXp = 0;
    int chapterTotalXp = 100;
    if (_chapters.isNotEmpty) {
      final currentTitle = user?.currentChapterTitle ?? '';
      final idx = _chapters.indexWhere((c) => c['title'] == currentTitle);
      if (idx != -1) {
        final activeChapter = _chapters[idx];
        chapterSubtitle = 'CHAPTER ${activeChapter['order_index'] ?? (idx + 1)}. ${(activeChapter['title'] ?? '').toUpperCase()}';
        if (idx + 1 < _chapters.length) {
          nextChapterTitle = (_chapters[idx + 1]['title'] ?? 'NEXT').toString().toUpperCase();
        } else {
          nextChapterTitle = 'MAX LEVEL';
        }
        chapterXp = user?.currentLevelXp ?? 0;
        chapterTotalXp = user?.totalLevelXp ?? 100;
      }
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isBannerPressed = true),
      onTapUp: (_) {
        setState(() => _isBannerPressed = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RankHierarchyScreen()));
      },
      onTapCancel: () => setState(() => _isBannerPressed = false),
      child: AnimatedScale(
        scale: _isBannerPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1213).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hexagon Icon
                  Container(
                    width: 50, height: 50,
                    child: Center(
                      child: (rankIcon != null && rankIcon.startsWith('http'))
                        ? Image.network(rankIcon, width: 50, height: 50, fit: BoxFit.contain)
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.hexagon, color: const Color(0xFFC5A059).withOpacity(0.8), size: 50),
                              Icon(Icons.hexagon_outlined, color: const Color(0xFFFFD700), size: 52),
                              const Icon(Icons.science_outlined, color: Color(0xFF4A3411), size: 24),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Rank Name and Chapter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rankName.substring(0, 1) + rankName.substring(1).toLowerCase(), // Proper Case
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chapterSubtitle,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // XP Text
                  Text(
                    '${totalXp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} XP',
                    style: GoogleFonts.spaceGrotesk(
                      color: userColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      shadows: [Shadow(color: userColor.withOpacity(0.4), blurRadius: 10)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  double progress = (chapterTotalXp > 0 ? (chapterXp / chapterTotalXp) : 0).clamp(0.0, 1.0).toDouble();
                  return Stack(
                    children: [
                      Container(
                        height: 6,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      if (progress > 0)
                        Container(
                          height: 6,
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: userColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 6,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: userColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 8),
              // Progress Text
              Text(
                '$chapterXp/$chapterTotalXp XP MENUJU $nextChapterTitle',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankStair() {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(bottom: 60, child: CustomPaint(size: const Size(400, 400), painter: ConcentricRingsPainter())),
          Positioned(bottom: 0, child: Image.asset('assets/rank_stair.png', width: 350, fit: BoxFit.contain)),
          if (_users.isNotEmpty) Positioned(bottom: 210, child: _stairUser(_users[0], 1)),
          if (_users.length > 1) Positioned(bottom: 150, left: 20, child: _stairUser(_users[1], 2)),
          if (_users.length > 2) Positioned(bottom: 120, right: 20, child: _stairUser(_users[2], 3)),
        ],
      ),
    );
  }

  Widget _stairUser(dynamic user, int rank) {
    final isFirst = rank == 1;
    final size = isFirst ? 90.0 : 75.0;
    final fallbackColor = isFirst ? const Color(0xFFCCFF00) : (rank == 2 ? const Color(0xFF9B59B6) : const Color(0xFF00FBFF));
    final userColor = _parseColor(user['profile_bg_color']) ?? fallbackColor;
    return GestureDetector(
      onTap: () {
        if (user['id'] != ApiService().currentUser?.id) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen(userId: user['id'])));
        }
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size, height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: userColor, width: 3)),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundImage: user['avatar_url'] != null ? NetworkImage(ApiService.getAvatarUrl(user['avatar_url'], fallbackSeed: user['username'])) : null,
                    backgroundColor: userColor,
                    child: user['avatar_url'] == null ? Icon(Icons.person, color: Colors.white.withOpacity(0.5), size: size * 0.6) : null,
                  ),
                ),
              ),
              if (isFirst) Positioned(top: -30, child: Image.asset('assets/rank_crown.png', width: 40)),
              Positioned(
                bottom: -10, right: -10,
                child: SizedBox(
                  width: 40, height: 40,
                  child: (user['rank_icon_url'] != null && user['rank_icon_url'].startsWith('http'))
                    ? Image.network(user['rank_icon_url'], width: 40, height: 40, fit: BoxFit.contain)
                    : Icon(rank == 1 ? Icons.workspace_premium : (rank == 2 ? Icons.military_tech : Icons.shield), color: const Color(0xFFFFD700), size: 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(user['username'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
          Text('${user['xp'] ?? 0} XP', style: TextStyle(color: userColor, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _leaderboardTile(int rank, dynamic user, bool isMe) {
    final itemColor = _parseColor(user['profile_bg_color']) ?? _cyan;
    return GestureDetector(
      onTap: !isMe ? () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen(userId: user['id'])));
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: isMe ? itemColor.withOpacity(0.1) : _cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isMe ? itemColor : Colors.white.withOpacity(0.05), width: isMe ? 1.5 : 1),
          boxShadow: isMe ? [BoxShadow(color: itemColor.withOpacity(0.15), blurRadius: 15, spreadRadius: 1)] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              if (isMe) Container(width: 6, color: itemColor),
              const SizedBox(width: 20),
              SizedBox(width: 30, child: Text('$rank', style: TextStyle(color: isMe ? itemColor : Colors.white24, fontSize: 22, fontWeight: FontWeight.w400))),
              const SizedBox(width: 10),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isMe ? itemColor : Colors.white.withOpacity(0.1), width: 2)),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: itemColor,
                        backgroundImage: user['avatar_url'] != null ? NetworkImage(ApiService.getAvatarUrl(user['avatar_url'], fallbackSeed: user['username'])) : null,
                        child: user['avatar_url'] == null ? const Icon(Icons.person, color: Colors.white24, size: 20) : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -8, right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                      child: (user['rank_icon_url'] != null && user['rank_icon_url'].startsWith('http'))
                        ? Image.network(user['rank_icon_url'], width: 24, height: 24, fit: BoxFit.contain)
                        : const Icon(Icons.military_tech, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user['username'] + (isMe ? ' (You)' : ''), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
                    Text((user['rank_title'] ?? 'Unranked').toUpperCase(), style: TextStyle(color: isMe ? itemColor : Colors.white38, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${user['xp']}', style: TextStyle(color: itemColor, fontSize: 18, fontWeight: FontWeight.w900, shadows: [Shadow(color: itemColor.withOpacity(0.5), blurRadius: 10)])),
                    const Text('XP', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900)),
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

class ConcentricRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 40);
    
    // Main subtle rings
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 120, basePaint);
    canvas.drawCircle(center, 180, basePaint);
    canvas.drawCircle(center, 260, basePaint);
    
    // Cyan Neon Highlights
    final neonPaint = Paint()
      ..color = const Color(0xFF00FBFF).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
    final highlightPaint = Paint()
      ..color = const Color(0xFF00FBFF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw some glowing arcs
    final rect1 = Rect.fromCircle(center: center, radius: 180);
    canvas.drawArc(rect1, -math.pi / 2 - 0.8, 1.2, false, neonPaint);
    canvas.drawArc(rect1, -math.pi / 2 - 0.8, 1.2, false, highlightPaint);

    final rect2 = Rect.fromCircle(center: center, radius: 260);
    canvas.drawArc(rect2, math.pi / 6, 0.8, false, neonPaint);
    canvas.drawArc(rect2, math.pi / 6, 0.8, false, highlightPaint);
    
    canvas.drawArc(rect2, math.pi, 0.5, false, neonPaint);
    canvas.drawArc(rect2, math.pi, 0.5, false, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}