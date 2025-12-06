# ✅ Deployment Checklist

## 📋 Pre-Deployment Verification

### Code Quality
- [ ] `flutter analyze` passes with no errors
- [ ] All imports are correct
- [ ] No unused variables or imports
- [ ] Code follows Dart style guide
- [ ] No hardcoded sensitive data (API keys, passwords)

```bash
# Run analysis
cd elder_app
flutter analyze

cd ../parent_app
flutter analyze
```

### Firebase Configuration
- [ ] `firebase_options.dart` contains correct credentials
- [ ] `google-services.json` exists in both apps
- [ ] Project ID is correct: `baitaplon-android-1acec`
- [ ] API key is valid: `AIzaSyBvQqmwp1SCxOKqjcMVi1w5GOdDQHk8SYA`
- [ ] Firebase services are enabled:
  - [ ] Authentication (Email/Password + Anonymous)
  - [ ] Firestore Database
  - [ ] Cloud Storage (for photos)
  - [ ] Cloud Messaging (for notifications)

### Firestore Setup
- [ ] Firestore database created in Firebase Console
- [ ] Database location: **asia-southeast1**
- [ ] Security rules deployed (from FIRESTORE_RULES.txt)
- [ ] Test user created: `elder@test.com / password123`

### Dependencies
- [ ] All packages installed: `flutter pub get`
- [ ] No version conflicts
- [ ] Package versions compatible with Flutter 3.9.2+

```bash
# Check pubspec.lock
flutter pub get
flutter pub list
```

### Android Configuration
- [ ] Minimum SDK: Android 21+
- [ ] Target SDK: Android 34+
- [ ] Package names correct:
  - [ ] `com.eldercare.elder_app`
  - [ ] `com.eldercare.parent_app`
- [ ] App permissions in `AndroidManifest.xml`:
  - [ ] INTERNET
  - [ ] CAMERA (for photos)
  - [ ] READ_EXTERNAL_STORAGE
  - [ ] WRITE_EXTERNAL_STORAGE

---

## 🔨 Build & Release Process

### Step 1: Clean Build
```bash
# Elder App
cd elder_app
flutter clean
flutter pub get

# Parent App
cd ../parent_app
flutter clean
flutter pub get
```

### Step 2: Test on Emulator/Device
```bash
# Make sure device is connected
adb devices

# Test Elder App
cd elder_app
flutter run

# Test Parent App (in another terminal)
cd parent_app
flutter run
```

### Step 3: Build APK (Debug)
```bash
# Elder App
cd elder_app
flutter build apk --debug

# Parent App
cd ../parent_app
flutter build apk --debug
```

Check: `build/app/outputs/apk/debug/app-debug.apk`

### Step 4: Build APK (Release)
```bash
# Elder App
cd elder_app
flutter build apk --release

# Parent App
cd ../parent_app
flutter build apk --release
```

Check: `build/app/outputs/apk/release/app-release.apk`

### Step 5: Build App Bundle (for Play Store)
```bash
# Elder App
cd elder_app
flutter build appbundle --release

# Parent App
cd ../parent_app
flutter build appbundle --release
```

Check: `build/app/outputs/bundle/release/app-release.aab`

---

## 🧪 Pre-Release Testing

### Authentication Testing
- [ ] Elder can register with email/password
- [ ] Elder can login with valid credentials
- [ ] Elder cannot login with invalid credentials
- [ ] Login shows appropriate error messages
- [ ] Logout works correctly
- [ ] Parent can login with valid elder ID
- [ ] Parent cannot login with invalid elder ID

### Dashboard Testing
- [ ] Dashboard loads after authentication
- [ ] All 3 status cards render correctly
- [ ] Cards display correct data
- [ ] Real-time updates work (refresh within 2 seconds)
- [ ] Navigation between tabs works
- [ ] Bottom navigation is responsive

### Medicine Testing
- [ ] Can create medicine schedule
- [ ] Schedule appears in list
- [ ] Parent can log medicine taken
- [ ] Status card updates when medicine logged
- [ ] Can update medicine schedule
- [ ] Can delete medicine schedule
- [ ] Time picker works correctly

### Check-in Testing
- [ ] Parent can log check-in
- [ ] Elder dashboard updates after check-in
- [ ] Late detection works (after 8 AM)
- [ ] Can check-in multiple times per day
- [ ] Time is recorded correctly

### Alert Testing
- [ ] Parent can send SOS alert
- [ ] Alert appears in elder dashboard (red card)
- [ ] Unresolved alerts display correctly
- [ ] Alert can be marked as resolved
- [ ] Only active alerts show in dashboard

### Real-time Synchronization
- [ ] Open app on 2 devices (elder + parent)
- [ ] Parent logs medicine → Elder app updates within 2 seconds
- [ ] Parent check-in → Elder app updates within 2 seconds
- [ ] Parent SOS → Elder app updates within 2 seconds
- [ ] No lag or sync delays

### Error Handling
- [ ] Network error handling (offline message)
- [ ] Firebase error messages are helpful
- [ ] App doesn't crash on errors
- [ ] User can retry failed operations

---

## 📊 Performance Testing

### Load Time
- [ ] App launches in < 3 seconds
- [ ] Dashboard loads in < 2 seconds
- [ ] Status cards render in < 1 second
- [ ] Real-time updates don't cause lag

### Memory
- [ ] No memory leaks (check with Android Studio Profiler)
- [ ] App uses < 150MB RAM on average
- [ ] No crashes during extended usage

### Battery
- [ ] Firestore streams not draining battery excessively
- [ ] Background processes minimal when app is closed

---

## 🔐 Security Checklist

- [ ] Firestore rules in place (from FIRESTORE_RULES.txt)
- [ ] Rules prevent unauthorized access
- [ ] API keys not exposed in source code
- [ ] Passwords never stored in code
- [ ] HTTPS enforced for all API calls
- [ ] User data encrypted in transit
- [ ] No sensitive data in logs

```
Firestore Rules Check:
- [ ] Users can only read/write their own documents
- [ ] Parent users can only read/write their own documents
- [ ] Authenticated users can read relevant data
- [ ] All write operations require authentication
```

---

## 📱 Device Testing

### Android 9 (SDK 28)
- [ ] App installs successfully
- [ ] All features work
- [ ] No permission issues
- [ ] No crashes

### Android 10 (SDK 29)
- [ ] App installs successfully
- [ ] All features work
- [ ] Storage permissions work correctly
- [ ] No crashes

### Android 11 (SDK 30)
- [ ] App installs successfully
- [ ] All features work
- [ ] Scoped storage handled correctly
- [ ] No crashes

### Android 12+ (SDK 31+)
- [ ] App installs successfully
- [ ] All features work
- [ ] Notification permissions requested
- [ ] No crashes

---

## 📦 APK Distribution

### Upload to Play Store (Optional)
1. Go to [Google Play Console](https://play.google.com/console)
2. Create app listings
3. Upload app bundle (APB file)
4. Fill in app info:
   - [ ] App title
   - [ ] Description
   - [ ] Screenshots
   - [ ] Privacy policy
   - [ ] Permissions justification
5. Request release review
6. Publish

### Direct APK Distribution
1. Build APK files
2. Host on secure server
3. Create QR code linking to download
4. Share installation instructions
5. Monitor crash reports

---

## 🚀 Post-Deployment

### Monitoring
- [ ] Enable Firebase Crash Analytics
- [ ] Monitor error logs in Firebase Console
- [ ] Check app usage statistics
- [ ] Monitor user feedback

### User Communication
- [ ] Create user guide/documentation
- [ ] Provide support contact
- [ ] Share known issues (if any)
- [ ] Provide update schedule

### Maintenance
- [ ] Regular security updates
- [ ] Monitor Firebase quota usage
- [ ] Check for deprecated dependencies
- [ ] Update dependencies regularly

```bash
# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

---

## 📝 Sign-off Checklist

**Pre-Release Sign-off:**

- [ ] All tests passed
- [ ] Code review completed
- [ ] Performance verified
- [ ] Security review done
- [ ] Firebase setup confirmed
- [ ] Documentation complete
- [ ] APK successfully built
- [ ] Installation successful on test device
- [ ] All features working as expected

**Release Sign-off:**

- [ ] APK ready for distribution
- [ ] User documentation ready
- [ ] Support team briefed
- [ ] Monitoring set up
- [ ] Go/No-go decision made

---

## 🆘 Troubleshooting Reference

### If app crashes on launch:
1. Check `flutter logs`
2. Verify Firebase initialization in main.dart
3. Check google-services.json is present
4. Run `flutter clean && flutter pub get`

### If real-time updates don't work:
1. Check internet connection
2. Verify Firestore rules allow read
3. Check user is authenticated
4. Verify collection paths are correct
5. Restart app

### If authentication fails:
1. Verify Firebase Authentication is enabled
2. Check Email/Password is enabled
3. Verify user exists in Firebase Console
4. Check error message in app logs

### If push notifications don't work:
1. Verify Firebase Cloud Messaging enabled
2. Check app has notification permissions
3. Verify FCM token is generated
4. Check notification topic subscriptions

---

## 📞 Support & Documentation

**Files to Reference:**
- `QUICK_START.md` - Quick setup guide
- `FIREBASE_SETUP.md` - Detailed Firebase setup
- `TEST_GUIDE.md` - Comprehensive testing guide
- `README.md` - Full project documentation
- `FIRESTORE_RULES.txt` - Database security rules

**Resources:**
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Android Documentation](https://developer.android.com/docs)

---

## ✅ Final Status

**Pre-Deployment:** _(Fill in before release)_

- Code Quality: _____ / 10
- Firebase Setup: _____ / 10
- Testing Coverage: _____ / 10
- Security Review: _____ / 10
- Performance: _____ / 10

**Overall Readiness:** ____% 

**Ready for Release:** ☐ YES  ☐ NO

**Sign-off Date:** _______________

**Sign-off Person:** _______________

---

**All checks passed? Let's deploy! 🚀**
