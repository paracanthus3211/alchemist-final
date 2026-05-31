import re

file_path = 'lib/add_friends_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Update _friendCard signature and caller
# Add rankIconUrl to caller
content = content.replace("xpValue: (u['xp'] ?? 0).toString(),", "xpValue: (u['xp'] ?? 0).toString(),\n                        rankIconUrl: u['rank_icon_url'],")
content = content.replace("xpValue: (f['xp'] ?? 0).toString(),", "xpValue: (f['xp'] ?? 0).toString(),\n                        rankIconUrl: f['rank_icon_url'],")

# Update _friendCard definition
old_friend_card = '''  Widget _friendCard({
    required String name,
    required String level,
    required String rank,
    String? avatarUrl,
    required Color rankColor,
    required Widget trailing,
    bool isOnline = false,
    String? xpValue,
    VoidCallback? onTap,
  }) {'''
new_friend_card = '''  Widget _friendCard({
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
  }) {'''
content = content.replace(old_friend_card, new_friend_card)

old_icon = '''child: const Icon(Icons.science, size: 14, color: Color(0xFFC59F54)),'''
new_icon = '''child: (rankIconUrl != null && rankIconUrl.startsWith('http'))
                                ? Padding(padding: const EdgeInsets.all(4.0), child: Image.network(rankIconUrl, fit: BoxFit.contain))
                                : const Icon(Icons.science, size: 14, color: Color(0xFFC59F54)),'''
content = content.replace(old_icon, new_icon)

# Update _requestCard
content = content.replace("rankColor: _getRankColor(r['rank_title'] ?? ''),", "rankColor: _getRankColor(r['rank_title'] ?? ''),\n            rankIconUrl: r['rank_icon_url'],")

old_req_card = '''  Widget _requestCard({
    required String name,
    required String level,
    required String rank,
    required String timeAgo,
    String? avatarUrl,
    required Color rankColor,
    required VoidCallback onAccept,
    required VoidCallback onIgnore,
  }) {'''
new_req_card = '''  Widget _requestCard({
    required String name,
    required String level,
    required String rank,
    required String timeAgo,
    String? avatarUrl,
    String? rankIconUrl,
    required Color rankColor,
    required VoidCallback onAccept,
    required VoidCallback onIgnore,
  }) {'''
content = content.replace(old_req_card, new_req_card)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('UI update script finished.')
