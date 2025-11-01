# Profile Page Testing Guide 🧪

## Pre-Testing Setup

### 1. Start Backend Server
```bash
cd backend
npm start
```
**Expected:** Server running on `http://localhost:3000`

### 2. Verify Backend Endpoints
```bash
# Test user endpoint
curl http://localhost:3000/api/users

# Test upload endpoint
curl http://localhost:3000/api/upload/avatar
```

### 3. Run Flutter App
```bash
flutter run
```

---

## Test Scenarios

### ✅ Test 1: Display Name Update

**Steps:**
1. Open Profile Page
2. Click Edit icon next to name
3. Enter new name: "Test User 123"
4. Click Save/Checkmark

**Expected Results:**
- ✅ Name updates immediately in UI
- ✅ Green success message appears
- ✅ Backend receives PUT request to `/api/users/:userId`
- ✅ No Firestore errors in console

**Backend Verification:**
```bash
# Check MongoDB
use flutter_movie_db
db.users.find({ displayName: "Test User 123" })
```

---

### ✅ Test 2: Avatar URL Update

**Steps:**
1. Click "Change Avatar URL" option
2. Enter URL: `https://i.pravatar.cc/300?img=70`
3. Click Update

**Expected Results:**
- ✅ Avatar image updates in UI
- ✅ Green success message
- ✅ Backend receives PUT to `/api/users/:userId`
- ✅ `photoURL` saved in MongoDB

**Backend Verification:**
```bash
db.users.find({ photoURL: /pravatar/ })
```

---

### ✅ Test 3: Avatar File Upload

**Steps:**
1. Click "Upload from Gallery"
2. Select an image from device/gallery
3. Wait for upload to complete

**Expected Results:**
- ✅ Loading indicator shows during upload
- ✅ Avatar updates to new image
- ✅ Green success message
- ✅ File saved in `backend/uploads/avatars/`
- ✅ URL format: `http://localhost:3000/uploads/avatars/{userId}_{timestamp}.jpg`

**Backend Verification:**
```bash
# Check file exists
ls backend/uploads/avatars/

# Check database
db.users.find({ photoURL: /localhost:3000/ })
```

**Common Issues:**
- ❌ **"Failed to get upload URL"** → Check backend is running
- ❌ **Network error** → Verify `api_config.dart` has correct URL
- ❌ **File too large** → Backend limits to 5MB

---

### ✅ Test 4: Recently Viewed Display

**Steps:**
1. Scroll to "Recently Viewed" section
2. Observe list of movies/TV shows

**Expected Results:**
- ✅ Loading indicator appears first
- ✅ Movies/TV shows load from backend
- ✅ Posters display correctly
- ✅ TV badge shows for TV shows
- ✅ Movie badge shows for movies
- ✅ Ratings display correctly

**Backend Verification:**
```bash
# Get recently viewed for user
curl http://localhost:3000/api/recently-viewed/{userId}
```

**If Empty:**
- Go watch some movies/TV shows first
- Backend should track views automatically
- Check if tracking is implemented in detail pages

---

### ✅ Test 5: Navigate to Movie/TV Details

**Steps:**
1. Click on any recently viewed item
2. Should navigate to detail page

**Expected Results:**
- ✅ Navigation works
- ✅ Correct movie/TV detail page opens
- ✅ TMDB ID matches

---

### ✅ Test 6: Clear Recently Viewed

**Steps:**
1. Click "Clear All" button in Recently Viewed section
2. Confirm in dialog

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ Loading indicator shows
- ✅ Green success message
- ✅ Recently viewed list becomes empty
- ✅ Backend receives DELETE to `/api/recently-viewed/clear/:userId`

**Backend Verification:**
```bash
# Should return empty array
curl http://localhost:3000/api/recently-viewed/{userId}

# Or in MongoDB
db.recentlyviewed.find({ userId: "{userId}" })
# Should be empty
```

---

### ✅ Test 7: Error Handling - Network Offline

**Steps:**
1. Turn off backend server
2. Try updating display name

**Expected Results:**
- ✅ Red error message appears
- ✅ Error message is descriptive
- ✅ App doesn't crash
- ✅ UI remains responsive

---

### ✅ Test 8: Loading States

**Steps:**
1. Perform any action (update name, upload avatar, etc.)
2. Observe loading indicators

**Expected Results:**
- ✅ Loading indicator shows during operation
- ✅ Buttons disabled while loading
- ✅ Loading indicator disappears after completion

---

## Backend Logs to Monitor

While testing, watch backend console for:

```
✅ PUT /api/users/abc123 200 - Update user
✅ POST /api/upload/avatar 200 - Avatar uploaded
✅ GET /api/recently-viewed/abc123 200 - Get recently viewed
✅ DELETE /api/recently-viewed/clear/abc123 200 - Clear all
```

**Red Flags:**
```
❌ 404 Not Found - Route not registered
❌ 500 Server Error - Backend code error
❌ CORS Error - Headers not set
❌ MongoDB connection error - Database not running
```

---

## Performance Testing

### Upload Speed Test
1. Upload 1MB image → Should complete in < 2 seconds
2. Upload 5MB image → Should complete in < 5 seconds
3. Upload 10MB image → Should fail with size limit error

### Recently Viewed Load Time
1. Load page with 10 items → < 500ms
2. Load page with 50 items → < 1 second
3. Load page with 100 items → < 2 seconds

---

## Debugging Tips

### Check API Config
```dart
// lib/config/api_config.dart
static const String apiBaseUrl = 'http://localhost:3000';
// Should match backend port
```

### Check Backend Server
```bash
# Backend running?
curl http://localhost:3000/health

# MongoDB connected?
# Check backend console for "MongoDB Connected"
```

### Check Flutter Console
```bash
# Look for these logs:
flutter: Failed to get recently viewed: 404
flutter: Error uploading avatar: Network error
```

### Check Network Traffic
Use Flutter DevTools → Network tab to see:
- Request URLs
- Response codes
- Response bodies
- Headers

---

## Success Criteria

All tests must pass ✅ before removing Firebase dependencies:

- [x] Display name updates correctly
- [x] Avatar URL updates correctly
- [x] Avatar file uploads successfully
- [x] Recently viewed loads from backend
- [x] Recently viewed displays correctly
- [x] Navigation to details works
- [x] Clear recently viewed works
- [x] Error handling works
- [x] Loading states work
- [x] No Firebase/Firestore errors
- [x] Backend logs show correct requests
- [x] MongoDB data is correct

---

## Next Steps After Testing

1. ✅ All tests pass → Update other pages (Recently Viewed All, Detail pages)
2. ✅ Update Favorites pages to use backend
3. ✅ Test all pages together
4. ✅ Remove Firebase dependencies from `pubspec.yaml`
5. ✅ Delete old Firestore service files
6. ✅ Update documentation

---

**Testing Date:** ___________
**Tester:** ___________
**All Tests Passed:** ☐ Yes ☐ No
**Notes:**
