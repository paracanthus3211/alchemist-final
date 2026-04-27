import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
import 'services/api_service.dart';
import 'rank_editor_screen.dart';
import 'models/user_model.dart';

class RankHierarchyScreen extends StatefulWidget {
  const RankHierarchyScreen({super.key});

  @override
  State<RankHierarchyScreen> createState() => _RankHierarchyScreenState();
}

class _RankHierarchyScreenState extends State<RankHierarchyScreen> {
  List<dynamic> _ranks = [];
  bool _isLoading = true;
  int _userXp = 0;

  static const _cyan = Color(0xFF00FBFF);
  static const _cardBg = Color(0xFF161D1E);
  static const _bg = Color(0xFF0D1213);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService().getRanks(),
      Future.value(ApiService().currentUser),
    ]);
    if (mounted) {
      setState(() {
        _ranks = results[0] as List;
        _userXp = (results[1] as AppUser?)?.totalXp ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.menu, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text('ALCHEMIST RANKS', style: TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const Spacer(),
                  if (user?.avatarUrl != null)
                    CircleAvatar(radius: 18, backgroundImage: NetworkImage(user!.avatarUrl!))
                  else
                    const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: _cyan.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back, color: _cyan, size: 20),
                          ),
                        ),
                        const Spacer(),
                        if (isAdmin)
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankEditorScreen())),
                            child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Full Rank Hierarchy', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Text(
                      'The Rank page functions to display user rankings based on the XP they have collected, motivate users to study harder, and provide recognition for their achievements.',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 48),

                    _isLoading
                      ? const Center(child: CircularProgressIndicator(color: _cyan))
                      : Column(
                          children: _ranks.map((rank) => _rankHierarchyCard(rank)).toList(),
                        ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankHierarchyCard(dynamic rank) {
    final threshold = (rank['xp_threshold'] ?? rank['min_xp'] ?? 0) as int;
    final isUnlocked = _userXp >= threshold;
    final color = _getRankColor(rank['name']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? color.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Large Sigil Icon
          Container(
            width: 80, height: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_getRankIcon(rank['name']), color: isUnlocked ? color : Colors.white12, size: 48),
          ),
          const SizedBox(width: 24),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rank['name'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                Text(_getRankSubtitle(rank['name']), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Threshold
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('THRESHOLD', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              Text('$threshold XP', style: TextStyle(color: isUnlocked ? Colors.white : Colors.white24, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('grand')) return const Color(0xFFD4AF37);
    if (n.contains('adept')) return const Color(0xFF00FBFF);
    return const Color(0xFFCCFF00);
  }

  IconData _getRankIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('grand')) return Icons.star_rounded;
    if (n.contains('adept')) return Icons.science_rounded;
    return Icons.shield_rounded;
  }

  String _getRankSubtitle(String name) {
    final n = name.toLowerCase();
    if (n.contains('novice')) return 'calon alchemist';
    if (n.contains('apprentice')) return 'pelajar giat';
    if (n.contains('adept')) return 'ahli transmutasi';
    if (n.contains('master')) return 'peneliti utama';
    return 'pencari ilmu';
  }
}
