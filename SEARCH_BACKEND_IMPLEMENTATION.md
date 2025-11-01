# Search Backend Implementation - Summary

## ✅ Implementation Complete

Successfully migrated **Search** functionality from direct TMDB API calls to custom Backend API with TMDB fallback pattern. Backend searches both Movies and TV Series collections simultaneously.

---

## 📋 Changes Overview

### Backend Changes (Node.js)

#### 1. Controller Created

**`backend/src/controllers/searchController.js`**

**Three search functions:**

1. **`searchMulti()`** - Search both movies and TV series
```javascript
async function searchMulti(req, res) {
  const { q, limit = 20 } = req.query;
  
  // Search movies by title (case-insensitive)
  const movies = await Movie.find({
    title: { $regex: searchQuery, $options: 'i' }
  });
  
  // Search TV series by name (case-insensitive)
  const tvSeries = await TvSeries.find({
    name: { $regex: searchQuery, $options: 'i' }
  });
  
  // Combine and sort by popularity
  const combinedResults = [...movieResults, ...tvResults]
    .sort((a, b) => (b.popularity || 0) - (a.popularity || 0))
    .slice(0, searchLimit);
}
```

2. **`searchMovies()`** - Search movies only
3. **`searchTvSeries()`** - Search TV series only

**Key Features:**
- Case-insensitive regex search
- Searches both collections in parallel (`Promise.all`)
- Combines results and sorts by popularity
- Returns up to 20 results (configurable via `limit` query param)
- Consistent response format matching TMDB

#### 2. Routes Created

**`backend/src/routes/search.js`**
```javascript
router.get('/', searchMulti);           // GET /api/search?q=query
router.get('/movies', searchMovies);    // GET /api/search/movies?q=query
router.get('/tv', searchTvSeries);      // GET /api/search/tv?q=query
```

#### 3. Server Updated

**`backend/index.js`**
- Added route: `app.use('/api/search', require('./src/routes/search'))`
- Updated API endpoints documentation

---

### Flutter Changes (Dart)

#### Updated File: `lib/reapeatedfunction/searchbarfunction.dart`

**Import Added:**
```dart
import 'package:flutter_movie_app/config/api_config.dart';
```

**Function `searchlistfunction()` Updated:**

**Before:**
```dart
Future<void> searchlistfunction(val) async {
  var searchurl = 'https://api.themoviedb.org/3/search/multi?api_key=$apikey&query=$val';
  var searchresponse = await http.get(Uri.parse(searchurl));
  // ... process TMDB response
}
```

**After:**
```dart
Future<void> searchlistfunction(val) async {
  // Try Backend API first
  try {
    var searchUrl = '${ApiConfig.baseUrl}/api/search?q=${Uri.encodeComponent(val)}';
    var response = await http.get(Uri.parse(searchUrl));
    
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      
      if (json.containsKey('success') && json['success'] == true) {
        print('✅ Loading search results from Backend...');
        // Process Backend results
        
        if (searchresult.isNotEmpty) {
          return; // Success - exit early
        }
      }
    }
  } catch (e) {
    print('❌ Error searching from Backend: $e');
    print('⚠️  Falling back to TMDB...');
  }

  // Fallback to TMDB API if Backend fails or has no results
  var searchurl = 'https://api.themoviedb.org/3/search/multi?api_key=$apikey&query=$val';
  // ... TMDB fallback logic
}
```

**Key Changes:**
- Backend-first approach with automatic TMDB fallback
- URL encoding for search query (`Uri.encodeComponent`)
- Returns early if Backend has results
- Falls back to TMDB if Backend is empty or fails
- Maintains same result format for UI compatibility

---

## 🎯 Architecture Pattern

### Request Flow
```
User types search query
    ↓
1. Try Backend API first
   GET /api/search?q=query
    ↓
Backend searches:
  - Movies collection (by title)
  - TV Series collection (by name)
  - Combines & sorts by popularity
    ↓
✅ Has results? → Return to Flutter
    ↓
❌ No results or error?
    ↓
2. Fallback to TMDB API
   GET /search/multi?api_key=xxx&query=yyy
    ↓
Return TMDB results to Flutter
```

### Response Format (Backend)

**Request:**
```
GET /api/search?q=spider&limit=10
```

**Response:**
```json
{
  "success": true,
  "results": [
    {
      "id": 557,
      "title": "Spider-Man",
      "poster_path": "/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg",
      "backdrop_path": "/...",
      "vote_average": 7.2,
      "overview": "After being bitten by...",
      "release_date": "2002-05-01",
      "popularity": 123.456,
      "media_type": "movie"
    },
    {
      "id": 12345,
      "title": "Spider-Man: The Animated Series",
      "name": "Spider-Man: The Animated Series",
      "poster_path": "/...",
      "vote_average": 8.1,
      "first_air_date": "1994-11-19",
      "release_date": "1994-11-19",
      "popularity": 98.765,
      "media_type": "tv"
    }
  ],
  "total": 2,
  "query": "spider"
}
```

---

## 🧪 Testing Results

### Test 1: Search in Backend Database
```bash
curl -G "http://localhost:3000/api/search" --data-urlencode "q=gen"
```

**Result:** ✅ Success
```json
{
  "success": true,
  "results": [
    {
      "name": "Gen V",
      "title": "Gen V",
      "overview": "At America's only college for superheroes...",
      "media_type": "tv",
      "vote_average": 7.713,
      "popularity": 164.9106,
      ...
    }
  ],
  "total": 1,
  "query": "gen"
}
```

### Test 2: Search Not in Backend Database
```bash
curl -G "http://localhost:3000/api/search" --data-urlencode "q=spider"
```

**Result:** ✅ Empty result (expected - Spider-Man not in our 10+10 database)
```json
{
  "success": true,
  "results": [],
  "total": 0,
  "query": "spider"
}
```

**Flutter Behavior:**
- Backend returns empty → Automatically falls back to TMDB
- TMDB has Spider-Man → Shows Spider-Man results
- User gets results seamlessly!

### Test 3: Search with Special Characters
```bash
curl -G "http://localhost:3000/api/search" --data-urlencode "q=gen & v"
```

**Result:** ✅ URL encoding works correctly

---

## 📊 Search Algorithm

### Backend Search Logic

**1. Case-Insensitive Regex:**
```javascript
{ title: { $regex: searchQuery, $options: 'i' } }
```
- Searches for partial matches
- Case-insensitive (Gen = gen = GEN)
- Examples: "gen" matches "Gen V", "Legend", "Oxygen"

**2. Parallel Execution:**
```javascript
const [movies, tvSeries] = await Promise.all([
  Movie.find({ title: ... }),
  TvSeries.find({ name: ... })
]);
```
- Both queries run simultaneously
- Faster than sequential searches
- Optimized performance

**3. Combined & Sorted:**
```javascript
const combinedResults = [...movieResults, ...tvResults]
  .sort((a, b) => (b.popularity || 0) - (a.popularity || 0))
  .slice(0, searchLimit);
```
- Merges movies and TV series
- Sorts by popularity (most popular first)
- Limits to requested amount (default 20)

---

## ✨ Benefits

1. **Reduced API Calls:** Backend database search reduces TMDB API usage
2. **Faster Results:** Local MongoDB search is faster than external API
3. **Offline Capability:** Can search even if TMDB is down
4. **Consistent Pattern:** Same Backend-first approach across all features
5. **Smart Fallback:** Automatically expands search to TMDB when needed
6. **Best of Both Worlds:** 
   - Shows Backend results when available (faster)
   - Falls back to TMDB for comprehensive search (complete)

---

## 🔍 Search Behavior Examples

### Scenario 1: Item in Database
**User searches:** "gen"
- ✅ Backend finds "Gen V" TV series
- ✅ Shows result immediately
- ❌ TMDB not called (saved API quota!)

### Scenario 2: Item NOT in Database
**User searches:** "spider-man"
- ❌ Backend returns empty
- ✅ Automatically falls back to TMDB
- ✅ Shows comprehensive Spider-Man results from TMDB

### Scenario 3: Partial Match
**User searches:** "the"
- ✅ Backend finds "The Long Walk", "The Elixir", etc.
- ✅ Shows Backend results
- ❌ TMDB not needed

### Scenario 4: Backend Down
**User searches:** anything
- ❌ Backend fails to respond
- ✅ Catches error gracefully
- ✅ Falls back to TMDB automatically
- ✅ User still gets results!

---

## 📝 Technical Details

### URL Encoding
**Flutter side:**
```dart
var searchUrl = '${ApiConfig.baseUrl}/api/search?q=${Uri.encodeComponent(val)}';
```
- Properly encodes special characters
- Handles spaces, &, ?, etc.
- Example: "Gen & V" → "Gen%20%26%20V"

### MongoDB Regex Performance
**Indexed fields:**
- Movies: `title` field
- TV Series: `name` field

**Optimization tips:**
- Add text index for faster full-text search
- Current regex search works for small datasets (10-100 items)
- For larger datasets (1000+), consider MongoDB text search

### Response Consistency
**Backend formats TV series for Flutter compatibility:**
```javascript
{
  name: tv.name,      // Original TV field
  title: tv.name,     // Added for Flutter compatibility
  first_air_date: tv.first_air_date,  // Original
  release_date: tv.first_air_date,    // Added for consistency
  media_type: 'tv'
}
```

---

## 📁 Files Modified/Created

### Backend (3 files)

**Created:**
1. `backend/src/controllers/searchController.js` - Search logic
2. `backend/src/routes/search.js` - Search routes

**Modified:**
3. `backend/index.js` - Registered search routes

### Flutter (1 file)

**Modified:**
1. `lib/reapeatedfunction/searchbarfunction.dart` - Backend-first search logic

---

## 🚀 API Endpoints Summary

| Endpoint | Method | Description | Example |
|----------|--------|-------------|---------|
| `/api/search` | GET | Search movies + TV | `/api/search?q=avatar` |
| `/api/search/movies` | GET | Search movies only | `/api/search/movies?q=avatar` |
| `/api/search/tv` | GET | Search TV only | `/api/search/tv?q=breaking` |

**Query Parameters:**
- `q` (required): Search query string
- `limit` (optional): Max results (default: 20)

---

## 🔮 Future Enhancements (Optional)

### 1. Full-Text Search
```javascript
// Add text index to schema
movieSchema.index({ title: 'text', overview: 'text' });

// Search with MongoDB text search
db.movies.find({ $text: { $search: query } });
```
**Benefits:** Faster, more accurate, supports phrase search

### 2. Search Suggestions/Autocomplete
- Backend endpoint: `/api/search/suggestions?q=spi`
- Returns top 5 matches as you type
- Improves UX

### 3. Search Filters
```
/api/search?q=avatar&year=2009&media_type=movie
```
- Filter by year, genre, rating
- More precise results

### 4. Search Analytics
- Track popular searches
- Improve search algorithm based on user behavior
- Cache frequently searched terms

### 5. Fuzzy Search
- Handle typos: "spiderman" → "spider-man"
- Levenshtein distance algorithm
- Better user experience

---

**Implementation Date:** October 25, 2025
**Status:** ✅ Complete and Tested
**Pattern:** Backend-first with TMDB fallback
**Endpoints:** 3 new search endpoints
**Algorithm:** Case-insensitive regex + popularity sorting
