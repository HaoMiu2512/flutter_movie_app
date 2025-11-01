# Flutter Movie App Backend

Backend API cho Flutter Movie App sử dụng Node.js, Express, MongoDB và Firebase Authentication.

## Tính năng

- **Authentication**: Firebase Authentication để xác thực người dùng
- **Movies API**: Quản lý danh sách phim với pagination, filter, search
- **Favorites API**: Người dùng có thể thêm/xóa phim yêu thích
- **MongoDB**: Lưu trữ dữ liệu phim và favorites
- **RESTful API**: Thiết kế API chuẩn REST

## Yêu cầu

- Node.js v16 trở lên
- MongoDB (local hoặc MongoDB Atlas)
- Firebase project với Admin SDK
- npm hoặc yarn

## Cài đặt

### 1. Cài đặt dependencies

```bash
cd backend
npm install
```

### 2. Cấu hình Firebase Admin SDK

- Truy cập [Firebase Console](https://console.firebase.google.com/)
- Chọn project của bạn
- Vào **Project Settings** > **Service Accounts**
- Click **Generate New Private Key**
- Lưu file JSON vào `backend/src/config/firebase-service-account.json`

### 3. Cấu hình MongoDB

Tạo file `.env` trong thư mục `backend`:

```bash
cp .env.example .env
```

Chỉnh sửa file `.env`:

```env
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/flutter_movies
# Hoặc sử dụng MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/flutter_movies

# Server Port
PORT=3000

# Firebase Admin SDK path
FIREBASE_SERVICE_ACCOUNT_PATH=./src/config/firebase-service-account.json
```

### 4. Khởi tạo dữ liệu mẫu

```bash
npm run seed
```

Lệnh này sẽ tạo 10 phim mẫu trong database.

## Chạy server

### Development mode (với nodemon)

```bash
npm run dev
```

### Production mode

```bash
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

## API Endpoints

### Public Endpoints (không cần authentication)

#### 1. Get all movies
```
GET /api/movies?page=1&limit=20&genre=Action&year=2020&isPro=false&sort=-rating
```

**Query Parameters:**
- `page`: Trang hiện tại (default: 1)
- `limit`: Số phim mỗi trang (default: 20)
- `genre`: Filter theo thể loại
- `year`: Filter theo năm
- `isPro`: Filter phim Pro (true/false)
- `sort`: Sắp xếp (-createdAt, -rating, -views, etc.)

#### 2. Get movie by ID
```
GET /api/movies/:id
```

#### 3. Search movies
```
GET /api/movies/search?q=batman&page=1&limit=20
```

#### 4. Get trending movies
```
GET /api/movies/trending?limit=10
```

#### 5. Get top rated movies
```
GET /api/movies/top-rated?limit=10
```

### Protected Endpoints (cần Firebase token)

**Headers required:**
```
Authorization: Bearer <Firebase-ID-Token>
```

#### 6. Get user's favorites
```
GET /api/users/favorites?page=1&limit=20
```

#### 7. Add to favorites
```
POST /api/users/favorites
Content-Type: application/json

{
  "movieId": "507f1f77bcf86cd799439011"
}
```

#### 8. Remove from favorites
```
DELETE /api/users/favorites/:movieId
```

#### 9. Check if movie is favorited
```
GET /api/users/favorites/check/:movieId
```

## Database Schema

### Movie Model
```javascript
{
  title: String,
  overview: String,
  poster: String,
  video_url: String,
  rating: Number (0-10),
  year: Number,
  genre: [String],
  isPro: Boolean,
  views: Number,
  favoritesCount: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### UserFavorite Model
```javascript
{
  userId: String (Firebase UID),
  movieId: ObjectId (ref: Movie),
  createdAt: Date,
  updatedAt: Date
}
```

## Thêm phim mới

Bạn có thể thêm phim mới trực tiếp vào MongoDB hoặc tạo script seed tùy chỉnh.

### Sử dụng MongoDB Compass hoặc mongosh:

```javascript
db.movies.insertOne({
  title: "Your Movie Title",
  overview: "Movie description here...",
  poster: "https://image.tmdb.org/t/p/w500/poster.jpg",
  video_url: "https://example.com/video.mp4",
  rating: 8.5,
  year: 2024,
  genre: ["Action", "Thriller"],
  isPro: false,
  views: 0,
  favoritesCount: 0
})
```

## Cấu hình Flutter App

Trong Flutter app, cập nhật `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Development
  static const String baseUrl = 'http://localhost:3000';

  // Production - thay bằng URL server của bạn
  // static const String baseUrl = 'https://your-api.com';
}
```

## Deployment

### 1. Railway, Render, hoặc Heroku

- Tạo repository Git
- Push code lên GitHub
- Connect repository với platform
- Thêm environment variables (.env)
- Deploy

### 2. VPS (DigitalOcean, AWS EC2, etc.)

```bash
# Install Node.js, MongoDB
# Clone repository
git clone <your-repo>
cd backend
npm install
npm start

# Sử dụng PM2 để chạy production
npm install -g pm2
pm2 start index.js --name flutter-movie-api
pm2 save
pm2 startup
```

## Testing

Test API bằng cURL hoặc Postman:

```bash
# Health check
curl http://localhost:3000/health

# Get movies
curl http://localhost:3000/api/movies

# Get favorites (với Firebase token)
curl -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
     http://localhost:3000/api/users/favorites
```

## Troubleshooting

### MongoDB connection error
- Kiểm tra MongoDB đang chạy: `mongod` hoặc MongoDB service
- Kiểm tra connection string trong `.env`

### Firebase authentication error
- Đảm bảo `firebase-service-account.json` có trong `src/config/`
- Kiểm tra file có permissions đúng
- Verify Firebase token từ client

### Port already in use
```bash
# Thay đổi PORT trong .env hoặc kill process:
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

## License

MIT License
