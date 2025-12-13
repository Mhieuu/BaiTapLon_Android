# 🎭 MOCK MODE - Hướng dẫn chạy App mà không cần Backend

## Tổng quan

App được tích hợp sẵn **MOCK MODE** để bạn có thể demo giao diện và tính năng mà **KHÔNG CẦN BACKEND API**.

## Cách bật MOCK MODE

1. Mở file: `lib/config/app_config.dart`
2. Đảm bảo `MOCK_MODE = true`:

```dart
static const bool MOCK_MODE = true;  // ✅ Bật để dùng mock data
```

3. Khi có backend, đổi về `false`:

```dart
static const bool MOCK_MODE = false;  // 🌐 Kết nối API thực
```

## Tài khoản Demo

Khi `MOCK_MODE = true`, sử dụng các SĐT sau để đăng nhập:

### 👵 Người cao tuổi (Carer)
- **Số điện thoại:** `0123456789`
- **Tên:** Bà Nguyễn Thị Lan
- **Giao diện:** Dashboard với lịch uống thuốc, check-in, hẹn khám

### 👨‍👩‍👧 Người thân (Parent)
- **Số điện thoại:** `0987654321`
- **Tên:** Anh Trần Văn Nam
- **Giao diện:** Theo dõi người cao tuổi, xem lịch sử, cài đặt

## Dữ liệu Demo

Mock data bao gồm:

### ✅ Lịch uống thuốc (Medication Schedules)
- Thuốc huyết áp Amlodipine (8:00 sáng, 19:00 tối)
- Vitamin D3 (12:00 trưa)
- Thuốc tiểu đường Metformin (sáng-chiều-tối)
- Omega-3 (20:00 tối)

### ✅ Lịch sử Check-in (7 ngày gần đây)
- Check-in sáng & tối mỗi ngày
- Một số check-in đúng giờ, một số trễ
- Có ghi chú cụ thể

### ✅ Lịch hẹn khám (Appointments)
- Khám tim mạch (sắp tới)
- Xét nghiệm đường huyết (sắp tới)
- Khám mắt (đã hoàn thành)

### ✅ Thông báo
- Nhắc nhở uống thuốc
- Check-in thành công
- Lịch hẹn sắp tới

### ✅ Ảnh slideshow
- 5 ảnh demo từ Picsum

## Chạy App

```bash
# Di chuyển vào thư mục frontend
cd frontend

# Cài dependencies (nếu chưa)
flutter pub get

# Chạy app
flutter run

# Hoặc chọn device cụ thể
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d <device-id>   # Android/iOS
```

## Kiểm tra Mode

Khi app khởi động, check console log:

### Mock Mode (có banner cam ở màn hình login):
```
🎭 [APP_CONFIG] MOCK MODE - Sử dụng dữ liệu demo
📱 Demo Người cao tuổi: 0123456789
👨‍👩‍👧 Demo Người thân: 0987654321
```

### Live Mode (kết nối API):
```
🌐 [APP_CONFIG] LIVE MODE - Kết nối backend API
🌐 [API_CONFIG] Base URL: http://localhost:3000/api
```

## Lợi ích Mock Mode

✅ **Demo giao diện** mà không cần setup backend  
✅ **Test UI/UX** nhanh chóng  
✅ **Phát triển frontend** độc lập  
✅ **Presentation** cho stakeholders  
✅ **Kiểm tra responsive** trên nhiều devices  

## Chuyển sang Live Mode

Khi đã có backend API:

1. Đổi `MOCK_MODE = false` trong `app_config.dart`
2. Cấu hình đúng `baseUrl` trong `api_config.dart`
3. Đảm bảo backend đang chạy
4. Restart app

## Lưu ý

- Mock data chỉ tồn tại trong session hiện tại
- Không có API call thực khi ở Mock Mode
- Một số tính năng như upload ảnh, gửi notification thực sẽ bị giới hạn
- Mock data được cấu hình trong `lib/services/mock_data_service.dart`

## Tùy chỉnh Mock Data

Để thêm/sửa mock data, chỉnh sửa file:
```
lib/services/mock_data_service.dart
```

Ví dụ thêm lịch uống thuốc:
```dart
MedicationSchedule(
  id: 'med_005',
  carerId: 'carer_001',
  medicationName: 'Tên thuốc mới',
  dosage: '1 viên',
  frequency: 'Sáng',
  time: '07:00',
  notes: 'Ghi chú',
  isActive: true,
  createdAt: DateTime.now(),
),
```

---

**Happy Coding! 🚀**
