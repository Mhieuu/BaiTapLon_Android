# An Tâm - Hệ thống Hỗ trợ Chăm sóc Người cao tuổi

## Tổng quan
"An Tâm" là một hệ thống ứng dụng "ghép cặp" được thiết kế để kết nối con cái (đang đi làm, bận rộn) với cha mẹ lớn tuổi (sống một mình hoặc ở xa).

## Cấu trúc Dự án

### Hai Ứng dụng:
1. **App "Con"** - Cho Người Chăm sóc: Trung tâm chỉ huy để lên lịch, theo dõi, và nhận cảnh báo
2. **App "Cha Mẹ"** - Cho Người cao tuổi: Ứng dụng cực kỳ đơn giản với 3 nút bấm lớn

## Cài đặt

1. Cài đặt Flutter SDK
2. Clone repository
3. Chạy `flutter pub get`
4. Cấu hình MongoDB connection string trong `lib/config/database_config.dart`
5. Chạy app: `flutter run`

## Cấu trúc Thư mục

```
lib/
├── main.dart
├── config/
│   └── database_config.dart
├── models/
│   ├── user.dart
│   ├── medication_schedule.dart
│   ├── appointment.dart
│   └── check_in.dart
├── services/
│   ├── database_service.dart
│   ├── notification_service.dart
│   └── auth_service.dart
├── app_con/
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── schedule_screen.dart
│   │   └── history_screen.dart
│   └── widgets/
├── app_parent/
│   ├── screens/
│   │   └── main_screen.dart
│   └── widgets/
└── shared/
    ├── widgets/
    └── utils/
```

## Tính năng Chính

### App "Con":
- Tạo lịch uống thuốc
- Tạo lịch hẹn tái khám
- Dashboard theo dõi trạng thái
- Nhận cảnh báo khi cha mẹ chưa check-in
- Xem lịch sử check-in

### App "Cha Mẹ":
- Nút SOS khẩn cấp
- Nút Check-in uống thuốc
- Nút Gọi Con
- Giao diện cực kỳ đơn giản, font chữ lớn





