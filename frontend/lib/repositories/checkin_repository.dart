import '../models/check_in.dart';
import '../services/api_service.dart';

class CheckInRepository {
  final ApiService _apiService = ApiService();

  Future<String> createCheckIn(CheckIn checkIn) async {
    try {
      return await _apiService.createCheckIn(checkIn);
    } catch (e) {
      throw Exception('Lỗi tạo check-in: $e');
    }
  }

  Future<CheckIn?> getTodayCheckIn(String medicationScheduleId) async {
    try {
      return await _apiService.getTodayCheckIn(medicationScheduleId);
    } catch (e) {
      throw Exception('Lỗi lấy check-in: $e');
    }
  }

  Future<List<CheckIn>> getCheckInsByElderId(
    String elderId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _apiService.getCheckInsByElderId(
        elderId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử check-in: $e');
    }
  }
}





