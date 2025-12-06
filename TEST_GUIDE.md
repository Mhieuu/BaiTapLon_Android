# 🎯 Hướng dẫn Test Firebase & Build APK

## 📋 Yêu cầu trước khi test

### 1. Cấu hình Firebase Console

**👉 Xem chi tiết tại: `FIREBASE_SETUP.md`**

Tóm tắt các bước:
- [ ] Truy cập [Firebase Console](https://console.firebase.google.com)
- [ ] Chọn project `baitaplon-android-1acec` (hoặc tạo mới)
- [ ] Add Android apps với package names:
  - `com.eldercare.elder_app`
  - `com.eldercare.parent_app`
- [ ] Download `google-services.json` cho mỗi app
- [ ] Đặt vào: `android/app/google-services.json`

### 2. Enable Firebase Services
- [ ] **Authentication**: Enable `Email/Password` & `Anonymous`
- [ ] **Firestore**: Create database (Location: Asia Southeast 1)
- [ ] **Firestore Rules**: Publish rules từ `FIRESTORE_RULES.txt`
- [ ] **Cloud Storage**: Enable (cho photo upload) - Optional
- [ ] **Cloud Messaging**: Enable (cho notifications) - Optional

---

## 🚀 Build & Run trên Android

### Opcion 1: Build APK (Production)
```bash
# Elder App
cd elder_app
flutter build apk --release

# Parent App
cd ../parent_app
flutter build apk --release
```

APK files sẽ ở:
- `elder_app/build/app/outputs/apk/release/app-release.apk`
- `parent_app/build/app/outputs/apk/release/app-release.apk`

### Option 2: Run trên Device/Emulator (Dev)
```bash
# Kết nối Android Device hoặc start emulator

# Elder App
cd elder_app
flutter run

# Parent App (terminal khác)
cd parent_app
flutter run
```

---

## 🧪 Test Cases

### Test Case 1: User Registration & Login
**Elder App:**
1. Tấn home screen → click "Đăng Ký"
2. Điền: Email, Password, Tên
3. Click "Đăng Ký"
4. ✅ Expect: Redirect to Dashboard

**Parent App:**
1. Tấn home screen
2. Điền: Elder ID (từ Elder App account UID)
3. Click "Tiếp tục"
4. ✅ Expect: Redirect to Home (3 buttons)

### Test Case 2: Medicine Schedule
**Elder App:**
1. Dashboard → BottomNav → "Lịch thuốc"
2. Điền: Tên thuốc, Số viên, Giờ, Loại
3. Click "Tạo Lịch"
4. ✅ Expect: "Tạo lịch uống thuốc thành công"
5. Dashboard → Check "Uống Thuốc" card

**Parent App:**
1. Home → Click "Đã Uống Thuốc"
2. ✅ Expect: Feedback screen → "Đã ghi nhận thuốc"
3. Elder App → Dashboard → "Uống Thuốc" card update realtime ✅

### Test Case 3: Check-in
**Parent App:**
1. Home → Click "Check-in"
2. ✅ Expect: Feedback screen → "Check-in thành công"
3. Elder App → Dashboard → "Check-in" card update realtime ✅

### Test Case 4: SOS
**Parent App:**
1. Home → Click "SOS"
2. ✅ Expect: Alert dialog → "SOS Gửi Thành Công"
3. Elder App → Dashboard → "Cảnh báo" card update realtime ✅

---

## 🔥 Firebase Console - Kiểm tra Data

Sau khi test, vào **Firebase Console > Firestore**:

```
Collections:
├── users/ (Elder accounts)
│   └── {uid}
│       ├── email: string
│       ├── name: string
│       └── createdAt: timestamp
│
├── parent_users/ (Parent accounts)
│   └── {uid}
│       ├── elderId: string
│       └── createdAt: timestamp
│
├── medicine_schedules/ (Lịch thuốc)
│   └── {scheduleId}
│       ├── elderId: string
│       ├── medicineName: string
│       └── scheduledTime: string
│
├── medicine_logs/ (Log uống thuốc)
│   └── {logId}
│       ├── elderId: string
│       ├── medicineName: string
│       └── takenAt: timestamp
│
├── checkin_logs/ (Log check-in)
│   └── {checkinId}
│       ├── elderId: string
│       ├── checkinTime: timestamp
│       └── isLate: boolean
│
├── alerts/ (Cảnh báo)
│   └── {alertId}
│       ├── elderId: string
│       ├── alertType: string (sos, missed_medicine, no_checkin)
│       └── createdAt: timestamp
│
└── elder_status/ (Realtime status)
    └── {elderId}
        ├── medicine_status: string
        ├── checkin_today: boolean
        └── latest_alert: string
```

---

## 🆘 Troubleshooting

### Error: "google-services.json not found"
- ✅ Ensure `google-services.json` ở:
  - `elder_app/android/app/google-services.json`
  - `parent_app/android/app/google-services.json`

### Error: "Permission denied" in Firestore
- ✅ Kiểm tra Firebase Rules (FIRESTORE_RULES.txt)
- ✅ Ensure Authentication enabled

### App crashes on login
- ✅ Check `firebase_options.dart` credentials
- ✅ Ensure Firebase project ID đúng

### Realtime updates không work
- ✅ Kiểm tra Firestore rules cho `.where()` queries
- ✅ Ensure StreamBuilder bắt đúng elderId

---

## 📱 Build Android App Bundle (Play Store)
```bash
cd elder_app
flutter build appbundle --release

# File: elder_app/build/app/outputs/bundle/release/app-release.aab
```

---

## ✅ Checklist trước deploy
- [ ] Firebase rules deployed
- [ ] All collections created
- [ ] Test cases all pass
- [ ] No console errors
- [ ] APK/AAB built successfully
- [ ] App signed with keystore

Goodluck! 🚀
