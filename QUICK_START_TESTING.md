# 🚀 Quick Start - Testing Migration

## ⚡ Fast Track Testing Guide

**Migration Status**: ✅ **100% COMPLETE** - Ready for testing!

---

## 1️⃣ Start Backend (Terminal 1)

```bash
cd backend
npm run dev
```

**Expected Output**:
```
Server running on port 3000
MongoDB connected successfully
```

**Check Health**:
```bash
curl http://localhost:3000/health
```

---

## 2️⃣ Run Flutter App (Terminal 2)

```bash
flutter run
```

---

## 3️⃣ Test Features (5 Minutes)

### ✅ Test 1: Profile Page (1 min)
1. Open app → Go to Profile Page
2. Click "Edit Display Name" → Enter new name → Save
3. **Expected**: Name updates immediately
4. **Backend Check**: `GET /api/users/:userId` should show new name

### ✅ Test 2: Avatar Upload (1 min)
1. Click "Change Avatar" → Select image from gallery
2. **Expected**: Avatar uploads and displays
3. **Backend Check**: File appears in `backend/uploads/avatars/`

### ✅ Test 3: Recently Viewed (1 min)
1. Navigate to any movie/TV detail page
2. Go back to Profile Page → Scroll to "Recently Viewed"
3. **Expected**: Movie/TV appears in recently viewed
4. Click "View All" → **Expected**: Same item appears
5. Click "Clear All" → **Expected**: List clears

### ✅ Test 4: Favorites (2 min)
1. Go to any movie detail page
2. Click ❤️ (heart icon) to add to favorites
3. **Expected**: Heart fills (red/pink color)
4. Go to Favorites Page
5. **Expected**: Movie appears in favorites list
6. Click ❤️ again to remove
7. **Expected**: Removed from favorites

---

## 4️⃣ Verify Backend (Optional)

### Check MongoDB Data

**Connect to MongoDB**:
```bash
mongo
use flutter_movies
```

**Check Collections**:
```javascript
// View users
db.users.find().pretty()

// View favorites
db.favorites.find().pretty()

// View recently viewed
db.recentlyviewed.find().pretty()
```

### Check Backend Logs

Watch terminal where backend is running:
- You should see API calls logged
- Example: `GET /api/users/:userId 200 OK`
- Example: `POST /api/favorites 201 Created`

---

## 5️⃣ Troubleshooting

### Backend Not Starting?
```bash
cd backend
npm install
npm run dev
```

### Flutter Errors?
```bash
flutter clean
flutter pub get
flutter run
```

### Can't Connect to Backend?
Check `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://localhost:3000';
```

For Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

For iOS simulator, `localhost:3000` should work.

### MongoDB Connection Issues?
Check `backend/index.js`:
```javascript
const MONGODB_URI = 'mongodb://localhost:27017/flutter_movies';
```

Make sure MongoDB is running:
```bash
# Windows
net start MongoDB

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

---

## 6️⃣ Success Criteria

### ✅ All Tests Pass If:
- [ ] Profile name updates work
- [ ] Avatar uploads successfully
- [ ] Recently viewed tracks movie/TV views
- [ ] Favorites can be added/removed
- [ ] Backend logs show API calls
- [ ] MongoDB contains data

### 🎉 Ready for Production!

When all tests pass:
1. Remove Firebase dependencies (see step 15 in TODO)
2. Deploy backend to cloud
3. Update API URL in `api_config.dart`
4. Ship it! 🚀

---

## 📚 Full Documentation

For detailed testing instructions, see:
- **PROFILE_PAGE_TESTING_GUIDE.md** - Comprehensive testing guide
- **MIGRATION_SUMMARY_FINAL.md** - Complete migration summary
- **BACKEND_SERVICES_QUICK_REFERENCE.md** - Service usage examples

---

## 🎯 Quick Reference

### Backend Endpoints
- User: `http://localhost:3000/api/users/:userId`
- Favorites: `http://localhost:3000/api/favorites/:userId`
- Recently Viewed: `http://localhost:3000/api/recently-viewed/:userId`
- Avatar Upload: `http://localhost:3000/api/upload/avatar`

### Flutter Services
```dart
import '../services/backend_user_service.dart';
import '../services/backend_upload_service.dart';
import '../services/backend_favorites_service.dart';
import '../services/backend_recently_viewed_service.dart';
```

### Test User
If you need to create a test user:
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-123",
    "email": "test@test.com",
    "displayName": "Test User"
  }'
```

---

**Time to Complete**: ~5 minutes  
**Difficulty**: Easy  
**Status**: Ready to test! 🎉
