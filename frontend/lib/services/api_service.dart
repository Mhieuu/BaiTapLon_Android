import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/medication_schedule.dart';
import '../models/appointment.dart';
import '../models/check_in.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // Log base URL khi khởi tạo để debug
    ApiConfig.logBaseUrl();
    print('🔗 [API_SERVICE] Khởi tạo với baseUrl: $baseUrl');
  }

  String get baseUrl => ApiConfig.baseUrl;

  // Helper method để xử lý response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Lỗi parse response: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // ========== USER APIs ==========

  Future<Map<String, dynamic>> register(User user) async {
    try {
      final url = '$baseUrl/users/register';
      print('📤 [API] Register - URL: $url');
      print('📤 [API] Register - Data: ${user.name}, ${user.phoneNumber}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': user.name,
          'phoneNumber': user.phoneNumber,
          'email': user.email,
          'type': user.type.toString().split('.').last,
        }),
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
        onTimeout: () {
          print('⏱️ [API] Register - Request timeout');
          throw Exception('Request timeout - Backend có thể chưa chạy');
        },
      );
      
      print('📥 [API] Register - Response status: ${response.statusCode}');
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('❌ [API] Register - Connection error: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra backend có đang chạy không: $e');
    } catch (e) {
      print('❌ [API] Register - Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String phoneNumber) async {
    try {
      final url = '$baseUrl/users/login';
      print('📤 [API] Login - URL: $url');
      print('📤 [API] Login - Phone: $phoneNumber');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phoneNumber': phoneNumber}),
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
        onTimeout: () {
          print('⏱️ [API] Login - Request timeout');
          throw Exception('Request timeout - Backend có thể chưa chạy');
        },
      );
      
      print('📥 [API] Login - Response status: ${response.statusCode}');
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('❌ [API] Login - Connection error: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra backend có đang chạy không: $e');
    } catch (e) {
      print('❌ [API] Login - Error: $e');
      rethrow;
    }
  }

  Future<User> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  Future<bool> linkCarerAndElder(String carerId, String elderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/link'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'carerId': carerId,
        'elderId': elderId,
      }),
    );
    final data = _handleResponse(response);
    return data['success'] ?? false;
  }

  // ========== CALL REQUEST APIs ==========

  Future<String> createCallRequest({
    required String elderId,
    required String carerId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/call-requests'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'elderId': elderId,
        'carerId': carerId,
      }),
    );
    final data = _handleResponse(response);
    return data['requestId'] ?? '';
  }

  Future<List<Map<String, dynamic>>> getPendingCallRequestsForCarer(
      String carerId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/call-requests/carer/$carerId'));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      throw Exception('Unexpected response format: ${data.runtimeType}');
    } else {
      final error = json.decode(response.body);
      throw Exception(
          error['error'] ?? 'Request failed với status ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getCallRequestsForCarer({
    required String carerId,
    bool includeAcknowledged = false,
  }) async {
    final url =
        '$baseUrl/call-requests/carer/$carerId${includeAcknowledged ? '?all=true' : ''}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      throw Exception('Unexpected response format: ${data.runtimeType}');
    } else {
      final error = json.decode(response.body);
      throw Exception(
          error['error'] ?? 'Request failed với status ${response.statusCode}');
    }
  }

  Future<void> acknowledgeCallRequest(String requestId) async {
    final response =
        await http.post(Uri.parse('$baseUrl/call-requests/$requestId/ack'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = json.decode(response.body);
      throw Exception(
          error['error'] ?? 'Request failed với status ${response.statusCode}');
    }
  }

  // Gửi request liên kết
  Future<Map<String, dynamic>> sendLinkRequest(String carerId, String elderPhoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/link-request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'carerId': carerId,
        'elderPhoneNumber': elderPhoneNumber,
      }),
    );
    return _handleResponse(response);
  }

  // Kiểm tra trạng thái request
  Future<Map<String, dynamic>?> getLinkRequestStatus(String carerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/link-request-status/$carerId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) return null;
      return data;
    }
    return null;
  }

  // Lấy các request chờ xác nhận của elder
  Future<List<Map<String, dynamic>>> getLinkRequestsForElder(String elderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/link-requests/$elderId'),
    );
    
    // Backend trả về List trực tiếp, không phải Map
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((r) => r as Map<String, dynamic>).toList();
        } else {
          throw Exception('Expected List but got ${data.runtimeType}');
        }
      } catch (e) {
        throw Exception('Lỗi parse response: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // Xác nhận hoặc từ chối request
  Future<Map<String, dynamic>> confirmLinkRequest({
    required String requestId,
    required String elderId,
    required bool accept,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/link-confirm'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'requestId': requestId,
        'elderId': elderId,
        'accept': accept,
      }),
    );
    return _handleResponse(response);
  }

  // ========== MEDICATION SCHEDULE APIs ==========

  Future<String> createMedicationSchedule(MedicationSchedule schedule) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medication-schedules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'carerId': schedule.carerId,
        'elderId': schedule.elderId,
        'medicationName': schedule.medicationName,
        'dosage': schedule.dosage,
        'time': {
          'hour': schedule.time.hour,
          'minute': schedule.time.minute,
        },
        'daysOfWeek': schedule.daysOfWeek,
        'specificDates': schedule.specificDates ?? [],
        'isActive': schedule.isActive,
      }),
    );
    final data = _handleResponse(response);
    return data['scheduleId'] ?? '';
  }

  Future<List<MedicationSchedule>> getMedicationSchedulesByCarerId(String carerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medication-schedules/carer/$carerId'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((s) => MedicationSchedule.fromJson(s)).toList();
        }
        throw Exception('Lỗi parse response: expected List nhưng nhận ${data.runtimeType}');
      } catch (e) {
        throw Exception('Lỗi parse response: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
    }
  }

  Future<List<MedicationSchedule>> getMedicationSchedulesByElderId(String elderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medication-schedules/elder/$elderId'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((s) => MedicationSchedule.fromJson(s)).toList();
        }
        throw Exception('Lỗi parse response: expected List nhưng nhận ${data.runtimeType}');
      } catch (e) {
        throw Exception('Lỗi parse response: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
    }
  }

  Future<void> deleteMedicationSchedule(String id) async {
    await http.delete(Uri.parse('$baseUrl/medication-schedules/$id'));
  }

  Future<void> updateMedicationSchedule(String id, MedicationSchedule schedule) async {
    final response = await http.put(
      Uri.parse('$baseUrl/medication-schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'carerId': schedule.carerId,
        'elderId': schedule.elderId,
        'medicationName': schedule.medicationName,
        'dosage': schedule.dosage,
        'time': {
          'hour': schedule.time.hour,
          'minute': schedule.time.minute,
        },
        'daysOfWeek': schedule.daysOfWeek,
        'specificDates': schedule.specificDates ?? [],
        'isActive': schedule.isActive,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
    }
  }

  // ========== CHECK-IN APIs ==========

  Future<String> createCheckIn(CheckIn checkIn) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-ins'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'medicationScheduleId': checkIn.medicationScheduleId,
        'elderId': checkIn.elderId,
        'checkInTime': checkIn.checkInTime.toIso8601String(),
        'isOnTime': checkIn.isOnTime,
        'notes': checkIn.notes,
      }),
    );
    final data = _handleResponse(response);
    return data['checkInId'] ?? '';
  }

  Future<CheckIn?> getTodayCheckIn(String medicationScheduleId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-ins/today/$medicationScheduleId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) return null;
      return CheckIn.fromJson(data);
    }
    return null;
  }

  Future<List<CheckIn>> getCheckInsByElderId(
    String elderId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String url = '$baseUrl/check-ins/elder/$elderId';
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    
    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(Uri.parse(url));
    
    // Backend trả về List trực tiếp, không phải Map
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((c) => CheckIn.fromJson(c as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Expected List but got ${data.runtimeType}');
        }
      } catch (e) {
        throw Exception('Lỗi parse response: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // ========== APPOINTMENT APIs ==========

  Future<String> createAppointment(Appointment appointment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'carerId': appointment.carerId,
        'elderId': appointment.elderId,
        'title': appointment.title,
        'description': appointment.description,
        'dateTime': appointment.dateTime.toIso8601String(),
        'location': appointment.location,
        'isCompleted': appointment.isCompleted,
      }),
    );
    final data = _handleResponse(response);
    return data['appointmentId'] ?? '';
  }

  Future<List<Appointment>> getAppointmentsByCarerId(String carerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/carer/$carerId'),
    );
    final data = _handleResponse(response);
    return (data as List).map((a) => Appointment.fromJson(a)).toList();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await http.put(
      Uri.parse('$baseUrl/appointments/${appointment.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': appointment.title,
        'description': appointment.description,
        'dateTime': appointment.dateTime.toIso8601String(),
        'location': appointment.location,
        'isCompleted': appointment.isCompleted,
      }),
    );
  }

  Future<void> deleteAppointment(String id) async {
    await http.delete(Uri.parse('$baseUrl/appointments/$id'));
  }

  // ========== PHOTO SHARING APIs ==========

  Future<String> uploadPhoto({
    required String carerId,
    required String elderId,
    required String imageBase64,
    String? description,
  }) async {
    try {
      final url = '$baseUrl/photos';
      print('📤 [API] Upload Photo - URL: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'carerId': carerId,
          'elderId': elderId,
          'imageBase64': imageBase64,
          'description': description ?? '',
        }),
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
        onTimeout: () {
          print('⏱️ [API] Upload Photo - Request timeout');
          throw Exception('Request timeout - Backend có thể chưa chạy');
        },
      );
      
      print('📥 [API] Upload Photo - Response status: ${response.statusCode}');
      final data = _handleResponse(response);
      return data['photoId'] ?? '';
    } on http.ClientException catch (e) {
      print('❌ [API] Upload Photo - Connection error: $e');
      throw Exception('Không thể kết nối đến server: $e');
    } catch (e) {
      print('❌ [API] Upload Photo - Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPhotosByElderId(String elderId) async {
    try {
      final url = '$baseUrl/photos/elder/$elderId';
      print('📤 [API] Get Photos by Elder - URL: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
        onTimeout: () {
          print('⏱️ [API] Get Photos - Request timeout');
          throw Exception('Request timeout - Backend có thể chưa chạy');
        },
      );
      
      print('📥 [API] Get Photos - Response status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        throw Exception('Unexpected response format: ${data.runtimeType}');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ [API] Get Photos - Connection error: $e');
      throw Exception('Không thể kết nối đến server: $e');
    } catch (e) {
      print('❌ [API] Get Photos - Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPhotosByCarerId(String carerId) async {
    try {
      final url = '$baseUrl/photos/carer/$carerId';
      print('📤 [API] Get Photos by Carer - URL: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
        onTimeout: () {
          print('⏱️ [API] Get Photos - Request timeout');
          throw Exception('Request timeout - Backend có thể chưa chạy');
        },
      );
      
      print('📥 [API] Get Photos - Response status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        throw Exception('Unexpected response format: ${data.runtimeType}');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Request failed với status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ [API] Get Photos - Connection error: $e');
      throw Exception('Không thể kết nối đến server: $e');
    } catch (e) {
      print('❌ [API] Get Photos - Error: $e');
      rethrow;
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      final url = '$baseUrl/photos/$id';
      print('📤 [API] Delete Photo - URL: $url');
      
      await http.delete(Uri.parse(url)).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
        onTimeout: () {
          print('⏱️ [API] Delete Photo - Request timeout');
          throw Exception('Request timeout - Backend có thể chưa chạy');
        },
      );
      
      print('✅ [API] Delete Photo - Success');
    } on http.ClientException catch (e) {
      print('❌ [API] Delete Photo - Connection error: $e');
      throw Exception('Không thể kết nối đến server: $e');
    } catch (e) {
      print('❌ [API] Delete Photo - Error: $e');
      rethrow;
    }
  }
}

