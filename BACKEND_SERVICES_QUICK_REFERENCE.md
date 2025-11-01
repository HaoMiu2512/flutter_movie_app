# Flutter Backend Services - Quick Reference 🚀

## 📦 Import Services

```dart
// User Profile
import 'package:flutter_movie_app/services/backend_user_service.dart';
import 'package:flutter_movie_app/models/user_profile.dart';

// Favorites
import 'package:flutter_movie_app/services/backend_favorites_service.dart';
import 'package:flutter_movie_app/models/favorite.dart';

// Recently Viewed
import 'package:flutter_movie_app/services/backend_recently_viewed_service.dart';
import 'package:flutter_movie_app/models/recently_viewed.dart';

// Upload
import 'package:flutter_movie_app/services/backend_upload_service.dart';

// Firebase Auth (for userId)
import 'package:firebase_auth/firebase_auth.dart';
```

---

## 👤 User Profile Service

### Get User Profile
```dart
final user = FirebaseAuth.instance.currentUser;
final profile = await BackendUserService.getUserProfile(user!.uid);

if (profile != null) {
  print('Name: ${profile.displayName}');
  print('Email: ${profile.email}');
  print('Bio: ${profile.bio}');
  print('Avatar: ${profile.photoURL}');
  print('Favorites: ${profile.totalFavorites}');
}
```

### Create User (After Firebase Auth)
```dart
final user = FirebaseAuth.instance.currentUser;
final profile = await BackendUserService.createUser(
  firebaseUid: user!.uid,
  email: user.email!,
  displayName: user.displayName ?? 'User',
  photoURL: user.photoURL,
);
```

### Update Profile
```dart
final user = FirebaseAuth.instance.currentUser;
final updated = await BackendUserService.updateUserProfile(
  user!.uid,
  {
    'displayName': 'New Name',
    'bio': 'Movie enthusiast 🎬',
    'phoneNumber': '+1234567890',
    'country': 'USA',
    'favoriteGenres': ['Action', 'Sci-Fi', 'Drama'],
  },
);
```

### Get User Stats
```dart
final stats = await BackendUserService.getUserStats(user.uid);
if (stats != null) {
  print('Favorites: ${stats['totalFavorites']}');
  print('Reviews: ${stats['totalReviews']}');
  print('Comments: ${stats['totalComments']}');
}
```

---

## ❤️ Favorites Service

### Add to Favorites
```dart
final user = FirebaseAuth.instance.currentUser;
final success = await BackendFavoritesService.addFavorite(
  userId: user!.uid,
  mediaType: 'movie', // or 'tv'
  mediaId: 550,
  title: 'Fight Club',
  posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
  backdropPath: '/backdrop.jpg',
  overview: 'An insomniac office worker...',
  rating: 8.4,
  releaseDate: '1999-10-15',
  genres: ['Drama', 'Thriller'],
);

if (success) {
  print('Added to favorites!');
}
```

### Remove from Favorites
```dart
// By media ID
final removed = await BackendFavoritesService.removeFavoriteByMedia(
  userId: user.uid,
  mediaType: 'movie',
  mediaId: 550,
);

// Or by favorite ID (if you have it)
await BackendFavoritesService.removeFavorite(favoriteId);
```

### Check if Favorite
```dart
final isFav = await BackendFavoritesService.isFavorite(
  userId: user.uid,
  mediaType: 'movie',
  mediaId: 550,
);

setState(() {
  isFavorite = isFav;
});
```

### Get All Favorites
```dart
// All favorites
final favorites = await BackendFavoritesService.getUserFavorites(
  user.uid,
  page: 1,
  limit: 20,
);

// Only movies
final movieFavorites = await BackendFavoritesService.getFavoriteMovies(user.uid);

// Only TV shows
final tvFavorites = await BackendFavoritesService.getFavoriteTVShows(user.uid);

// Display
for (var fav in favorites) {
  print('${fav.title} (${fav.mediaType}) - ${fav.rating}⭐');
}
```

### Clear All Favorites
```dart
final cleared = await BackendFavoritesService.clearAllFavorites(user.uid);
```

---

## 🕒 Recently Viewed Service

### Track View
```dart
final user = FirebaseAuth.instance.currentUser;

await BackendRecentlyViewedService.trackView(
  userId: user!.uid,
  mediaType: 'movie',
  mediaId: 550,
  title: 'Fight Club',
  posterPath: '/poster.jpg',
  backdropPath: '/backdrop.jpg',
  overview: 'Description...',
  rating: 8.4,
  releaseDate: '1999-10-15',
  watchProgress: 45,          // 45% watched
  lastWatchPosition: 2700,    // 45 minutes in seconds
);
```

### Get Recently Viewed
```dart
// All recently viewed
final recentViews = await BackendRecentlyViewedService.getRecentlyViewed(
  user.uid,
  page: 1,
  limit: 20,
);

// Only movies
final movieViews = await BackendRecentlyViewedService.getRecentlyViewedMovies(user.uid);

// Only TV shows
final tvViews = await BackendRecentlyViewedService.getRecentlyViewedTVShows(user.uid);

// Display
for (var view in recentViews) {
  print('${view.title} - Watched ${view.viewCount} times');
  print('Progress: ${view.watchProgress}%');
  if (view.isCompleted) {
    print('✅ Completed');
  }
}
```

### Get Watch Progress
```dart
final progress = await BackendRecentlyViewedService.getWatchProgress(
  userId: user.uid,
  mediaType: 'movie',
  mediaId: 550,
);

if (progress != null) {
  print('Progress: ${progress['watchProgress']}%');
  print('Position: ${progress['lastWatchPosition']} seconds');
  print('View count: ${progress['viewCount']}');
}
```

### Clear History
```dart
// Remove single item
await BackendRecentlyViewedService.removeRecentlyViewed(recentlyViewedId);

// Clear all
await BackendRecentlyViewedService.clearRecentlyViewed(user.uid);
```

---

## 📤 Upload Service

### Upload Avatar
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Pick image
final picker = ImagePicker();
final pickedFile = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 800,
  maxHeight: 800,
  imageQuality: 85,
);

if (pickedFile != null) {
  final user = FirebaseAuth.instance.currentUser;
  
  // Upload
  final result = await BackendUploadService.uploadAvatar(
    imageFile: File(pickedFile.path),
    userId: user!.uid,
    oldAvatarPath: profile?.photoURL, // Delete old avatar
  );
  
  if (result != null) {
    final avatarUrl = result['url'];
    final filename = result['filename'];
    
    // Update user profile
    await BackendUserService.updateUserProfile(user.uid, {
      'photoURL': avatarUrl,
    });
    
    print('Avatar uploaded: $avatarUrl');
    
    // Display image
    setState(() {
      _avatarUrl = avatarUrl;
    });
  }
}
```

### Display Avatar
```dart
// From URL
Image.network(
  BackendUploadService.getAvatarUrlFromPath(profile.photoURL) 
    ?? 'https://via.placeholder.com/150',
  fit: BoxFit.cover,
)

// Or directly
Image.network(
  profile.photoURL ?? 'https://via.placeholder.com/150',
  fit: BoxFit.cover,
)
```

### Delete Avatar
```dart
final filename = profile.photoURL?.split('/').last;
if (filename != null) {
  await BackendUploadService.deleteAvatar(filename);
}
```

---

## 🎬 Complete Example: Movie Detail Page

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/services/backend_favorites_service.dart';
import 'package:flutter_movie_app/services/backend_recently_viewed_service.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  final String title;
  final String posterPath;
  
  const MovieDetailPage({
    required this.movieId,
    required this.title,
    required this.posterPath,
  });

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool _isFavorite = false;
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Track view
      await BackendRecentlyViewedService.trackView(
        userId: user.uid,
        mediaType: 'movie',
        mediaId: widget.movieId,
        title: widget.title,
        posterPath: widget.posterPath,
      );
      
      // Check if favorite
      final isFav = await BackendFavoritesService.isFavorite(
        userId: user.uid,
        mediaType: 'movie',
        mediaId: widget.movieId,
      );
      
      setState(() {
        _isFavorite = isFav;
        _loading = false;
      });
    }
  }
  
  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    if (_isFavorite) {
      // Remove
      await BackendFavoritesService.removeFavoriteByMedia(
        userId: user.uid,
        mediaType: 'movie',
        mediaId: widget.movieId,
      );
    } else {
      // Add
      await BackendFavoritesService.addFavorite(
        userId: user.uid,
        mediaType: 'movie',
        mediaId: widget.movieId,
        title: widget.title,
        posterPath: widget.posterPath,
      );
    }
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: Center(
        child: Text('Movie Detail'),
      ),
    );
  }
}
```

---

## 🔄 Migration Checklist

### ✅ Replace Firestore Code

**Before (Firestore)**:
```dart
final favoritesRef = FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('favorites');
  
await favoritesRef.add({...});
```

**After (Backend)**:
```dart
await BackendFavoritesService.addFavorite(
  userId: userId,
  mediaType: 'movie',
  mediaId: movieId,
  title: title,
);
```

---

## 🌐 API Base URL

Current: `http://10.0.2.2:3000` (Android Emulator)

Change in `lib/config/api_config.dart`:
```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// iOS Simulator
static const String baseUrl = 'http://localhost:3000';

// Physical Device (same WiFi)
static const String baseUrl = 'http://192.168.1.x:3000';
```

---

## 🎉 Ready to Use!

All services are ready. Start updating your UI! 🚀
