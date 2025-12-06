# ⚡ Quick Start Guide

## 🎯 Tính năng chính

Elder App:
- ✅ User authentication (email/password)
- ✅ Real-time medicine schedule status
- ✅ Daily check-in tracking with late detection
- ✅ SOS alert button
- ✅ Dashboard with 3 status cards

Parent App:
- ✅ Login with elder ID
- ✅ Log medicine taken
- ✅ Check-in confirmation
- ✅ Send SOS alert
- ✅ Real-time status updates

---

## 🚀 Setup trong 5 phút

### 1️⃣ Clone project (Nếu chưa)
```bash
git clone <your-repo-url>
cd BaiTapLon_Android-1
```

### 2️⃣ Setup Firebase
```
👉 Mở file: FIREBASE_SETUP.md
👉 Làm theo hướng dẫn (7 steps, 10 phút)
👉 Save google-services.json vào android/app/ của mỗi app
```

### 3️⃣ Install dependencies
```bash
# Elder App
cd elder_app
flutter pub get

# Parent App
cd ../parent_app
flutter pub get
```

### 4️⃣ Run on device/emulator
```bash
# Terminal 1: Elder App
cd elder_app
flutter run

# Terminal 2: Parent App
cd parent_app
flutter run
```

### 5️⃣ Test features
```
Xem TEST_GUIDE.md để test cases chi tiết
```

---

## 📱 Test Workflow

### Step 1: Register Elder Account
1. Open **Elder App**
2. Tap **"Chuyển sang Đăng ký"** (Switch to signup)
3. Enter:
   - Name: `Grandpa`
   - Email: `elder@test.com`
   - Password: `password123`
4. Tap **"Đăng ký"** (Sign up)
5. **Copy the UID** from logs or Firebase Console
   ```
   Example UID: abc123xyz789...
   ```

### Step 2: Login Parent Account
1. Open **Parent App**
2. Enter **Elder ID** (the UID from step 1)
3. Tap **"Tiếp tục"** (Continue)

### Step 3: Test Medicine Schedule
1. In **Elder App**:
   - Tap **"Thuốc"** (Medicine) tab
   - Tap **"+ Tạo lịch"** (Add schedule)
   - Enter:
     - Medicine: `Paracetamol`
     - Quantity: `1`
     - Time: `09:00`
     - Type: `Tablet`
   - Tap **"Tạo"** (Create)
   - Dashboard should show **green card** (medicine due)

2. In **Parent App**:
   - Tap **"Thuốc"** (Medicine) button
   - You should see **blue feedback screen**
   - Elder dashboard should show **updated status**

### Step 4: Test Check-in
1. In **Parent App**:
   - Tap **"Kiểm tra"** (Check-in) button
   - You should see **green feedback screen**
   - If after 8 AM, should show as **late**

2. In **Elder App**:
   - Check-in card should show **green** (checked in on time)
   - Or **orange** (checked in late)

### Step 5: Test SOS Alert
1. In **Parent App**:
   - Tap **"SOS"** button
   - Should see **success dialog**
   - Alert card in Elder dashboard should turn **red**

---

## 🔧 File Structure

```
elder_app/
├── lib/
│   ├── main.dart                    # App entry & routing
│   ├── firebase_options.dart        # Firebase config
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── medicine_model.dart
│   │   ├── checkin_model.dart
│   │   ├── alert_model.dart
│   │   └── photo_model.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── medicine_service.dart
│   │   ├── checkin_service.dart
│   │   ├── alert_service.dart
│   │   └── photo_service.dart
│   └── screens/
│       ├── auth/login_screen.dart
│       └── dashboard/dashboard_screen.dart
│
parent_app/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── models/                      # Same as elder_app
│   ├── services/                    # Simplified versions
│   └── screens/
│       ├── auth/login_screen.dart
│       └── home/home_screen.dart

FIREBASE_SETUP.md                   # 👈 Start here!
TEST_GUIDE.md                       # 👈 For detailed testing
FIRESTORE_RULES.txt                 # 👈 Security rules
```

---

## ⚠️ Common Issues & Fixes

### ❌ "google-services.json not found"
```
✅ Solution:
   1. Download from Firebase Console
   2. Place at: android/app/google-services.json
   3. Run: flutter clean && flutter pub get
```

### ❌ "Authentication disabled"
```
✅ Solution:
   1. Go to Firebase Console > Authentication
   2. Enable Email/Password
   3. Enable Anonymous
   4. Wait 2 minutes
```

### ❌ "Permission denied on Firestore"
```
✅ Solution:
   1. Go to Firestore > Rules
   2. Copy from FIRESTORE_RULES.txt
   3. Publish rules
   4. Wait 1-2 minutes
```

### ❌ "Package name mismatch"
```
✅ Solution:
   1. Check android/app/build.gradle:
      applicationId "com.eldercare.elder_app"
   2. Matches Firebase registered package name
   3. Run: flutter clean && flutter pub get
```

### ❌ "Real-time updates not working"
```
✅ Solution:
   1. Check internet connection
   2. Check Firestore Rules allow read
   3. Check user is authenticated
   4. Restart app
```

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Firebase Backend                         │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │              Firestore (NoSQL Database)                  │  │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│   │  │    users     │  │parent_users  │  │   medicine_  │   │  │
│   │  │  collection  │  │ collection   │  │   schedules  │   │  │
│   │  └──────────────┘  └──────────────┘  └──────────────┘   │  │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│   │  │medicine_logs │  │checkin_logs  │  │   alerts     │   │  │
│   │  │ collection   │  │ collection   │  │ collection   │   │  │
│   │  └──────────────┘  └──────────────┘  └──────────────┘   │  │
│   └──────────────────────────────────────────────────────────┘  │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │             Cloud Storage (for photos)                   │  │
│   └──────────────────────────────────────────────────────────┘  │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │    Firebase Messaging (for notifications)               │  │
│   └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
                ┌─────────────┴─────────────┐
                │                           │
        ┌──────────────┐          ┌──────────────┐
        │  Elder App   │          │ Parent App   │
        ├──────────────┤          ├──────────────┤
        │ - Dashboard  │          │ - Home       │
        │ - Medicine   │          │ - Medicine   │
        │ - Check-in   │          │ - Check-in   │
        │ - SOS        │          │ - SOS        │
        │ - Photos     │          │ - Photos     │
        └──────────────┘          └──────────────┘
```

---

## 🎓 Learning Path

1. **Beginner**: Read this file (QUICK_START.md)
2. **Setup**: Follow FIREBASE_SETUP.md
3. **Testing**: Follow TEST_GUIDE.md
4. **Code**: Explore lib/models and lib/services
5. **Advanced**: Check README.md for full documentation

---

## 📞 Need Help?

- Check **FIRESTORE_RULES.txt** for database security
- Check **TEST_GUIDE.md** for detailed test cases
- Check **README.md** for full documentation
- Check **logs** with: `flutter logs`
- Check **Firebase Console** for errors

---

## ✅ Success Indicators

You know it's working when:

✅ Elder App:
- Can register with email/password
- Dashboard shows 3 status cards
- Cards update in real-time
- Can create medicine schedule
- Logout works

✅ Parent App:
- Can login with elder ID
- All 3 buttons (Medicine, Check-in, SOS) work
- Status updates visible in elder dashboard
- Feedback screens appear after action

✅ Real-time:
- Parent logs medicine → Elder dashboard updates within 1-2 seconds
- Parent check-in → Elder dashboard updates within 1-2 seconds
- Parent SOS → Elder alert card turns red within 1-2 seconds

---

**Ready? Let's go! 🚀**

1. 📖 Read: `FIREBASE_SETUP.md`
2. ⚙️ Setup: Follow 7 steps
3. 🧪 Test: Follow `TEST_GUIDE.md`
4. 🎉 Success!

Happy coding! 💚
