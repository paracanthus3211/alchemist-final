import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/daily_task_model.dart';
import 'base_url_stub.dart'
    if (dart.library.io) 'base_url_io.dart';

class ApiService {
  static String get baseUrl => getApiBaseUrl();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  AppUser? _currentUser;
  String? _token;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = AppUser.fromJson(data['user']);
        return {'user': _currentUser, 'error': null};
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        return {'user': null, 'error': errorData['message'] ?? 'Kredensial salah'};
      } else {
        return {'user': null, 'error': 'Server Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Network/CORS Error: $e');
      return {'user': null, 'error': 'Koneksi Gagal: Periksa internet atau server (CORS)'};
    }
  }

  void logout() {
    _currentUser = null;
    _token = null;
  }

  Future<bool> addUserXp(List<int> questionIds) async {
    try {
      if (questionIds.isEmpty) return true; // Nothing to add
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/xp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'question_ids': questionIds}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int newTotalXp = data['total_xp'] ?? (_currentUser?.totalXp ?? 0);
        
        // Update local user object
        if (_currentUser != null) {
          _currentUser = AppUser(
            id: _currentUser!.id,
            username: _currentUser!.username,
            email: _currentUser!.email,
            role: _currentUser!.role,
            totalXp: newTotalXp,
            currentStreak: _currentUser!.currentStreak,
            avatarUrl: _currentUser!.avatarUrl,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Add User XP Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getCurriculum() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/curriculum'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      print('Fetch Curriculum Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getRanks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ranks'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List?;
        return data ?? [];
      }
      return [];
    } catch (e) {
      print('Fetch Ranks Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getLeaderboard({String period = 'all', String scope = 'global'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard?period=$period&scope=$scope'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      print('Fetch Leaderboard Error: $e');
      return [];
    }
  }

  /// Add XP from a virtual lab reaction (with local fallback if endpoint unavailable).
  Future<void> addLabXp(int xpAmount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/lab-xp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'xp': xpAmount}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int newTotal = data['total_xp'] ?? ((_currentUser?.totalXp ?? 0) + xpAmount);
        _updateLocalXp(newTotal);
      } else {
        _updateLocalXp((_currentUser?.totalXp ?? 0) + xpAmount);
      }
    } catch (e) {
      _updateLocalXp((_currentUser?.totalXp ?? 0) + xpAmount);
      print('Add Lab XP Error (local fallback applied): $e');
    }
  }

  void _updateLocalXp(int newTotal) {
    if (_currentUser != null) {
      _currentUser = AppUser(
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
        role: _currentUser!.role,
        totalXp: newTotal,
        currentStreak: _currentUser!.currentStreak,
        avatarUrl: _currentUser!.avatarUrl,
        createdAt: _currentUser!.createdAt,
      );
    }
  }


  Future<bool> createChapter(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chapters'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 201) {
        print('Create Chapter failed: ${response.statusCode} ${response.body}');
      }
      return response.statusCode == 201;
    } catch (e) {
      print('Create Chapter Error: $e');
      return false;
    }
  }

  Future<bool> updateChapter(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chapters/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        print('Update Chapter failed: ${response.statusCode} ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Update Chapter Error: $e');
      return false;
    }
  }

  Future<bool> deleteChapter(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chapters/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Chapter Error: $e');
      return false;
    }
  }

  Future<bool> createLevel(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/levels'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Create Level Error: $e');
      return false;
    }
  }

  Future<bool> deleteLevel(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/levels/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Level Error: $e');
      return false;
    }
  }

  Future<bool> updateLevel(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/levels/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Level Error: $e');
      return false;
    }
  }

  Future<bool> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Create Question Error: $e');
      return false;
    }
  }

  Future<bool> updateQuestion(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/questions/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Question Error: $e');
      return false;
    }
  }

  Future<bool> deleteQuestion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/questions/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Question Error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // DAILY TASKS
  // ──────────────────────────────────────────────

  Future<List<DailyTaskModel>> getDailyTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daily-tasks'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((e) => DailyTaskModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get Daily Tasks Error: $e');
      return [];
    }
  }

  Future<Map<String, int>> getDailyTaskStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daily-tasks/stats'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return {
          'templates': data['templates'] as int,
          'active': data['active'] as int,
          'inactive': data['inactive'] as int,
        };
      }
      return {'templates': 0, 'active': 0, 'inactive': 0};
    } catch (e) {
      print('Get Daily Task Stats Error: $e');
      return {'templates': 0, 'active': 0, 'inactive': 0};
    }
  }

  Future<bool> createDailyTask(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/daily-tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        print('Create DailyTask failed: ${response.body}');
      }
      return response.statusCode == 201;
    } catch (e) {
      print('Create DailyTask Error: $e');
      return false;
    }
  }

  Future<bool> updateDailyTask(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/daily-tasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update DailyTask Error: $e');
      return false;
    }
  }

  Future<bool> deleteDailyTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/daily-tasks/$id'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete DailyTask Error: $e');
      return false;
    }
  }

  Future<bool> updateDailyTaskProgress(int taskId, int progress) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/daily-tasks/$taskId/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'current_progress': progress}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Progress Error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // ARTICLES
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getArticles({String? category, String? search}) async {
    try {
      String url = '$baseUrl/articles?';
      if (category != null) url += 'category=$category&';
      if (search != null) url += 'search=$search&';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      print('Get Articles Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getArticleDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles/$id'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Get Article Details Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> createArticle(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/articles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'error': null};
      } else {
        String errorMsg = 'Status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? errorMsg;
        } catch (_) {
          errorMsg = 'Error ${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}';
        }
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('Create Article Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateArticle(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/articles/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'error': null};
      } else {
        String errorMsg = 'Status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? errorMsg;
        } catch (_) {
          errorMsg = 'Error ${response.statusCode}: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}';
        }
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      print('Update Article Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> deleteArticle(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/articles/$id'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Article Error: $e');
      return false;
    }
  }

  Future<bool> toggleBookmark(int articleId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/articles/$articleId/bookmark'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Toggle Bookmark Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getBookmarks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookmarks'),
        headers: {
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      print('Get Bookmarks Error: $e');
      return [];
    }
  }

  // ──────────────────────────────────────────────
  // IMAGE UPLOAD
  // ──────────────────────────────────────────────

  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final uri = Uri.parse('$baseUrl/upload-image');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        print('Upload Image failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload Image Error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // RANK CRUD
  // ──────────────────────────────────────────────

  Future<String?> createRank(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ranks'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      print('Create Rank Error: $e');
      return 'Network Error: $e';
    }
  }

  Future<bool> updateRank(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/ranks/$id'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update Rank Error: $e');
      return false;
    }
  }

  Future<bool> deleteRank(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ranks/$id'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Rank Error: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // FRIENDS
  // ──────────────────────────────────────────────

  Future<List<dynamic>> getFriends() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/friends'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body)['data'] ?? [];
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> getFriendRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/friends/requests'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body)['data'] ?? [];
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data != null && data.isNotEmpty) return data;
      }
      
      // Fallback: If search endpoint fails or returns empty, try finding them in leaderboard
      final fallbackResponse = await http.get(
        Uri.parse('$baseUrl/leaderboard?period=all&scope=global'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (fallbackResponse.statusCode == 200) {
        final data = jsonDecode(fallbackResponse.body)['data'] as List?;
        if (data != null) {
          final q = query.toLowerCase();
          return data.where((u) {
            final uname = (u['username'] ?? '').toString().toLowerCase();
            return uname.contains(q);
          }).toList();
        }
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> sendFriendRequest(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/friends/$userId'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/friends/$requestId/accept'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> declineFriendRequest(String requestId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/friends/$requestId'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}
