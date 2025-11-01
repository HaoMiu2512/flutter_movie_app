# Flutter Movie App - Backend Integration Guide

## 📋 Tổng quan

Hệ thống Flutter Movie App đã được tích hợp với backend tự xây dựng:

### Stack công nghệ:
- **Frontend**: Flutter (giữ nguyên UI)
- **Backend**: Node.js + Express
- **Database**: MongoDB (lưu phim & favorites)
- **Authentication**: Firebase Authentication (giữ nguyên)
- **API**: RESTful API

### Dữ liệu phim:
- ✅ Tự quản lý (không phụ thuộc TMDB)
- ✅ Có thể thêm/sửa/xóa phim dễ dàng
- ✅ Tùy chỉnh fields theo nhu cầu

## 🎯 Điểm khác biệt so với version cũ

| Tính năng | Version cũ (TMDB) | Version mới (Backend) |
|-----------|-------------------|----------------------|
| Nguồn dữ liệu phim | TMDB API | MongoDB (tự quản lý) |
| Favorites | Firestore | Backend API + MongoDB |
| Authentication | Firebase | Firebase (giữ nguyên) |
| Video URL | TMDB | Tự host hoặc link |
| Thêm phim mới | Không thể | Dễ dàng |
| Chi phí API | Giới hạn request | Không giới hạn |

## 📁 Cấu trúc Project

```
flutter_movie_app/
├── backend/                          # 🆕 Backend API
│   ├── src/
│   │   ├── config/
│   │   │   ├── database.js          # MongoDB config
│   │   │   └── firebase.js          # Firebase Admin SDK
│   │   ├── controllers/
│   │   │   ├── movieController.js   # Logic xử lý phim
│   │   │   └── favoriteController.js # Logic favorites
│   │   ├── middleware/
│   │   │   └── auth.js              # Verify Firebase token
│   │   ├── models/
│   │   │   ├── Movie.js             # Schema phim
│   │   │   └── UserFavorite.js      # Schema favorites
│   │   ├── routes/
│   │   │   ├── movies.js            # Routes cho phim
│   │   │   └── favorites.js         # Routes cho favorites
│   │   └── scripts/
│   │       └── seed.js              # Seed data mẫu
│   ├── index.js                      # Entry point
│   ├── package.json
│   ├── .env
│   ├── QUICK_START.md               # Setup nhanh
│   └── README.md                     # API documentation
│
├── lib/
│   ├── config/
│   │   └── api_config.dart          # 🆕 Config base URL
│   ├── models/
│   │   └── movie.dart               # ✏️ Updated model
│   ├── services/
│   │   ├── movie_api_service.dart   # 🆕 Service gọi API phim
│   │   ├── backend_favorites_service.dart # 🆕 Service favorites
│   │   └── favorites_service.dart   # (Firestore - giữ lại)
│   ├── HomePage/
│   ├── LoginPage/
│   └── ...
│
├── BACKEND_SETUP.md                  # 🆕 Hướng dẫn chi tiết
└── INTEGRATION_GUIDE.md              # 🆕 File này
```

## 🚀 Setup & Deployment

### Step 1: Setup Backend (5 phút)

Xem chi tiết: [backend/QUICK_START.md](backend/QUICK_START.md)

```bash
cd backend
npm install
npm run seed
npm run dev
```

### Step 2: Cấu hình Flutter App

File `lib/config/api_config.dart` đã được tạo:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  // Khi deploy: 'https://your-api.com'
}
```

### Step 3: Sử dụng Services mới

#### Lấy danh sách phim:

```dart
import 'package:flutter_movie_app/services/movie_api_service.dart';

final movieService = MovieApiService();

// Lấy tất cả phim
List<Movie> movies = await movieService.getMovies(
  page: 1,
  limit: 20,
  genre: 'Action',  // optional
  year: 2024,       // optional
  isPro: false,     // optional
);

// Tìm kiếm
List<Movie> results = await movieService.searchMovies('batman');

// Trending
List<Movie> trending = await movieService.getTrendingMovies();

// Top rated
List<Movie> topRated = await movieService.getTopRatedMovies();
```

#### Quản lý Favorites:

```dart
import 'package:flutter_movie_app/services/backend_favorites_service.dart';

final favService = BackendFavoritesService();

// Lấy danh sách yêu thích
List<Movie> favorites = await favService.getFavorites();

// Thêm vào favorites
bool success = await favService.addToFavorites(movie);

// Xóa khỏi favorites
await favService.removeFromFavorites(movieId);

// Kiểm tra đã thích chưa
bool isFav = await favService.isFavoriteMovie(movieId);

// Toggle (thêm/xóa)
await favService.toggleFavorite(movie);
```

## 🎬 Quản lý Phim

### Thêm phim mới

#### Option 1: MongoDB Compass (GUI)

1. Download [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Connect to `mongodb://localhost:27017`
3. Database: `flutter_movies` → Collection: `movies`
4. Insert Document:

```json
{
  "title": "Avengers: Endgame",
  "overview": "After the devastating events...",
  "poster": "https://image.tmdb.org/t/p/w500/poster.jpg",
  "video_url": "https://your-cdn.com/video.mp4",
  "rating": 8.4,
  "year": 2019,
  "genre": ["Action", "Adventure", "Sci-Fi"],
  "isPro": false,
  "views": 0,
  "favoritesCount": 0
}
```

#### Option 2: Script (Bulk import)

Tạo file `backend/src/scripts/add-movies.js`:

```javascript
require('dotenv').config();
const mongoose = require('mongoose');
const Movie = require('../models/Movie');

const newMovies = [
  {
    title: "Your Movie 1",
    overview: "Description...",
    poster: "https://...",
    video_url: "https://...",
    rating: 8.0,
    year: 2024,
    genre: ["Action"],
    isPro: false,
    views: 0,
    favoritesCount: 0
  },
  // Thêm nhiều phim...
];

async function addMovies() {
  await mongoose.connect(process.env.MONGODB_URI);
  await Movie.insertMany(newMovies);
  console.log(`Added ${newMovies.length} movies`);
  process.exit(0);
}

addMovies();
```

Chạy:
```bash
node src/scripts/add-movies.js
```

### Update/Delete phim

Sử dụng MongoDB Compass hoặc tạo admin panel (tùy chọn).

## 🌐 Deploy Production

### Backend Deployment

#### Railway.app (Recommended - Free)

1. Push code lên GitHub
2. Vào [Railway.app](https://railway.app)
3. New Project → Deploy from GitHub
4. Chọn repo `flutter_movie_app`
5. Root Directory: `/backend`
6. Add MongoDB service
7. Environment variables:
   ```
   MONGODB_URI=<railway-mongodb-url>
   PORT=3000
   FIREBASE_SERVICE_ACCOUNT_PATH=./src/config/firebase-service-account.json
   ```
8. Deploy

URL: `https://your-app.up.railway.app`

#### Render.com (Free)

1. New Web Service → Connect GitHub
2. Build Command: `npm install`
3. Start Command: `npm start`
4. Root Directory: `backend`
5. Add env vars
6. Create

### Flutter App Update

Sau khi deploy backend, update `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Development
  // static const String baseUrl = 'http://localhost:3000';

  // Production
  static const String baseUrl = 'https://your-app.up.railway.app';
}
```

Build Flutter app:
```bash
flutter clean
flutter pub get
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🔧 Tùy chỉnh & Mở rộng

### Thêm field mới cho Movie

1. Update MongoDB model (`backend/src/models/Movie.js`):
```javascript
const movieSchema = new mongoose.Schema({
  // Existing fields...
  director: String,        // 🆕
  cast: [String],          // 🆕
  duration: Number,        // 🆕
  // ...
});
```

2. Update Flutter model (`lib/models/movie.dart`):
```dart
class Movie {
  final String? director;
  final List<String>? cast;
  final int? duration;
  // ...
}
```

3. Restart backend và update Flutter app

### Thêm API endpoint mới

1. Create controller (`backend/src/controllers/movieController.js`):
```javascript
const getMoviesByDirector = async (req, res) => {
  const { director } = req.params;
  const movies = await Movie.find({
    director: new RegExp(director, 'i')
  });
  res.json({ success: true, data: movies });
};
```

2. Add route (`backend/src/routes/movies.js`):
```javascript
router.get('/director/:director', getMoviesByDirector);
```

3. Use in Flutter:
```dart
final movies = await http.get(
  Uri.parse('${ApiConfig.baseUrl}/api/movies/director/Christopher%20Nolan')
);
```

## 📊 Monitor & Analytics

### Server monitoring

```bash
# Check server status
curl http://localhost:3000/health

# Watch logs
npm run dev  # Development
pm2 logs flutter-movie-api  # Production
```

### Database stats

```javascript
// In MongoDB
db.movies.countDocuments()
db.userfavorites.countDocuments()

// Popular movies
db.movies.find().sort({ views: -1 }).limit(10)

// Most favorited
db.movies.find().sort({ favoritesCount: -1 }).limit(10)
```

## 🐛 Troubleshooting

### Backend không start được

```bash
# Check MongoDB
# Windows: net start MongoDB
# Mac: brew services start mongodb-community
# Linux: sudo systemctl start mongod

# Check port 3000
netstat -ano | findstr :3000  # Windows
lsof -ti:3000  # Mac/Linux
```

### Flutter không connect được backend

1. Check baseUrl trong `api_config.dart`
2. Android emulator: `http://10.0.2.2:3000` thay vì `localhost:3000`
3. iOS simulator: `http://localhost:3000` OK
4. Physical device: Dùng IP máy tính (cùng WiFi)

### Favorites không hoạt động

1. Check Firebase token có được gửi không
2. Backend log: xem middleware auth
3. Verify user đã đăng nhập

## 📚 Resources

- [Backend API Documentation](backend/README.md)
- [Quick Start Guide](backend/QUICK_START.md)
- [Backend Setup Details](BACKEND_SETUP.md)
- [Express.js](https://expressjs.com/)
- [MongoDB](https://www.mongodb.com/docs/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## ✅ Checklist hoàn thành

- [x] Backend API server
- [x] MongoDB models (Movie, UserFavorite)
- [x] Firebase Authentication integration
- [x] Movie CRUD endpoints
- [x] Favorites endpoints
- [x] Flutter services (MovieApiService, BackendFavoritesService)
- [x] Updated Movie model
- [x] Seed sample data
- [x] Documentation & guides

## 🎉 Kết luận

Bạn đã có một backend hoàn chỉnh để:
- ✅ Tự quản lý dữ liệu phim
- ✅ Thêm/sửa/xóa phim dễ dàng
- ✅ Không giới hạn API requests
- ✅ Tích hợp Firebase Auth
- ✅ Quản lý favorites
- ✅ Sẵn sàng deploy production

**Next steps:**
1. Thêm phim của bạn vào database
2. Customize UI Flutter (nếu cần)
3. Deploy backend lên Railway/Render
4. Build và publish Flutter app

Good luck! 🚀
