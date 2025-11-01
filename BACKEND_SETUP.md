# Hướng dẫn tích hợp Backend với Flutter Movie App

## Tổng quan

Backend đã được tạo với các tính năng:
- ✅ Node.js + Express server
- ✅ MongoDB để lưu trữ phim và favorites
- ✅ Firebase Authentication để xác thực
- ✅ RESTful API endpoints
- ✅ Seed data mẫu (10 phim)

## Cấu trúc thư mục Backend

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # MongoDB connection
│   │   └── firebase.js          # Firebase Admin SDK
│   ├── controllers/
│   │   ├── movieController.js   # Movie business logic
│   │   └── favoriteController.js # Favorites logic
│   ├── middleware/
│   │   └── auth.js              # Firebase token verification
│   ├── models/
│   │   ├── Movie.js             # Movie schema
│   │   └── UserFavorite.js      # User favorites schema
│   ├── routes/
│   │   ├── movies.js            # Movie routes
│   │   └── favorites.js         # Favorites routes
│   └── scripts/
│       └── seed.js              # Seed sample data
├── index.js                      # Server entry point
├── package.json
├── .env.example
└── README.md
```

## Các bước Setup Backend

### Bước 1: Cài đặt Node.js dependencies

```bash
cd backend
npm install
```

### Bước 2: Cấu hình Firebase Admin SDK

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project Flutter Movie App
3. **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Lưu file JSON vào: `backend/src/config/firebase-service-account.json`

### Bước 3: Cài đặt MongoDB

**Option 1: MongoDB Local (Windows)**
```bash
# Download từ https://www.mongodb.com/try/download/community
# Cài đặt và start MongoDB service
net start MongoDB
```

**Option 2: MongoDB Atlas (Cloud - Miễn phí)**
1. Tạo account tại https://www.mongodb.com/cloud/atlas
2. Tạo cluster miễn phí
3. Tạo database user
4. Get connection string

### Bước 4: Cấu hình .env

```bash
cd backend
cp .env.example .env
```

Sửa file `.env`:
```env
# Local MongoDB
MONGODB_URI=mongodb://localhost:27017/flutter_movies

# Hoặc MongoDB Atlas
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/flutter_movies

PORT=3000
FIREBASE_SERVICE_ACCOUNT_PATH=./src/config/firebase-service-account.json
```

### Bước 5: Seed dữ liệu mẫu

```bash
npm run seed
```

Output:
```
Connected to MongoDB
Cleared existing movies
Inserted 10 sample movies
✅ Database seeded successfully!
```

### Bước 6: Chạy server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

### Bước 7: Test API

Mở browser hoặc Postman:
- Health check: http://localhost:3000/health
- Get movies: http://localhost:3000/api/movies
- API docs: http://localhost:3000/

## Tích hợp với Flutter App

### Các file Flutter đã được tạo:

1. **`lib/config/api_config.dart`** - Cấu hình base URL
2. **`lib/services/movie_api_service.dart`** - Service gọi API phim
3. **`lib/services/backend_favorites_service.dart`** - Service quản lý favorites
4. **`lib/models/movie.dart`** - Model đã được cập nhật

### Sử dụng trong Flutter

#### 1. Thay đổi baseUrl khi deploy

Trong `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Development
  static const String baseUrl = 'http://localhost:3000';

  // Khi deploy, thay bằng URL thực
  // static const String baseUrl = 'https://your-api.herokuapp.com';
}
```

#### 2. Sử dụng MovieApiService

```dart
import 'package:flutter_movie_app/services/movie_api_service.dart';

final movieService = MovieApiService();

// Get all movies
final movies = await movieService.getMovies(page: 1, limit: 20);

// Search
final results = await movieService.searchMovies('batman');

// Get trending
final trending = await movieService.getTrendingMovies(limit: 10);

// Get top rated
final topRated = await movieService.getTopRatedMovies(limit: 10);

// Get movie detail
final movie = await movieService.getMovieById('movie_id');
```

#### 3. Sử dụng BackendFavoritesService

```dart
import 'package:flutter_movie_app/services/backend_favorites_service.dart';

final favService = BackendFavoritesService();

// Get favorites
final favorites = await favService.getFavorites();

// Add to favorites
await favService.addToFavorites(movie);

// Remove from favorites
await favService.removeFromFavorites(movieId);

// Check if favorite
final isFav = await favService.isFavoriteMovie(movieId);

// Toggle favorite
await favService.toggleFavorite(movie);
```

## Thêm phim mới vào Database

### Sử dụng MongoDB Compass (GUI)

1. Download [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Connect: `mongodb://localhost:27017`
3. Chọn database: `flutter_movies`
4. Chọn collection: `movies`
5. Click **Add Data** → **Insert Document**

```json
{
  "title": "Tên phim",
  "overview": "Mô tả phim",
  "poster": "https://image.tmdb.org/t/p/w500/poster.jpg",
  "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  "rating": 8.5,
  "year": 2024,
  "genre": ["Action", "Thriller"],
  "isPro": false,
  "views": 0,
  "favoritesCount": 0
}
```

### Sử dụng mongosh (CLI)

```bash
mongosh

use flutter_movies

db.movies.insertOne({
  "title": "Your Movie",
  "overview": "Description",
  "poster": "https://...",
  "video_url": "https://...",
  "rating": 8.0,
  "year": 2024,
  "genre": ["Drama"],
  "isPro": false,
  "views": 0,
  "favoritesCount": 0
})
```

## Deployment Backend

### Option 1: Railway.app (Miễn phí)

1. Push code lên GitHub
2. Truy cập [Railway.app](https://railway.app/)
3. **New Project** → **Deploy from GitHub**
4. Chọn repository
5. Add **MongoDB** service
6. Add environment variables
7. Deploy

### Option 2: Render.com (Miễn phí)

1. Push code lên GitHub
2. Truy cập [Render.com](https://render.com/)
3. **New Web Service** → Connect GitHub
4. Chọn repository, thư mục `backend`
5. Build Command: `npm install`
6. Start Command: `npm start`
7. Add environment variables
8. Create Web Service

### Option 3: Heroku

```bash
# Install Heroku CLI
heroku login
cd backend
heroku create flutter-movie-api

# Add MongoDB addon
heroku addons:create mongolab:sandbox

# Set env vars
heroku config:set FIREBASE_SERVICE_ACCOUNT_PATH=./src/config/firebase-service-account.json

# Deploy
git push heroku main
```

## Cập nhật Flutter App sau khi deploy

Sau khi deploy backend, cập nhật `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Thay bằng URL production của bạn
  static const String baseUrl = 'https://your-app.railway.app';
  // hoặc
  // static const String baseUrl = 'https://your-app.onrender.com';
}
```

Build lại Flutter app:
```bash
flutter clean
flutter pub get
flutter run
```

## API Authentication Flow

1. User đăng nhập bằng Firebase trong Flutter app
2. Flutter app lấy Firebase ID token: `await user.getIdToken()`
3. Gửi request với header: `Authorization: Bearer <token>`
4. Backend verify token bằng Firebase Admin SDK
5. Nếu valid, trả về data

## Troubleshooting

### Lỗi: Cannot connect to MongoDB
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Fix**: Khởi động MongoDB service
```bash
# Windows
net start MongoDB

# Linux/Mac
sudo systemctl start mongod
```

### Lỗi: Firebase Admin SDK error
```
Error initializing Firebase Admin SDK
```
**Fix**: Kiểm tra file `firebase-service-account.json` có tồn tại và đúng path

### Lỗi: Port 3000 already in use
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

## Tài liệu tham khảo

- [Backend README](backend/README.md) - Chi tiết về API endpoints
- [Express.js Docs](https://expressjs.com/)
- [MongoDB Docs](https://www.mongodb.com/docs/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## Liên hệ & Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. MongoDB đã chạy chưa
2. File `.env` đã cấu hình đúng
3. Firebase service account key đã đúng
4. Port 3000 có đang được sử dụng không
