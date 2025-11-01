# Flutter Services - Backend Integration Complete ✅

## 📦 Flutter Services Created

Tất cả Flutter services để connect với backend đã được tạo thành công!

---

## 🎯 Services Created

### 1. **API Configuration** (`lib/config/api_config.dart`)

**Purpose**: Central configuration for all backend API endpoints

**Features**:
- Base URL configuration (Android Emulator, iOS Simulator, Physical Device)
- All endpoint constants organized by feature
- Helper methods to build URLs with query parameters
- Header configurations (JSON, Multipart)

**Key Methods**:
```dart
ApiConfig.apiBaseUrl                              // Get base URL
ApiConfig.getUserProfileUrl(userId)               // User profile URL
ApiConfig.getFavoritesUrl(userId, mediaType, ...) // Favorites with filters
ApiConfig.getCheckFavoriteUrl(userId, type, id)   // Check favorite
ApiConfig.getRecentlyViewedUrl(userId, ...)       // Recently viewed
ApiConfig.getAvatarUrl(filename)                  // Avatar URL
ApiConfig.jsonHeaders                             // JSON headers
ApiConfig.multipartHeaders                        // Multipart headers
```

---

### 2. **User Service** (`lib/services/backend_user_service.dart`)

**Purpose**: Manage user profiles via backend API

**Model**: `lib/models/user_profile.dart` (UserProfile)

**Methods**:
```dart
// Get user profile
BackendUserService.getUserProfile(userId)

// Create new user (after Firebase Auth)
BackendUserService.createUser(
  firebaseUid: uid,
  email: email,
  displayName: name,
  photoURL: url,
)

// Update user profile (upsert)
BackendUserService.updateUserProfile(userId, {
  'displayName': 'New Name',
  'bio': 'Bio text',
  'phoneNumber': '+1234567890',
  'country': 'USA',
  'favoriteGenres': ['Action', 'Sci-Fi'],
})

// Get user statistics
BackendUserService.getUserStats(userId)

// Delete user
BackendUserService.deleteUser(userId)
```

**UserProfile Model Fields**:
- Basic: `id`, `firebaseUid`, `email`, `displayName`, `photoURL`, `bio`
- Contact: `phoneNumber`, `dateOfBirth`, `country`
- Preferences: `favoriteGenres`, `emailNotifications`, `pushNotifications`
- Stats: `totalFavorites`, `totalReviews`, `totalComments`
- Metadata: `joinDate`, `lastActive`, `createdAt`, `updatedAt`

---

### 3. **Favorites Service** (`lib/services/backend_favorites_service.dart`)

**Purpose**: Manage favorites (movies/TV shows) via backend API

**Model**: `lib/models/favorite.dart` (Favorite)

**Methods**:
```dart
// Get all favorites
BackendFavoritesService.getUserFavorites(
  userId,
  mediaType: 'movie', // or 'tv'
  page: 1,
  limit: 20,
)

// Add to favorites
BackendFavoritesService.addFavorite(
  userId: uid,
  mediaType: 'movie',
  mediaId: 550,
  title: 'Fight Club',
  posterPath: '/path.jpg',
  backdropPath: '/backdrop.jpg',
  overview: 'Description...',
  rating: 8.4,
  releaseDate: '1999-10-15',
  genres: ['Drama', 'Thriller'],
)

// Remove by favorite ID
BackendFavoritesService.removeFavorite(favoriteId)

// Remove by media ID
BackendFavoritesService.removeFavoriteByMedia(
  userId: uid,
  mediaType: 'movie',
  mediaId: 550,
)

// Check if favorited
BackendFavoritesService.isFavorite(
  userId: uid,
  mediaType: 'movie',
  mediaId: 550,
)

// Clear all favorites
BackendFavoritesService.clearAllFavorites(userId)

// Shortcuts
BackendFavoritesService.getFavoriteMovies(userId)
BackendFavoritesService.getFavoriteTVShows(userId)
```

**Favorite Model Fields**:
- Reference: `id`, `userId`, `mediaType`, `mediaId`
- Media Data: `title`, `posterPath`, `backdropPath`, `overview`, `rating`, `releaseDate`, `genres`
- Metadata: `addedAt`, `createdAt`, `updatedAt`

---

### 4. **Recently Viewed Service** (`lib/services/backend_recently_viewed_service.dart`)

**Purpose**: Track and manage recently viewed items with watch progress

**Model**: `lib/models/recently_viewed.dart` (RecentlyViewed)

**Methods**:
```dart
// Get recently viewed
BackendRecentlyViewedService.getRecentlyViewed(
  userId,
  mediaType: 'movie', // or 'tv'
  page: 1,
  limit: 20,
)

// Track a view (auto-creates or updates)
BackendRecentlyViewedService.trackView(
  userId: uid,
  mediaType: 'movie',
  mediaId: 550,
  title: 'Fight Club',
  posterPath: '/path.jpg',
  watchProgress: 45,           // Percentage 0-100
  lastWatchPosition: 2700,     // Seconds
)

// Remove single item
BackendRecentlyViewedService.removeRecentlyViewed(recentlyViewedId)

// Clear all history
BackendRecentlyViewedService.clearRecentlyViewed(userId)

// Get watch progress
BackendRecentlyViewedService.getWatchProgress(
  userId: uid,
  mediaType: 'movie',
  mediaId: 550,
)

// Shortcuts
BackendRecentlyViewedService.getRecentlyViewedMovies(userId)
BackendRecentlyViewedService.getRecentlyViewedTVShows(userId)
```

**RecentlyViewed Model Fields**:
- Reference: `id`, `userId`, `mediaType`, `mediaId`
- Media Data: `title`, `posterPath`, `backdropPath`, `overview`, `rating`, `releaseDate`
- Tracking: `viewedAt`, `viewCount`, `watchProgress`, `lastWatchPosition`
- Metadata: `createdAt`, `updatedAt`
- Helpers: `isMovie`, `isTVShow`, `hasWatchProgress`, `isCompleted`

---

### 5. **Upload Service** (`lib/services/backend_upload_service.dart`)

**Purpose**: Upload files (avatars) to backend

**Methods**:
```dart
// Upload avatar
final result = await BackendUploadService.uploadAvatar(
  imageFile: File('/path/to/image.jpg'),
  userId: 'firebase-uid-123',
  oldAvatarPath: '/uploads/avatars/old-file.jpg', // optional
);

// Returns:
// {
//   'filename': 'userId_timestamp.jpg',
//   'path': '/uploads/avatars/userId_timestamp.jpg',
//   'url': 'http://10.0.2.2:3000/uploads/avatars/userId_timestamp.jpg',
//   'size': 123456,
//   'mimetype': 'image/jpeg'
// }

// Delete avatar
BackendUploadService.deleteAvatar('filename.jpg')

// Get avatar URL from filename
BackendUploadService.getAvatarUrl('filename.jpg')

// Get avatar URL from path
BackendUploadService.getAvatarUrlFromPath('/uploads/avatars/file.jpg')
```

**Features**:
- Multipart/form-data upload
- Auto-deletes old avatar on new upload
- Max file size: 5MB
- Allowed types: JPEG, JPG, PNG, GIF, WebP
- Returns full URL for immediate use

---

## 📝 How to Use in Flutter

### **Example 1: Get User Profile**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/services/backend_user_service.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final profile = await BackendUserService.getUserProfile(user.uid);
  
  if (profile != null) {
    print('Name: ${profile.displayName}');
    print('Bio: ${profile.bio}');
    print('Favorites: ${profile.totalFavorites}');
  }
}
```

### **Example 2: Add to Favorites**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/services/backend_favorites_service.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final success = await BackendFavoritesService.addFavorite(
    userId: user.uid,
    mediaType: 'movie',
    mediaId: 550,
    title: 'Fight Club',
    posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    rating: 8.4,
  );
  
  if (success) {
    print('Added to favorites!');
  }
}
```

### **Example 3: Track View**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/services/backend_recently_viewed_service.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  await BackendRecentlyViewedService.trackView(
    userId: user.uid,
    mediaType: 'movie',
    mediaId: 550,
    title: 'Fight Club',
    posterPath: '/poster.jpg',
    watchProgress: 45,          // 45% watched
    lastWatchPosition: 2700,    // 45 minutes (in seconds)
  );
}
```

### **Example 4: Upload Avatar**

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/services/backend_upload_service.dart';
import 'package:flutter_movie_app/services/backend_user_service.dart';

// Pick image
final picker = ImagePicker();
final pickedFile = await picker.pickImage(source: ImageSource.gallery);

if (pickedFile != null) {
  final user = FirebaseAuth.instance.currentUser;
  
  // Upload avatar
  final result = await BackendUploadService.uploadAvatar(
    imageFile: File(pickedFile.path),
    userId: user!.uid,
  );
  
  if (result != null) {
    final avatarUrl = result['url'];
    
    // Update user profile with new avatar URL
    await BackendUserService.updateUserProfile(user.uid, {
      'photoURL': avatarUrl,
    });
    
    print('Avatar uploaded: $avatarUrl');
  }
}
```

### **Example 5: Check if Favorite**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/services/backend_favorites_service.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final isFav = await BackendFavoritesService.isFavorite(
    userId: user.uid,
    mediaType: 'movie',
    mediaId: 550,
  );
  
  setState(() {
    isFavorite = isFav;
  });
}
```

---

## 🔧 Integration Checklist

### ✅ **Completed**
- [x] Backend APIs ready (MongoDB + Express)
- [x] Flutter API config created
- [x] User service created
- [x] Favorites service created
- [x] Recently viewed service created
- [x] Upload service created
- [x] Models created (UserProfile, Favorite, RecentlyViewed)

### ⏳ **Next Steps**
- [ ] Update UI to use new services
- [ ] Replace Firestore calls with backend calls
- [ ] Test all features
- [ ] Remove Firebase dependencies (cloud_firestore, firebase_storage)
- [ ] Update profile page to use backend

---

## 📊 Service Comparison

### **Before (Firestore)**
```dart
// Firestore - Complex and coupled to Firebase
final favoritesRef = FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('favorites');

final snapshot = await favoritesRef.get();
final favorites = snapshot.docs.map((doc) => doc.data()).toList();
```

### **After (Backend)**
```dart
// Backend - Simple and clean
final favorites = await BackendFavoritesService.getUserFavorites(userId);
```

---

## 🎉 Benefits

### **Performance**
- ✅ Faster queries with MongoDB indexes
- ✅ Pagination support (reduce data transfer)
- ✅ Cached media data (reduce TMDB calls)

### **Features**
- ✅ Watch progress tracking
- ✅ View count tracking
- ✅ User statistics auto-update
- ✅ Better filtering (by mediaType)

### **Cost**
- ✅ No Firebase Firestore costs
- ✅ No Firebase Storage costs
- ✅ Self-hosted backend

### **Control**
- ✅ Full control over data structure
- ✅ Easy to add new features
- ✅ Custom validation and business logic

---

## 📁 Files Created

```
lib/
├── config/
│   └── api_config.dart ✅ (Updated)
├── models/
│   ├── user_profile.dart ✅ (New)
│   ├── favorite.dart ✅ (New)
│   └── recently_viewed.dart ✅ (New)
└── services/
    ├── backend_user_service.dart ✅ (New)
    ├── backend_favorites_service.dart ✅ (Updated)
    ├── backend_recently_viewed_service.dart ✅ (New)
    └── backend_upload_service.dart ✅ (New)
```

---

## 🚀 Next: Update UI Components

Bây giờ bạn có thể:
1. Update `profile_page.dart` to use backend services
2. Update favorite button to use new service
3. Track views when user opens detail page
4. Remove old Firestore services
5. Remove Firebase dependencies

**All Flutter services are ready to use! 🎊**
