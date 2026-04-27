import 'package:flutter/material.dart';
import 'widgets/background_wrapper.dart';
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
  String _selectedTime = 'THIS MONTH';
  String _selectedScope = 'GLOBALLY';
  List<dynamic> _users = [];
  List<dynamic> _ranks = [];
  bool _isLoading = true;

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
    final api = ApiService();
    final period = _selectedTime == 'THIS WEEK' ? 'week' : _selectedTime == 'THIS MONTH' ? 'month' : 'all';
    final scope = _selectedScope == 'FRIENDS' ? 'friends' : 'global';
    final results = await Future.wait([
      api.getLeaderboard(period: period, scope: scope),
      api.getRanks(),
    ]);
    if (mounted) {
      setState(() {
        _users = results[0] as List;
        _ranks = results[1] as List;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? get _currentRankData {
    final userXp = ApiService().currentUser?.totalXp ?? 0;
    if (_ranks.isEmpty) return null;
    final qualified = _ranks.where((r) {
      final minXp = (r['xp_threshold'] ?? r['min_xp'] ?? r['xp_required'] ?? 0) as int;
      return minXp <= userXp;
    }).toList();
    if (qualified.isEmpty) return null;
    qualified.sort((a, b) {
      final aXp = (a['xp_threshold'] ?? a['min_xp'] ?? a['xp_required'] ?? 0) as int;
      final bXp = (b['xp_threshold'] ?? b['min_xp'] ?? b['xp_required'] ?? 0) as int;
      return bXp.compareTo(aXp);
    });
    return qualified.first;
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, color: _cyan, size: 24),
                  const SizedBox(width: 8),
                  const Text('PARACANTHUS', style: TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const Spacer(),
                  if (user?.avatarUrl != null)
                    CircleAvatar(radius: 18, backgroundImage: NetworkImage(user!.avatarUrl!))
                  else
                    const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
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
                      const Text('Alchemy Rank', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 24),

                      // Time Filters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _timeFilter('THIS WEEK'),
                          _timeFilter('THIS MONTH'),
                          _timeFilter('ALL TIME'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Scope Filters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _scopeFilter('GLOBALLY'),
                          const SizedBox(width: 24),
                          _scopeFilter('FRIENDS'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Rank Progress Card
                      _buildRankProgressCard(),
                      const SizedBox(height: 40),

                      // Podium
                      if (_users.isNotEmpty) _buildPodium(),
                      const SizedBox(height: 40),

                      // Leaderboard List
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(color: _cyan))
                      else if (_users.length > 3)
                        Column(
                          children: _users.asMap().entries.where((e) => e.key > 2).map((entry) {
                            final u = entry.value;
                            final isMe = u['id'] == user?.id;
                            return _leaderboardTile(entry.key + 1, u, isMe);
                          }).toList(),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? _cyan.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label, style: TextStyle(color: active ? _cyan : Colors.white38, fontSize: 12, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 4),
          if (active) Container(width: 40, height: 2, color: _cyan),
        ],
      ),
    );
  }

  Widget _scopeFilter(String label) {
    final active = _selectedScope == label;
    return GestureDetector(
      onTap: () => setState(() { _selectedScope = label; _fetchData(); }),
      child: Text(label, style: TextStyle(color: active ? _cyan : Colors.white38, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
    );
  }

  Widget _buildRankProgressCard() {
    final user = ApiService().currentUser;
    final rank = _currentRankData;
    final nextRank = _ranks.length > _ranks.indexOf(rank) + 1 ? _ranks[_ranks.indexOf(rank) + 1] : null;
    
    final currentXp = user?.totalXp ?? 0;
    final minXp = (rank?['xp_threshold'] ?? rank?['min_xp'] ?? 0) as int;
    final nextXp = (nextRank?['xp_threshold'] ?? nextRank?['min_xp'] ?? (minXp + 1000)) as int;
    final progress = (currentXp - minXp) / (nextXp - minXp);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RankHierarchyScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: _cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.military_tech, color: _cyan, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rank?['name'] ?? 'Novice Alchemist', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      Text('LEVEL ${((currentXp / 200).floor() + 1)} • AHLI ATOM', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text('$currentXp XP', style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.05),
                color: _cyan,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text('${(currentXp % 200)}/${200} XP MENUJU LEVEL ${((currentXp / 200).floor() + 2)}', 
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumUser(_users.length > 1 ? _users[1] : null, 2, 80),
        const SizedBox(width: 12),
        _podiumUser(_users.isNotEmpty ? _users[0] : null, 1, 110),
        const SizedBox(width: 12),
        _podiumUser(_users.length > 2 ? _users[2] : null, 3, 70),
      ],
    );
  }

  Widget _podiumUser(dynamic user, int rank, double baseHeight) {
    final isFirst = rank == 1;
    final size = isFirst ? 80.0 : 60.0;
    return Column(
      children: [
        if (user != null)
          Stack(
            alignment: Alignment.center,
            children: [
              if (isFirst) Container(width: size + 10, height: size + 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCCFF00))),
              Container(
                width: size, height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                  image: user['avatar_url'] != null ? DecorationImage(image: NetworkImage(user['avatar_url']), fit: BoxFit.cover) : null,
                ),
                child: user['avatar_url'] == null ? const Icon(Icons.person, color: Colors.white24) : null,
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFCCFF00), shape: BoxShape.circle),
                  child: const Icon(Icons.science, color: Colors.black, size: 12),
                ),
              ),
            ],
          )
        else
          SizedBox(width: size, height: size + (isFirst ? 10 : 0)),
        const SizedBox(height: 8),
        Text(user?['username'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
        Text('${user?['xp'] ?? 0} XP', style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          width: 80, height: baseHeight,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
          child: Center(child: Text('$rank', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 32, fontWeight: FontWeight.w900))),
        ),
      ],
    );
  }

  Widget _leaderboardTile(int rank, dynamic user, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? Colors.transparent : _cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? _cyan : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('$rank', style: const TextStyle(color: Colors.white24, fontSize: 16, fontWeight: FontWeight.w900))),
          CircleAvatar(radius: 20, backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null, child: user['avatar_url'] == null ? const Icon(Icons.person) : null),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['username'] + (isMe ? ' (You)' : ''), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                Text(user['rank_title'] ?? 'NOVICE ALCHEMIST', style: TextStyle(color: _cyan.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
          Text('${user['xp']}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          const Text('XP', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
