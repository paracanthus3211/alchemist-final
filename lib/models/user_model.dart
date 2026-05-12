enum UserRole { user, admin }

class AppUser {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final int totalXp;
  final int streakCount;
  final int maxStreak;
  final DateTime? lastStudyAt;
  final String? avatarUrl;
  final int? equippedAvatarId;
  final String? createdAt;
  final int? selectedRankId;
  final int quizLevel;
  final String currentLevelName;
  final String currentChapterTitle;
  final int currentLevelProgress;
  final int currentLevelXp; // Tambahan
  final int totalLevelXp;   // Tambahan
  final String? profileBgColor;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.totalXp = 0,
    this.streakCount = 0,
    this.maxStreak = 0,
    this.lastStudyAt,
    this.avatarUrl,
    this.equippedAvatarId,
    this.createdAt,
    this.selectedRankId,
    this.quizLevel = 1,
    this.currentLevelName = 'Novice',
    this.currentChapterTitle = 'Prologue',
    this.currentLevelProgress = 0,
    this.currentLevelXp = 0,
    this.totalLevelXp = 0,
    this.profileBgColor,
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
      streakCount: json['streak_count'] ?? json['streak_days'] ?? 0,
      maxStreak: json['max_streak'] ?? 0,
      lastStudyAt: json['last_study_at'] != null ? DateTime.tryParse(json['last_study_at']) : null,
      avatarUrl: json['avatar_url'],
      equippedAvatarId: json['equipped_avatar_id'] != null ? int.tryParse(json['equipped_avatar_id'].toString()) : null,
      createdAt: json['created_at'],
      selectedRankId: json['selected_rank_id'] != null ? int.tryParse(json['selected_rank_id'].toString()) : null,
      quizLevel: json['quiz_level'] ?? 1,
      currentLevelName: json['current_level_name'] ?? 'Novice',
      currentChapterTitle: json['current_chapter_title'] ?? 'Prologue',
      currentLevelProgress: json['current_level_progress'] ?? 0,
      currentLevelXp: json['current_level_xp'] ?? 0,
      totalLevelXp: json['total_level_xp'] ?? 0,
      profileBgColor: json['profile_bg_color'],
    );
  }
}
