import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../models/medication_schedule.dart';
import '../models/check_in.dart';
import 'notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // Kiểm tra và gửi cảnh báo cho tất cả schedules chưa check-in sau 30 phút
  Future<void> checkAndSendAlerts(String carerId) async {
    try {
      print('🔔 [ALERT_SERVICE] Bắt đầu kiểm tra alerts cho carer: $carerId');
      
      // Lấy tất cả schedules của carer
      final schedules = await _apiService.getMedicationSchedulesByCarerId(carerId);
      
      final now = DateTime.now();
      final alertsToSend = <Map<String, dynamic>>[];

      for (var schedule in schedules) {
        // Kiểm tra xem có phải ngày hôm nay và đã đến giờ uống chưa
        if (!_isTodaySchedule(schedule, now)) continue;
        if (!_isTimeToTake(schedule, now)) continue;

        // Kiểm tra xem đã check-in chưa
        final checkIn = await _apiService.getTodayCheckIn(schedule.id);
        if (checkIn != null) continue; // Đã check-in rồi

        // Tính thời gian đã trôi qua từ giờ uống thuốc
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          schedule.time.hour,
          schedule.time.minute,
        );

        final minutesPassed = now.difference(scheduledTime).inMinutes;

        // Nếu đã qua 30 phút mà chưa check-in, gửi alert
        if (minutesPassed >= 30) {
          alertsToSend.add({
            'schedule': schedule,
            'minutesPassed': minutesPassed,
          });
        }
      }

      // Gửi notifications
      for (var alert in alertsToSend) {
        final schedule = alert['schedule'] as MedicationSchedule;
        final minutesPassed = alert['minutesPassed'] as int;
        
        await _sendAlertToCarer(
          carerId: carerId,
          medicationName: schedule.medicationName,
          scheduledTime: '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
          minutesPassed: minutesPassed,
        );
      }

      print('🔔 [ALERT_SERVICE] Đã gửi ${alertsToSend.length} alerts');
    } catch (e) {
      print('❌ [ALERT_SERVICE] Lỗi kiểm tra alerts: $e');
    }
  }

  // Kiểm tra yêu cầu gọi lại cho carer (con)
  Future<void> checkCallRequests(String carerId) async {
    try {
      final requests = await _apiService.getPendingCallRequestsForCarer(carerId);

      for (final request in requests) {
        final elderName = request['elderName'] ?? 'Cha/Mẹ';
        final elderPhone = request['elderPhone'] ?? '';
        final body =
            '$elderName đang muốn bạn gọi lại khi rảnh. SĐT: $elderPhone';

        await _notificationService.showAlertNotification(
          title: 'Yêu cầu gọi lại',
          body: body,
        );

        if (request['id'] != null) {
          await _apiService.acknowledgeCallRequest(request['id']);
        }
      }
    } catch (e) {
      print('❌ [ALERT_SERVICE] Lỗi kiểm tra yêu cầu gọi lại: $e');
    }
  }

  // Gửi alert cho carer
  Future<void> _sendAlertToCarer({
    required String carerId,
    required String medicationName,
    required String scheduledTime,
    required int minutesPassed,
  }) async {
    final title = '⚠️ Cảnh báo!';
    final body = 'Cha Mẹ chưa xác nhận uống thuốc $medicationName (${scheduledTime}). Đã trễ ${minutesPassed} phút.';

    await _notificationService.showAlertNotification(
      title: title,
      body: body,
    );

    // Có thể thêm: Gửi qua API để lưu vào database hoặc gửi email/SMS
    print('📢 [ALERT_SERVICE] Đã gửi alert: $body');
  }

  // Kiểm tra xem schedule có phải hôm nay không
  bool _isTodaySchedule(MedicationSchedule schedule, DateTime now) {
    final today = now.weekday % 7; // 0 = CN, 1 = T2, ..., 6 = T7
    return schedule.daysOfWeek.contains(today);
  }

  // Kiểm tra xem đã đến giờ uống thuốc chưa
  bool _isTimeToTake(MedicationSchedule schedule, DateTime now) {
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      schedule.time.hour,
      schedule.time.minute,
    );
    return now.isAfter(scheduledTime);
  }

  // Gửi SOS alert cho carer
  Future<void> sendSOSAlert({
    required String carerId,
    required String elderName,
    required String elderPhone,
  }) async {
    final title = '🚨 SOS KHẨN CẤP!';
    final body = '$elderName ($elderPhone) đã bấm nút SOS khẩn cấp!';

    await _notificationService.showSOSNotification(
      title: title,
      body: body,
    );

    print('🚨 [ALERT_SERVICE] Đã gửi SOS alert: $body');
  }
}


