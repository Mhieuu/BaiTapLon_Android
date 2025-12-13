import 'package:flutter/foundation.dart';
import '../models/medication_schedule.dart';
import '../repositories/medication_repository.dart';
import '../config/app_config.dart';
import '../services/mock_data_service.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationRepository _repository = MedicationRepository();
  
  List<MedicationSchedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MedicationSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load schedules by carer ID
  Future<void> loadSchedulesByCarer(String carerId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // 🎭 MOCK MODE: Sử dụng dữ liệu demo
      if (AppConfig.MOCK_MODE) {
        await Future.delayed(const Duration(milliseconds: 500));
        _schedules = MockDataService.getMockMedicationSchedules();
        print('🎭 [MEDICATION] Loaded ${_schedules.length} mock schedules');
        notifyListeners();
        return;
      }
      
      // LIVE MODE: Gọi API thực
      _schedules = await _repository.getSchedulesByCarerId(carerId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load schedules by elder ID
  Future<void> loadSchedulesByElder(String elderId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _schedules = await _repository.getSchedulesByElderId(elderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create new schedule
  Future<bool> createSchedule(MedicationSchedule schedule) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.createSchedule(schedule);
      // Reload schedules
      if (schedule.carerId.isNotEmpty) {
        await loadSchedulesByCarer(schedule.carerId);
      } else if (schedule.elderId.isNotEmpty) {
        await loadSchedulesByElder(schedule.elderId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete schedule
  Future<bool> deleteSchedule(String id, String carerId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.deleteSchedule(id);
      // Reload schedules
      await loadSchedulesByCarer(carerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update schedule
  Future<bool> updateSchedule(String id, MedicationSchedule schedule) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.updateSchedule(id, schedule);
      await loadSchedulesByCarer(schedule.carerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get current medication (for elder app)
  MedicationSchedule? getCurrentMedication() {
    final now = DateTime.now();
    print('🔍 [MEDICATION_VM] Đang tìm lịch hiện tại từ ${_schedules.length} lịch');
    
    for (final schedule in _schedules) {
      final isToday = schedule.isToday();
      final isTimeToTake = schedule.isTimeToTake();
      print('  - ${schedule.medicationName}: isToday=$isToday, isTimeToTake=$isTimeToTake, isActive=${schedule.isActive}');
      
      if (isTimeToTake) {
        print('✅ [MEDICATION_VM] Tìm thấy lịch: ${schedule.medicationName}');
        return schedule;
      }
    }
    
    print('❌ [MEDICATION_VM] Không tìm thấy lịch nào phù hợp');
    return null;
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





