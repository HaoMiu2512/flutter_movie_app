# Facebook Authentication Setup Guide

## 📱 Tổng Quan

Tính năng Facebook Authentication đã được tích hợp hoàn chỉnh vào Flutter Movie App với Firebase Authentication.

## ✅ Những gì đã hoàn thành

### 1. Code Implementation
- ✅ [auth_service.dart](lib/services/auth_service.dart) - Đã thêm Facebook auth methods
- ✅ [login_page.dart](lib/LoginPage/login_page.dart) - Facebook login button functional
- ✅ [register_page.dart](lib/LoginPage/register_page.dart) - Facebook register button functional
- ✅ [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) - Facebook configuration added
- ✅ [strings.xml](android/app/src/main/res/values/strings.xml) - Facebook App ID placeholder

### 2. Dependencies
- ✅ flutter_facebook_auth: ^7.1.2

### 3. Features
- ✅ Sign in with Facebook
- ✅ Get Facebook user data (name, email, profile picture)
- ✅ Firebase integration
- ✅ Error handling
- ✅ Loading states
- ✅ Success/error messages

## 🔧 Cấu Hình Facebook App

### Bước 1: Tạo Facebook App

1. **Truy cập Facebook Developers Console:**
   - https://developers.facebook.com/
   - Đăng nhập với tài khoản Facebook của bạn

2. **Tạo App mới:**
   - Click "My Apps" → "Create App"
   - Chọn "Consumer" hoặc "None" (tùy use case)
   - App Name: `Flutter Movie App` (hoặc tên bạn muốn)
   - App Contact Email: Email của bạn
   - Click "Create App"

3. **Lưu App ID và Client Token:**
   - Sau khi tạo app, bạn sẽ thấy App ID và Client Token
   - **App ID**: Số dài (VD: 123456789012345)
   - **Client Token**: String dài
   - Lưu lại 2 giá trị này

### Bước 2: Cấu hình Facebook Login

1. **Thêm Facebook Login Product:**
   - Trong Dashboard, click "Add Product"
   - Tìm "Facebook Login" và click "Set Up"
   - Chọn "Android" platform

2. **Cấu hình Android:**

   **a. Google Play Package Name:**
   ```
   com.example.flutter_movie_app
   ```

   **b. Default Activity Class Name:**
   ```
   com.example.flutter_movie_app.MainActivity
   ```

   **c. Key Hashes:**

   Để lấy Development Key Hash, chạy lệnh:

   **Windows:**
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
   ```
   Password: `android`

   **Mac/Linux:**
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```
   Password: `android`

   Copy Key Hash và paste vào Facebook Console.

3. **Save Changes:**
   - Click "Save"
   - Click "Next" để hoàn tất setup

### Bước 3: Enable Facebook Login trong Firebase

1. **Truy cập Firebase Console:**
   - https://console.firebase.google.com/
   - Chọn project: `flutter-movie-app-253e7`

2. **Enable Facebook Provider:**
   - Vào **Authentication** → **Sign-in method**
   - Tìm **Facebook** và click **Enable**

3. **Nhập App ID và App Secret:**
   - **App ID**: Copy từ Facebook Developers Console
   - **App Secret**:
     - Vào Facebook Developers Console
     - Settings → Basic
     - Copy "App Secret" (click "Show" nếu cần)
   - Paste vào Firebase

4. **Copy OAuth redirect URI:**
   - Firebase sẽ show OAuth redirect URI
   - Copy URL này (VD: https://flutter-movie-app-253e7.firebaseapp.com/__/auth/handler)

5. **Click "Save" trong Firebase**

### Bước 4: Cấu hình OAuth Redirect URI trong Facebook

1. **Quay lại Facebook Developers Console:**
   - Facebook Login → Settings

2. **Valid OAuth Redirect URIs:**
   - Paste OAuth redirect URI từ Firebase
   - Click "Save Changes"

### Bước 5: Cập nhật strings.xml

1. **Mở file:** `android/app/src/main/res/values/strings.xml`

2. **Thay thế placeholders:**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <string name="app_name">Flutter Movie App</string>

       <!-- Facebook Configuration -->
       <string name="facebook_app_id">YOUR_ACTUAL_APP_ID</string>
       <string name="facebook_client_token">YOUR_ACTUAL_CLIENT_TOKEN</string>
       <string name="fb_login_protocol_scheme">fbYOUR_ACTUAL_APP_ID</string>
   </resources>
   ```

3. **Ví dụ với App ID = 123456789012345:**
   ```xml
   <string name="facebook_app_id">123456789012345</string>
   <string name="facebook_client_token">abcdef1234567890abcdef1234567890</string>
   <string name="fb_login_protocol_scheme">fb123456789012345</string>
   ```

### Bước 6: Publish Facebook App (Production)

**⚠️ Quan trọng:** App ở chế độ Development chỉ cho phép test với tài khoản admin/developer.

1. **Add Testers (Development Mode):**
   - Roles → Test Users
   - Add test users hoặc
   - Roles → Roles → Add people as Testers/Developers

2. **Switch to Live Mode (Production):**
   - Settings → Basic
   - App Mode: Đổi từ "Development" sang "Live"
   - Điền Privacy Policy URL (bắt buộc)
   - Điền Terms of Service URL (optional)
   - Chọn Category
   - Click "Switch Mode"

## 📝 Files đã được cấu hình

### 1. pubspec.yaml
```yaml
dependencies:
  flutter_facebook_auth: ^7.1.2
```

### 2. AndroidManifest.xml
```xml
<!-- Internet permission -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Facebook Configuration -->
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>

<!-- Facebook Activities -->
<activity android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

### 3. AuthService Methods

```dart
// Sign in with Facebook
Future<UserCredential> signInWithFacebook() async

// Sign out from Facebook
Future<void> signOutFacebook() async

// Get Facebook user data
Future<Map<String, dynamic>?> getFacebookUserData() async

// Check if logged in with Facebook
Future<bool> isLoggedInWithFacebook() async
```

## 🧪 Testing

### Test trong Development Mode

1. **Thêm Test Users:**
   - Facebook Developers Console → Roles → Test Users
   - Create test user hoặc add existing user as tester

2. **Test trên App:**
   - Rebuild app: `flutter clean && flutter pub get && flutter run`
   - Click Facebook button ở Login/Register page
   - Login với test user account
   - Verify navigate đến HomePage

### Test với Real Users (Live Mode)

1. **Switch to Live Mode** (xem Bước 6 trên)
2. **Test với bất kỳ Facebook account nào**

## 🐛 Troubleshooting

### Lỗi 1: "App Not Setup"
**Nguyên nhân:** Facebook App chưa được cấu hình đúng

**Giải pháp:**
- Kiểm tra App ID và Client Token đúng trong strings.xml
- Kiểm tra Package Name đúng trong Facebook Console
- Rebuild app sau khi thay đổi

### Lỗi 2: "Invalid Key Hash"
**Nguyên nhân:** Key Hash không khớp

**Giải pháp:**
- Generate lại Key Hash bằng keytool command
- Add vào Facebook Console → Settings → Basic → Key Hashes
- Có thể add nhiều key hashes (development + production)

### Lỗi 3: "Given URL is not allowed"
**Nguyên nhân:** OAuth Redirect URI không được cấu hình

**Giải pháp:**
- Copy OAuth redirect URI từ Firebase
- Add vào Facebook Login → Settings → Valid OAuth Redirect URIs

### Lỗi 4: "This app is in development mode"
**Nguyên nhân:** App ở Development mode, chỉ admin/tester test được

**Giải pháp:**
- Add user as Tester trong Facebook Console, hoặc
- Switch app sang Live mode

### Lỗi 5: "User cancelled login"
**Không phải lỗi** - User đã cancel login flow

## ✅ Checklist Setup

- [ ] Tạo Facebook App
- [ ] Lưu App ID và Client Token
- [ ] Add Facebook Login product
- [ ] Cấu hình Android platform (Package Name, Activity, Key Hash)
- [ ] Enable Facebook provider trong Firebase
- [ ] Nhập App ID và App Secret vào Firebase
- [ ] Copy OAuth redirect URI từ Firebase
- [ ] Add OAuth redirect URI vào Facebook Console
- [ ] Update strings.xml với App ID và Client Token thực
- [ ] Add test users (nếu Development mode)
- [ ] Switch to Live mode (cho production)
- [ ] Rebuild app: `flutter clean && flutter pub get && flutter run`
- [ ] Test Facebook login flow

## 🚀 Run & Test

### Clean & Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Test Flow
1. Open app
2. Go to Login or Register page
3. Click "Facebook" button
4. Login với Facebook account
5. Grant permissions
6. Verify redirect về app
7. Verify navigate đến HomePage
8. Verify username hiển thị đúng

## 📚 Additional Resources

- [Facebook Developers Console](https://developers.facebook.com/)
- [Firebase Console](https://console.firebase.google.com/)
- [flutter_facebook_auth Documentation](https://pub.dev/packages/flutter_facebook_auth)
- [Firebase Facebook Auth Guide](https://firebase.google.com/docs/auth/android/facebook-login)

## 🔐 Security Notes

- **Không commit** facebook_app_id và facebook_client_token vào git nếu là giá trị thật
- Sử dụng environment variables cho production
- Review app permissions (chỉ request email và public_profile)
- Enable App Secret Proof trong production

## 📱 Platform Support

- ✅ Android (Đã cấu hình)
- ⚠️ iOS (Cần cấu hình thêm Info.plist và URL Schemes)
- ⚠️ Web (Cần cấu hình thêm SDK và App ID)

## 🎉 Hoàn Thành!

Facebook Authentication đã sẵn sàng!

**Next Steps:**
1. Tạo Facebook App và lấy credentials
2. Update strings.xml
3. Rebuild app
4. Test và enjoy! 🎊
