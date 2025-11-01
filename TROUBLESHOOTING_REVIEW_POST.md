# Quick Fix - Review Posting Issue

## Problem
Nút "Post" không hoạt động khi tạo review.

## Root Cause Analysis

### Backend Status
- ✅ MongoDB running (mongod.exe PID 5452)
- ✅ Backend code looks correct
- ✅ Backend logs show "Server is running on port 3000"
- ❌ Backend not responding to HTTP requests (curl fails)

### Possible Issues
1. **Port Binding**: Backend may be listening on wrong interface
2. **Firewall**: Windows Firewall blocking connections
3. **Process Conflict**: Multiple node processes may have crashed
4. **MongoDB Connection**: Connection successful but async issue

## Immediate Solutions

### Solution 1: Restart Backend Properly

```bash
# 1. Kill all node processes
taskkill /F /IM node.exe

# 2. Wait a moment
timeout /t 2

# 3. Start backend in a new terminal
cd C:\flutter_app\flutter_movie_app\backend
npm start

# 4. Wait for "Server is running" message
# 5. Test with browser: http://localhost:3000/health
```

### Solution 2: Use Different Port

If port 3000 is blocked, try port 3001:

```bash
# In backend/.env
PORT=3001
```

Then update Flutter:
```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://10.0.2.2:3001'; // Android Emulator
```

### Solution 3: Check Windows Firewall

```powershell
# Run as Administrator in PowerShell
New-NetFirewallRule -DisplayName "Node.js Backend" -Direction Inbound -Program "C:\Program Files\nodejs\node.exe" -Action Allow
```

### Solution 4: Test with Postman/Browser First

Before testing in Flutter app:
1. Open browser: `http://localhost:3000/health`
2. Should see: `{"success":true,"message":"Flutter Movie API is running"...}`
3. If this works, issue is in Flutter app
4. If this doesn't work, issue is in backend

## Flutter App Debug Steps

### Check API Config
```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
// static const String baseUrl = 'http://localhost:3000'; // iOS Simulator
```

### Add Debug Logging

In `review_form_dialog.dart`, add logging:

```dart
Future<void> _submitReview() async {
  if (!_formKey.currentState!.validate()) {
    print('❌ Form validation failed');
    return;
  }

  print('✅ Starting submit review...');
  print('Media: ${widget.mediaType}/${widget.mediaId}');
  print('Sentiment: $_selectedSentiment');
  print('Text length: ${_textController.text.length}');

  setState(() => _isSubmitting = true);

  try {
    print('📡 Calling ReviewService.createReview...');
    
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

    print('📥 Response received: $result');
    
    setState(() => _isSubmitting = false);

    if (result['success']) {
      print('✅ Review posted successfully!');
      Navigator.pop(context, true);
      // ... rest of code
    } else {
      print('❌ Review failed: ${result['message']}');
      // ... error handling
    }
  } catch (e) {
    print('💥 Exception: $e');
    print('Stack trace: ${StackTrace.current}');
    // ... error handling
  }
}
```

### Check Console Output

Run app with:
```bash
flutter run --verbose
```

Look for:
- `❌ Form validation failed` → Form validation issue
- `📡 Calling ReviewService...` → Function called
- `📥 Response received` → Backend responded
- `💥 Exception` → Network or parsing error

## Common Error Messages & Fixes

### "Failed to connect"
**Cause**: Backend not running or wrong URL  
**Fix**: 
1. Ensure backend running: `npm start`
2. Check URL matches: `10.0.2.2:3000` for Android

### "SocketException: Connection refused"
**Cause**: Backend not listening or firewall blocking  
**Fix**: 
1. Check firewall settings
2. Try different port
3. Restart backend

### "TimeoutException"
**Cause**: Backend too slow or crashed  
**Fix**:
1. Check backend logs for errors
2. Check MongoDB is running
3. Increase timeout in http client

### "FormatException: Unexpected character"
**Cause**: Backend returning HTML instead of JSON  
**Fix**:
1. Check backend route exists
2. Test with Postman first
3. Check CORS settings

## Verification Steps

### 1. Backend Health Check
```bash
curl http://localhost:3000/health
```
Expected:
```json
{
  "success": true,
  "message": "Flutter Movie API is running",
  "timestamp": "2025-10-31T..."
}
```

### 2. Create Test Review via API
```bash
curl -X POST http://localhost:3000/api/reviews/movie/550 \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test123",
    "userName": "Test User",
    "sentiment": "good",
    "title": "Great movie",
    "text": "This is a test review with more than 10 characters",
    "containsSpoilers": false
  }'
```

Expected:
```json
{
  "success": true,
  "message": "Review posted successfully",
  "data": {...}
}
```

### 3. Check MongoDB
```bash
# Connect to MongoDB
mongosh flutter_movies

# Check reviews collection
db.reviews.find().pretty()
```

## Quick Test Checklist

- [ ] MongoDB running (`mongod.exe` in Task Manager)
- [ ] Backend running (`node.exe` in Task Manager)
- [ ] Backend logs show "Server is running on port 3000"
- [ ] Browser can access `http://localhost:3000/health`
- [ ] Postman can POST to `/api/reviews/movie/550`
- [ ] Flutter app uses correct URL (`10.0.2.2:3000`)
- [ ] Form validation passes (text >= 10 chars)
- [ ] Console shows debug logs when tapping Post

## Next Steps

1. **First**: Restart backend properly (Solution 1)
2. **Second**: Test backend with browser/Postman
3. **Third**: Add debug logging to Flutter app
4. **Fourth**: Run Flutter with `--verbose` and check logs
5. **Fifth**: If still failing, share console output

---

**Last Updated**: October 31, 2025  
**Status**: Troubleshooting backend connectivity
