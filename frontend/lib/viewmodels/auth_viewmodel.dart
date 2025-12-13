import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../config/app_config.dart';
import '../services/mock_data_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  static const String _userKey = 'current_user_id';

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Load saved user from local storage
  Future<void> loadSavedUser() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userKey);
      if (userId != null) {
        _currentUser = await _repository.getUserById(userId);
        _errorMessage = null;
        notifyListeners();
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
    notifyListeners();
    
    try {
      print('🔄 [AUTH] Bắt đầu đăng nhập: $phoneNumber');
      
      // 🎭 MOCK MODE: Sử dụng dữ liệu demo
      if (AppConfig.MOCK_MODE) {
        await Future.delayed(const Duration(seconds: 1)); // Giả lập delay API
        
        if (phoneNumber == AppConfig.MOCK_CARER_PHONE) {
          _currentUser = MockDataService.getMockCarer();
          print('🎭 [AUTH] Mock login - Người cao tuổi: ${_currentUser!.name}');
        } else if (phoneNumber == AppConfig.MOCK_PARENT_PHONE) {
          _currentUser = MockDataService.getMockParent();
          print('🎭 [AUTH] Mock login - Người thân: ${_currentUser!.name}');
        } else {
          print('❌ [AUTH] Số điện thoại không khớp với mock data');
          _errorMessage = 'Số điện thoại không tồn tại.\n\nDemo:\n- Người cao tuổi: ${AppConfig.MOCK_CARER_PHONE}\n- Người thân: ${AppConfig.MOCK_PARENT_PHONE}';
          notifyListeners();
          return false;
        }
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, _currentUser!.id);
        
        print('✅ [AUTH] Mock đăng nhập thành công! User: ${_currentUser!.name}');
        notifyListeners();
        return true;
      }
      
      // LIVE MODE: Gọi API thực
      final user = await _repository.login(phoneNumber);
      
      if (user != null) {
        _currentUser = user;
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, user.id);
        
        print('✅ [AUTH] Đăng nhập thành công! User: ${user.name}');
        notifyListeners();
        return true;
      } else {
        print('❌ [AUTH] Số điện thoại không tồn tại: $phoneNumber');
        _errorMessage = 'Số điện thoại không tồn tại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ [AUTH] Lỗi đăng nhập: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(User user) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    
    try {
      print('🔄 [AUTH] Bắt đầu đăng ký user: ${user.name}');
      final registeredUser = await _repository.register(user);
      
      if (registeredUser == null) {
        print('❌ [AUTH] Register trả về null');
        _errorMessage = 'Đăng ký thất bại - Không nhận được dữ liệu từ server';
        return false;
      }
      
      _currentUser = registeredUser;
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, registeredUser.id);
      
      print('✅ [AUTH] Đăng ký thành công! User ID: ${registeredUser.id}');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [AUTH] Lỗi đăng ký: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Link carer and elder
  Future<bool> linkCarerAndElder(String carerId, String elderId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _repository.linkCarerAndElder(carerId, elderId);
      if (success) {
        // Reload user to get updated data
        await loadSavedUser();
        return true;
      } else {
        _errorMessage = 'Liên kết thất bại';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
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

