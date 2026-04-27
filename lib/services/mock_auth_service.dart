import '../models/user_model.dart';

class MockAuthService {
  // Singleton pattern
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> login(String username, String password) async {
    // Artificial delay for realism
    await Future.delayed(const Duration(milliseconds: 800));

    // Admin logic
    if (username.toLowerCase() == 'admin') {
      _currentUser = AppUser(
        id: 'admin_01',
        username: 'Administrator',
        email: 'admin@alchemist.com',
        role: UserRole.admin,
      );
      return _currentUser;
    }

    // Standard user logic (accept any other login for dummy purposes)
    _currentUser = AppUser(
      id: 'user_01',
      username: username.isEmpty ? 'Scholar' : username,
      email: '$username@example.com',
      role: UserRole.user,
    );
    
    return _currentUser;
  }

  void logout() {
    _currentUser = null;
  }
}
