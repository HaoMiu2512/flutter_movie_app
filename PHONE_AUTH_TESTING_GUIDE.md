# Hướng Dẫn Testing Phone Authentication

## Tổng Quan
Tính năng phone authentication đã được tích hợp vào app với các trang:
- **PhoneAuthPage**: Trang nhập số điện thoại
- **OtpVerificationPage**: Trang xác thực OTP
- **LoginPage**: Đã tích hợp button Phone login
- **RegisterPage**: Đã tích hợp button Phone register

## Cấu Hình Firebase

### 1. Kiểm Tra Firebase Console
Truy cập [Firebase Console](https://console.firebase.google.com/)

1. Chọn project: `flutter-movie-app-253e7`
2. Vào **Authentication** > **Sign-in method**
3. Đảm bảo **Phone** đã được enable
4. Thêm số điện thoại test (nếu cần):
   - Vào tab **Phone numbers for testing**
   - Thêm số test và mã OTP (VD: +84123456789 với mã 123456)

### 2. Cấu Hình Android

#### a. AndroidManifest.xml
File đã được cấu hình cơ bản tại: `android/app/src/main/AndroidManifest.xml`

Đảm bảo có quyền sau (thường đã tự động thêm):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
```

#### b. build.gradle
Kiểm tra file: `android/app/build.gradle`

Đảm bảo có:
```gradle
android {
    compileSdk 34

    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}
```

### 3. Dependencies
File `pubspec.yaml` đã có đầy đủ:
- ✅ firebase_core: ^4.1.1
- ✅ firebase_auth: ^6.1.0
- ✅ google_sign_in: ^6.2.2

## Test Cases

### Test Case 1: Đăng Nhập bằng Phone từ Login Page

**Bước 1: Mở Login Page**
```bash
flutter run
```

**Bước 2: Click button "Phone"**
- Ở Login Page, tìm button có icon phone_android (màu cyan)
- Click vào button này

**Bước 3: Nhập số điện thoại**
- Chọn country code (mặc định +84 cho Vietnam)
- Nhập số điện thoại (ít nhất 9 chữ số)
- VD: 123456789

**Bước 4: Gửi OTP**
- Click button "SEND OTP"
- Chờ loading indicator
- Sẽ chuyển sang OtpVerificationPage

**Bước 5: Nhập OTP**
- Nhập mã OTP 6 chữ số nhận được qua SMS
- Hoặc sử dụng test phone number đã cấu hình trong Firebase

**Bước 6: Xác thực**
- Click button "VERIFY & SIGN IN"
- Nếu thành công, sẽ chuyển đến HomePage

**Kết quả mong đợi:**
- ✅ Nhận được OTP qua SMS
- ✅ Xác thực thành công
- ✅ Chuyển đến HomePage với username là số điện thoại
- ✅ Hiển thị SnackBar "Phone verification successful!"

### Test Case 2: Đăng Ký bằng Phone từ Register Page

**Bước 1: Mở Register Page**
- Từ Login Page, click "Sign Up"

**Bước 2: Click button "Phone"**
- Ở Register Page, tìm button có icon phone_android
- Click vào button này

**Bước 3-6: Giống Test Case 1**

**Kết quả mong đợi: Giống Test Case 1**

### Test Case 3: Resend OTP

**Bước 1-4: Giống Test Case 1** (đến OtpVerificationPage)

**Bước 5: Chờ countdown**
- Chờ 60 giây cho countdown timer hết

**Bước 6: Click "Resend"**
- Sau khi countdown = 0, button "Resend" sẽ active
- Click vào button này

**Bước 7: Nhận OTP mới**
- Nhận mã OTP mới qua SMS
- Nhập mã mới vào

**Kết quả mong đợi:**
- ✅ Countdown từ 60s về 0s
- ✅ Button "Resend" active sau khi countdown = 0
- ✅ Nhận được OTP mới
- ✅ Hiển thị SnackBar "OTP code has been resent!"

### Test Case 4: Validation

#### a. Phone Number Validation

**Test 4.1: Số điện thoại rỗng**
- Bước: Để trống field phone number, click "SEND OTP"
- Kết quả: Hiển thị lỗi "Please enter phone number"

**Test 4.2: Số điện thoại quá ngắn**
- Bước: Nhập số < 9 chữ số (VD: 12345), click "SEND OTP"
- Kết quả: Hiển thị lỗi "Phone number is too short"

**Test 4.3: Ký tự không hợp lệ**
- Bước: Nhập ký tự không phải số (VD: abc123), click "SEND OTP"
- Kết quả: Hiển thị lỗi "Only numbers allowed"

#### b. OTP Validation

**Test 4.4: OTP rỗng**
- Bước: Để trống OTP field, click "VERIFY & SIGN IN"
- Kết quả: Hiển thị lỗi "Please enter OTP code"

**Test 4.5: OTP không đủ 6 chữ số**
- Bước: Nhập < 6 chữ số (VD: 123), click "VERIFY & SIGN IN"
- Kết quả: Hiển thị lỗi "OTP must be 6 digits"

**Test 4.6: OTP sai**
- Bước: Nhập OTP sai (VD: 000000), click "VERIFY & SIGN IN"
- Kết quả: Hiển thị SnackBar với lỗi "Invalid OTP code. Please try again."

### Test Case 5: UI/UX Testing

**Test 5.1: Loading State**
- Khi click "SEND OTP" hoặc "VERIFY & SIGN IN"
- Kết quả: Button disabled, hiển thị CircularProgressIndicator

**Test 5.2: Back Navigation**
- Click icon back (arrow_back) ở góc trên trái
- Kết quả: Quay lại page trước đó

**Test 5.3: Country Code Dropdown**
- Click dropdown country code
- Kết quả: Hiển thị danh sách (+84, +1, +44, +91)
- Chọn được các mã khác nhau

**Test 5.4: Info Boxes**
- Kiểm tra info box với icon info_outline
- Kết quả: Hiển thị thông tin hướng dẫn rõ ràng

### Test Case 6: Error Handling

**Test 6.1: Network Error**
- Tắt internet
- Thử send OTP
- Kết quả: Hiển thị lỗi "Network connection error"

**Test 6.2: Firebase Error**
- Sử dụng số điện thoại không hợp lệ theo format quốc tế
- Kết quả: Hiển thị lỗi từ Firebase

**Test 6.3: Auto-verification (Android only)**
- Trên Android, có thể tự động verify OTP
- Kết quả: Tự động sign in mà không cần nhập OTP

## Test với Số Điện Thoại Test

### Cấu hình số test trong Firebase:

1. Vào Firebase Console > Authentication > Sign-in method
2. Scroll xuống phần "Phone numbers for testing"
3. Thêm số test:
   - Phone number: `+84123456789`
   - OTP code: `123456`

### Test với số test:

```
Country code: +84
Phone number: 123456789
OTP: 123456
```

**Lưu ý:** Số test không gửi SMS thật, chỉ để testing

## Checklist Testing

### Functional Testing
- [ ] Login Page có button Phone login
- [ ] Register Page có button Phone register
- [ ] PhoneAuthPage hiển thị đúng UI
- [ ] Có thể nhập số điện thoại
- [ ] Có thể chọn country code
- [ ] Gửi OTP thành công
- [ ] Nhận được OTP qua SMS
- [ ] OtpVerificationPage hiển thị đúng số điện thoại
- [ ] Có thể nhập OTP
- [ ] Verify OTP thành công
- [ ] Navigate đến HomePage sau khi verify
- [ ] Resend OTP hoạt động
- [ ] Countdown timer hoạt động

### Validation Testing
- [ ] Validate phone number rỗng
- [ ] Validate phone number ngắn
- [ ] Validate ký tự không hợp lệ
- [ ] Validate OTP rỗng
- [ ] Validate OTP không đủ 6 chữ số
- [ ] Validate OTP sai

### UI/UX Testing
- [ ] Loading state hiển thị đúng
- [ ] Back button hoạt động
- [ ] Country code dropdown hoạt động
- [ ] Info boxes hiển thị
- [ ] SnackBar messages hiển thị
- [ ] Color scheme nhất quán
- [ ] Icons phù hợp

### Error Handling
- [ ] Network error
- [ ] Firebase errors
- [ ] Invalid phone format
- [ ] Invalid OTP
- [ ] Timeout

## Lệnh Testing

### Run App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter devices
flutter run -d <device_id>
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Check for Errors
```bash
flutter analyze
flutter doctor
```

## Troubleshooting

### Vấn đề 1: Không nhận được OTP
**Giải pháp:**
- Kiểm tra Phone authentication đã enable trong Firebase
- Kiểm tra số điện thoại đúng format (+[country_code][number])
- Thử với số điện thoại test
- Kiểm tra network connection

### Vấn đề 2: App crash khi gửi OTP
**Giải pháp:**
- Chạy `flutter clean && flutter pub get`
- Kiểm tra Firebase configuration
- Kiểm tra google-services.json
- Rebuild app

### Vấn đề 3: OTP không đúng
**Giải pháp:**
- Sử dụng OTP từ SMS
- Đảm bảo nhập đúng 6 chữ số
- Thử resend OTP
- Kiểm tra verificationId đúng

### Vấn đề 4: Google Play Services error
**Giải pháp:**
- Cập nhật Google Play Services trên device
- Kiểm tra minSdk >= 21
- Test trên emulator có Google Play

## Notes

### Development Environment
- Flutter SDK: ^3.9.2
- Dart SDK: Latest stable
- Firebase Core: ^4.1.1
- Firebase Auth: ^6.1.0

### Supported Platforms
- ✅ Android (API 21+)
- ⚠️ iOS (cần cấu hình thêm)
- ⚠️ Web (có thể cần reCAPTCHA)

### Country Codes Available
- +84 (Vietnam)
- +1 (USA/Canada)
- +44 (UK)
- +91 (India)

### Security Notes
- OTP timeout: 60 seconds
- Resend cooldown: 60 seconds
- Auto-retrieval timeout: 120 seconds
- Phone numbers được validate trước khi gửi

## Kết Luận

Tính năng Phone Authentication đã được tích hợp đầy đủ với:
- ✅ UI/UX đẹp và nhất quán
- ✅ Validation đầy đủ
- ✅ Error handling tốt
- ✅ Resend OTP functionality
- ✅ Countdown timer
- ✅ Loading states
- ✅ Auto-verification support

Sẵn sàng để testing và deploy!
