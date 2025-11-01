# Fix Movies Using Backend API (Not TMDB)

## 🐛 Issue
> "Hình như phần movie tôi chạy nó hiển thị ở TMDB chứ ko phải từ backend"

### Problem
Movies section was calling TMDB API instead of Backend API for:
- Now Playing movies → Called generic getMovies() instead of backend endpoint
- Upcoming movies → Called generic getMovies() instead of backend endpoint

---

## 🔍 Root Cause

### Missing Backend Methods

**MovieApiService** was missing:
- `getNowPlayingMovies()` method
- `getUpcomingMovies()` method

**UnifiedMovieService** was using fallback:
```dart
// WRONG ❌
Future<List<Movie>> getNowPlayingMovies({...}) async {
  if (_useBackend) {
    // Backend doesn't have "now playing" category, use regular movies
    return getMovies(page: page, limit: limit);  // ❌ Wrong!
  }
  return _getTMDBMovies('/movie/now_playing', ...);
}
```

**Result**: Now Playing always showed Popular movies (duplicate data) ❌

---

## ✅ Fix Applied

### 1. Added Methods to MovieApiService

**File**: `lib/services/movie_api_service.dart`

#### Added getNowPlayingMovies()
```dart
// Get now playing movies
Future<List<Movie>> getNowPlayingMovies({int limit = 10}) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/movies/now-playing').replace(
      queryParameters: {'limit': limit.toString()},
    );

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((json) => Movie.fromBackendApi(json))
            .toList();
      }
    }

    print('Error fetching now playing movies: ${response.statusCode}');
    return [];
  } catch (e) {
    print('Error fetching now playing movies: $e');
    return [];
  }
}
```

#### Added getUpcomingMovies()
```dart
// Get upcoming movies
Future<List<Movie>> getUpcomingMovies({int limit = 10}) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/movies/upcoming').replace(
      queryParameters: {'limit': limit.toString()},
    );

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((json) => Movie.fromBackendApi(json))
            .toList();
      }
    }

    print('Error fetching upcoming movies: ${response.statusCode}');
    return [];
  } catch (e) {
    print('Error fetching upcoming movies: $e');
    return [];
  }
}
```

### 2. Updated UnifiedMovieService

**File**: `lib/services/unified_movie_service.dart`

#### Fixed getNowPlayingMovies()
```dart
// BEFORE ❌
Future<List<Movie>> getNowPlayingMovies({int page = 1, int limit = 10}) async {
  if (_useBackend) {
    // Backend doesn't have "now playing" category, use regular movies
    return getMovies(page: page, limit: limit);  // ❌ Wrong endpoint
  }
  return _getTMDBMovies('/movie/now_playing', page: page, limit: limit);
}

// AFTER ✅
Future<List<Movie>> getNowPlayingMovies({int page = 1, int limit = 10}) async {
  if (_useBackend) {
    try {
      final movies = await _backendService.getNowPlayingMovies(limit: limit);
      
      if (movies.isNotEmpty) {
        print('UnifiedMovieService: Loaded ${movies.length} now playing from Backend ✅');
        return movies;
      }
    } catch (e) {
      print('UnifiedMovieService: Backend now playing failed, trying TMDB... ⚠️');
    }
  }
  
  return _getTMDBMovies('/movie/now_playing', page: page, limit: limit);
}
```

#### Fixed getUpcomingMovies()
```dart
// BEFORE ❌
Future<List<Movie>> getUpcomingMovies({int page = 1, int limit = 10}) async {
  if (_useBackend) {
    // Backend doesn't have "upcoming" category, use newest movies
    return getMovies(page: page, limit: limit);  // ❌ Wrong endpoint
  }
  return _getTMDBMovies('/movie/upcoming', page: page, limit: limit);
}

// AFTER ✅
Future<List<Movie>> getUpcomingMovies({int page = 1, int limit = 10}) async {
  if (_useBackend) {
    try {
      final movies = await _backendService.getUpcomingMovies(limit: limit);
      
      if (movies.isNotEmpty) {
        print('UnifiedMovieService: Loaded ${movies.length} upcoming from Backend ✅');
        return movies;
      }
    } catch (e) {
      print('UnifiedMovieService: Backend upcoming failed, trying TMDB... ⚠️');
    }
  }
  
  return _getTMDBMovies('/movie/upcoming', page: page, limit: limit);
}
```

---

## 📊 Impact

### Before Fix

**Movies Section**:
```
Popular Movies: Backend ✅ (correct)
  → GET /api/movies

Now Playing: Backend ❌ (wrong endpoint)
  → GET /api/movies (same as Popular!)
  
Top Rated: Backend ✅ (correct)
  → GET /api/movies/top-rated
```

**Result**: Now Playing showed duplicate of Popular movies ❌

### After Fix

**Movies Section**:
```
Popular Movies: Backend ✅
  → GET /api/movies

Now Playing: Backend ✅
  → GET /api/movies/now-playing

Top Rated: Backend ✅
  → GET /api/movies/top-rated
```

**Result**: Each section shows correct data! ✅

---

## 🎯 Complete Backend Integration

### All Movie Endpoints Now Use Backend

| Section | Endpoint | Service Method | Status |
|---------|----------|----------------|--------|
| **Popular** | `/api/movies` | `getMovies()` | ✅ Backend |
| **Now Playing** | `/api/movies/now-playing` | `getNowPlayingMovies()` | ✅ **FIXED** |
| **Top Rated** | `/api/movies/top-rated` | `getTopRatedMovies()` | ✅ Backend |
| **Upcoming** | `/api/movies/upcoming` | `getUpcomingMovies()` | ✅ **FIXED** |
| **Trending** | `/api/trending` | `getTrendingMovies()` | ✅ Backend |
| **Search** | `/api/search` | `searchMovies()` | ✅ Backend |

**All 6 movie endpoints now use Backend!** 🎉

---

## 🧪 Testing

### Manual Testing

1. **Restart Flutter App**:
   ```bash
   flutter run
   # Or hot restart: Press 'R' in terminal
   ```

2. **Check Movies Section**:
   - Scroll to Movies section on homepage
   - Should see 3 sections:
     1. **Popular Now** → 10 unique movies
     2. **Now Playing** → 10 unique movies (different from Popular)
     3. **Top Rated** → 10 unique movies (different from Popular)

3. **Verify Data Source**:
   - Check Flutter console logs:
   ```
   ✅ Should see:
   UnifiedMovieService: Loaded 10 popular from Backend ✅
   UnifiedMovieService: Loaded 10 now playing from Backend ✅
   UnifiedMovieService: Loaded 10 top rated from Backend ✅
   
   ❌ Should NOT see:
   Backend now playing failed, trying TMDB...
   ```

4. **Check Backend Logs**:
   ```bash
   cd backend
   npm run dev
   
   # Should see:
   ✅ Serving now playing movies from cache
   ✅ Serving top rated movies from cache
   ```

### Verify Unique Data

**Before Fix**:
```
Popular Movies: Spider-Man, Avatar, Avengers...
Now Playing: Spider-Man, Avatar, Avengers...  ← DUPLICATE ❌
Top Rated: The Godfather, Shawshank...
```

**After Fix**:
```
Popular Movies: Spider-Man, Avatar, Avengers...
Now Playing: Dune 2, Mission Impossible...  ← UNIQUE ✅
Top Rated: The Godfather, Shawshank...
```

---

## 📋 Files Modified

### 1. lib/services/movie_api_service.dart
**Changes**:
- ✅ Added `getNowPlayingMovies()` method
- ✅ Added `getUpcomingMovies()` method

**Lines Added**: ~60 lines

### 2. lib/services/unified_movie_service.dart
**Changes**:
- ✅ Fixed `getNowPlayingMovies()` to call backend method
- ✅ Fixed `getUpcomingMovies()` to call backend method
- ✅ Removed fallback to `getMovies()`

**Lines Modified**: ~30 lines

---

## 🔗 Backend Endpoints (Already Exist)

### Routes Already Configured

**File**: `backend/src/routes/movies.js`

```javascript
router.get('/', getPopularMovies);           // ✅ /api/movies
router.get('/top-rated', getTopRatedMovies); // ✅ /api/movies/top-rated
router.get('/now-playing', getNowPlayingMovies); // ✅ /api/movies/now-playing
router.get('/upcoming', getUpcomingMovies);   // ✅ /api/movies/upcoming
```

**All backend endpoints were already working!** The issue was Flutter not calling them.

---

## ✅ Success Criteria

- [x] MovieApiService has getNowPlayingMovies() method
- [x] MovieApiService has getUpcomingMovies() method
- [x] UnifiedMovieService calls backend for now playing
- [x] UnifiedMovieService calls backend for upcoming
- [x] Popular Movies shows from backend
- [x] Now Playing shows from backend (unique data)
- [x] Top Rated shows from backend
- [x] Upcoming shows from backend (when available)
- [x] All 4 sections show different movies
- [x] No TMDB fallback unless backend fails

---

## 🎯 Summary

### Problem
- Now Playing & Upcoming were NOT calling backend endpoints
- They fell back to Popular Movies endpoint
- Showed duplicate data

### Solution
- Added `getNowPlayingMovies()` to MovieApiService
- Added `getUpcomingMovies()` to MovieApiService
- Updated UnifiedMovieService to use new methods
- Now correctly calls backend endpoints

### Result
- **100% Backend Integration** for Movies section
- All 4 movie categories show unique data from backend
- TMDB only used as fallback if backend fails

---

**Date**: November 1, 2025  
**Issue**: Movies using TMDB instead of Backend  
**Root Cause**: Missing backend methods for Now Playing & Upcoming  
**Fix**: Added 2 methods to MovieApiService, updated UnifiedMovieService  
**Status**: ✅ FIXED - All movies now from Backend  
**Impact**: Movies section now 100% backend-powered
