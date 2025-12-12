// Tạm thời comment out workmanager do lỗi tương thích
// import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'alert_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  Timer? _alertTimer;
  String? _currentCarerId;

  // Khởi tạo background service
  Future<void> initialize() async {
    print('✅ [BACKGROUND] BackgroundService đã khởi tạo (dùng Timer thay vì workmanager)');
  }

  // Bắt đầu periodic task để kiểm tra alerts mỗi 1 phút (khi app đang chạy)
  Future<void> startAlertChecking(String carerId) async {
    // Dừng timer cũ nếu có
    _alertTimer?.cancel();
    
    _currentCarerId = carerId;
    
    // Lưu carerId để có thể truy cập sau
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_carer_id', json.encode(carerId));

    // Tạo Timer để check alerts mỗi 1 phút (chỉ khi app đang chạy)
    _alertTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        if (_currentCarerId != null) {
          try {
            final alertService = AlertService();
            await alertService.checkAndSendAlerts(_currentCarerId!);
            await alertService.checkCallRequests(_currentCarerId!);
          } catch (e) {
            print('❌ [BACKGROUND] Lỗi khi check alerts: $e');
          }
        }
      },
    );

    // Check ngay lập tức lần đầu
    try {
      final alertService = AlertService();
      await alertService.checkAndSendAlerts(carerId);
      await alertService.checkCallRequests(carerId);
    } catch (e) {
      print('❌ [BACKGROUND] Lỗi khi check alerts lần đầu: $e');
    }

    print('✅ [BACKGROUND] Đã bắt đầu Timer để check alerts mỗi 15 phút cho carer: $carerId');
    print('⚠️ [BACKGROUND] Lưu ý: Timer chỉ hoạt động khi app đang chạy. Khi app đóng, alerts sẽ không được check tự động.');
  }

  // Dừng periodic task
  Future<void> stopAlertChecking() async {
    _alertTimer?.cancel();
    _alertTimer = null;
    _currentCarerId = null;
    print('🛑 [BACKGROUND] Đã dừng Timer check alerts');
  }
}


