import '../models/medication_schedule.dart';
import '../services/api_service.dart';

class MedicationRepository {
  final ApiService _apiService = ApiService();

  Future<String> createSchedule(MedicationSchedule schedule) async {
    try {
      return await _apiService.createMedicationSchedule(schedule);
    } catch (e) {
      throw Exception('Lỗi tạo lịch uống thuốc: $e');
    }
  }

  Future<List<MedicationSchedule>> getSchedulesByCarerId(String carerId) async {
    try {
      return await _apiService.getMedicationSchedulesByCarerId(carerId);
    } catch (e) {
      throw Exception('Lỗi lấy lịch uống thuốc: $e');
    }
  }

  Future<List<MedicationSchedule>> getSchedulesByElderId(String elderId) async {
    try {
      return await _apiService.getMedicationSchedulesByElderId(elderId);
    } catch (e) {
      throw Exception('Lỗi lấy lịch uống thuốc: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _apiService.deleteMedicationSchedule(id);
    } catch (e) {
      throw Exception('Lỗi xóa lịch: $e');
    }
  }

  Future<void> updateSchedule(String id, MedicationSchedule schedule) async {
    try {
      await _apiService.updateMedicationSchedule(id, schedule);
    } catch (e) {
      throw Exception('Lỗi cập nhật lịch: $e');
    }
  }
}





