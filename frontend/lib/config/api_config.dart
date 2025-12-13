import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Tự động detect platform để chọn đúng base URL
  static String get baseUrl {
    if (kIsWeb) {
      // Web: dùng localhost
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android emulator: dùng 10.0.2.2 (alias của localhost)
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // iOS simulator: dùng localhost
      return 'http://localhost:3000/api';
    } else {
      // Desktop (Windows/Mac/Linux): dùng localhost
      return 'http://localhost:3000/api';
    }
  }
  
  // Production URL (uncomment khi deploy)
  // static const String baseUrl = 'https://your-api-domain.com/api';
  
  // Timeout cho requests (giây)
  static const int requestTimeout = 30;
  
  // Log base URL khi khởi tạo (để debug)
  static void logBaseUrl() {
    print('🌐 [API_CONFIG] Base URL: $baseUrl');
    print('🌐 [API_CONFIG] Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
  }
}

