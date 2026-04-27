import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
import 'services/mock_auth_service.dart';
import 'login_screen.dart';
import 'admin/lab_curricula_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00FBFF);
    const cardBg = Color(0xFF111718);

    return BackgroundWrapper(
      showGrid: true,
      removeSafeAreaPadding: true,
      child: Column(
        children: [
          // --- ADMIN HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: primaryCyan, size: 30),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN DASHBOARD',
                      style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                    Text(
                      'ALCHEMIST CENTRAL CONTROL',
                      style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () {
                    MockAuthService().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(24),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _adminCard(Icons.science_outlined, 'MANAGE\nQUIZZES', '12 Active', onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LabCurriculaScreen()),
                  );
                }),
                _adminCard(Icons.article_outlined, 'MANAGE\nARTICLES', '45 Published'),
                _adminCard(Icons.people_outline, 'USER\nMODERATION', '1.2k Total'),
                _adminCard(Icons.analytics_outlined, 'SYSTEM\nANALYTICS', 'Running'),
                _adminCard(Icons.notifications_active_outlined, 'PUSH\nNOTIFICATIONS', 'History'),
                _adminCard(Icons.settings_suggest_outlined, 'APP\nSETTINGS', 'Config'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(IconData icon, String title, String status, {VoidCallback? onTap}) {
    const primaryCyan = Color(0xFF00FBFF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111718),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: primaryCyan, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
