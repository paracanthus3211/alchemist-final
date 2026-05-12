import 'package:flutter/material.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  double _fontSizeMultiplier = 1.0;
  String _language = 'English';

  double get fontSizeMultiplier => _fontSizeMultiplier;
  String get language => _language;

  set fontSizeMultiplier(double value) {
    if (_fontSizeMultiplier != value) {
      _fontSizeMultiplier = value;
      notifyListeners();
    }
  }

  set language(String value) {
    if (_language != value) {
      _language = value;
      notifyListeners();
    }
  }

  static const Map<String, Map<String, String>> _localizedMap = {
    'English': {
      'following': 'FOLLOWING',
      'friends': 'FRIENDS',
      'followers': 'FOLLOWERS',
      'history': 'HISTORY',
      'achievements': 'ACHIEVEMENTS',
      'settings': 'SETTINGS',
      'recent_read': 'RECENT READ',
      'achievement_header': 'ACHIEVEMENT',
      'font_size': 'Font Size',
      'language': 'Language',
      'about': 'About Alchemist',
      'logout': 'LOGOUT',
      'joined': 'JOINED ON',
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      'completed': 'Completed',
      'reading': 'Reading...',
      'unknown_art': 'Unknown Article',
      'streak': 'STREAK LEARNING',
      'chapter': 'CHAPTER',
      'progress': 'PROGRESS LEARNING',
      'daily_task': 'DAILY TASK',
      'continue_reading': 'CONTINUE READING',
      'manage_tasks': 'Manage Tasks',
      'home': 'HOME',
      'quiz': 'QUIZ',
      'rank': 'RANK',
      'profile': 'PROFILE',
      'more': 'MORE',
      'current_level': 'CURRENT LEVEL',
    },
    'Indonesia': {
      'following': 'MENGIKUTI',
      'friends': 'TEMAN',
      'followers': 'PENGIKUT',
      'history': 'RIWAYAT',
      'achievements': 'PENCAPAIAN',
      'settings': 'PENGATURAN',
      'recent_read': 'BARU DIBACA',
      'achievement_header': 'PENCAPAIAN',
      'font_size': 'Ukuran Font',
      'language': 'Bahasa',
      'about': 'Tentang Alchemist',
      'logout': 'KELUAR',
      'joined': 'BERGABUNG PADA',
      'small': 'Kecil',
      'medium': 'Sedang',
      'large': 'Besar',
      'completed': 'Selesai',
      'reading': 'Sedang Membaca...',
      'unknown_art': 'Artikel Tidak Diketahui',
      'streak': 'STREAK BELAJAR',
      'chapter': 'BAB',
      'progress': 'PROGRES BELAJAR',
      'daily_task': 'TUGAS HARIAN',
      'continue_reading': 'LANJUT BACA',
      'manage_tasks': 'Kelola Tugas',
      'home': 'BERANDA',
      'quiz': 'KUIS',
      'rank': 'PERINGKAT',
      'profile': 'PROFIL',
      'more': 'LAINNYA',
      'current_level': 'LEVEL SAAT INI',
    }
  };

  String t(String key) {
    return _localizedMap[_language]?[key] ?? key;
  }
}
