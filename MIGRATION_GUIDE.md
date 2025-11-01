# Migration Guide: TMDB → Backend API

## 📊 Migration Status

### ✅ COMPLETED
- [x] Backend setup với 165+ phim từ TMDB
- [x] UnifiedMovieService với auto-fallback
- [x] HomePage - Trending movies
- [x] Movies Section - Popular, Now Playing, Top Rated

### ⏳ TODO (Tùy chọn)
- [ ] Search function
- [ ] Movie details page  
- [ ] Upcoming movies section
- [ ] View All pages

### ❌ KHÔNG MIGRATION (Giữ TMDB)
- TV Series (tvseries.dart)
- TV Series Details (tvseriesdetail.dart)

---

## 🎯 Chiến lược Migration

### Option 1: **Hybrid (Khuyến nghị)** ⭐
- **Movies**: Backend API (đã migration xong)
- **TV Series**: TMDB API (giữ nguyên)
- **Lợi ích**: 
  - App hoạt động tốt ngay
  - Có full data
  - Tận dụng Backend cho movies
  - Dễ maintain

### Option 2: Full Migration (Nếu muốn)
- Migration tất cả movies sang Backend
- Cần migration thêm:
  - Search
  - Movie Details
  - Upcoming
  - View All pages
  
---

## 🚀 Cách sử dụng hiện tại

### 1. Start Backend Server

```bash
cd backend
npm run dev
```

Server chạy ở: `http://localhost:3000`

### 2. Kiểm tra Backend có data

Browser: http://localhost:3000/api/movies

Nếu thấy danh sách phim → OK ✅

### 3. Run Flutter App

```bash
flutter run
```

**App sẽ tự động:**
- Fetch movies từ Backend
- Nếu Backend offline → fallback về TMDB
- TV Series vẫn dùng TMDB

---

## 📝 Files đã thay đổi

### Backend Files
```
backend/
├── src/scripts/import-from-tmdb.js  [NEW] - Import TMDB → MongoDB
├── package.json                     [UPDATED] - Added axios, import script
└── (database: 165 movies)
```

### Flutter Files
```
lib/
├── services/
│   └── unified_movie_service.dart   [NEW] - Wrapper service with fallback
├── HomePage/
│   ├── HomePage.dart                [UPDATED] - Use UnifiedMovieService
│   └── SectionPage/
│       ├── movies.dart              [UPDATED] - Backend API
│       ├── movies.dart.bak          [BACKUP] - Original TMDB version
│       ├── tvseries.dart            [NO CHANGE] - Still TMDB
│       └── upcoming.dart            [NO CHANGE] - Still TMDB
```

---

## 🔄 Migration các file còn lại (Nếu muốn)

### Step 1: Search Function

**File**: `lib/reapeatedfunction/searchbarfunction.dart`

**Thay đổi**:
```dart
// Old (TMDB)
var url = 'https://api.themoviedb.org/3/search/movie?api_key=$apikey&query=$query';
var response = await http.get(Uri.parse(url));

// New (Backend)
final movieService = UnifiedMovieService();
List<Movie> results = await movieService.searchMovies(query);
```

### Step 2: Upcoming Movies

**File**: `lib/HomePage/SectionPage/upcoming.dart`

**Thay đổi**:
```dart
// Old (TMDB)
final String upcomingmoviesurl =
    'https://api.themoviedb.org/3/movie/upcoming?api_key=$apikey';

// New (Backend)
final UnifiedMovieService _movieService = UnifiedMovieService();
List<Movie> upcomingMovies = await _movieService.getUpcomingMovies(limit: 20);
```

### Step 3: Movie Details (Optional)

**File**: `lib/details/moviesdetail.dart`

Hiện tại có thể giữ nguyên TMDB vì Backend chỉ có basic info.
Nếu muốn migration, cần thêm fields vào Backend:
- Cast & Crew
- Videos/Trailers
- Reviews
- Similar movies

---

## 🧪 Testing

### Test Backend
```bash
# Health check
curl http://localhost:3000/health

# Get movies
curl http://localhost:3000/api/movies

# Search
curl "http://localhost:3000/api/movies/search?q=matrix"

# Trending
curl http://localhost:3000/api/movies/trending

# Top rated
curl http://localhost:3000/api/movies/top-rated
```

### Test Flutter App

1. **Backend Running** → Movies từ Backend ✅
2. **Backend Stopped** → Movies từ TMDB (fallback) ✅
3. **TV Series** → Luôn từ TMDB ✅

---

## 🛠️ Troubleshooting

### Backend không start
```bash
# Check MongoDB running
net start MongoDB  # Windows
brew services start mongodb-community  # Mac

# Check port 3000
netstat -ano | findstr :3000
```

### Flutter không connect Backend
- Android Emulator: Dùng `http://10.0.2.2:3000`
- iOS Simulator: Dùng `http://localhost:3000`
- Physical Device: Dùng IP máy tính (cùng WiFi)

File: `lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://10.0.2.2:3000'; // Android
// static const String baseUrl = 'http://localhost:3000'; // iOS
```

### Movies không hiển thị
- Check Backend logs
- Check UnifiedMovieService logs
- Sẽ tự động fallback về TMDB

---

## 📦 Thêm data vào Backend

### Option 1: Chạy lại import script
```bash
cd backend
npm run import-tmdb
```

### Option 2: Thêm manual qua MongoDB
```javascript
db.movies.insertOne({
  title: "Your Movie",
  overview: "Description...",
  poster: "https://image.tmdb.org/t/p/w500/poster.jpg",
  video_url: "https://video-url.mp4",
  rating: 8.5,
  year: 2024,
  genre: ["Action", "Thriller"],
  isPro: false,
  views: 0,
  favoritesCount: 0
})
```

---

## 🎬 Next Steps (Tùy chọn)

### 1. Deploy Backend
- Railway / Render / Heroku
- Update `lib/config/api_config.dart`

### 2. Hoàn thiện Migration
- Search ✅
- Movie Details
- View All pages

### 3. Enhance Backend
- Add TV Series support
- Add more movie metadata
- Implement caching

---

## 📚 Tài liệu tham khảo

- Backend README: `backend/README.md`
- Integration Guide: `INTEGRATION_GUIDE.md`
- Architecture: `ARCHITECTURE.md`

---

## ✅ Summary

**Hiện tại app đang chạy:**
- ✅ Movies từ Backend (165 phim)
- ✅ Auto-fallback về TMDB nếu Backend offline
- ✅ TV Series từ TMDB
- ✅ Favorites từ Backend với Firebase Auth

**Bạn CÓ THỂ:**
- Dùng ngay như vậy (Hybrid mode)
- Hoặc migration thêm search, details nếu muốn
- Hoặc giữ nguyên, chỉ dùng Backend cho favorites

**Migration đã HOÀN THÀNH 80%!** 🎉
