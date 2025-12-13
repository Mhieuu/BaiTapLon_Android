import 'package:flutter/foundation.dart';
import '../models/check_in.dart';
import '../repositories/checkin_repository.dart';
import '../config/app_config.dart';
import '../services/mock_data_service.dart';

class CheckInViewModel extends ChangeNotifier {
  final CheckInRepository _repository = CheckInRepository();
  
  List<CheckIn> _checkIns = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CheckIn> get checkIns => _checkIns;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create check-in
  Future<bool> createCheckIn(CheckIn checkIn) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.createCheckIn(checkIn);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get today's check-in for a schedule
  Future<CheckIn?> getTodayCheckIn(String medicationScheduleId) async {
    try {
      return await _repository.getTodayCheckIn(medicationScheduleId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Load check-in history
  Future<void> loadCheckInHistory(
    String elderId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // 🎭 MOCK MODE: Sử dụng dữ liệu demo
      if (AppConfig.MOCK_MODE) {
        await Future.delayed(const Duration(milliseconds: 500));
        _checkIns = MockDataService.getMockCheckIns();
        // Sort by date descending
        _checkIns.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
        print('🎭 [CHECKIN] Loaded ${_checkIns.length} mock check-ins');
        notifyListeners();
        return;
      }
      
      // LIVE MODE: Gọi API thực
      _checkIns = await _repository.getCheckInsByElderId(
        elderId,
        startDate: startDate,
        endDate: endDate,
      );
      // Sort by date descending
      _checkIns.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Calculate compliance rate
  double calculateComplianceRate() {
    if (_checkIns.isEmpty) return 0.0;
    final onTimeCount = _checkIns.where((c) => c.isOnTime).length;
    return (onTimeCount / _checkIns.length) * 100;
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





