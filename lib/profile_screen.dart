import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
import 'services/api_service.dart';
import 'welcome_screen.dart';
import 'add_friends_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  static const _cyan = Color(0xFF00FBFF);
  static const _lime = Color(0xFFCCFF00);
  static const _cardBg = Color(0xFF111718);

  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;

    return BackgroundWrapper(
      showGrid: true,
      removeSafeAreaPadding: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ─── PROFILE HEADER CARD ───
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (user?.username ?? 'ALCHEMIST').toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: _cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          _getRoleTitle(user?.totalXp ?? 0),
                          style: const TextStyle(color: _cyan, fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statLabel('XP', '${user?.totalXp ?? 0}'),
                          _dividerV(),
                          _statLabel('STREAK', '${user?.currentStreak ?? 0} Days'),
                          _dividerV(),
                          _statLabel('JOINED', _formatJoinDate(user?.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Friends Button
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFriendsScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: _cyan.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, color: _cyan, size: 18),
                              SizedBox(width: 8),
                              Text('Manage Friends', style: TextStyle(color: _cyan, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _cyan, width: 3),
                    boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: _cardBg,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alchemist'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── TABS ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    _tabNavItem('Awards', 0),
                    _tabNavItem('History', 1),
                    _tabNavItem('Settings', 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSelectedContent(user?.totalXp ?? 0),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _getRoleTitle(int xp) {
    if (xp >= 1000) return 'Grand Alchemist';
    if (xp >= 500) return 'Master Alchemist';
    if (xp >= 200) return 'Senior Researcher';
    if (xp >= 100) return 'Junior Researcher';
    if (xp >= 50) return 'Apprentice';
    return 'Novice Alchemist';
  }

  String _formatJoinDate(String? createdAt) {
    if (createdAt == null) return '2025';
    try {
      final dt = DateTime.parse(createdAt);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt.substring(0, 7);
    }
  }

  Widget _buildSelectedContent(int userXp) {
    switch (_selectedTab) {
      case 0: return _buildAchievementsContent(userXp);
      case 1: return _buildHistoryContent();
      case 2: return _buildSettingsContent();
      default: return _buildAchievementsContent(userXp);
    }
  }

  // ─── ACHIEVEMENTS TAB ───
  Widget _buildAchievementsContent(int userXp) {
    final achievements = [
      {'icon': '⚗️', 'name': 'First Reaction', 'desc': 'Complete your first lab reaction', 'xpRequired': 10, 'unlocked': userXp >= 10},
      {'icon': '🔬', 'name': '50 XP Club', 'desc': 'Reach 50 total XP', 'xpRequired': 50, 'unlocked': userXp >= 50},
      {'icon': '🧪', 'name': '100 XP Researcher', 'desc': 'Reach 100 total XP', 'xpRequired': 100, 'unlocked': userXp >= 100},
      {'icon': '🏆', 'name': '200 XP Senior', 'desc': 'Reach 200 total XP', 'xpRequired': 200, 'unlocked': userXp >= 200},
      {'icon': '⭐', 'name': '500 XP Master', 'desc': 'Reach 500 total XP', 'xpRequired': 500, 'unlocked': userXp >= 500},
      {'icon': '👑', 'name': '1000 XP Grand', 'desc': 'Reach 1000 total XP', 'xpRequired': 1000, 'unlocked': userXp >= 1000},
      {'icon': '🔥', 'name': 'Streak Keeper', 'desc': 'Maintain a 3-day streak', 'xpRequired': 0, 'unlocked': (ApiService().currentUser?.currentStreak ?? 0) >= 3},
      {'icon': '💎', 'name': 'Precipitation Pro', 'desc': 'React AgNO₃ + NaCl in virtual lab', 'xpRequired': 0, 'unlocked': userXp >= 20},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ACHIEVEMENTS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            Text('${achievements.where((a) => a['unlocked'] == true).length}/${achievements.length}',
              style: const TextStyle(color: _lime, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        ...achievements.map((a) => _achievementTile(
          a['icon'] as String,
          a['name'] as String,
          a['desc'] as String,
          a['unlocked'] as bool,
        )),
      ],
    );
  }

  Widget _achievementTile(String icon, String name, String desc, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? _lime.withValues(alpha: 0.05) : _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? _lime.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: unlocked ? _lime.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: TextStyle(fontSize: 24, color: unlocked ? null : const Color(0xFF333333)))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: unlocked ? Colors.white : Colors.white24, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(desc, style: TextStyle(color: unlocked ? Colors.white38 : Colors.white12, fontSize: 11)),
          ])),
          Icon(unlocked ? Icons.check_circle : Icons.lock_outline, color: unlocked ? _lime : Colors.white12, size: 22),
        ],
      ),
    );
  }

  // ─── HISTORY TAB ───
  Widget _buildHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT ACTIVITY', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        const SizedBox(height: 16),
        ...List.generate(3, (i) => _historyItem()),
      ],
    );
  }

  Widget _historyItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_stories_outlined, color: _cyan, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('The Alchemy of AI', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            Text('2 hours ago', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white10),
        ],
      ),
    );
  }

  // ─── SETTINGS TAB ───
  Widget _buildSettingsContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
          child: Column(
            children: [
              _settingsItem(Icons.person_outline, 'Username', ApiService().currentUser?.username ?? '-', true),
              _divider(),
              _settingsItem(Icons.email_outlined, 'Email', ApiService().currentUser?.email ?? '-', false),
              _divider(),
              _settingsItem(Icons.language, 'Language', 'Indonesia', true),
              _divider(),
              _settingsItem(Icons.info_outline, 'App Version', 'v2.0.1', false),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              ApiService().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _cardBg,
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.redAccent, width: 1)),
              elevation: 0,
            ),
            child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Divider(color: Colors.white.withValues(alpha: 0.05), height: 32);
  Widget _dividerV() => Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08));

  Widget _settingsItem(IconData icon, String title, String value, bool showArrow) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))),
        Flexible(child: Text(value, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12), overflow: TextOverflow.ellipsis)),
        if (showArrow) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.chevron_right, color: Colors.white24, size: 20)),
      ],
    );
  }

  Widget _statLabel(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _tabNavItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? _cyan : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white24, fontWeight: FontWeight.w900, fontSize: 13))),
        ),
      ),
    );
  }
}
