import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'rank_screen.dart';
import 'profile_screen.dart';
import 'more_menu_screen.dart';
import 'daily_task_management_screen.dart';
import 'daily_task_form_sheet.dart';
import 'services/api_service.dart';
import 'models/user_model.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    QuizScreen(),
    RankScreen(),
    ProfileScreen(),
    const _MoreTabNavigator(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const navBgColor = Color(0xFF0B1214);

    final user = ApiService().currentUser;
    final isAdmin = user?.role == UserRole.admin;
    final showFab = _selectedIndex == 0 && isAdmin;

    return Scaffold(
      backgroundColor: navBgColor,
      floatingActionButton: showFab ? _buildAdminFAB(context) : null,
      // Persistent bottom nav bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home_rounded, label: 'HOME', index: 0, color: primaryCyan),
              _navItem(icon: Icons.biotech_rounded, label: 'QUIZ', index: 1, color: primaryCyan),
              _navItem(icon: Icons.bar_chart_rounded, label: 'RANK', index: 2, color: primaryCyan),
              _navItem(icon: Icons.person_rounded, label: 'PROFILE', index: 3, color: primaryCyan),
              _navItem(icon: Icons.more_horiz_rounded, label: 'MORE', index: 4, color: primaryCyan),
            ],
          ),
        ),
      ),
      // IndexedStack keeps all pages alive
      body: IndexedStack(
        index: _selectedIndex > 3 ? 0 : _selectedIndex,
        children: _pages,
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index, required Color color}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 4) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.6),
            builder: (context) => const MoreMenuPopup(),
          );
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Container(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected) 
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                Icon(
                  icon,
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
                  size: 28,
                ),
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

  Widget _buildAdminFAB(BuildContext context) {
    const cyan = Color(0xFF00FBFF);
    const card = Color(0xFF111718);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const DailyTaskManagementScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cyan.withValues(alpha: 0.25)),
            ),
            child: const Text(
              'Manage Tasks',
              style: TextStyle(
                  color: cyan, fontSize: 11, fontWeight: FontWeight.w700),
            ),
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

// Placeholder untuk halaman yang belum dibuat
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MoreTabNavigator extends StatelessWidget {
  const _MoreTabNavigator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // No longer used as a page
  }
}
