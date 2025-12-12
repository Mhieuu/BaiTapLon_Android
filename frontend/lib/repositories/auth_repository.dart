import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<User?> login(String phoneNumber) async {
    try {
      final response = await _apiService.login(phoneNumber);
      if (response['success'] == true && response['user'] != null) {
        return User.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  Future<User> register(User user) async {
    try {
      final response = await _apiService.register(user);
      if (response['success'] == true && response['user'] != null) {
        return User.fromJson(response['user']);
      }
      throw Exception('Đăng ký thất bại');
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      return await _apiService.getUserById(id);
    } catch (e) {
      throw Exception('Lỗi lấy thông tin user: $e');
    }
  }

  Future<bool> linkCarerAndElder(String carerId, String elderId) async {
    try {
      return await _apiService.linkCarerAndElder(carerId, elderId);
    } catch (e) {
      throw Exception('Lỗi liên kết: $e');
    }
  }
}





