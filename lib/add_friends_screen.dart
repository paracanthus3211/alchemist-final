import 'package:flutter/material.dart';
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

  static const _cyan = Color(0xFF00FBFF);
  static const _cardBg = Color(0xFF1A1F2E);
  static const _bg = Color(0xFF0D1117);

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
            // ─── HEADER ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SOCIAL LAB',
                    style: TextStyle(
                      color: _cyan,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle),
                    child: const Icon(Icons.search, color: Colors.white54, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── TABS ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.white12,
                indicatorColor: _cyan,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Add friends'),
                  Tab(text: 'your friends'),
                  Tab(text: 'Requests'),
                ],
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
                        rank: u['rank_title'] ?? 'Novice',
                        avatarUrl: u['avatar_url'],
                        rankColor: _cyan,
                        trailing: GestureDetector(
                          onTap: sent ? null : () => _sendRequest(uid),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: sent ? Colors.white.withOpacity(0.05) : _cyan.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: sent ? Colors.white12 : _cyan.withOpacity(0.5)),
                            ),
                            child: Icon(sent ? Icons.check : Icons.person_add_alt_1, color: sent ? Colors.white24 : _cyan, size: 20),
                          ),
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
                        rank: f['rank_title'] ?? 'Alchemist',
                        avatarUrl: f['avatar_url'],
                        rankColor: _cyan,
                        isOnline: f['is_online'] == true,
                        trailing: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                        ),
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
            avatarUrl: r['avatar_url'],
            rankColor: _getRankColor(r['rank_title'] ?? ''),
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
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.person_search_outlined, color: Colors.white24, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, letterSpacing: 0.5),
                  border: InputBorder.none,
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
    required Color rankColor,
    required Widget trailing,
    bool isOnline = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.06),
                  image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
                ),
                child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white24, size: 30) : null,
              ),
              // Level badge
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117).withOpacity(0.9),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Text(level, textAlign: TextAlign.center, style: const TextStyle(color: _cyan, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ),
              if (isOnline)
                Positioned(
                  top: 2, right: 2,
                  child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: _cardBg, width: 1.5))),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: rankColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(rank.toUpperCase(), style: TextStyle(color: rankColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _requestCard({
    required String name,
    required String level,
    required String rank,
    required String timeAgo,
    String? avatarUrl,
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
