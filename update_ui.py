import re

file_path = 'lib/add_friends_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Colors
content = content.replace('static const _cyan = Color(0xFF00FBFF);', 'static const _cyan = Color(0xFF00D5C8);')
content = content.replace('static const _cardBg = Color(0xFF1A1F2E);', 'static const _cardBg = Color(0xFF152224);')
content = content.replace('static const _bg = Color(0xFF0D1117);', 'static const _bg = Color(0xFF0C1214);')

# 2. Header and Tabs
old_header_tabs = '''            // ─── HEADER ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOCIAL LAB',
                    style: GoogleFonts.spaceGrotesk(
                      color: _cyan,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
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
                labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'ADD FRIENDS'),
                  Tab(text: 'YOUR FRIENDS'),
                  Tab(text: 'REQUESTS'),
                ],
              ),
            ),'''

new_header_tabs = '''            const SizedBox(height: 24),
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
            ),'''
content = content.replace(old_header_tabs, new_header_tabs)

# 3. Add Friend Tab Calls
content = content.replace("rank: u['rank_title'] ?? 'Novice',", "rank: '${u['rank_title'] ?? 'NOVICE'} • CHAPTER ${u['level'] ?? 1}',\n                        xpValue: (u['xp'] ?? 0).toString(),")
old_trailing_add = '''trailing: GestureDetector(
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
                        ),'''
new_trailing_add = '''trailing: GestureDetector(
                          onTap: sent ? null : () => _sendRequest(uid),
                          child: Icon(sent ? Icons.check : Icons.person_add_outlined, color: sent ? Colors.white24 : _cyan, size: 24),
                        ),'''
content = content.replace(old_trailing_add, new_trailing_add)

# 4. Your Friends Tab Calls
content = content.replace("rank: f['rank_title'] ?? 'Alchemist',", "rank: '${f['rank_title'] ?? 'NOVICE'} • CHAPTER ${f['level'] ?? 1}',\n                        xpValue: (f['xp'] ?? 0).toString(),")
old_trailing_arrow = '''trailing: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                        ),'''
new_trailing_arrow = '''trailing: const SizedBox(),'''
content = content.replace(old_trailing_arrow, new_trailing_arrow)

# 5. Search Bar
old_search_bar = '''  Widget _buildSearchBar({required String hint, required Function(String) onSearch}) {
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
                onSubmitted: onSearch,'''
new_search_bar = '''  Widget _buildSearchBar({required String hint, required Function(String) onSearch}) {
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
                onSubmitted: onSearch,'''
content = content.replace(old_search_bar, new_search_bar)

# 6. Friend Card
old_friend_card = '''  Widget _friendCard({
    required String name,
    required String level,
    required String rank,
    String? avatarUrl,
    required Color rankColor,
    required Widget trailing,
    bool isOnline = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }'''
new_friend_card = '''  Widget _friendCard({
    required String name,
    required String level,
    required String rank,
    String? avatarUrl,
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
                    child: ClipPath(
                      clipper: HexagonClipper(),
                      child: Container(
                        width: 26,
                        height: 30,
                        color: const Color(0xFFC59F54),
                        alignment: Alignment.center,
                        child: ClipPath(
                          clipper: HexagonClipper(),
                          child: Container(
                            width: 22,
                            height: 26,
                            color: const Color(0xFF251E15),
                            child: const Icon(Icons.science, size: 14, color: Color(0xFFC59F54)),
                          ),
                        ),
                      ),
                    ),
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
  }'''
content = content.replace(old_friend_card, new_friend_card)

# 7. Add HexagonClipper class
clipper_class = '''
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
'''
if 'class HexagonClipper' not in content:
    content += clipper_class

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('UI update script finished.')
