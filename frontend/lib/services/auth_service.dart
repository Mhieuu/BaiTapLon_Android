import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  User? _currentUser;
  static const String _userKey = 'current_user_id';

  User? get currentUser => _currentUser;

  Future<bool> login(String phoneNumber) async {
    try {
      final response = await _apiService.login(phoneNumber);
      if (response['success'] == true && response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, _currentUser!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      final response = await _apiService.register(user);
      if (response['success'] == true) {
        _currentUser = User.fromJson(response['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, _currentUser!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userKey);
      if (userId != null) {
        final user = await _apiService.getUserById(userId);
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      print('Load saved user error: $e');
      return false;
    }
  }

  Future<bool> linkCarerAndElder(String carerId, String elderId) async {
    try {
      final success = await _apiService.linkCarerAndElder(carerId, elderId);
      if (success && _currentUser != null) {
        // Refresh user info sau khi liên kết thành công
        await refreshCurrentUser();
      }
      return success;
    } catch (e) {
      print('Link carer and elder error: $e');
      return false;
    }
  }

  /// Refresh current user info from API
  Future<bool> refreshCurrentUser() async {
    try {
      if (_currentUser == null) {
        return false;
      }
      final user = await _apiService.getUserById(_currentUser!.id);
      if (user != null) {
        _currentUser = user;
        print('✅ [AUTH_SERVICE] Đã refresh user info - parentId: ${_currentUser?.parentId}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [AUTH_SERVICE] Lỗi refresh user: $e');
      return false;
    }
  }
}

