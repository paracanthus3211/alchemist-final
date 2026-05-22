import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'rank_screen.dart';
import 'profile_screen.dart';
import 'services/settings_service.dart';
import 'more_menu_screen.dart';
import 'daily_task_management_screen.dart';
import 'daily_task_form_sheet.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';
import 'articles_screen.dart';
import 'virtual_lab_screen.dart';
import 'add_friends_screen.dart';
import 'bookmark_screen.dart';
import 'intro_screen.dart';

// ─── Breakpoint: <= 720px → mobile bottom nav, > 720px → desktop sidebar ───
const _kDesktopBreakpoint = 720.0;

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;
  bool _isMoreMenuVisible = false;
  int _bookmarkCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    SettingsService().addListener(_rebuild);
    ApiService().addListener(_rebuild);
    _fetchBookmarkCount();
  }

  void _fetchBookmarkCount() async {
    try {
      final bookmarks = await ApiService().getBookmarks();
      if (mounted) {
        setState(() {
          _bookmarkCount = bookmarks.length;
        });
      }
    } catch (_) {}
  }

  Widget _buildBookmarkIcon(int count, double size) {
    final hasItems = count > 0;
    final Color ribbonColor = hasItems ? const Color(0xFF2B66C5) : Colors.white30;

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.bookmark_rounded,
            color: ribbonColor,
            size: size + 4,
          ),
          if (hasItems)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SettingsService().removeListener(_rebuild);
    ApiService().removeListener(_rebuild);
    super.dispose();
  }

  String _t(String key) => SettingsService().t(key);

  final List<Widget> _pages = const [
    HomeScreen(),
    QuizScreen(),
    RankScreen(),
    ProfileScreen(),
    _MoreTabNavigator(),
  ];

  void _onNavTap(int index) {
    if (index == 4) {
      setState(() => _isMoreMenuVisible = !_isMoreMenuVisible);
      if (_isMoreMenuVisible) {
        _fetchBookmarkCount();
      }
    } else {
      setState(() {
        _selectedIndex = index;
        _isMoreMenuVisible = false;
      });
    }
  }

  // ─── Nav items data ───────────────────────────────────────────
  List<_NavItemData> get _navItems => [
    _NavItemData(icon: Icons.home_rounded,       assetPath: 'assets/home_logo.png', label: _t('home'),    index: 0),
    _NavItemData(icon: Icons.biotech_rounded,    assetPath: 'assets/quiz_logo.png', label: _t('quiz'),    index: 1),
    _NavItemData(icon: Icons.bar_chart_rounded,  assetPath: 'assets/rank_logo.png', label: _t('rank'),    index: 2),
    _NavItemData(icon: Icons.person_rounded,     assetPath: null,                   label: _t('profile'), index: 3),
    _NavItemData(icon: Icons.more_horiz_rounded, assetPath: 'assets/more.png',      label: _t('more'),    index: 4),
  ];

  // ─── More-menu extra items ─────────────────────────────────────
  List<_MoreItemData> get _moreItems => [
    _MoreItemData(
      icon: Icons.library_books_rounded,
      assetPath: 'assets/library_logo.png',
      label: _t('recent_read'),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => ArticlesScreen()));
        _fetchBookmarkCount();
      },
    ),
    _MoreItemData(
      icon: Icons.science_rounded,
      assetPath: 'assets/logo.png',
      label: 'Virtual Lab',
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => VirtualLabScreen()));
        _fetchBookmarkCount();
      },
    ),
    _MoreItemData(
      icon: Icons.group_rounded,
      assetPath: 'assets/add_friend.png',
      label: 'Friends',
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => AddFriendsScreen()));
        _fetchBookmarkCount();
      },
    ),
    _MoreItemData(
      icon: Icons.bookmark_rounded,
      assetPath: 'assets/scroll.png',
      label: 'Bookmark',
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarkScreen()));
        _fetchBookmarkCount();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
        return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT — left sidebar + content
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    const bgColor    = Color(0xFF080D0E);
    const sidebarBg  = Color(0xFF0B1416);
    const primaryCyan = Color(0xFF00FBFF);
    final user = ApiService().currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: (_selectedIndex == 0 && isAdmin) ? _buildAdminFAB(context) : null,
      body: Row(
        children: [
          // ── SIDEBAR ──────────────────────────────────────────
          Container(
            width: 240,
            color: sidebarBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'ALCHEMIST',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),

                // User info
                _SidebarUserTile(user: user),

                const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 8),

                // Nav items (main)
                ..._navItems.where((e) => e.index < 4).map((e) =>
                  _SidebarNavItem(
                    icon: e.icon,
                    assetPath: e.assetPath,
                    label: e.label,
                    isSelected: _selectedIndex == e.index,
                    onTap: () => _onNavTap(e.index),
                    accentColor: primaryCyan,
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 8),

                // More items in sidebar
                ..._moreItems.map((e) =>
                  _SidebarNavItem(
                    icon: e.icon,
                    assetPath: e.assetPath,
                    label: e.label,
                    isSelected: false,
                    onTap: e.onTap,
                    accentColor: primaryCyan,
                    badgeCount: e.assetPath == 'assets/scroll.png' ? _bookmarkCount : null,
                  ),
                ),

                const Spacer(),

                // Logout
                const Divider(color: Colors.white10, height: 1),
                _SidebarLogoutButton(),
              ],
            ),
          ),

          // ── CONTENT ──────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _selectedIndex > 3 ? 0 : _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — bottom nav bar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    const primaryCyan = Color(0xFF00FBFF);
    const navBgColor  = Color(0xFF0B1214);
    final user   = ApiService().currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: navBgColor,
      floatingActionButton: (_selectedIndex == 0 && isAdmin) ? _buildAdminFAB(context) : null,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Secondary More Menu
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isMoreMenuVisible ? 70 : 0,
            decoration: BoxDecoration(
              color: navBgColor,
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _moreItems.map((e) => _moreNavItem(
                    icon: e.icon,
                    assetPath: e.assetPath,
                    onTap: e.onTap,
                  )).toList(),
                ),
              ),
            ),
          ),
          // Bottom Nav Bar
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: navBgColor,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.map((e) => _navItem(
                  icon: e.icon,
                  assetPath: e.assetPath,
                  label: e.label,
                  index: e.index,
                  color: primaryCyan,
                )).toList(),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex > 3 ? 0 : _selectedIndex,
        children: _pages,
      ),
    );
  }

  // ─── Shared bottom-nav widgets ─────────────────────────────────
  Widget _navItem({required IconData icon, String? assetPath, required String label, required int index, required Color color}) {
    final isSelected = _selectedIndex == index;

    Widget iconWidget;
    if (assetPath != null) {
      // Use original PNG colors — dim when inactive via Opacity
      iconWidget = Opacity(
        opacity: isSelected ? 1.0 : 0.35,
        child: Image.asset(
          assetPath,
          width: 28, height: 28,
          errorBuilder: (_, __, ___) => Icon(
            icon,
            color: isSelected ? color : Colors.white38,
            size: 28,
          ),
        ),
      );
    } else {
      iconWidget = Icon(
        icon,
        color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
        size: 28,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavTap(index),
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 18, spreadRadius: 1,
                      )],
                    ),
                  ),
                iconWidget,
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreNavItem({required IconData icon, String? assetPath, required VoidCallback onTap}) {
    final bool isOctopus = assetPath == 'assets/logo.png';
    final bool isBookmark = assetPath == 'assets/scroll.png';
    final double size = isOctopus ? 44.0 : 28.0;

    Widget iconWidget;
    if (isBookmark) {
      iconWidget = _buildBookmarkIcon(_bookmarkCount, size);
    } else if (assetPath != null) {
      iconWidget = Image.asset(
        assetPath,
        width: size, height: size,
        errorBuilder: (_, __, ___) => Icon(icon, color: Colors.white70, size: size),
      );
    } else {
      iconWidget = Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: size);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 65,
        child: Center(child: iconWidget),
      ),
    );
  }

  // ─── Admin FAB ─────────────────────────────────────────────────
  Widget _buildAdminFAB(BuildContext context) {
    const cyan = Color(0xFF00FBFF);
    const card = Color(0xFF111718);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DailyTaskManagementScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cyan.withValues(alpha: 0.25)),
            ),
            child: Text(_t('manage_tasks'),
              style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
        FloatingActionButton(
          heroTag: 'adminFAB',
          onPressed: () async {
            await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const DailyTaskFormSheet(),
            );
          },
          backgroundColor: cyan,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Data models for nav items
// ═══════════════════════════════════════════════════════════════════
class _NavItemData {
  final IconData icon;
  final String? assetPath;
  final String label;
  final int index;
  const _NavItemData({required this.icon, this.assetPath, required this.label, required this.index});
}

class _MoreItemData {
  final IconData icon;
  final String? assetPath;
  final String label;
  final VoidCallback onTap;
  const _MoreItemData({required this.icon, this.assetPath, required this.label, required this.onTap});
}

// ═══════════════════════════════════════════════════════════════════
// Sidebar sub-widgets
// ═══════════════════════════════════════════════════════════════════
class _SidebarUserTile extends StatelessWidget {
  final AppUser? user;
  const _SidebarUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final initial = (user?.username ?? 'U').substring(0, 1).toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E3030),
              border: Border.all(color: Colors.white12),
            ),
            child: user?.avatarUrl != null
                ? ClipOval(child: Image.network(
                    ApiService.getAvatarUrl(user!.avatarUrl, fallbackSeed: user!.username),
                    key: ValueKey(ApiService.getAvatarUrl(user!.avatarUrl, fallbackSeed: user!.username)),
                    fit: BoxFit.cover,
                  ))
                : Center(child: Text(initial,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? 'User',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.currentLevelName ?? 'Novice',
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String? assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final int? badgeCount;

  const _SidebarNavItem({
    required this.icon,
    this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (assetPath == 'assets/scroll.png') {
      final hasItems = (badgeCount ?? 0) > 0;
      final Color ribbonColor = hasItems ? const Color(0xFF2B66C5) : Colors.white30;
      iconWidget = SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.bookmark_rounded,
              color: ribbonColor,
              size: 28,
            ),
            if (hasItems)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (assetPath != null) {
      iconWidget = Opacity(
        opacity: isSelected ? 1.0 : 0.35,
        child: Image.asset(
          assetPath!,
          width: 32, height: 32,
          errorBuilder: (_, __, ___) => Icon(
            icon, size: 28,
            color: isSelected ? accentColor : Colors.white38,
          ),
        ),
      );
    } else {
      iconWidget = Icon(icon, size: 20,
          color: isSelected ? accentColor : Colors.white38);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isSelected ? accentColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : Colors.white54,
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarLogoutButton extends StatelessWidget {
  const _SidebarLogoutButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () {
            ApiService().logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const IntroScreen()),
              (route) => false,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
            ),
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                SizedBox(width: 10),
                Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12, fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── More tab placeholder ──────────────────────────────────────────
class _MoreTabNavigator extends StatelessWidget {
  const _MoreTabNavigator();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
