import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'services/api_service.dart';
import 'widgets/background_wrapper.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  List<dynamic> _friends = [];
  List<dynamic> _requests = [];
  List<dynamic> _searchResults = [];

  bool _loadingFriends = true;
  bool _loadingRequests = true;
  bool _searching = false;
  final Set<String> _sentRequests = {};

  static const _cyan = Color(0xFF00D5C8);
  static const _cardBg = Color(0xFF152224);
  static const _bg = Color(0xFF0C1214);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _loadFriends();
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _loadingFriends = true);
    final data = await ApiService().getFriends();
    if (mounted) setState(() { _friends = data; _loadingFriends = false; });
  }

  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    final data = await ApiService().getFriendRequests();
    if (mounted) setState(() { _requests = data; _loadingRequests = false; });
  }

  Future<void> _searchUsers(String q) async {
    if (q.trim().isEmpty) { setState(() => _searchResults = []); return; }
    setState(() => _searching = true);
    final data = await ApiService().searchUsers(q.trim());
    if (mounted) setState(() { _searchResults = data; _searching = false; });
  }

  Future<void> _sendRequest(String userId) async {
    setState(() => _sentRequests.add(userId));
    await ApiService().sendFriendRequest(userId);
  }

  Future<void> _acceptRequest(String requestId) async {
    await ApiService().acceptFriendRequest(requestId);
    _loadRequests(); _loadFriends();
  }

  Future<void> _declineRequest(String requestId) async {
    await ApiService().declineFriendRequest(requestId);
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // ─── TABS ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF151E20),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(0xFF033F40),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: _cyan,
                  unselectedLabelColor: const Color(0xFF6B7A7D),
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0),
                  unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0),
                  tabs: const [
                    Tab(text: 'ADD FRIENDS'),
                    Tab(text: 'YOUR FRIENDS'),
                    Tab(text: 'REQUEST'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAddFriendsTab(),
                  _buildYourFriendsTab(),
                  _buildRequestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 0: ADD FRIENDS ───
  Widget _buildAddFriendsTab() {
    return Column(
      children: [
        _buildSearchBar(hint: 'FIND BY USERNAME...', onSearch: _searchUsers),
        const SizedBox(height: 8),
        Expanded(
          child: _searching
            ? const Center(child: CircularProgressIndicator(color: _cyan))
            : _searchResults.isEmpty && _searchCtrl.text.isNotEmpty
              ? const Center(child: Text('No users found', style: TextStyle(color: Colors.white38)))
              : _searchResults.isEmpty
                ? const Center(child: Text('Search for friends by username', style: TextStyle(color: Colors.white24)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length,
                    itemBuilder: (_, i) {
                      final u = _searchResults[i];
                      final uid = u['id'].toString();
                      final sent = _sentRequests.contains(uid);
                      return _friendCard(
                        name: u['username'] ?? 'User',
                        level: 'LVL ${u['level'] ?? 1}',
                        rank: '${u['rank_title'] ?? 'NOVICE'} • CHAPTER ${u['level'] ?? 1}',
                        xpValue: (u['xp'] ?? 0).toString(),
                        rankIconUrl: u['rank_icon_url'],
                        avatarUrl: ApiService.getAvatarUrl(u['avatar_url'], fallbackSeed: u['username']),
                        rankColor: _cyan,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: int.tryParse(uid))));
                        },
                        trailing: GestureDetector(
                          onTap: sent ? null : () => _sendRequest(uid),
                          child: Icon(sent ? Icons.check : Icons.person_add_outlined, color: sent ? Colors.white24 : _cyan, size: 24),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // ─── TAB 1: YOUR FRIENDS ───
  Widget _buildYourFriendsTab() {
    return Column(
      children: [
        _buildSearchBar(hint: 'FIND BY USERNAME...', onSearch: (_) {}),
        const SizedBox(height: 8),
        Expanded(
          child: _loadingFriends
            ? const Center(child: CircularProgressIndicator(color: _cyan))
            : _friends.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.people_outline, color: Colors.white12, size: 56),
                  const SizedBox(height: 12),
                  const Text('No friends yet', style: TextStyle(color: Colors.white24, fontSize: 15)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _tabController.animateTo(0),
                    child: const Text('Add some →', style: TextStyle(color: _cyan, fontSize: 13)),
                  ),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadFriends,
                  color: _cyan,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _friends.length,
                    itemBuilder: (_, i) {
                      final f = _friends[i];
                      return _friendCard(
                        name: f['username'] ?? 'User',
                        level: 'LVL ${f['level'] ?? 1}',
                        rank: '${f['rank_title'] ?? 'NOVICE'} • CHAPTER ${f['level'] ?? 1}',
                        xpValue: (f['xp'] ?? 0).toString(),
                        rankIconUrl: f['rank_icon_url'],
                        avatarUrl: ApiService.getAvatarUrl(f['avatar_url'], fallbackSeed: f['username']),
                        rankColor: _cyan,
                        isOnline: f['is_online'] == true,
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: f['id'])));
                        },
                        trailing: const SizedBox(),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ─── TAB 2: REQUESTS ───
  Widget _buildRequestsTab() {
    if (_loadingRequests) return const Center(child: CircularProgressIndicator(color: _cyan));
    if (_requests.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.inbox_outlined, color: Colors.white12, size: 56),
      const SizedBox(height: 12),
      const Text('No pending requests', style: TextStyle(color: Colors.white24, fontSize: 15)),
    ]));

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: _cyan,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _requests.length,
        itemBuilder: (_, i) {
          final r = _requests[i];
          final rid = r['id'].toString();
          return _requestCard(
            name: r['username'] ?? 'User',
            level: 'LVL ${r['level'] ?? 1}',
            rank: r['rank_title'] ?? 'Novice',
            timeAgo: r['time_ago'] ?? 'recently',
            avatarUrl: ApiService.getAvatarUrl(r['avatar_url'], fallbackSeed: r['username']),
            rankColor: _getRankColor(r['rank_title'] ?? ''),
            rankIconUrl: r['rank_icon_url'],
            onAccept: () => _acceptRequest(rid),
            onIgnore: () => _declineRequest(rid),
          );
        },
      ),
    );
  }

  // ─── WIDGETS ───

  Widget _buildSearchBar({required String hint, required Function(String) onSearch}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: _cyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Color(0xFF6B7A7D)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onSubmitted: onSearch,
                onChanged: (v) { 
                  setState(() {}); // Rebuild UI to update empty states
                  if (v.isEmpty) {
                    setState(() => _searchResults = []); 
                  } else if (v.length > 2 && onSearch == _searchUsers) {
                    onSearch(v); // Auto search
                  }
                },
              ),
            ),
            if (_searchCtrl.text.isNotEmpty && onSearch == _searchUsers)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchResults = []);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.close, color: Colors.white24, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _friendCard({
    required String name,
    required String level,
    required String rank,
    String? avatarUrl,
    String? rankIconUrl,
    required Color rankColor,
    required Widget trailing,
    bool isOnline = false,
    String? xpValue,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            // Avatar + Badge
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
                    ),
                    child: avatarUrl == null ? const Center(child: Text('CHAPTER', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold))) : null,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: (rankIconUrl != null && rankIconUrl.startsWith('http'))
                        ? Image.network(
                            rankIconUrl,
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.science, size: 16, color: Color(0xFFC59F54)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(rank.toUpperCase(), style: const TextStyle(color: Color(0xFF6B7A7D), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ],
              ),
            ),
            if (xpValue != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(xpValue, style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w500)),
                  const Text('XP', style: TextStyle(color: Color(0xFF6B7A7D), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            if (trailing is! SizedBox) ...[
              const SizedBox(width: 16),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Widget _requestCard({
    required String name,
    required String level,
    required String rank,
    required String timeAgo,
    String? avatarUrl,
    String? rankIconUrl,
    required Color rankColor,
    required VoidCallback onAccept,
    required VoidCallback onIgnore,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Avatar + name
          Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.06),
                      image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
                    ),
                    child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white24, size: 36) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(level, style: const TextStyle(color: _cyan, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: rankColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(rank.toUpperCase(), style: TextStyle(color: rankColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 4),
              Text('Requested $timeAgo', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(color: _cyan, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('Accept', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onIgnore,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: const Center(child: Text('Ignore', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 14))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String rank) {
    final r = rank.toLowerCase();
    if (r.contains('grand') || r.contains('master')) return const Color(0xFFFFD700);
    if (r.contains('senior') || r.contains('silver')) return const Color(0xFFC0C0C0);
    if (r.contains('expert') || r.contains('noble')) return const Color(0xFF00FBFF);
    if (r.contains('adept') || r.contains('isotope')) return const Color(0xFF8B5CF6);
    return const Color(0xFF00FBFF);
  }
}
