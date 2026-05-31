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
    _fetchRanks();
  }

  Future<void> _handleSelect(int rankId) async {
    // Find the rank to check threshold
    final rank = _ranks.firstWhere((r) => r['id'] == rankId, orElse: () => null);
    if (rank != null) {
      final threshold = (rank['xp_threshold'] ?? rank['min_xp'] ?? 0) as int;
      if (_userXp < threshold) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('XP tidak cukup! Butuh $threshold XP, kamu punya $_userXp XP.'),
              backgroundColor: Colors.redAccent,
            )
          );
        }
        return;
      }
    }
    final success = await ApiService().selectRank(rankId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rank badge equipped!'), backgroundColor: Color(0xFF00FBFF))
      );
      // Refresh user data (if possible) or just UI
      setState(() {});
    }
  }

  Future<void> _fetchRanks() async {
    setState(() => _isLoading = true);
    final results = await Future.wait<dynamic>([
      ApiService().getRanks(),
      ApiService().getCurrentUser(),
    ]);
    if (mounted) {
      setState(() {
        _ranks = results[0] as List;
        _userXp = (results[1] as AppUser?)?.totalXp ?? 0;
        _isLoading = false;
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
        child: Column(
          children: [
            // Custom Header matching screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: _cyan.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: _cyan, size: 24),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'ALCHEMIST RANKS',
                        style: TextStyle(
                          color: _cyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (isAdmin)
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankEditorScreen())),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    )
                  else
                    const SizedBox(width: 45),
                  const SizedBox(width: 10),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _cyan))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 40,
                        childAspectRatio: 0.5,
                      ),
                      itemCount: _ranks.length,
                      itemBuilder: (context, index) {
                        return _rankGridItem(_ranks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankGridItem(dynamic rank) {
    final threshold = (rank['xp_threshold'] ?? rank['min_xp'] ?? 0) as int;
    final isUnlocked = _userXp >= threshold;
    final user = ApiService().currentUser;
    final isSelected = user?.selectedRankId == rank['id'];
    
    return GestureDetector(
      onTap: () => _handleSelect(rank['id']),
      child: Column(
        children: [
          // Rank Icon (Hexagon Gold)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                child: (rank['icon_url'] != null && rank['icon_url'].startsWith('http'))
                    ? Image.network(
                        rank['icon_url'],
                        fit: BoxFit.contain,
                        color: isUnlocked ? null : Colors.white.withOpacity(0.1),
                        colorBlendMode: isUnlocked ? null : BlendMode.modulate,
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.hexagon, color: const Color(0xFFC5A059).withOpacity(0.8), size: 70),
                          Icon(Icons.hexagon_outlined, color: const Color(0xFFFFD700), size: 72),
                          const Icon(Icons.science_outlined, color: Color(0xFF4A3411), size: 32),
                        ],
                      ),
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: _cyan, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.black, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Rank Name
          Text(
            rank['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white24,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Chapter Info
          Text(
            'CHAPTER ${rank['chapter'] ?? '1'}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white60 : Colors.white10,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          // Threshold
          Text(
            'Threshold : ${threshold} XP',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white38 : Colors.white10,
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}