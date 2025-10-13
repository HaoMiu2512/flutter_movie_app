# Troubleshooting Guide

## 🐛 Common Errors & Solutions

### 1. MissingPluginException (Facebook)

**Error:**
```
Facebook Sign-In failed: MissingPluginException(No implementation found
for method login on channel app.meedu/flutter_facebook_auth)
```

**Nguyên nhân:**
- Flutter chưa register Facebook plugin
- App chưa được rebuild sau khi thêm dependency

**Giải pháp:**
```bash
# 1. Stop app hiện tại (nếu đang chạy)
# Press 'q' trong terminal hoặc stop từ IDE

# 2. Clean build
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Rebuild app (QUAN TRỌNG!)
flutter run

# Hoặc nếu dùng IDE:
# - Stop app
# - Clean project
# - Rebuild & Run
```

**Lưu ý:**
- ⚠️ Hot reload/restart KHÔNG đủ khi thêm plugin mới
- ✅ Phải full rebuild (flutter run)
- ✅ Nếu vẫn lỗi, thử uninstall app từ device và rebuild

### 2. Facebook App Not Setup

**Error:**
```
Facebook Sign-In failed: APP_NOT_SETUP
```

**Nguyên nhân:**
- Chưa tạo Facebook App
- App ID/Client Token sai trong strings.xml
- Package name không khớp

**Giải pháp:**
1. **Check strings.xml:**
   ```xml
   <!-- File: android/app/src/main/res/values/strings.xml -->
   <string name="facebook_app_id">YOUR_ACTUAL_APP_ID</string>
   <string name="facebook_client_token">YOUR_ACTUAL_TOKEN</string>
   ```
   - Đảm bảo đã thay `YOUR_ACTUAL_APP_ID` bằng App ID thật
   - Không để "YOUR_APP_ID"

2. **Verify Facebook Console:**
   - Settings → Basic → App ID phải khớp
   - Package name: `com.example.flutter_movie_app`

3. **Rebuild app** sau khi sửa strings.xml

### 3. Invalid Key Hash

**Error:**
```
Invalid key hash. The key hash ... does not match any stored key hashes.
```

**Nguyên nhân:**
- Key hash chưa được add vào Facebook Console
- Debug vs Release key hash khác nhau

**Giải pháp:**

**1. Generate Key Hash:**

Windows:
```bash
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
```

Mac/Linux:
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

Password: `android`

**2. Add vào Facebook Console:**
- Settings → Basic → Key Hashes
- Paste key hash
- Save Changes

**3. Có thể add nhiều key hashes:**
- Debug key hash (development)
- Release key hash (production)

### 4. OAuth Redirect URI Error

**Error:**
```
Given URL is not allowed by the Application configuration
```

**Nguyên nhân:**
- OAuth Redirect URI chưa được configure trong Facebook

**Giải pháp:**
1. **Get URI từ Firebase:**
   - Firebase Console → Authentication → Facebook
   - Copy OAuth redirect URI
   - Ví dụ: `https://flutter-movie-app-253e7.firebaseapp.com/__/auth/handler`

2. **Add vào Facebook:**
   - Facebook Console → Facebook Login → Settings
   - "Valid OAuth Redirect URIs"
   - Paste URI
   - Save Changes

### 5. App in Development Mode

**Error:**
```
This app is in development mode and you don't have access to it.
```

**Nguyên nhân:**
- Facebook App ở Development mode
- User không phải admin/developer/tester

**Giải pháp:**

**Option A: Add as Tester (Development)**
1. Facebook Console → Roles → Test Users
2. Create test user hoặc Add people as Testers
3. Login app với test account

**Option B: Switch to Live Mode (Production)**
1. Facebook Console → Settings → Basic
2. Privacy Policy URL (bắt buộc)
3. Category
4. App Mode: Development → **Live**
5. Confirm

### 6. Firebase Facebook Not Enabled

**Error:**
```
Error: This operation is not allowed. Enable Facebook sign-in in Firebase.
```

**Nguyên nhân:**
- Facebook provider chưa enable trong Firebase

**Giải pháp:**
1. Firebase Console → Authentication
2. Sign-in method → Facebook → Enable
3. Enter App ID and App Secret
4. Save

### 7. Network Error

**Error:**
```
Network connection error. Please check your internet connection.
```

**Giải pháp:**
- Check internet connection
- Check emulator có internet không
- Restart emulator nếu cần
- Check Firebase project active

### 8. Phone Auth: Invalid Phone Number

**Error:**
```
Invalid phone number format
```

**Giải pháp:**
- Format: `+[country_code][number]`
- Ví dụ: `+84123456789`
- Không có dấu cách, dấu gạch ngang
- Country code bắt đầu bằng +

### 9. Phone Auth: Too Many Requests

**Error:**
```
TOO_MANY_REQUESTS: SMS quota exceeded
```

**Giải pháp:**
- Đợi vài phút trước khi thử lại
- Sử dụng test phone numbers
- Increase quota trong Firebase (nếu production)

### 10. Google Sign-In Cancelled

**Not an error:**
```
Google Sign-In was cancelled
```

**Giải pháp:**
- User đã cancel, không phải lỗi
- App đã handle đúng (không show error)

## 🔧 General Troubleshooting Steps

### Step 1: Clean Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Step 2: Verify Configuration

**Check files:**
- [ ] `pubspec.yaml` - dependencies correct
- [ ] `AndroidManifest.xml` - Facebook config present
- [ ] `strings.xml` - Real App ID/Token (not placeholders)
- [ ] `google-services.json` - Firebase config

### Step 3: Check Console Logs

Look for specific errors in terminal output:
```bash
# Run with verbose
flutter run -v

# Check for:
# - Plugin registration errors
# - Network errors
# - Firebase errors
# - Platform-specific errors
```

### Step 4: Platform-Specific

**Android:**
```bash
# Check gradle sync
cd android
./gradlew --refresh-dependencies

# Check app permissions in AndroidManifest.xml
# - INTERNET permission
```

**Emulator:**
```bash
# Check emulator has Google Play Services
# - Settings → About → Google Play services

# Restart emulator if needed
```

### Step 5: Firebase Console

Check Firebase Console:
- [ ] Project active
- [ ] Authentication enabled
- [ ] Providers enabled (Facebook, Phone)
- [ ] No billing issues
- [ ] API keys active

### Step 6: Facebook Console

Check Facebook Console:
- [ ] App created
- [ ] Facebook Login added
- [ ] Android platform configured
- [ ] Key hashes added
- [ ] OAuth redirect URI added
- [ ] App mode (Development vs Live)

## 📝 Debug Checklist

### Before Running App:
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Clean build if added new plugins
- [ ] Configuration files updated
- [ ] Firebase project accessible
- [ ] Internet connection working

### When Error Occurs:
- [ ] Read full error message
- [ ] Check this troubleshooting guide
- [ ] Search error in documentation
- [ ] Check Firebase/Facebook console
- [ ] Try clean rebuild

### Testing:
- [ ] Test on real device (not just emulator)
- [ ] Test with different accounts
- [ ] Test cancellation flows
- [ ] Test error scenarios
- [ ] Check console logs

## 🆘 Still Having Issues?

### Debugging Commands:

```bash
# Check Flutter installation
flutter doctor -v

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Check device connection
flutter devices

# Run with verbose logging
flutter run -v
```

### Log Files:

Check these locations for detailed logs:
- Terminal output from `flutter run -v`
- Android Logcat (in Android Studio)
- Firebase Console → Authentication → Logs
- Facebook Console → Webhooks & Errors

### Get Help:

1. **Documentation:**
   - [FACEBOOK_AUTH_SETUP_GUIDE.md](FACEBOOK_AUTH_SETUP_GUIDE.md)
   - [PHONE_AUTH_TESTING_GUIDE.md](PHONE_AUTH_TESTING_GUIDE.md)

2. **Check Console:**
   - Firebase Console error logs
   - Facebook Console error messages

3. **Stack Overflow:**
   - Search exact error message
   - Include platform (Android/iOS)

4. **GitHub Issues:**
   - flutter_facebook_auth issues
   - firebase_auth issues

## ✅ Prevention Tips

### Best Practices:

1. **Always rebuild** after:
   - Adding new dependencies
   - Changing native code
   - Updating configuration files

2. **Keep credentials organized:**
   - Document App IDs
   - Save Key Hashes
   - Track OAuth URLs

3. **Test incrementally:**
   - Test each auth method separately
   - Verify before moving to next feature

4. **Version control:**
   - Commit working states
   - Don't commit real credentials
   - Use `.gitignore` for secrets

5. **Documentation:**
   - Read setup guides fully
   - Follow steps in order
   - Don't skip configuration steps

## 🎯 Quick Fixes

| Error | Quick Fix |
|-------|-----------|
| MissingPluginException | `flutter clean && flutter run` |
| Invalid credentials | Check strings.xml |
| Key hash error | Generate and add to Facebook |
| OAuth error | Add redirect URI |
| Development mode | Add tester or go Live |
| Network error | Check internet |
| Firebase error | Check Firebase Console |

---

**Last Updated:** October 13, 2025

**Need more help?** Check the detailed setup guides! 📚
