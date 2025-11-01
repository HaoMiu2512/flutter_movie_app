# Trending & Upcoming Backend Implementation - Summary

## ✅ Implementation Complete

Successfully migrated **Trending** and **Upcoming** from direct TMDB API calls to custom Backend API with TMDB fallback pattern. Each collection contains **10 items** from TMDB.

---

## 📋 Changes Overview

### Database Changes (MongoDB)

#### New Collections Created

1. **`trendings`** - Mixed content (Movies + TV Series)
   - Count: 10 items (9 movies, 1 TV series)
   - Sorted by: popularity descending
   - Fields: id, poster_path, title/name, vote_average, media_type, etc.

2. **`upcomings`** - Movies only
   - Count: 10 upcoming movies
   - Sorted by: release_date ascending (nearest first)
   - Fields: id, poster_path, title, vote_average, release_date, etc.

---

### Backend Changes (Node.js)

#### 1. Models Created

**`backend/src/models/Trending.js`**
```javascript
const trendingSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  poster_path: String,
  backdrop_path: String,
  title: String, // For movies
  name: String, // For TV series
  vote_average: Number,
  media_type: { type: String, enum: ['movie', 'tv'], required: true },
  overview: String,
  release_date: String,
  first_air_date: String,
  popularity: Number,
  genre_ids: [Number],
  // ... other fields
});
```

**`backend/src/models/Upcoming.js`**
```javascript
const upcomingSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  poster_path: String,
  backdrop_path: String,
  title: { type: String, required: true },
  vote_average: Number,
  overview: String,
  release_date: String,
  popularity: Number,
  genre_ids: [Number],
  // ... other fields
});
```

#### 2. Controllers Created

**`backend/src/controllers/trendingController.js`**
- `getTrending()` - Get all trending (movies + TV)
- `getTrendingMovies()` - Get trending movies only
- `getTrendingTv()` - Get trending TV series only

**`backend/src/controllers/upcomingController.js`**
- `getUpcomingMovies()` - Get upcoming movies

#### 3. Routes Created

**`backend/src/routes/trending.js`**
```javascript
router.get('/', getTrending);          // GET /api/trending
router.get('/movies', getTrendingMovies);  // GET /api/trending/movies
router.get('/tv', getTrendingTv);      // GET /api/trending/tv
```

**`backend/src/routes/movies.js`** (updated)
```javascript
router.get('/upcoming', getUpcomingMovies); // GET /api/movies/upcoming
```

#### 4. Main Server Updated

**`backend/index.js`**
- Added route: `app.use('/api/trending', require('./src/routes/trending'))`
- Updated API endpoint list in root response

#### 5. Import Script Created

**`backend/src/scripts/importTrendingUpcoming.js`**
- Fetches 10 trending items from TMDB trending/all/week endpoint
- Fetches 10 upcoming movies from TMDB movie/upcoming endpoint
- Imports to MongoDB with upsert (update or insert)
- Usage: `node src/scripts/importTrendingUpcoming.js`

---

### Flutter Changes (Dart)

#### 1. HomePage - Trending (`lib/HomePage/HomePage.dart`)

**Import Added:**
```dart
import 'package:flutter_movie_app/config/api_config.dart';
```

**Function `trendinglist()` Updated:**
```dart
Future<void> trendinglist(int checkerno) async {
  // Try Backend API first
  try {
    var trendingUrl = '${ApiConfig.baseUrl}/api/trending';
    var response = await http.get(Uri.parse(trendingUrl));
    
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      
      // Check if Backend API response
      if (json.containsKey('success') && json['success'] == true) {
        print('✅ Loading trending from Backend...');
        // Process Backend response
        return; // Success - exit early
      }
    }
  } catch (e) {
    print('❌ Error loading trending from Backend: $e');
    print('⚠️  Falling back to TMDB...');
  }

  // Fallback to TMDB API (week/day based on checkerno)
  // ... original TMDB code
}
```

**Key Changes:**
- Backend-first approach with automatic TMDB fallback
- Clears list before loading to prevent duplicates
- Ignores `checkerno` parameter for Backend (always returns same data)
- TMDB fallback still respects week/day parameter

#### 2. Upcoming Page (`lib/HomePage/SectionPage/upcoming.dart`)

**Import Added:**
```dart
import 'package:flutter_movie_app/config/api_config.dart';
```

**URL Changed:**
```dart
// OLD:
final String upcomingmoviesurl = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$apikey';

// NEW:
final String upcomingmoviesurl = '${ApiConfig.baseUrl}/api/movies/upcoming';
```

**Function `getUpcomming()` Updated:**
```dart
Future<void> getUpcomming() async {
  getUpcomminglist.clear();

  // Try Backend API first
  try {
    var response = await http.get(Uri.parse(upcomingmoviesurl));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      
      if (json.containsKey('success') && json['success'] == true) {
        print('✅ Loading upcoming from Backend...');
        // Process Backend response
        return; // Success
      }
    }
  } catch (e) {
    print('❌ Error loading upcoming from Backend: $e');
    print('⚠️  Falling back to TMDB...');
  }

  // Fallback to TMDB API
  // ... original TMDB code
}
```

---

## 🧪 Testing Results

### Backend Endpoints Tested

#### Test 1: All Trending (Movies + TV)
```bash
curl http://localhost:3000/api/trending
```
**Result:** ✅ Success - 10 trending items returned
- 9 movies (The Long Walk, xXx, The Fantastic 4, etc.)
- 1 TV series (Gen V)
- Sorted by popularity

Response format:
```json
{
  "success": true,
  "results": [
    {
      "id": 604079,
      "poster_path": "/wobVTa99eW0ht6c1rNNzLkazPtR.jpg",
      "title": "The Long Walk",
      "vote_average": 6.873,
      "media_type": "movie",
      "popularity": 233.8912,
      ...
    },
    ...
  ],
  "total": 10
}
```

#### Test 2: Upcoming Movies
```bash
curl http://localhost:3000/api/movies/upcoming
```
**Result:** ✅ Success - 10 upcoming movies returned
- Sorted by release_date (nearest first)
- Ne Zha 2 (2025-01-29)
- KPop Demon Hunters (2025-06-20)
- Pets on a Train (2025-07-02)
- ... up to Regretting You (2025-10-22)

Response format:
```json
{
  "success": true,
  "results": [
    {
      "id": 980477,
      "poster_path": "/cb5NyNrqiCNNoDkA8FfxHAtypdG.jpg",
      "title": "Ne Zha 2",
      "vote_average": 8.042,
      "release_date": "2025-01-29",
      ...
    },
    ...
  ],
  "total": 10
}
```

---

## 🎯 Architecture Pattern

### Request Flow
```
Flutter App
    ↓
1. Try Backend API first
    ↓
Backend Server → MongoDB (trendings/upcomings collections)
    ↓
✅ Success? → Return data
    ↓
❌ Error/Empty?
    ↓
2. Fallback to TMDB API
    ↓
TMDB API → Direct response
    ↓
Return data to Flutter
```

### Response Format (Backend)
Backend returns TMDB-compatible format:

```json
{
  "success": true,
  "results": [
    {
      "id": <number>,
      "poster_path": <string>,
      "title": <string>,        // For movies
      "name": <string>,         // For TV series
      "vote_average": <number>,
      "media_type": <"movie"|"tv">,
      "release_date": <string>, // For movies
      "first_air_date": <string>, // For TV
      ...
    }
  ],
  "total": <number>
}
```

---

## 📊 Files Modified/Created

### Backend (10 files)

**Created:**
1. `backend/src/models/Trending.js` - Trending schema
2. `backend/src/models/Upcoming.js` - Upcoming schema
3. `backend/src/controllers/trendingController.js` - Trending endpoints logic
4. `backend/src/controllers/upcomingController.js` - Upcoming endpoint logic
5. `backend/src/routes/trending.js` - Trending routes
6. `backend/src/scripts/importTrendingUpcoming.js` - Import script

**Modified:**
7. `backend/src/routes/movies.js` - Added upcoming route
8. `backend/index.js` - Registered trending routes
9. `backend/.env` - Added TMDB_API_KEY

### Flutter (2 files)

**Modified:**
1. `lib/HomePage/HomePage.dart` - Updated `trendinglist()` function
2. `lib/HomePage/SectionPage/upcoming.dart` - Updated `getUpcomming()` function

---

## 📦 Database Import Summary

### Trending Collection (10 items)
```
✅ MOVIE: A House of Dynamite (ID: 1290159)
✅ MOVIE: The Long Walk (ID: 604079)
✅ MOVIE: The Roses (ID: 1267905)
✅ MOVIE: xXx (ID: 7451)
✅ MOVIE: The Fantastic 4: First Steps (ID: 617126)
✅ TV: Gen V (ID: 205715)
✅ MOVIE: Good Boy (ID: 1422096)
✅ MOVIE: The Elixir (ID: 1306525)
✅ MOVIE: Chainsaw Man - The Movie: Reze Arc (ID: 1218925)
✅ MOVIE: Weapons (ID: 1078605)
```

### Upcoming Collection (10 movies)
```
✅ Black Phone 2 (ID: 1197137) - Release: 2025-10-15
✅ The Toxic Avenger Unrated (ID: 338969) - Release: 2025-08-28
✅ The Strangers: Chapter 2 (ID: 1010756) - Release: 2025-09-25
✅ KPop Demon Hunters (ID: 803796) - Release: 2025-06-20
✅ Primitive War (ID: 1257009) - Release: 2025-08-21
✅ Pets on a Train (ID: 1107216) - Release: 2025-07-02
✅ Chainsaw Man - The Movie: Reze Arc (ID: 1218925) - Release: 2025-09-19
✅ Ne Zha 2 (ID: 980477) - Release: 2025-01-29
✅ Anemone (ID: 1364608) - Release: 2025-10-02
✅ Regretting You (ID: 1327862) - Release: 2025-10-22
```

---

## ✨ Benefits

1. **Reduced API Calls:** Trending and Upcoming now loaded from local MongoDB
2. **Faster Response:** Local database queries faster than external API
3. **Offline Ready:** Data available even if TMDB API is down
4. **Consistent Pattern:** Same Backend-first approach as Movies/TV Series/Videos
5. **Graceful Degradation:** Automatic fallback ensures app always works
6. **Cost Savings:** Fewer TMDB API calls reduce quota usage
7. **Curated Content:** Can manually update trending/upcoming anytime by re-running import script

---

## 🔄 Data Update Process

To refresh trending/upcoming data:

```bash
cd backend
node src/scripts/importTrendingUpcoming.js
```

This will:
- Fetch latest 10 trending items from TMDB
- Fetch latest 10 upcoming movies from TMDB
- Update MongoDB collections (upsert - update existing or insert new)
- Show summary of imported items

**Recommended Schedule:**
- Trending: Weekly update (matches TMDB trending/week)
- Upcoming: Monthly update (new releases don't change often)

---

## 🔍 API Endpoints Summary

### Trending Endpoints
- `GET /api/trending` - All trending (movies + TV)
- `GET /api/trending/movies` - Trending movies only
- `GET /api/trending/tv` - Trending TV series only

### Upcoming Endpoint
- `GET /api/movies/upcoming` - Upcoming movies

All endpoints return:
```json
{
  "success": true,
  "results": [...],
  "total": <number>
}
```

---

## 📝 Notes

- **Trending Week/Day:** Flutter still has `checkerno` parameter (1=week, 2=day) but Backend returns same data. TMDB fallback still respects this parameter.

- **Media Type:** Trending includes both movies and TV series. Backend properly identifies `media_type` field.

- **Data Limit:** Import script limits to 10 items each. Backend can return up to 20 items per endpoint (configurable in controller).

- **TMDB API Key:** Now stored in Backend `.env` file for import script usage.

- **Response Compatibility:** Backend returns TMDB-compatible format, so Flutter code needs minimal changes.

---

## 🚀 Next Steps (Optional Enhancements)

1. **Scheduled Updates:** Create cron job to auto-update trending/upcoming daily/weekly
2. **Cache Headers:** Add cache-control headers for better performance
3. **Pagination:** Add pagination support for larger datasets
4. **Filters:** Add query parameters to filter by media_type, genre, etc.
5. **Admin Panel:** Create admin interface to manually curate trending/upcoming
6. **Analytics:** Track Backend vs TMDB usage ratio

---

**Implementation Date:** October 25, 2025
**Status:** ✅ Complete and Tested
**Pattern:** Backend-first with TMDB fallback
**Collections:** 2 new MongoDB collections (trendings, upcomings)
**Endpoints:** 4 new Backend endpoints
**Items:** 10 trending + 10 upcoming = 20 items total
