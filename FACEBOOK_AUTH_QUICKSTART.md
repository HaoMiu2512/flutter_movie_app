# Facebook Authentication - Quick Start

## 🚀 5 Bước Setup Nhanh

### Bước 1: Tạo Facebook App (5 phút)

1. Vào https://developers.facebook.com/
2. Click "My Apps" → "Create App"
3. Chọn type → Nhập app name → Create
4. **Lưu lại:**
   - **App ID**: (ví dụ: 123456789012345)
   - **Client Token**: Settings → Basic → Show

### Bước 2: Add Facebook Login (2 phút)

1. Dashboard → "Add Product" → "Facebook Login"
2. Choose "Android"
3. Nhập:
   - Package name: `com.example.flutter_movie_app`
   - Activity: `com.example.flutter_movie_app.MainActivity`

4. **Get Key Hash:**
   ```bash
   # Windows
   keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64

   # Mac/Linux
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```
   Password: `android`

5. Copy Key Hash → Paste vào Facebook Console → Save

### Bước 3: Enable trong Firebase (3 phút)

1. Vào https://console.firebase.google.com/
2. Project: `flutter-movie-app-253e7`
3. Authentication → Sign-in method → Facebook → Enable
4. Nhập:
   - **App ID**: từ Facebook Console
   - **App Secret**: Facebook Console → Settings → Basic → App Secret
5. **Copy OAuth redirect URI** từ Firebase
6. Save

### Bước 4: Cấu hình OAuth (1 phút)

1. Quay lại Facebook Console
2. Facebook Login → Settings
3. "Valid OAuth Redirect URIs" → Paste URI từ Firebase
4. Save

### Bước 5: Update strings.xml (1 phút)

File: `android/app/src/main/res/values/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Flutter Movie App</string>

    <!-- Replace with YOUR values -->
    <string name="facebook_app_id">123456789012345</string>
    <string name="facebook_client_token">abc123def456ghi789</string>
    <string name="fb_login_protocol_scheme">fb123456789012345</string>
</resources>
```

**⚠️ Thay thế:**
- `123456789012345` → Your App ID
- `abc123def456ghi789` → Your Client Token
- `fb123456789012345` → fb + Your App ID

## 🏃‍♂️ Run & Test

```bash
flutter clean
flutter pub get
flutter run
```

1. Click "Facebook" button
2. Login với Facebook account
3. Done! ✅

## 🧪 Test với Development Mode

**⚠️ Lưu ý:** Development mode chỉ cho phép admin/testers

### Add Test Users:
1. Facebook Console → Roles → Test Users → Add
2. Login app với test user account

### Hoặc Add Your Account:
1. Facebook Console → Roles → Roles → Add Testers
2. Add email của bạn → Accept invitation
3. Test với account của bạn

## 🌐 Switch to Live Mode (Production)

1. Facebook Console → Settings → Basic
2. Privacy Policy URL: **(Required)**
   - Nhập URL (có thể tạm thời dùng: https://example.com/privacy)
3. Category: Chọn category phù hợp
4. App Mode: **Development → Live**
5. Confirm

✅ Bây giờ bất kỳ user nào cũng có thể login!

## 🐛 Common Errors

### "App Not Setup"
→ Check App ID trong strings.xml đúng chưa
→ Rebuild app

### "Invalid Key Hash"
→ Generate lại Key Hash
→ Add vào Facebook Console → Settings → Key Hashes

### "Given URL is not allowed"
→ Add OAuth redirect URI vào Facebook Login → Settings

### "This app is in development mode"
→ Add user as Tester, hoặc
→ Switch to Live mode

## ✅ Checklist

- [ ] Tạo Facebook App
- [ ] Lưu App ID & Client Token
- [ ] Setup Facebook Login (Android)
- [ ] Get & add Key Hash
- [ ] Enable Facebook trong Firebase
- [ ] Add App ID & Secret vào Firebase
- [ ] Copy OAuth redirect URI
- [ ] Add OAuth URI vào Facebook
- [ ] Update strings.xml
- [ ] Rebuild app
- [ ] Test login

## 🎉 Done!

Total time: ~15 phút

**Chi tiết hơn:** [FACEBOOK_AUTH_SETUP_GUIDE.md](FACEBOOK_AUTH_SETUP_GUIDE.md)

**Tổng kết:** [FACEBOOK_AUTH_SUMMARY.md](FACEBOOK_AUTH_SUMMARY.md)
