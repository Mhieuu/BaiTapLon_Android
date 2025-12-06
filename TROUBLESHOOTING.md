# 🔧 Troubleshooting Wizard

## Quick Diagnostic Tool

**Answer these questions to find your solution:**

---

## 1️⃣ What's Not Working?

### ❌ App won't launch
→ [Jump to Section A](#section-a-app-wont-launch)

### ❌ Can't login/register
→ [Jump to Section B](#section-b-authentication-errors)

### ❌ Real-time updates not working
→ [Jump to Section C](#section-c-real-time-issues)

### ❌ Can't create medicine schedule
→ [Jump to Section D](#section-d-medicine-schedule-issues)

### ❌ Check-in not working
→ [Jump to Section E](#section-e-check-in-issues)

### ❌ SOS alert not showing
→ [Jump to Section F](#section-f-sos-alert-issues)

### ❌ Firebase errors in console
→ [Jump to Section G](#section-g-firebase-errors)

### ❌ App crashes
→ [Jump to Section H](#section-h-app-crashes)

### ❌ Other issue
→ [Jump to Section I](#section-i-other-issues)

---

## Section A: App Won't Launch

### ❌ Error: "google-services.json not found"

**Cause:** Firebase config file missing

**Solution:**
1. Download from [Firebase Console](https://console.firebase.google.com)
2. Place at: `android/app/google-services.json`
3. Verify path is correct:
   ```
   BaiTapLon_Android-1/
   └── elder_app/
       └── android/
           └── app/
               └── google-services.json ✅
   ```
4. Run: `flutter clean && flutter pub get`
5. Rebuild: `flutter run`

---

### ❌ Error: "Gradle build failed"

**Cause:** Build system error

**Solution:**
```bash
# Clean everything
flutter clean
flutter pub get

# Rebuild
flutter run
```

If still fails:
```bash
# Delete gradle cache
cd android
./gradlew clean
cd ..
flutter run
```

---

### ❌ Error: "Package name mismatch"

**Cause:** App package name doesn't match Firebase config

**Solution:**
1. Check Firebase Console > Your app
2. Find package name (e.g., `com.eldercare.elder_app`)
3. Check `android/app/build.gradle`:
   ```gradle
   android {
       defaultConfig {
           applicationId "com.eldercare.elder_app"  // Must match!
       }
   }
   ```
4. Must match google-services.json package name
5. Run: `flutter clean && flutter pub get && flutter run`

---

### ❌ Error: "Device not found"

**Cause:** No connected device or emulator

**Solution:**

**Option 1: Connect physical device**
```bash
# Enable USB debugging on phone
# Connect USB cable
adb devices  # Should show device

flutter run
```

**Option 2: Start emulator**
```bash
# List available emulators
flutter emulators

# Start an emulator
flutter emulators --launch <emulator_name>

# Wait for startup (2-3 minutes)
flutter run
```

**Option 3: List devices**
```bash
flutter devices  # See all available devices
```

---

### ❌ Error: "SDK version mismatch"

**Cause:** Android SDK version too old

**Solution:**
1. Install Android SDK 34+:
   - Open Android Studio
   - Tools > SDK Manager
   - Install "Android 14.0 (API 34)"
2. Update `android/app/build.gradle`:
   ```gradle
   android {
       compileSdk 34  // Update this
       
       defaultConfig {
           targetSdk 34  // Update this
       }
   }
   ```
3. Run: `flutter pub get && flutter run`

---

## Section B: Authentication Errors

### ❌ Error: "Authentication disabled"

**Cause:** Firebase Authentication not enabled

**Solution:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click **Authentication** (left sidebar)
4. Click **Get started** (if shown)
5. Click **Email/Password**
6. Toggle to **Enable**
7. Click **Save**
8. Click **Anonymous**
9. Toggle to **Enable**
10. Click **Save**
11. Wait 2-3 minutes
12. Restart app: `flutter run`

---

### ❌ Error: "User not found" or "Wrong password"

**Cause:** Incorrect credentials

**Solution:**
1. Verify email exists in Firebase Console > Authentication
2. Verify password is correct
3. Check email for typos
4. Try creating new test user:
   ```
   Email: test@example.com
   Password: password123
   ```

---

### ❌ Error: "Email already in use"

**Cause:** User already registered

**Solution:**
1. Use different email, OR
2. Delete user from Firebase Console:
   - Authentication > Users
   - Find user
   - Click trash icon
   - Confirm delete
3. Wait 30 seconds
4. Try registering again

---

### ❌ Parent App: "Invalid elder ID"

**Cause:** Elder ID doesn't exist

**Solution:**
1. Get elder's UID from:
   - Firebase Console > Authentication > Users
   - OR from elder app logs: `flutter logs`
   - Look for "UID: abc123xyz..."
2. Copy exact UID (including all characters)
3. Paste into parent app login
4. Tap continue

---

### ❌ Error: "Permission denied" on login

**Cause:** Firestore rules not allowing operation

**Solution:**
1. Go to Firebase Console > Firestore
2. Click **Rules** tab
3. Copy from `FIRESTORE_RULES.txt`
4. Paste into rules editor
5. Click **Publish**
6. Wait 1-2 minutes
7. Restart app

---

## Section C: Real-time Issues

### ❌ Status cards not updating

**Cause:** Real-time stream not connected

**Solution:**

**Step 1: Check internet**
```bash
# Ping Firebase
# On Windows: ping firebase.google.com
```

**Step 2: Check Firestore rules**
1. Go to Firebase Console > Firestore > Rules
2. Rules must allow read for authenticated users:
   ```javascript
   allow read: if request.auth != null;
   ```
3. If not, update and publish

**Step 3: Check user is authenticated**
```dart
// In terminal:
flutter logs

// Look for:
// "User UID: abc123xyz..."
// If not shown, user not authenticated
```

**Step 4: Restart app**
```bash
flutter run --no-fast-start
```

**Step 5: Force refresh**
- Close app completely
- Wait 5 seconds
- Reopen app

---

### ❌ Delay in status updates (> 3 seconds)

**Cause:** Slow internet or large data

**Solution:**

**Option 1: Check internet speed**
- Use WiFi instead of mobile data
- Run speed test: speedtest.net

**Option 2: Reduce data**
- Delete old medicine schedules
- Archive old logs

**Option 3: Check Firestore indexes**
- Go to Firebase Console > Firestore > Indexes
- Ensure indexes are built for queries

---

### ❌ Stream keeps reconnecting

**Cause:** Network interruption or Firestore issue

**Solution:**
```bash
# Check Firebase status
# Go to: https://status.firebase.google.com

# Or restart device:
flutter run --no-fast-start
```

---

## Section D: Medicine Schedule Issues

### ❌ Can't create medicine schedule

**Cause:** Form validation or Firestore error

**Solution:**

**Check form fields:**
- [ ] Medicine name: Not empty
- [ ] Quantity: Not empty, valid number
- [ ] Time: Valid HH:mm format (09:00)
- [ ] Type: Selected from dropdown

**If form OK, check Firestore:**
1. Go to Firebase Console > Firestore
2. Check collection: `medicine_schedules`
3. Verify documents are being created
4. If not, check rules allow write:
   ```javascript
   match /medicine_schedules/{scheduleId} {
     allow write: if request.auth.uid == resource.data.elderId;
   }
   ```

**If rules OK:**
1. Check user is authenticated
2. Restart app
3. Try again

---

### ❌ Medicine status card shows "No data"

**Cause:** No medicine schedule created yet

**Solution:**
1. Go to Elder App > Medicine tab
2. Tap "+ Tạo lịch" (Create schedule)
3. Fill in form
4. Tap "Tạo" (Create)
5. Dashboard should update within 2 seconds

---

### ❌ Can't log medicine taken (Parent App)

**Cause:** No medicines scheduled for today

**Solution:**
1. In Elder App: Create medicine schedule
2. Ensure today's date is valid
3. Wait for real-time sync (1-2 seconds)
4. In Parent App: Tap "Thuốc" button again

---

### ❌ Time picker doesn't work

**Cause:** UI issue

**Solution:**
1. Tap time field
2. Time picker should appear
3. If not, check Flutter version:
   ```bash
   flutter --version
   # Should be 3.9.2+
   ```
4. If old version, update:
   ```bash
   flutter upgrade
   ```

---

## Section E: Check-in Issues

### ❌ Check-in button doesn't work

**Cause:** Service error or permissions

**Solution:**
1. Check user is authenticated
2. Check elderId is set
3. Verify Firestore rules allow write
4. Restart app: `flutter run`

---

### ❌ Check-in marked as "late" incorrectly

**Cause:** System time wrong or logic issue

**Solution:**
1. Check device time settings:
   - Settings > Date & Time
   - Enable automatic time
2. Current expected time: 8:00 AM
3. If device time is after 8:00 AM, marked as late ✅

---

### ❌ Check-in not showing on dashboard

**Cause:** Real-time sync delay

**Solution:**
1. Wait 2-3 seconds for sync
2. If still not showing:
   - Restart Elder App
   - Restart Parent App
   - Try check-in again

---

## Section F: SOS Alert Issues

### ❌ SOS button does nothing

**Cause:** Service error or permissions

**Solution:**
1. Check user is authenticated
2. Check elderId is valid
3. Restart app: `flutter run`

---

### ❌ Alert doesn't appear on dashboard

**Cause:** Real-time stream issue

**Solution:**
1. Wait 2-3 seconds
2. Check Firestore Console > alerts collection
3. Alert should exist as document
4. If exists but not showing:
   - Restart Elder App
   - Alert should appear in red

---

### ❌ Alert won't resolve

**Cause:** Permission or permission issue

**Solution:**
1. Alert can only be resolved by elder user
2. Ensure logged in as elder (not parent)
3. Refresh dashboard
4. Try again

---

## Section G: Firebase Errors

### ❌ Error: "PERMISSION_DENIED" on Firestore

**Cause:** Security rules don't allow operation

**Solution:**
1. Check Firestore > Rules
2. Find rule for failing operation
3. Ensure user is authenticated:
   ```javascript
   allow read, write: if request.auth != null;
   ```
4. Ensure user is owner of data:
   ```javascript
   allow write: if request.auth.uid == resource.data.elderId;
   ```
5. Publish rules
6. Wait 1-2 minutes
7. Retry

---

### ❌ Error: "UNAUTHENTICATED" on Firestore

**Cause:** User not logged in

**Solution:**
1. Verify login was successful
2. Check Firebase Console > Authentication
3. User should exist in list
4. App should show user UID in logs
5. Restart app and login again

---

### ❌ Error: "DEADLINE_EXCEEDED"

**Cause:** Firestore slow or connection timeout

**Solution:**
1. Check internet connection
2. Try operation again (usually temporary)
3. If persistent:
   - Clear app cache: Settings > Apps > Clear Cache
   - Restart device
   - Retry

---

### ❌ Error: "NOT_FOUND" on document

**Cause:** Document doesn't exist

**Solution:**
1. Check Firestore Console
2. Navigate to expected collection
3. Verify document ID is correct
4. If not found, create manually or via app

---

## Section H: App Crashes

### ❌ App crashes on startup

**Cause:** Firebase init error or bad data

**Solution:**

**Step 1: Check logs**
```bash
flutter logs
```

**Step 2: Look for error message:**
- FirebaseException
- NullPointerException
- other error

**Step 3: Common causes:**

**If "google-services.json not found":**
→ [See Section A](#section-a-app-wont-launch)

**If "NoSuchMethodError":**
- Bad data in Firestore
- Update data type
- Or delete and recreate document

**If "FlutterError":**
- Widget build error
- Usually in Firestore listen
- Clear app data and restart

---

### ❌ App crashes after login

**Cause:** Screen navigation or stream error

**Solution:**
1. Check logs: `flutter logs`
2. Look for specific error line
3. Check main.dart routing
4. Verify DashboardScreen exists
5. Restart app: `flutter run --no-fast-start`

---

### ❌ App crashes on button tap

**Cause:** Service error or network issue

**Solution:**
1. Check internet connection
2. Check Firestore status: status.firebase.google.com
3. Check logs: `flutter logs`
4. Restart app
5. Try again

---

## Section I: Other Issues

### ❌ "Package 'firebase_core' not found"

**Cause:** Dependencies not installed

**Solution:**
```bash
cd elder_app  # or parent_app
flutter pub get
flutter run
```

---

### ❌ "Gradle sync failed"

**Cause:** Dependency or build.gradle error

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

### ❌ "Unable to find device"

**Cause:** No device connected

**Solution:**
```bash
# List devices
flutter devices

# If empty, connect device or start emulator
flutter emulators --launch <emulator_name>
```

---

### ❌ "Old Dart version"

**Cause:** Dart outdated

**Solution:**
```bash
flutter upgrade
```

---

### ❌ "Permission denied" on build

**Cause:** File permissions (Linux/Mac)

**Solution:**
```bash
sudo chown -R $(whoami) .
flutter clean
flutter pub get
flutter run
```

---

### ❌ "Strange UI glitches"

**Cause:** Widget state issue

**Solution:**
1. Full restart:
   ```bash
   flutter clean
   flutter pub get
   flutter run --no-fast-start
   ```
2. Clear app cache: Settings > Apps > Clear Cache
3. Reinstall app

---

### ❌ Performance is slow

**Cause:** Too many real-time listeners

**Solution:**
1. Dispose streams when not needed
2. Limit number of concurrent streams
3. Clear old data from Firestore
4. Use pagination for large lists

---

## General Troubleshooting Steps

### Always try in this order:

1. **Check internet connection**
   ```bash
   ping 8.8.8.8
   ```

2. **Check logs**
   ```bash
   flutter logs
   ```

3. **Clean and rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Clear app data**
   - Settings > Apps > [App] > Storage > Clear cache/data

5. **Restart device**
   - Power off and on

6. **Update dependencies**
   ```bash
   flutter pub upgrade
   flutter pub get
   ```

7. **Check Firebase status**
   - https://status.firebase.google.com

8. **Verify Firebase Console**
   - Collections exist
   - Rules published
   - Auth enabled

9. **Recreate test data**
   - Create new test user
   - Create new test medicine
   - Try operation again

10. **Ask for help**
    - Check TEST_GUIDE.md troubleshooting
    - Check README.md known issues
    - Check ARCHITECTURE.md error handling

---

## 📞 When All Else Fails

### Check These Files:
1. **TEST_GUIDE.md** - 20+ detailed solutions
2. **README.md** - Known issues section
3. **ARCHITECTURE.md** - Error handling patterns
4. **Firebase Docs** - https://firebase.flutter.dev

### Common Issues & Quicklinks:

| Issue | File | Section |
|-------|------|---------|
| Google Services JSON | TEST_GUIDE.md | Prerequisites |
| Firebase Rules | FIRESTORE_RULES.txt | Full rules |
| Real-time not working | ARCHITECTURE.md | Synchronization |
| Authentication | ARCHITECTURE.md | Security section |
| Crashes | This file | Section H |

### Still Stuck?

1. Take a screenshot of error
2. Check error message word by word
3. Search this file with Ctrl+F
4. If not found, check README.md
5. Last resort: Recreate test case step by step

---

## Quick Reference

### Emergency: Full Reset

```bash
# Nuclear option - completely reset everything
flutter clean
rm -rf build/
rm -rf android/.gradle
rm -rf windows/flutter/ephemeral
flutter pub get
flutter pub upgrade
flutter run --no-fast-start
```

### Emergency: Clear App Data
- Settings > Apps > [App] > Storage > Clear all data
- Restart app
- Login again

### Emergency: Rebuild Everything
```bash
flutter clean
flutter pub get
flutter upgrade
flutter run --no-fast-start
```

---

**Can't find your issue?**

Try this:
1. Read the exact error message carefully
2. Search this document (Ctrl+F)
3. Check TEST_GUIDE.md
4. Check README.md
5. Check ARCHITECTURE.md
6. Check Firebase documentation

**Still need help?**

Provide:
- Error message (exact text)
- Steps to reproduce
- Screenshot of error
- Device info (OS, Android version)
- Firebase project ID

---

**Most issues are solved by:**
1. Restarting the app ✅
2. Clearing cache ✅
3. Checking internet ✅
4. Checking Firebase Console ✅

Try these first! 🚀
