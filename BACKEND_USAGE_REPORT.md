# 📊 Backend Usage Report - Flutter Movie App

## 🎯 Tóm tắt nhanh
- ✅ **Backend tự code (Node.js + MongoDB)**: Movies & TV Series data
- 🌐 **TMDB API**: Trending, Search, Reviews, Similar, Recommended, Videos
- 🔥 **Firebase**: Authentication, Favorites, Recently Viewed

---

## 📱 Chi tiết từng phần

### 🎬 **1. MOVIES SECTION**

#### ✅ Sử dụng Backend (Node.js + MongoDB):
- **Popular Movies** (`/api/movies`)
  - File: `lib/HomePage/SectionPage/movies.dart`
  - Service: `lib/services/unified_movie_service.dart`
  - Fallback: TMDB API nếu Backend fail

- **Now Playing** (`/api/movies`)
  - File: `lib/HomePage/SectionPage/movies.dart`
  - Service: `lib/services/unified_movie_service.dart`
  - Fallback: TMDB API nếu Backend fail

- **Top Rated** (`/api/movies/top-rated`)
  - File: `lib/HomePage/SectionPage/movies.dart`
  - Service: `lib/services/unified_movie_service.dart`
  - Fallback: TMDB API nếu Backend fail

- **Movie Details** (chi tiết phim)
  - File: `lib/details/moviesdetail.dart`
  - Service: `lib/services/movie_detail_service.dart`
  - Backend: `/api/movies/tmdb/:tmdbId`
  - Fallback: TMDB API nếu Backend fail

#### 🌐 Sử dụng TMDB API (chưa có Backend):
- **Reviews** (đánh giá): `https://api.themoviedb.org/3/movie/{id}/reviews`
- **Similar Movies** (phim tương tự): `https://api.themoviedb.org/3/movie/{id}/similar`
- **Recommended** (gợi ý): `https://api.themoviedb.org/3/movie/{id}/recommendations`
- **Videos/Trailers**: `https://api.themoviedb.org/3/movie/{id}/videos`

---

### 📺 **2. TV SERIES SECTION**

#### ✅ Sử dụng Backend (Node.js + MongoDB):
- **Popular TV Series** (`/api/tv-series`)
  - File: `lib/HomePage/SectionPage/tvseries.dart`
  - Service: Direct API call
  - Fallback: TMDB API nếu Backend fail

- **Top Rated TV Series** (`/api/tv-series/top-rated`)
  - File: `lib/HomePage/SectionPage/tvseries.dart`
  - Service: Direct API call
  - Fallback: TMDB API nếu Backend fail

- **On The Air** (`/api/tv-series/on-the-air`) ✨ MỚI
  - File: `lib/HomePage/SectionPage/tvseries.dart`
  - Service: Direct API call
  - Fallback: TMDB API nếu Backend fail

- **TV Series Details** (chi tiết series)
  - File: `lib/details/tvseriesdetail.dart`
  - Service: `lib/services/tv_series_detail_service.dart`
  - Backend: `/api/tv-series/tmdb/:tmdbId`
  - Fallback: TMDB API nếu Backend fail

#### 🌐 Sử dụng TMDB API (chưa có Backend):
- **Reviews**: `https://api.themoviedb.org/3/tv/{id}/reviews`
- **Similar TV Series**: `https://api.themoviedb.org/3/tv/{id}/similar`
- **Recommended**: `https://api.themoviedb.org/3/tv/{id}/recommendations`
- **Videos/Trailers**: `https://api.themoviedb.org/3/tv/{id}/videos`

---

### 🎥 **3. UPCOMING MOVIES**

#### 🌐 100% TMDB API:
- File: `lib/HomePage/SectionPage/upcoming.dart`
- Endpoint: `https://api.themoviedb.org/3/movie/upcoming`
- ❌ **Chưa có Backend**

---

### 🔥 **4. TRENDING SECTION (HomePage)**

#### 🌐 100% TMDB API:
- **Trending This Week**
  - File: `lib/HomePage/HomePage.dart`
  - Endpoint: `https://api.themoviedb.org/3/trending/all/week`
  
- **Trending Today**
  - File: `lib/HomePage/HomePage.dart`
  - Endpoint: `https://api.themoviedb.org/3/trending/all/day`
  
- ❌ **Chưa có Backend**

---

### 🔍 **5. SEARCH FUNCTION**

#### 🌐 100% TMDB API:
- File: `lib/reapeatedfunction/searchbarfunction.dart`
- Endpoint: `https://api.themoviedb.org/3/search/multi`
- ❌ **Chưa có Backend**

---

### 🔥 **6. FIREBASE SERVICES**

#### Authentication (Firebase Auth):
- **Email/Password Login**
  - File: `lib/services/auth_service.dart`
  - Service: `FirebaseAuth.instance`
  
- **Google Sign In**
  - File: `lib/services/auth_service.dart`
  - Service: `FirebaseAuth.instance`
  
- **Phone Number Authentication**
  - File: `lib/services/auth_service.dart`
  - Service: `FirebaseAuth.instance`
  
- **Facebook Login**
  - File: `lib/services/auth_service.dart`
  - Service: `FirebaseAuth.instance`

#### User Data (Firestore):
- **Favorites (Yêu thích)**
  - File: `lib/services/favorites_service.dart`
  - Database: Firestore collection `users/{uid}/favorites`
  
- **Recently Viewed (Đã xem gần đây)**
  - File: `lib/services/recently_viewed_service.dart`
  - Database: Firestore collection `users/{uid}/recently_viewed`

---

## 📊 Database Thống kê

### Backend Database (MongoDB):
- **Movies Collection**: 10 phim
  - Popular, Now Playing, Top Rated
  - Full details: cast, crew, videos, genres, etc.
  
- **TV Series Collection**: 10 series
  - Popular, Top Rated, On The Air
  - Full details: seasons, cast, crew, videos, etc.

### Firebase Firestore:
- **Users Collection**: User profiles
- **Favorites Subcollection**: Per-user favorites
- **Recently Viewed Subcollection**: Per-user history

---

## 🎯 Kế hoạch mở rộng Backend

### Đã hoàn thành ✅:
1. Movies API với fallback TMDB
2. TV Series API với fallback TMDB
3. Movie Details service
4. TV Series Details service
5. On The Air TV Series endpoint

### Cần làm tiếp 🚧:
1. **Upcoming Movies** - thêm backend
2. **Trending** - thêm backend cho trending data
3. **Search** - thêm backend search endpoint
4. **Reviews, Similar, Recommended** - migrate từ TMDB sang Backend
5. **Videos/Trailers** - migrate sang Backend (hiện đã có trong DB nhưng chưa dùng)

---

## 🔧 Backend Endpoints hiện có

### Movies:
- `GET /api/movies` - Get all movies (Popular/Now Playing)
- `GET /api/movies/top-rated` - Get top rated movies
- `GET /api/movies/tmdb/:tmdbId` - Get movie by TMDB ID
- `GET /api/movies/:id` - Get movie by MongoDB ID

### TV Series:
- `GET /api/tv-series` - Get all TV series (Popular)
- `GET /api/tv-series/top-rated` - Get top rated series
- `GET /api/tv-series/on-the-air` - Get currently airing series ✨ NEW
- `GET /api/tv-series/tmdb/:tmdbId` - Get series by TMDB ID
- `GET /api/tv-series/:id` - Get series by MongoDB ID

---

## 📝 Notes

- **Backend Server**: `http://10.0.2.2:3000` (Android Emulator)
- **Real Device**: Cần đổi thành IP máy tính (VD: `http://192.168.1.x:3000`)
- **Production**: Cần deploy Backend lên cloud (Heroku, Railway, DigitalOcean, etc.)
- **Firebase**: Miễn phí cho Spark plan, cần upgrade nếu scale lớn

---

**Tóm lại**: 
- ✅ **Movies & TV Series data** → Backend tự code
- 🌐 **Reviews, Similar, Recommended, Videos** → TMDB API
- 🌐 **Trending, Search, Upcoming** → TMDB API
- 🔥 **Authentication & User Data** → Firebase
