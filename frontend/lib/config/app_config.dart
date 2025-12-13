class AppConfig {
  // 🎭 BẬT MOCK_MODE = true ĐỂ CHẠY APP MÀ KHÔNG CẦN BACKEND API
  // Đặt về false khi đã có backend thực
  static const bool MOCK_MODE = true;
  
  // Mock users cho demo (chỉ dùng khi MOCK_MODE = true)
  static const String MOCK_CARER_PHONE = '0123456789';
  static const String MOCK_PARENT_PHONE = '0987654321';
  
  // Thời gian buffer để check-in đúng giờ (phút)
  static const int checkInBufferMinutes = 30;
  
  // Thời gian chờ trước khi gửi cảnh báo (phút)
  static const int alertDelayMinutes = 30;
  
  // Thời gian slideshow ảnh (giây)
  static const int photoSlideshowIntervalSeconds = 5;
  
  // Kích thước font tối thiểu cho app Cha Mẹ
  static const double minFontSize = 24.0;
  
  // Kích thước nút tối thiểu cho app Cha Mẹ
  static const double minButtonSize = 100.0;
  
  static void logMode() {
    if (MOCK_MODE) {
      print('🎭 [APP_CONFIG] MOCK MODE - Sử dụng dữ liệu demo');
      print('📱 Demo Người cao tuổi: $MOCK_CARER_PHONE');
      print('👨‍👩‍👧 Demo Người thân: $MOCK_PARENT_PHONE');
    } else {
      print('🌐 [APP_CONFIG] LIVE MODE - Kết nối backend API');
    }
  }
}

