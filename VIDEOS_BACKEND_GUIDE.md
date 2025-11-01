# 🎬 Hướng dẫn thêm Backend cho Videos/Trailers

## 📋 Tổng quan
Videos/Trailers data **đã có sẵn** trong MongoDB database rồi! Chỉ cần:
1. Tạo API endpoints để lấy videos
2. Update Flutter code để dùng Backend thay vì TMDB API

---

## 🗄️ Database Schema hiện tại

### Movies - videos field:
```javascript
videos: [{
  id: {type: String},        // TMDB video ID
  key: {type: String},       // YouTube video key (dùng để play)
  name: {type: String},      // Tên video (VD: "Official Trailer")
  site: {type: String},      // "YouTube"
  type: {type: String},      // "Trailer", "Teaser", "Clip", etc.
  official: {type: Boolean}  // Video chính thức hay không
}]
```

### TV Series - videos field:
```javascript
videos: [{
  id: {type: String},
  key: {type: String},
  name: {type: String},
  site: {type: String},
  type: {type: String},
  official: {type: Boolean}
}]
```

---

## 🔧 Bước 1: Tạo Backend API Endpoints

### A. Update Movie Controller
**File**: `backend/src/controllers/movieController.js`

Thêm function mới vào cuối file (trước `module.exports`):

```javascript
// Get videos for a movie
const getMovieVideos = async (req, res) => {
  try {
    const { tmdbId } = req.params;
    const movie = await Movie.findOne({ tmdbId: parseInt(tmdbId) });

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Movie not found'
      });
    }

    // Return only videos
    res.json({
      success: true,
      data: {
        id: movie.tmdbId,
        results: movie.videos || [] // TMDB format compatibility
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching movie videos',
      error: error.message
    });
  }
};
```

**Export** thêm function này:
```javascript
module.exports = {
  getAllMovies,
  getMovieById,
  getMovieByTmdbId,
  searchMovies,
  getTrendingMovies,
  getTopRatedMovies,
  getMovieVideos // ← Thêm dòng này
};
```

---

### B. Update TV Series Controller
**File**: `backend/src/controllers/tvSeriesController.js`

Thêm function mới:

```javascript
// Get videos for a TV series
const getTvSeriesVideos = async (req, res) => {
  try {
    const { tmdbId } = req.params;
    const series = await TvSeries.findOne({ tmdbId: parseInt(tmdbId) });

    if (!series) {
      return res.status(404).json({
        success: false,
        message: 'TV Series not found'
      });
    }

    // Return only videos
    res.json({
      success: true,
      data: {
        id: series.tmdbId,
        results: series.videos || [] // TMDB format compatibility
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching TV series videos',
      error: error.message
    });
  }
};
```

**Export**:
```javascript
module.exports = {
  getAllTvSeries,
  getTopRatedTvSeries,
  getOnTheAirTvSeries,
  getTvSeriesByTmdbId,
  getTvSeriesById,
  getTvSeriesVideos // ← Thêm dòng này
};
```

---

### C. Update Routes - Movies
**File**: `backend/src/routes/movies.js`

Thêm route mới:

```javascript
const express = require('express');
const router = express.Router();
const {
  getAllMovies,
  getMovieById,
  getMovieByTmdbId,
  searchMovies,
  getTrendingMovies,
  getTopRatedMovies,
  getMovieVideos // ← Import
} = require('../controllers/movieController');

// ... existing routes ...

// Get movie videos by TMDB ID
router.get('/tmdb/:tmdbId/videos', getMovieVideos); // ← Thêm route này

module.exports = router;
```

**Route URL sẽ là**: `GET /api/movies/tmdb/:tmdbId/videos`

---

### D. Update Routes - TV Series
**File**: `backend/src/routes/tvSeries.js`

Thêm route mới:

```javascript
const express = require('express');
const router = express.Router();
const {
  getAllTvSeries,
  getTopRatedTvSeries,
  getOnTheAirTvSeries,
  getTvSeriesByTmdbId,
  getTvSeriesById,
  getTvSeriesVideos // ← Import
} = require('../controllers/tvSeriesController');

// ... existing routes ...

// Get TV series videos by TMDB ID
router.get('/tmdb/:tmdbId/videos', getTvSeriesVideos); // ← Thêm route này

module.exports = router;
```

**Route URL sẽ là**: `GET /api/tv-series/tmdb/:tmdbId/videos`

---

## 🧪 Bước 2: Test Backend API

### Start backend server:
```bash
cd backend
npm start
```

### Test với curl hoặc browser:

**Movies**:
```bash
# Example: Get videos for The Shawshank Redemption (TMDB ID: 278)
curl http://localhost:3000/api/movies/tmdb/278/videos
```

**TV Series**:
```bash
# Example: Get videos for Breaking Bad (TMDB ID: 1396)
curl http://localhost:3000/api/tv-series/tmdb/1396/videos
```

### Expected Response Format:
```json
{
  "success": true,
  "data": {
    "id": 278,
    "results": [
      {
        "id": "5c9294240e0a267cd516835f",
        "key": "6hB3S9bIaco",
        "name": "The Shawshank Redemption - Trailer",
        "site": "YouTube",
        "type": "Trailer",
        "official": true
      }
    ]
  }
}
```

---

## 📱 Bước 3: Update Flutter Code

### A. Update Movie Details
**File**: `lib/details/moviesdetail.dart`

Tìm function lấy videos (search: `movie/{widget.movieid}/videos`):

**TRƯỚC** (TMDB):
```dart
String videourl = 'https://api.themoviedb.org/3/movie/${widget.movieid}/videos?api_key=${ApiKey.apikey}';
```

**SAU** (Backend với fallback):
```dart
// Try Backend first
String videourl = '${ApiConfig.baseUrl}/api/movies/tmdb/${widget.movieid}/videos';

var videoResponse = await http.get(Uri.parse(videourl));
var videosdata;

if (videoResponse.statusCode == 200) {
  var tempdata = jsonDecode(videoResponse.statusCode.toString());
  
  // Check if Backend returned data
  if (tempdata['success'] == true && tempdata['data']['results'] != null) {
    videosdata = tempdata['data']['results'];
  } else {
    // Fallback to TMDB
    String tmdbVideoUrl = 'https://api.themoviedb.org/3/movie/${widget.movieid}/videos?api_key=${ApiKey.apikey}';
    var tmdbResponse = await http.get(Uri.parse(tmdbVideoUrl));
    if (tmdbResponse.statusCode == 200) {
      var tmdbData = jsonDecode(tmdbResponse.body);
      videosdata = tmdbData['results'];
    }
  }
} else {
  // Fallback to TMDB if Backend fails
  String tmdbVideoUrl = 'https://api.themoviedb.org/3/movie/${widget.movieid}/videos?api_key=${ApiKey.apikey}';
  var tmdbResponse = await http.get(Uri.parse(tmdbVideoUrl));
  if (tmdbResponse.statusCode == 200) {
    var tmdbData = jsonDecode(tmdbResponse.body);
    videosdata = tmdbData['results'];
  }
}
```

---

### B. Update TV Series Details
**File**: `lib/details/tvseriesdetail.dart`

Tương tự, tìm function lấy videos (search: `tv/${widget.tvseriesid}/videos`):

**TRƯỚC** (TMDB):
```dart
String videourl = 'https://api.themoviedb.org/3/tv/${widget.tvseriesid}/videos?api_key=${ApiKey.apikey}';
```

**SAU** (Backend với fallback):
```dart
// Try Backend first
String videourl = '${ApiConfig.baseUrl}/api/tv-series/tmdb/${widget.tvseriesid}/videos';

var videoResponse = await http.get(Uri.parse(videourl));
var videosdata;

if (videoResponse.statusCode == 200) {
  var tempdata = jsonDecode(videoResponse.body);
  
  // Check if Backend returned data
  if (tempdata['success'] == true && tempdata['data']['results'] != null) {
    videosdata = tempdata['data']['results'];
  } else {
    // Fallback to TMDB
    String tmdbVideoUrl = 'https://api.themoviedb.org/3/tv/${widget.tvseriesid}/videos?api_key=${ApiKey.apikey}';
    var tmdbResponse = await http.get(Uri.parse(tmdbVideoUrl));
    if (tmdbResponse.statusCode == 200) {
      var tmdbData = jsonDecode(tmdbResponse.body);
      videosdata = tmdbData['results'];
    }
  }
} else {
  // Fallback to TMDB if Backend fails
  String tmdbVideoUrl = 'https://api.themoviedb.org/3/tv/${widget.tvseriesid}/videos?api_key=${ApiKey.apikey}';
  var tmdbResponse = await http.get(Uri.parse(tmdbVideoUrl));
  if (tmdbResponse.statusCode == 200) {
    var tmdbData = jsonDecode(tmdbResponse.body);
    videosdata = tmdbData['results'];
  }
}
```

---

## 🎯 Response Format (Backend vs TMDB)

### Backend Response:
```json
{
  "success": true,
  "data": {
    "id": 278,
    "results": [
      {
        "id": "abc123",
        "key": "6hB3S9bIaco",
        "name": "Official Trailer",
        "site": "YouTube",
        "type": "Trailer",
        "official": true
      }
    ]
  }
}
```

### TMDB Response:
```json
{
  "id": 278,
  "results": [
    {
      "id": "abc123",
      "key": "6hB3S9bIaco",
      "name": "Official Trailer",
      "site": "YouTube",
      "type": "Trailer",
      "official": true
    }
  ]
}
```

**Khác biệt**: Backend wrap trong `success` và `data`, còn TMDB thì direct.

---

## ✅ Testing Checklist

### Backend:
- [ ] `npm start` không có lỗi
- [ ] Test endpoint: `GET /api/movies/tmdb/278/videos` → trả về videos
- [ ] Test endpoint: `GET /api/tv-series/tmdb/1396/videos` → trả về videos
- [ ] Response có format đúng với `success: true` và `data.results`

### Flutter:
- [ ] Import `ApiConfig` trong detail files
- [ ] Code try Backend first, fallback TMDB nếu fail
- [ ] Test với movie có videos trong DB
- [ ] Test với movie không có videos (fallback TMDB)
- [ ] Videos hiển thị đúng trong app

---

## 🚀 Lợi ích khi dùng Backend cho Videos

### ✅ Ưu điểm:
1. **Giảm API calls** đến TMDB → tiết kiệm quota
2. **Faster response** vì data đã có trong MongoDB
3. **Offline capability** nếu cache videos
4. **Custom filtering** (VD: chỉ lấy official trailers)
5. **Consistent data** với details page

### ⚠️ Lưu ý:
- Videos data phải được import đầy đủ từ TMDB
- Nếu movie mới chưa có trong DB → fallback TMDB
- Backend cần handle case `videos` array rỗng

---

## 📝 Tóm tắt các bước

1. **Backend**:
   - Thêm `getMovieVideos()` vào `movieController.js`
   - Thêm `getTvSeriesVideos()` vào `tvSeriesController.js`
   - Thêm route `/tmdb/:tmdbId/videos` cho cả movies và tv-series
   - Export functions và test endpoints

2. **Flutter**:
   - Update `moviesdetail.dart` để dùng Backend API
   - Update `tvseriesdetail.dart` để dùng Backend API
   - Thêm fallback logic về TMDB nếu Backend fail
   - Test trên emulator/device

3. **Testing**:
   - Start backend server
   - Test endpoints với curl/browser
   - Run Flutter app và xem videos có load không
   - Check fallback hoạt động khi Backend offline

---

## 💡 Tips

- **Data format**: Backend trả về format giống TMDB để dễ migrate
- **Error handling**: Luôn có fallback về TMDB
- **Performance**: Videos nhẹ nên response nhanh
- **Future**: Có thể thêm endpoint riêng lấy chỉ trailers: `/api/movies/tmdb/:id/trailers`

---

Chúc bạn thành công! 🎉
