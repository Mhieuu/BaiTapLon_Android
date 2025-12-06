# 👴👵 Elder Care System - Android Flutter App

Một hệ thống ứng dụng Flutter tích hợp cho quản lý sức khỏe người cao tuổi, gồm 2 apps:
- **Elder App** (Người con) - Quản lý dashboard, lịch thuốc, lịch sử
- **Parent App** (Cha/Mẹ) - UI siêu đơn giản, 3 nút chính

---

## 🎯 Features

### ✅ Module A: Authentication
- [x] Login/Register Elder App
- [x] Anonymous Login Parent App
- [x] Firebase Authentication
- [x] User Profile Management

### ✅ Module B: Medicine Schedule
- [x] Create Medicine Schedule (Elder)
- [x] Log Medicine Taken (Parent)
- [x] Realtime Status Card
- [x] Medicine History

### ✅ Module C: Daily Check-in
- [x] Check-in Button (Parent)
- [x] Late Detection
- [x] Realtime Status Update
- [x] Check-in History

### ✅ Module D: SOS Alert
- [x] SOS Button (Parent)
- [x] Alert Creation & Stream
- [x] Realtime Notification
- [x] Alert Resolution

### ✅ Module E: Dashboard
- [x] 3 Status Cards (Medicine, Checkin, Alert)
- [x] BottomNav Navigation
- [x] Realtime Updates via Firestore

### ⏳ Module F: Photo Sharing
- [ ] Photo Upload (Elder)
- [ ] Photo Gallery (Elder)
- [ ] Slideshow (Parent)

---

## 📁 Project Structure

```
BaiTapLon_Android-1/
├── elder_app/                          # Ứng dụng người con
│   ├── lib/
│   │   ├── main.dart                   # Entry point
│   │   ├── firebase_options.dart       # Firebase config
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── medicine_model.dart
│   │   │   ├── checkin_model.dart
│   │   │   ├── alert_model.dart
│   │   │   └── photo_model.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── medicine_service.dart
│   │   │   ├── checkin_service.dart
│   │   │   ├── alert_service.dart
│   │   │   └── photo_service.dart
│   │   └── screens/
│   │       ├── auth/
│   │       │   └── login_screen.dart
│   │       ├── dashboard/
│   │       │   ├── dashboard_screen.dart
│   │       │   ├── medicine_status_card.dart
│   │       │   ├── checkin_status_card.dart
│   │       │   └── alert_status_card.dart
│   │       ├── schedule/
│   │       │   └── create_schedule_screen.dart
│   │       ├── history/
│   │       │   └── (coming soon)
│   │       ├── alerts/
│   │       │   └── (coming soon)
│   │       └── photos/
│   │           └── (coming soon)
│   ├── android/
│   │   └── app/
│   │       └── google-services.json    # Firebase config
│   └── pubspec.yaml
│
├── parent_app/                         # Ứng dụng cha/mẹ
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart
│   │   ├── models/                     # Same as elder_app
│   │   ├── services/                   # Same as elder_app
│   │   └── screens/
│   │       ├── auth/
│   │       │   └── login_screen.dart
│   │       └── home/
│   │           └── home_screen.dart
│   ├── android/
│   │   └── app/
│   │       └── google-services.json
│   └── pubspec.yaml
│
├── FIRESTORE_RULES.txt                 # Firestore Security Rules
├── TEST_GUIDE.md                       # Testing instructions
└── README.md                           # This file
```

---

## 🔧 Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod (prepare), currently StreamBuilder
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Language**: Dart 3.0+
- **Database**: Firestore NoSQL
- **Platform**: Android (iOS support ready)

---

## 📦 Dependencies

```yaml
firebase_core: ^4.2.1
firebase_auth: ^6.1.2
cloud_firestore: ^6.1.0
firebase_storage: ^13.0.4
firebase_messaging: ^16.0.4
url_launcher: ^6.3.2
```

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.9.2+ installed
- Android Studio / Xcode
- Firebase account
- Emulator or Physical Device

### Setup

```bash
# 1. Clone repository
cd BaiTapLon_Android-1

# 2. Setup Elder App
cd elder_app
flutter pub get
flutter run

# 3. Setup Parent App (new terminal)
cd parent_app
flutter pub get
flutter run
```

### Firebase Setup
1. Create Firebase Project: `baitaplon-android-1acec`
2. Add Android apps with packages:
   - `com.eldercare.elder_app`
   - `com.eldercare.parent_app`
3. Download `google-services.json` → place in `android/app/`
4. Deploy Firestore Rules (see `FIRESTORE_RULES.txt`)

---

## 🧪 Testing

See **TEST_GUIDE.md** for detailed test cases.

### Quick Test Flow
1. **Register** Elder → Get UID
2. **Login** Parent with Elder UID
3. **Create** Medicine Schedule
4. **Parent clicks** "Đã uống thuốc"
5. **Elder sees** status update realtime ✅

---

## 📊 Data Models

### User (Elder)
```dart
{
  'uid': 'string',
  'email': 'string',
  'name': 'string',
  'phone': 'string?',
  'userType': 'elder',
  'createdAt': 'timestamp'
}
```

### MedicineSchedule
```dart
{
  'id': 'string',
  'elderId': 'string',
  'medicineName': 'string',
  'quantity': 'int',
  'scheduledTime': 'HH:mm',
  'medicineType': 'string',
  'notes': 'string?',
  'isActive': 'bool',
  'createdAt': 'timestamp'
}
```

### ElderStatus (Realtime)
```dart
{
  'medicine_status': 'done|pending',
  'checkin_today': 'bool',
  'is_checkin_late': 'bool',
  'latest_alert': 'sos|missed_medicine|no_checkin|null',
  'updated_at': 'timestamp'
}
```

---

## 🔐 Security

- Firebase Authentication (Email + Anonymous)
- Firestore Security Rules (see FIRESTORE_RULES.txt)
- Data validation on client & server
- No sensitive data in logs

---

## 🐛 Known Issues & Todos

### Known Issues
- [ ] Photo upload not yet implemented
- [ ] Slideshow not yet implemented
- [ ] History screens not yet implemented
- [ ] Offline mode not yet implemented

### Todos
- [ ] Implement photo upload to Firebase Storage
- [ ] Create photo gallery screen (Elder)
- [ ] Create slideshow screen (Parent)
- [ ] Add medicine history screen
- [ ] Add alert history screen
- [ ] Add check-in history screen
- [ ] Implement push notifications
- [ ] Implement offline sync
- [ ] Dark mode support
- [ ] Multi-language support (Vietnamese, English)

---

## 📱 Screenshots

Coming soon...

---

## 👨‍💻 Development

### Run with Debug
```bash
flutter run
```

### Run Release Build
```bash
flutter run --release
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
dart format lib/
```

---

## 🚀 Build for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (if needed)
```bash
flutter build ios --release
```

---

## 📞 Contact & Support

- **GitHub**: [BaiTapLon_Android](https://github.com/Mhieuu/BaiTapLon_Android)
- **Issues**: Report bugs in GitHub Issues
- **Email**: contact@eldercare.com (placeholder)

---

## 📄 License

MIT License - See LICENSE file

---

## 🙏 Credits

Developed for **Bài Tập Lớn - Android Development**

---

## 🎓 Learning Resources

- [Flutter Official Docs](https://flutter.dev/docs)
- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Dart Language](https://dart.dev/)

---

**Last Updated**: December 6, 2025

Happy Coding! 🚀
