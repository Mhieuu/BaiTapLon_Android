# 🔥 Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Project name: `baitaplon-android-1acec` (or your choice)
4. Click **"Continue"**
5. Uncheck **"Enable Google Analytics"** (optional)
6. Click **"Create project"**

---

## Step 2: Add Android Apps

### For Elder App
1. In Firebase Console, click **"Add app"**
2. Select **Android**
3. Package name: `com.eldercare.elder_app`
4. App nickname: `Elder App` (optional)
5. Debug SHA-1: (Get from: `keytool -list -v -keystore ~/.android/debug.keystore`)
   - Skip this for now, can add later
6. Click **"Register app"**
7. Download `google-services.json`
8. Move to: `elder_app/android/app/google-services.json`

### For Parent App
1. Repeat above steps with:
   - Package name: `com.eldercare.parent_app`
   - App nickname: `Parent App`
2. Download `google-services.json`
3. Move to: `parent_app/android/app/google-services.json`

---

## Step 3: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Click **Email/Password**
   - Enable **Email/Password**
   - Click **"Save"**
4. Click **Anonymous**
   - Enable **Anonymous**
   - Click **"Save"**

---

## Step 4: Create Firestore Database

1. Go to **Firestore Database**
2. Click **"Create database"**
3. Start in **Test mode** (for development, CHANGE IN PRODUCTION!)
4. Location: **asia-southeast1** (Singapore)
5. Click **"Create"**

**Important**: After testing, change to Production mode:
- Go to **Rules** tab
- Replace with content from `FIRESTORE_RULES.txt`
- Click **"Publish"**

---

## Step 5: Deploy Firestore Rules

1. Go to **Firestore > Rules**
2. Clear default rules
3. Paste content from `FIRESTORE_RULES.txt`
4. Click **"Publish"**

Example rules (see FIRESTORE_RULES.txt for full):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write only their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Parent users
    match /parent_users/{parentId} {
      allow read, write: if request.auth.uid == parentId;
    }
    
    // Medicine schedules
    match /medicine_schedules/{scheduleId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.elderId;
    }
    
    // ... other rules
  }
}
```

---

## Step 6: Enable Cloud Storage (Optional, for Photos)

1. Go to **Storage**
2. Click **"Get started"**
3. Start in **Test mode**
4. Location: **asia-southeast1**
5. Click **"Done"**

Update Firestore rules to include storage:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /elder_{elderId}/{fileName} {
      allow read, write: if request.auth.uid == elderId;
    }
  }
}
```

---

## Step 7: Enable Cloud Messaging (Optional, for Notifications)

1. Go to **Cloud Messaging**
2. Copy **Server API Key** (for backend)
3. Enable FCM for both apps

---

## Step 8: Verify Setup

### Check Google Services JSON
```bash
# For elder_app
cat elder_app/android/app/google-services.json

# For parent_app
cat parent_app/android/app/google-services.json
```

Must contain:
```json
{
  "project_info": {
    "project_id": "baitaplon-android-1acec",
    "storage_bucket": "baitaplon-android-1acec.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:397210354724:android:...",
        "android_client_info": {
          "package_name": "com.eldercare.elder_app"
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSy..."
        }
      ]
    }
  ]
}
```

### Test Connection
```bash
cd elder_app
flutter pub get
flutter run
```

---

## Step 9: Create Test User (Optional)

In Firebase Console:
1. Go to **Authentication > Users**
2. Click **"Add user"**
3. Email: `elder@test.com`
4. Password: `password123`
5. Click **"Add user"**

---

## ⚠️ Security Warnings

- ❌ **Never commit** `google-services.json` with production credentials
- ❌ **Never use** Test mode in production
- ✅ **Always use** proper Firestore rules
- ✅ **Use environment variables** for sensitive data
- ✅ **Enable Cloud Audit Logs** in production

---

## 🔧 Troubleshooting

### Error: "google-services.json not found"
```
Solution:
1. Ensure file path: android/app/google-services.json
2. Run: flutter clean
3. Run: flutter pub get
4. Run: flutter run
```

### Error: "Authentication is disabled"
```
Solution:
1. Go Firebase Console > Authentication
2. Enable Email/Password and Anonymous
3. Wait 2-3 minutes
4. Retry app
```

### Error: "Firestore permission denied"
```
Solution:
1. Go to Firestore > Rules
2. Check rules allow read/write for request.auth != null
3. Publish rules
4. Wait 1-2 minutes
5. Retry app
```

### Error: "Project ID mismatch"
```
Solution:
1. Check firebase_options.dart has correct projectId
2. Check google-services.json has same projectId
3. They must match!
```

---

## 📚 Additional Resources

- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Cloud Firestore Limits](https://firebase.google.com/docs/firestore/quotas)

---

## ✅ Checklist

- [ ] Firebase project created
- [ ] Android apps added
- [ ] google-services.json files placed
- [ ] Authentication enabled (Email + Anonymous)
- [ ] Firestore database created
- [ ] Firestore rules deployed
- [ ] Cloud Storage enabled (optional)
- [ ] Cloud Messaging enabled (optional)
- [ ] Test user created
- [ ] Apps can authenticate & read/write data

---

**All set!** Your Firebase is ready. Now go to TEST_GUIDE.md for testing instructions.
