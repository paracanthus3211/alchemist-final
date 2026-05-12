import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_view_screen.dart';
import 'avatar_shop_screen.dart';
import 'services/settings_service.dart';
import 'widgets/background_wrapper.dart';
import 'services/api_service.dart';
import 'welcome_screen.dart';
import 'add_friends_screen.dart';
import 'models/user_model.dart';
import 'rank_hierarchy_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0: History, 1: Achievements, 2: Settings
  List<dynamic> _ranks = [];
  dynamic _currentRank;
  dynamic _displayRank;
  bool _isLoading = true;
  List<dynamic> _readingHistory = [];
  int _friendCount = 0;
  int _followingCount = 0;
  int _followerCount = 0;
  AppUser? _friendUser;
  bool get _isSelf => widget.userId == null;

  // Global Settings handled by SettingsService

  @override
  void initState() {
    super.initState();
    _loadData();
    SettingsService().addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SettingsService().removeListener(_rebuild);
    super.dispose();
  }

  Future<void> _loadData() async {
    final api = ApiService();
    
    try {
      if (!_isSelf) {
        final profile = await api.getUserProfile(widget.userId!);
        if (profile != null && mounted) {
          final userData = profile['user'];
          final statsData = profile['stats'];
          final historyData = List<dynamic>.from(profile['history'] ?? []);
          final ranks = await api.getRanks();
          
          setState(() {
            _friendUser = AppUser.fromJson(userData);
            _readingHistory = historyData;
            _friendCount = statsData['friends'] ?? 0;
            _followingCount = statsData['following'] ?? 0;
            _followerCount = statsData['followers'] ?? 0;
            _ranks = ranks;
            
            final xp = _friendUser!.totalXp;
            _currentRank = _ranks.lastWhere((r) => (r['xp_threshold'] ?? 0) <= xp, orElse: () => null);
            _displayRank = _currentRank;
            if (_friendUser!.selectedRankId != null) {
              final selected = _ranks.firstWhere((r) => r['id'].toString() == _friendUser!.selectedRankId.toString(), orElse: () => null);
              if (selected != null) _displayRank = selected;
            }
          });
        }
        return;
      }

      // Refresh user data for self
      await api.getCurrentUser();
      
      final history = await api.getReadingHistory();
      final friends = await api.getFriends();
      final stats = await api.getFriendStats();
      final ranks = await api.getRanks();
      
      final xp = api.currentUser?.totalXp ?? 0;
      final currentRank = ranks.lastWhere((r) => (r['xp_threshold'] ?? 0) <= xp, orElse: () => null);
      
      if (mounted) {
        setState(() {
          _readingHistory = history;
          _friendCount = stats['friends'] ?? friends.length;
          _followingCount = stats['following'] ?? 0;
          _followerCount = stats['followers'] ?? 0;
          _ranks = ranks;
          _currentRank = currentRank;
          _displayRank = _currentRank;
          final selectedId = api.currentUser?.selectedRankId;
          if (selectedId != null) {
            final selected = _ranks.firstWhere((r) => r['id'].toString() == selectedId.toString(), orElse: () => null);
            if (selected != null) _displayRank = selected;
          }
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static const _cyan = Color(0xFF00FBFF);
  static const _yellow = Color(0xFFCCFF00);
  static const _lime = Color(0xFFCCFF00); // Same as yellow but used for streak
  static const _purple = Color(0xFFCC00FF);
  static const _bgCard = Color(0xFF1A2223);
  static const _bgApp = Color(0xFF0F1415);

  String _t(String key) => SettingsService().t(key);

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
    final user = _isSelf ? ApiService().currentUser : _friendUser;

    return BackgroundWrapper(
      showGrid: false,
      removeSafeAreaPadding: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if (!_isSelf)
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: _cyan, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              SizedBox(height: _isSelf ? 60 : 20),
              
              // ─── PROFILE HEADER ───
              _buildHeader(user),
              
              const SizedBox(height: 30),
              
              // ─── STATS CARDS ───
              _buildStatsRow(),
              
              const SizedBox(height: 40),
              
              // ─── CUSTOM TAB BAR ───
              _buildTabSwitcher(),
              
              const SizedBox(height: 30),
              
              // ─── TAB CONTENT ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildTabContent(user),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader(AppUser? user) {
    final profileColor = _parseColor(user?.profileBgColor) ?? _cyan;

    return Column(
      children: [
        // Avatar with Glow
        GestureDetector(
          onTap: _isSelf ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarShopScreen())).then((_) => _loadData()) : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: profileColor.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profileColor,
                ),
                child: ClipOval(
                  child: Image.network(
                    _getAvatarUrl(user),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.person, color: Colors.white.withOpacity(0.5), size: 50),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      );
                    },
                  ),
                ),
              ),
                Positioned(
                  bottom: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: profileColor, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.black, size: 16),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Username
        Text(
          (user?.username ?? 'ALCHEMIST').toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            color: profileColor,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: profileColor.withOpacity(0.8), blurRadius: 20),
            ],
          ),
        ),
        const SizedBox(height: 10),
        
        // Joined Date
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.white60, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    '${_t('joined').toUpperCase()} ${_formatJoinDate(user?.createdAt).toUpperCase()}',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white60, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w700, 
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard('$_followingCount', _t('following'), 'assets/following.png', _yellow),
          const SizedBox(width: 12),
          _statCard('$_friendCount', _t('friends'), 'assets/friends.png', _cyan),
          const SizedBox(width: 12),
          _statCard(
            '$_followerCount', 
            _t('followers'), 
            'assets/followers.png', 
            _purple,
            onTap: _isSelf ? null : _toggleFollow,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, String assetPath, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Image.asset(assetPath, width: 32, height: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, 
                  fontSize: 22, 
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white.withOpacity(0.3), 
                  fontSize: 10, 
                  fontWeight: FontWeight.w400, 
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (_isSelf || widget.userId == null) return;
    
    setState(() => _isLoading = true);
    final success = await ApiService().toggleFollow(widget.userId!);
    if (success) {
      await _loadData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabItem(_t('history'), 0),
          _tabItem(_t('achievements'), 1),
          if (_isSelf) _tabItem(_t('settings'), 2),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? _cyan : Colors.white24,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(AppUser? user) {
    switch (_selectedTab) {
      case 0: return _buildHistoryTab();
      case 1: return _buildAchievementsTab(user);
      case 2: return _buildSettingsTab();
      default: return const SizedBox();
    }
  }

  // ─── HISTORY TAB ───
  Widget _buildHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('recent_read'),
              style: TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.w500, 
                letterSpacing: 1.0,
              ),
            ),
            Icon(Icons.filter_list, color: Colors.white.withOpacity(0.4), size: 20),
          ],
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: _cyan))
        else if (_readingHistory.isEmpty)
          _buildEmptyHistory()
        else
          ..._readingHistory.map((h) {
            final isCompleted = h['completed_at'] != null;
            // Handle both flat and nested response structures
            final article = h['article'];
            final title = (article != null) 
                ? (article['title'] ?? _t('unknown_art')) 
                : (h['title'] ?? _t('unknown_art'));
            
            final articleId = (article != null) ? article['id'] : h['article_id'];
            
            return _historyCard(
              title,
              isCompleted ? _t('completed') : _t('reading'),
              _formatRelativeTime(h['last_read_at'] ?? h['updated_at']),
              isCompleted ? _cyan : _purple,
              onTap: articleId != null ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ArticleViewScreen(articleId: articleId)),
                ).then((_) => _loadData());
              } : null,
            );
          }),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.menu_book_outlined, color: Colors.white.withOpacity(0.1), size: 64),
            const SizedBox(height: 16),
            Text('No history found', style: TextStyle(color: Colors.white.withOpacity(0.2))),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(String title, String status, String time, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Thumbnail
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/read_article1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Timestamp
            Text(
              'Last read... $time',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACHIEVEMENTS TAB ───
  Widget _buildAchievementsTab(AppUser? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OVERVIEW HEADER
        Text(
          'OVERVIEW',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 24),
        
        // OVERVIEW GRID (Row based for control)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _overviewItem('assets/streak.png', '${user?.streakCount ?? 0} DAYS', _lime),
                  const SizedBox(height: 24),
                  _overviewItem('assets/xp.png', '${user?.totalXp ?? 0} XP', _cyan),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  _overviewItem('assets/scroll.png', 'ARTICLES READ', Colors.white60),
                  const SizedBox(height: 24),
                  _overviewItem(
                    'assets/chapter.png', 
                    'LEVEL ${user?.quizLevel ?? 1} : ${user?.currentLevelName?.toUpperCase() ?? 'NOVICE'}', 
                    Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  _overviewItem('assets/streak.png', 'BEST : ${user?.maxStreak ?? 0}', _lime),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 48),
        
        // ACHIEVEMENTS RANK HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACHIEVEMENTS RANK',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankHierarchyScreen()),
                );
              },
              child: Text(
                'MORE',
                style: GoogleFonts.spaceGrotesk(
                  color: _cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // HORIZONTAL BADGES
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: _ranks.where((r) => (r['xp_threshold'] ?? 0) <= (user?.totalXp ?? 0)).map((r) {
              return _badgeItem(r['name'] ?? 'WE', r['icon_url']);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _overviewItem(String assetPath, String text, Color color, {bool isMultiLine = false}) {
    return Row(
      children: [
        Image.asset(assetPath, width: 28, height: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _badgeItem(String label, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (imageUrl != null && imageUrl.startsWith('http'))
                    ? NetworkImage(imageUrl) as ImageProvider
                    : const AssetImage('assets/rank_stair.png'), // Fallback hexagon shape if available
                fit: BoxFit.contain,
              ),
              boxShadow: [
                BoxShadow(
                  color: _yellow.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: (imageUrl == null || !imageUrl.startsWith('http')) 
                ? const Center(child: Icon(Icons.hexagon_outlined, color: _yellow, size: 40))
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            label.split(' ').map((e) => e[0]).join().toUpperCase(), // Shorten to initials like WE, EE
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementCard(String title, String subtitle, IconData icon, Color iconColor, {String? imageUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.startsWith('assets/')
                        ? Image.asset(imageUrl, fit: BoxFit.contain)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(icon, color: iconColor, size: 28),
                          ),
                  )
                : Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16, 
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4), 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SETTINGS TAB ───
  Widget _buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('settings'),
              style: TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.0,
              ),
            ),
            Icon(Icons.filter_list, color: Colors.white.withOpacity(0.4), size: 20),
          ],
        ),
        const SizedBox(height: 20),
        
        // Font Size
        _settingsTile(
          _t('font_size'),
          _getFontSizeLabel(),
          'assets/font_size.png',
          onTap: _showFontSizePicker,
        ),
        
        // Language
        _settingsTile(
          _t('language'),
          SettingsService().language,
          'assets/language.png',
          onTap: _showLanguagePicker,
        ),
        
        // About Alchemist
        _settingsTile(
          'About Alchemist',
          'Ver. 2.0.1',
          'assets/about.png',
          onTap: _showAboutPage,
        ),
        
        const SizedBox(height: 30),
        
        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _handleLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF330000).withOpacity(0.4),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Color(0xFF660000), width: 2),
              ),
              elevation: 0,
            ),
            child: Text(
              _t('logout').toUpperCase(), 
              style: const TextStyle(
                fontWeight: FontWeight.w600, 
                letterSpacing: 2.0,
                fontSize: 14,
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsTile(String title, String value, String assetPath, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2426),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value, 
              style: TextStyle(
                color: Colors.white.withOpacity(0.4), 
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ───

  String _getFontSizeLabel() {
    final scale = SettingsService().fontSizeMultiplier;
    if (scale < 0.9) return _t('small');
    if (scale > 1.1) return _t('large');
    return _t('medium');
  }

  void _showFontSizePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t('font_size'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
                return Slider(
                  value: SettingsService().fontSizeMultiplier,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  activeColor: _cyan,
                  onChanged: (val) {
                    setModalState(() {});
                    SettingsService().fontSizeMultiplier = val;
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t('language'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('English', style: TextStyle(color: Colors.white)),
                onTap: () {
                  SettingsService().language = 'English';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Indonesia', style: TextStyle(color: Colors.white)),
                onTap: () {
                  SettingsService().language = 'Indonesia';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    final colors = [
      {'name': 'Default (Charcoal)', 'hex': null},
      {'name': 'Crimson', 'hex': '#540e15'},
      {'name': 'Forest', 'hex': '#143d22'},
      {'name': 'Ocean', 'hex': '#112a4f'},
      {'name': 'Amethyst', 'hex': '#3c1352'},
      {'name': 'Amber', 'hex': '#4d3309'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Profile Color', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...colors.map((c) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c['hex'] != null ? Color(int.parse("0xFF${c['hex'].toString().replaceAll('#', '')}")) : const Color(0xFF0B1214),
                    radius: 12,
                  ),
                  title: Text(c['name'] as String, style: const TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    await ApiService().updateProfileBgColor(c['hex'] as String?);
                    await _loadData();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Scaffold(
          backgroundColor: _bgApp,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(_t('about'), style: const TextStyle(color: Colors.white)),
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alchemist Curriculum System',
                  style: TextStyle(color: _cyan, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Alchemist is an educational platform designed to help students master the art of chemistry through interactive labs, engaging articles, and competitive ranks.',
                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 20),
                Text(
                  'Our mission is to make science learning fun and accessible to everyone. With virtual experiments and a gamified curriculum, students can learn at their own pace while competing with friends.',
                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 40),
                Text('Version: 2.0.1', style: TextStyle(color: Colors.white24)),
                Text('Developed by Alchemist Team', style: TextStyle(color: Colors.white24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    ApiService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  String _formatJoinDate(String? createdAt) {
    if (createdAt == null) return 'January 9, 2026';
    try {
      final dt = DateTime.parse(createdAt);
      const monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      const monthsId = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      final months = SettingsService().language == 'Indonesia' ? monthsId : monthsEn;
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return 'January 9, 2026';
    }
  }

  String _formatRelativeTime(String? timestamp) {
    final isId = SettingsService().language == 'Indonesia';
    if (timestamp == null) return isId ? 'Hari ini' : 'Today';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inMinutes < 60) return isId ? '${diff.inMinutes} mnt lalu' : '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return isId ? '${diff.inHours} jam lalu' : '${diff.inHours} hours ago';
      if (diff.inDays == 1) return isId ? 'Kemarin' : 'Yesterday';
      if (diff.inDays < 7) return isId ? '${diff.inDays} hari lalu' : '${diff.inDays} days ago';
      
      const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const monthsId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final months = isId ? monthsId : monthsEn;
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return isId ? 'Baru saja' : 'Recently';
    }
  }
}
