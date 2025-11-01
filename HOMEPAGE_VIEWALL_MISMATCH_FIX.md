# Homepage vs View All Data Mismatch Fix

## 🎯 Vấn Đề
> "Phần movie popular now ở homepage có những bộ phim khác nhưng khi click vào view all thì lại hiện những bộ khác"

**User Experience**:
- Homepage slider shows Movie A, B, C...
- Click "View All" → Shows Movie X, Y, Z...
- **Different movies!** ❌

---

## 🔍 Root Cause Analysis

### Data Flow Comparison

#### Homepage Slider (BEFORE FIX)
```dart
// movies.dart
UnifiedMovieService.getPopularMovies()
  ↓
// unified_movie_service.dart  
getMovies(page: page, limit: limit)  // ❌ Generic method
  ↓
// movie_api_service.dart
GET /api/movies?limit=10  // ❌ No sorting, random order
  ↓
// Backend: getAllMovies()
return Movie.find().limit(10)  // ❌ Unsorted, returns any 10 movies
```

#### View All Page (Working Correctly)
```dart
// sliderlist.dart → ViewAllPage
apiEndpoint: '/api/movies/popular'
  ↓
GET /api/movies/popular?limit=10  // ✅ Specific endpoint
  ↓
// Backend: getPopularMovies()
return Movie.find({ cacheType: 'popular' })
  .sort({ popularity: -1 })  // ✅ Sorted by popularity
  .limit(10)
```

### Why Different Data?

| Source | Endpoint | Sorting | Cache Type | Result |
|--------|----------|---------|------------|--------|
| **Homepage** | `/api/movies` | ❌ None | Mixed | Random 10 movies |
| **View All** | `/api/movies/popular` | ✅ By popularity | `popular` | Top 10 popular movies |

**Problem**: Homepage and View All were calling **different endpoints**!

---

## ✅ Solution

### Fix 1: Add `getPopularMovies()` to MovieApiService

**File**: `lib/services/movie_api_service.dart`

**Added new method**:
```dart
// Get popular movies
Future<List<Movie>> getPopularMovies({int limit = 10}) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/movies/popular').replace(
      queryParameters: {'limit': limit.toString()},
    );

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        print('MovieApiService: Loaded ${(data['data'] as List).length} popular movies from /api/movies/popular');
        return (data['data'] as List)
            .map((json) => Movie.fromBackendApi(json))
            .toList();
      }
    }

    print('Error fetching popular movies: ${response.statusCode}');
    return [];
  } catch (e) {
    print('Error fetching popular movies: $e');
    return [];
  }
}
```

**Why needed**:
- ✅ Calls specific `/api/movies/popular` endpoint
- ✅ Returns movies sorted by popularity
- ✅ Same data source as View All

---

### Fix 2: Update `UnifiedMovieService.getPopularMovies()`

**File**: `lib/services/unified_movie_service.dart`

#### Before ❌
```dart
Future<List<Movie>> getPopularMovies({int page = 1, int limit = 10}) async {
  return getMovies(page: page, limit: limit);  // ❌ Generic, unsorted
}
```

#### After ✅
```dart
Future<List<Movie>> getPopularMovies({int page = 1, int limit = 10}) async {
  if (_useBackend) {
    try {
      final movies = await _backendService.getPopularMovies(limit: limit);  // ✅ Specific method
      
      if (movies.isNotEmpty) {
        print('UnifiedMovieService: Loaded ${movies.length} popular movies from Backend ✅');
        return movies;
      }
    } catch (e) {
      print('UnifiedMovieService: Backend popular movies failed, trying TMDB... ⚠️');
    }
  }
  
  // Fallback to TMDB
  return _getTMDBMovies('/movie/popular', page: page, limit: limit);
}
```

**Benefits**:
- ✅ Uses specific backend method
- ✅ Calls `/api/movies/popular` endpoint
- ✅ Maintains TMDB fallback
- ✅ Consistent with View All

---

## 📊 Data Flow (AFTER FIX)

### Both Homepage & View All Use Same Endpoint

```
Homepage Slider
  ↓
UnifiedMovieService.getPopularMovies()
  ↓
MovieApiService.getPopularMovies()  // ✅ NEW
  ↓
GET /api/movies/popular
  ↓
Backend: getPopularMovies()
  ↓
Movie.find({ cacheType: 'popular' })
  .sort({ popularity: -1 })
  .limit(10)
  ↓
[Top 10 Popular Movies] ✅

View All Page
  ↓
Direct API call
  ↓
GET /api/movies/popular
  ↓
Backend: getPopularMovies()
  ↓
Movie.find({ cacheType: 'popular' })
  .sort({ popularity: -1 })
  .limit(10)
  ↓
[Top 10 Popular Movies] ✅
```

**Result**: Homepage slider and View All now show **SAME movies**!

---

## 🧪 Testing

### 1. Hot Reload Flutter App
```bash
r  # In Flutter terminal
```

### 2. Test Homepage Slider
- Go to Movies section
- Check "Popular Now" slider
- Note the first 3 movie titles

### 3. Test View All
- Click "View All" on Popular Now
- Check the movie list
- **Should see SAME movies** as homepage slider ✅

### 4. Verify Logs

**Flutter Console**:
```
MovieApiService: Loaded 10 popular movies from /api/movies/popular
UnifiedMovieService: Loaded 10 popular movies from Backend ✅
```

**Backend Console**:
```
📊 Found 20 popular movies in cache
✅ Serving popular movies from cache (page 1, 10 items of 20 total)
```

---

## 📈 Before vs After

### Before ❌

**Homepage**:
- Call: `/api/movies` (generic)
- Movies: Random unsorted 10 movies
- Example: Movie 1, 5, 12, 3, 8...

**View All**:
- Call: `/api/movies/popular` (specific)
- Movies: Top 10 by popularity
- Example: Movie 550, 238, 680, 155...

**Result**: Completely different movies! ❌

---

### After ✅

**Homepage**:
- Call: `/api/movies/popular` (specific)
- Movies: Top 10 by popularity
- Example: Movie 550, 238, 680, 155...

**View All**:
- Call: `/api/movies/popular` (specific)
- Movies: Top 10 by popularity  
- Example: Movie 550, 238, 680, 155...

**Result**: SAME movies! ✅

---

## 🎯 Consistency Check

### All Movie Categories Now Consistent

| Category | Homepage Method | View All Endpoint | Status |
|----------|----------------|-------------------|--------|
| **Popular** | `getPopularMovies()` | `/api/movies/popular` | ✅ Fixed |
| **Now Playing** | `getNowPlayingMovies()` | `/api/movies/now-playing` | ✅ Already correct |
| **Top Rated** | `getTopRatedMovies()` | `/api/movies/top-rated` | ✅ Already correct |
| **Upcoming** | `getUpcomingMovies()` | `/api/movies/upcoming` | ✅ Already correct |

**All categories now use matching endpoints!** 🎉

---

## 🔧 Technical Details

### Method Signature
```dart
// MovieApiService
Future<List<Movie>> getPopularMovies({int limit = 10})

// UnifiedMovieService  
Future<List<Movie>> getPopularMovies({int page = 1, int limit = 10})
```

### API Call
```dart
Uri.parse('${ApiConfig.baseUrl}/api/movies/popular')
  .replace(queryParameters: {'limit': limit.toString()})

// Example: http://localhost:3000/api/movies/popular?limit=10
```

### Response Format
```json
{
  "success": true,
  "source": "cache",
  "data": [
    {
      "tmdbId": 550,
      "title": "Fight Club",
      "popularity": 145.82,
      ...
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 20,
    "pages": 2
  }
}
```

---

## 📝 Related Files

### Modified
1. ✅ `lib/services/movie_api_service.dart`
   - Added `getPopularMovies()` method

2. ✅ `lib/services/unified_movie_service.dart`
   - Updated `getPopularMovies()` to use specific backend method

### Related (No changes needed)
- `lib/HomePage/SectionPage/movies.dart` - Already correct
- `lib/pages/view_all_page.dart` - Already correct
- `backend/src/controllers/movieControllerNew.js` - Already correct

---

## 🐛 Debugging Tips

### If movies still don't match:

1. **Clear cache and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check backend cache**:
   ```bash
   curl "http://localhost:3000/api/movies/popular?forceRefresh=true"
   ```

3. **Enable verbose logging**:
   - Check Flutter console for API calls
   - Check backend console for endpoint calls
   - Should see same endpoint being called

4. **Verify data in MongoDB**:
   ```javascript
   db.movies.find({ cacheType: 'popular' })
     .sort({ popularity: -1 })
     .limit(10)
   ```

---

## ✨ Summary

**Problem**: Homepage and View All showed different movies because they used different endpoints.

**Root Cause**: 
- Homepage: `/api/movies` (generic, unsorted)
- View All: `/api/movies/popular` (specific, sorted)

**Solution**: 
- Added `getPopularMovies()` to `MovieApiService`
- Updated `UnifiedMovieService` to use new method
- Both now call `/api/movies/popular`

**Result**: Homepage and View All now show SAME movies! ✅

---

**Date**: November 2, 2025  
**Status**: ✅ Fixed & Ready for Testing  
**Impact**: High - Ensures data consistency across UI  
**Related Issues**: Homepage/View All data mismatch
