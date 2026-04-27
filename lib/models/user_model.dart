enum UserRole { user, admin }

class AppUser {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final int totalXp;
  final int currentStreak;
  final String? avatarUrl;
  final String? createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] ?? '').toString().toUpperCase();
    return AppUser(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: roleStr == 'ADMIN' ? UserRole.admin : UserRole.user,
      totalXp: json['xp'] ?? json['total_xp'] ?? 0,
      currentStreak: json['streak_days'] ?? json['current_streak'] ?? 0,
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'],
    );
  }
}
