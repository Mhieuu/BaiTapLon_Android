// Wrapper service để chuyển từ DatabaseService sang ApiService
// Giữ lại interface cũ để không phải sửa nhiều code
import 'api_service.dart';
import '../models/user.dart';
import '../models/medication_schedule.dart';
import '../models/appointment.dart';
import '../models/check_in.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final ApiService _apiService = ApiService();

  // Không cần connect nữa vì dùng API
  Future<void> connect() async {
    // Do nothing - API connection is handled by HTTP
    print('Using API service instead of direct MongoDB connection');
  }

  Future<void> disconnect() async {
    // Do nothing
  }

  // User operations
  Future<String> createUser(User user) async {
    final response = await _apiService.register(user);
    return response['userId'] ?? '';
  }

  Future<User?> getUserById(String id) async {
    try {
      return await _apiService.getUserById(id);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByPhone(String phoneNumber) async {
    try {
      final response = await _apiService.login(phoneNumber);
      if (response['success'] == true) {
        return User.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    // TODO: Implement update user API endpoint in backend
    // For now, this is a placeholder
  }

  // Medication Schedule operations
  Future<String> createMedicationSchedule(MedicationSchedule schedule) async {
    return await _apiService.createMedicationSchedule(schedule);
  }

  Future<List<MedicationSchedule>> getMedicationSchedulesByElderId(String elderId) async {
    return await _apiService.getMedicationSchedulesByElderId(elderId);
  }

  Future<List<MedicationSchedule>> getMedicationSchedulesByCarerId(String carerId) async {
    return await _apiService.getMedicationSchedulesByCarerId(carerId);
  }

  Future<void> updateMedicationSchedule(MedicationSchedule schedule) async {
    // TODO: Implement update schedule API endpoint
  }

  Future<void> deleteMedicationSchedule(String id) async {
    await _apiService.deleteMedicationSchedule(id);
  }

  // Appointment operations
  Future<String> createAppointment(Appointment appointment) async {
    return await _apiService.createAppointment(appointment);
  }

  Future<List<Appointment>> getAppointmentsByElderId(String elderId) async {
    // TODO: Implement get appointments by elder ID
    return [];
  }

  Future<List<Appointment>> getAppointmentsByCarerId(String carerId) async {
    return await _apiService.getAppointmentsByCarerId(carerId);
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _apiService.updateAppointment(appointment);
  }

  Future<void> deleteAppointment(String id) async {
    await _apiService.deleteAppointment(id);
  }

  // Check-in operations
  Future<String> createCheckIn(CheckIn checkIn) async {
    return await _apiService.createCheckIn(checkIn);
  }

  Future<List<CheckIn>> getCheckInsByElderId(String elderId, {DateTime? startDate, DateTime? endDate}) async {
    return await _apiService.getCheckInsByElderId(elderId, startDate: startDate, endDate: endDate);
  }

  Future<List<CheckIn>> getCheckInsByMedicationScheduleId(String scheduleId) async {
    // TODO: Implement this endpoint in backend
    return [];
  }

  Future<CheckIn?> getTodayCheckIn(String medicationScheduleId) async {
    return await _apiService.getTodayCheckIn(medicationScheduleId);
  }
}

