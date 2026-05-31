import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';

class RankSelectorScreen extends StatefulWidget {
  const RankSelectorScreen({super.key});

  @override
  State<RankSelectorScreen> createState() => _RankSelectorScreenState();
}

class _RankSelectorScreenState extends State<RankSelectorScreen> {
  List<dynamic> _ranks = [];
  bool _isLoading = true;
  int? _selectedRankId;

  static const Color _cyan = Color(0xFF00FBFF);
  static const Color _bgDark = Color(0xFF0D1213);
  static const Color _cardBg = Color(0xFF161D1E);

  @override
  void initState() {
    super.initState();
    _fetchRanks();
  }

  Future<void> _fetchRanks() async {
    try {
      final ranks = await ApiService().getRanks();
      final user = ApiService().currentUser;
      if (mounted) {
        setState(() {
          _ranks = ranks;
          _selectedRankId = user?.selectedRankId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectRank(int rankId) async {
    setState(() => _selectedRankId = rankId);
    
    final success = await ApiService().selectRank(rankId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rank selected successfully!'),
          backgroundColor: _cyan,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select rank'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      showGrid: false,
      removeSafeAreaPadding: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.arrow_back, color: _cyan, size: 20),
            ),
          ),
          title: Text(
            'ALCHEMIST BANKS',
            style: GoogleFonts.spaceGrotesk(
              color: _cyan,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _cyan),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Grid of ranks
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 40,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _ranks.length,
                      itemBuilder: (context, index) {
                        final rank = _ranks[index];
                        final isSelected = _selectedRankId == rank['id'];
                        return _buildRankCard(rank, isSelected);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRankCard(dynamic rank, bool isSelected) {
    final rankColor = _getRankColor(rank['name']);
    
    // Try both field names: rank_icon_url and icon_url
    final iconUrl = rank['rank_icon_url'] ?? rank['icon_url'];
    
    return GestureDetector(
      onTap: () => _selectRank(rank['id']),
      child: Column(
        children: [
          // Rank Badge Container
          Stack(
            alignment: Alignment.topRight,
            children: [
              // Badge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: iconUrl != null
                    ? Image.network(
                        iconUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildDefaultBadge(rankColor),
                      )
                    : _buildDefaultBadge(rankColor),
              ),
              
              // Checkmark for selected
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan,
                    boxShadow: [
                      BoxShadow(
                        color: _cyan.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rank Name
          Text(
            rank['name'] ?? 'Unknown',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Chapter
          Text(
            'CHAPTER ${rank['chapter'] ?? '-'}',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          
          // Threshold XP
          Text(
            'Threshold : ${rank['xp_threshold'] ?? 0} XP',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBadge(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shield,
          color: Colors.white.withValues(alpha: 0.3),
          size: 50,
        ),
      ),
    );
  }

  Color _getRankColor(String? name) {
    if (name == null) return _cyan;
    final n = name.toLowerCase();
    
    // Map rank names to colors based on website design
    if (n.contains('novice')) return const Color(0xFFD4AF37); // Gold
    if (n.contains('adept')) return const Color(0xFFFF6B35); // Orange/Red
    if (n.contains('master')) return const Color(0xFF00FBFF); // Cyan
    if (n.contains('grand')) return const Color(0xFFB8F400); // Lime
    if (n.contains('sage')) return const Color(0xFFd896ff); // Purple
    
    return _cyan;
  }
}
