# Fix: Review Post Button Not Working

## Summary
Backend đang chạy nhưng không thể kết nối từ curl/Flutter app. Vấn đề là Git Bash không có đầy đủ quyền network binding.

## ✅ SOLUTION - Chạy Backend Trong Command Prompt

### Bước 1: Mở Command Prompt (CMD)
1. Press `Win + R`
2. Type: `cmd`
3. Press Enter

### Bước 2: Navigate to Backend Folder
```cmd
cd C:\flutter_app\flutter_movie_app\backend
```

### Bước 3: Start Backend
```cmd
npm run dev
```

### Bước 4: Verify
Mở browser và truy cập:
```
http://localhost:3001/health
```

Kết quả mong đợi:
```json
{
  "success": true,
  "message": "Flutter Movie API is running",
  "timestamp": "2025-10-31T..."
}
```

### Bước 5: Test Create Review
```cmd
curl -X POST http://localhost:3001/api/reviews/movie/550 ^
  -H "Content-Type: application/json" ^
  -d "{\"userId\":\"test123\",\"userName\":\"Test User\",\"sentiment\":\"good\",\"title\":\"Great movie\",\"text\":\"This is a test review with more than 10 characters\",\"containsSpoilers\":false}"
```

## 🎯 Flutter App Configuration

Backend giờ chạy trên PORT **3001** (đã update):

```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://10.0.2.2:3001'; // ✅ Updated to 3001
```

## 📱 Testing in Flutter App

1. **Hot Restart** app (không phải Hot Reload):
   ```
   Press 'R' in terminal hoặc Stop & Run lại
   ```

2. **Navigate** to movie detail page

3. **Tap** "Reviews" tab

4. **Tap** "Write Review" button (floating button bottom-right)

5. **Fill form**:
   - Select sentiment (tap any emotion)
   - Type title (optional)
   - Type review text (minimum 10 characters)
   - Optional: Check spoiler box

6. **Tap "Post"** button

7. **Expected**:
   - Dialog closes
   - Review appears in list
   - Snackbar shows "Review saved"

## 🐛 If Still Not Working

### Check Backend is Running in CMD
```cmd
netstat -ano | findstr "3001"
```

Should show:
```
TCP    0.0.0.0:3001           0.0.0.0:0              LISTENING       12345
```

### Check Flutter Console
Look for error messages:
- "SocketException" → Backend not reachable
- "FormatException" → Wrong response format
- "TimeoutException" → Backend too slow

### Add Debug Logging

In `review_form_dialog.dart`, around line 55:

```dart
Future<void> _submitReview() async {
  print('🔍 DEBUG: Starting submit...'); // ADD THIS
  
  if (!_formKey.currentState!.validate()) {
    print('❌ DEBUG: Validation failed'); // ADD THIS
    return;
  }

  print('✅ DEBUG: Validation passed'); // ADD THIS
  print('📝 DEBUG: Sentiment=$_selectedSentiment, Text length=${_textController.text.length}'); // ADD THIS

  setState(() => _isSubmitting = true);

  try {
    print('📡 DEBUG: Calling API...'); // ADD THIS
    
    Map<String, dynamic> result = await ReviewService.createReview(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      userId: widget.userId,
      userName: widget.userName,
      userPhotoUrl: widget.userPhotoUrl,
      sentiment: _selectedSentiment,
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      containsSpoilers: _containsSpoilers,
    );

    print('📥 DEBUG: Response=$result'); // ADD THIS
    
    // ... rest of code
  } catch (e, stack) {
    print('💥 DEBUG: Error=$e'); // ADD THIS
    print('📚 DEBUG: Stack=$stack'); // ADD THIS
    // ... rest of code
  }
}
```

Then check console output when tapping Post.

## 🔧 Alternative: Use PowerShell

If CMD doesn't work, try PowerShell:

```powershell
cd C:\flutter_app\flutter_movie_app\backend
npm run dev
```

## ✅ Verification Checklist

- [ ] Backend running in CMD/PowerShell (NOT Git Bash)
- [ ] `netstat -ano | findstr "3001"` shows LISTENING
- [ ] Browser can access `http://localhost:3001/health`
- [ ] Flutter app updated to use port 3001
- [ ] App restarted (Hot Restart, not Hot Reload)
- [ ] Form validation passes (text >= 10 chars)
- [ ] Console shows debug logs when tapping Post

## 📞 If Nothing Works

Backend chạy tốt trong CMD/PowerShell. Nếu vẫn lỗi sau khi:
1. ✅ Backend chạy trong CMD/PowerShell
2. ✅ Browser test thành công
3. ✅ Flutter app đã restart
4. ✅ Port 3001 đã update

Thì vấn đề có thể ở:
- Firebase Auth (userId empty)
- Form validation logic
- Network permissions in Android emulator

Share console logs để debug tiếp!

---

**Root Cause**: Git Bash không có full network binding permissions trên Windows  
**Solution**: Run backend in CMD/PowerShell instead  
**Status**: Backend code is correct, just need proper terminal
