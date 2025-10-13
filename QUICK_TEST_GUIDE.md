# Quick Test Guide - Phone Authentication

## 🚀 App đang chạy trên Emulator!

App đã được build thành công và đang chạy trên Android Emulator.

## 📱 Cách Test Nhanh

### Bước 1: Enable Phone Authentication trong Firebase

1. Truy cập: https://console.firebase.google.com/
2. Chọn project: **flutter-movie-app-253e7**
3. Vào **Authentication** → **Sign-in method**
4. Enable **Phone** authentication
5. (Optional) Thêm số test:
   - Click "Phone numbers for testing"
   - Thêm: `+84123456789` với OTP `123456`

### Bước 2: Test Phone Login

**Từ Login Page:**

1. Mở app (đang chạy trên emulator)
2. Tìm và click button **"Phone"** (màu cyan với icon điện thoại)
3. Chọn country code: **+84** (Vietnam)
4. Nhập số điện thoại: **123456789** (nếu dùng test number)
5. Click **"SEND OTP"**
6. Đợi navigate đến OTP page
7. Nhập OTP: **123456** (hoặc mã từ SMS)
8. Click **"VERIFY & SIGN IN"**
9. Kiểm tra navigate đến HomePage

**Kết quả mong đợi:**
- ✅ Không có crash
- ✅ Loading indicators hoạt động
- ✅ Navigate đến OTP page
- ✅ Nhập OTP thành công
- ✅ Navigate đến HomePage

### Bước 3: Test Phone Register

**Từ Register Page:**

1. Từ Login Page, click **"Sign Up"**
2. Ở Register Page, click button **"Phone"**
3. Làm theo các bước giống như Login

### Bước 4: Test Validation

**Phone Number Validation:**
- Để trống → Error: "Please enter phone number"
- Nhập < 9 số → Error: "Phone number is too short"
- Nhập chữ → Error: "Only numbers allowed"

**OTP Validation:**
- Để trống → Error: "Please enter OTP code"
- Nhập < 6 số → Error: "OTP must be 6 digits"
- OTP sai → SnackBar error

### Bước 5: Test Resend OTP

1. Ở OTP page, đợi countdown 60s về 0
2. Button "Resend" sẽ active
3. Click "Resend"
4. Kiểm tra SnackBar: "OTP code has been resent!"

## 🔧 Hot Reload Commands

App đang chạy với hot reload, bạn có thể:
- **r** - Hot reload
- **R** - Hot restart
- **q** - Quit app

## 🎯 Test Checklist

Checklist nhanh để test:

- [ ] Login Page có button Phone
- [ ] Register Page có button Phone
- [ ] Click Phone button → Navigate đến PhoneAuthPage
- [ ] PhoneAuthPage hiển thị đúng UI
- [ ] Country code dropdown hoạt động
- [ ] Validation phone number hoạt động
- [ ] Send OTP → Navigate đến OtpVerificationPage
- [ ] OtpVerificationPage hiển thị số điện thoại
- [ ] Validation OTP hoạt động
- [ ] Countdown timer hoạt động (60s)
- [ ] Resend OTP hoạt động
- [ ] Verify OTP → Navigate đến HomePage
- [ ] Back button hoạt động

## 📊 Firebase Test Numbers

Nếu chưa enable trong Firebase, sử dụng số test:

**Cấu hình trong Firebase Console:**
```
Phone: +84123456789
OTP: 123456
```

**Trong App:**
```
Country Code: +84
Phone Number: 123456789
OTP: 123456
```

## ⚠️ Troubleshooting

### Không nhận được OTP
1. Kiểm tra Phone authentication đã enable trong Firebase
2. Kiểm tra network connection
3. Sử dụng số test nếu testing
4. Kiểm tra console logs

### App crash
1. Check console output
2. Restart app: Press **R**
3. Hot reload: Press **r**

### Lỗi validation
- Đảm bảo phone number >= 9 chữ số
- Đảm bảo OTP = 6 chữ số
- Chỉ nhập số (0-9)

## 📝 Logs Location

Check logs trong terminal đang chạy `flutter run`:
- Stdout: Normal logs
- Stderr: Error logs
- Firebase logs sẽ hiện trong console

## 🎉 Features Completed

- ✅ PhoneAuthPage with UI
- ✅ OtpVerificationPage with UI
- ✅ Login/Register integration
- ✅ Phone number validation
- ✅ OTP validation
- ✅ Send OTP functionality
- ✅ Resend OTP functionality
- ✅ Countdown timer
- ✅ Loading states
- ✅ Error handling
- ✅ Navigation flow
- ✅ SnackBar messages

## 📚 Documentation

Chi tiết hơn xem:
- [PHONE_AUTH_TESTING_GUIDE.md](PHONE_AUTH_TESTING_GUIDE.md) - Full testing guide
- [PHONE_AUTH_SUMMARY.md](PHONE_AUTH_SUMMARY.md) - Feature summary

## 🚀 Ready to Test!

App đang chạy trên emulator. Bạn có thể bắt đầu test ngay bây giờ!

**Have fun testing!** 🎊
