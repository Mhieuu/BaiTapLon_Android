import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Load saved user on init
  Future<void> loadSavedUser() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.loadSavedUser();
      if (isLoggedIn && _authService.currentUser != null) {
        _currentUser = _authService.currentUser;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải thông tin user: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String phoneNumber) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _authService.login(phoneNumber);
      if (success && _authService.currentUser != null) {
        _currentUser = _authService.currentUser;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Số điện thoại không tồn tại';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(User user) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _authService.register(user);
      if (success && _authService.currentUser != null) {
        _currentUser = _authService.currentUser;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Đăng ký thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng ký: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Link carer and elder
  Future<bool> linkCarerAndElder(String carerId, String elderId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _authService.linkCarerAndElder(carerId, elderId);
      if (success) {
        // Reload user to get updated data
        await loadSavedUser();
        return true;
      } else {
        _errorMessage = 'Liên kết thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi liên kết: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}





