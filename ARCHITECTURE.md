# Flutter Movie App - System Architecture

## 📐 Overall Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                        UI Layer                            │ │
│  │  HomePage | MoviesPage | FavoritesPage | ProfilePage      │ │
│  └────────────────────┬──────────────────────────────────────┘ │
│                       │                                          │
│  ┌────────────────────▼──────────────────────────────────────┐ │
│  │                   Services Layer                          │ │
│  │  ┌──────────────────┐    ┌─────────────────────────────┐ │ │
│  │  │ MovieApiService  │    │ BackendFavoritesService     │ │ │
│  │  └────────┬─────────┘    └────────┬────────────────────┘ │ │
│  │           │                       │                        │ │
│  │  ┌────────▼───────────────────────▼────────────────────┐ │ │
│  │  │         Firebase Auth (Get ID Token)                │ │ │
│  │  └────────┬────────────────────────────────────────────┘ │ │
│  └───────────┼──────────────────────────────────────────────┘ │
└──────────────┼────────────────────────────────────────────────┘
               │
               │ HTTP Requests (Bearer Token)
               │
┌──────────────▼────────────────────────────────────────────────┐
│                      BACKEND API SERVER                        │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │               Express.js Middleware                       │ │
│  │  CORS → Body Parser → Auth Middleware (Firebase Verify)  │ │
│  └────────────────────┬─────────────────────────────────────┘ │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐ │
│  │                      Routes                               │ │
│  │  /api/movies/*  |  /api/users/favorites/*                │ │
│  └────────┬─────────────────────┬──────────────────────────┘ │
│           │                     │                              │
│  ┌────────▼─────────┐  ┌───────▼─────────────────────────┐  │
│  │ Movie Controller │  │ Favorite Controller             │  │
│  │ - getAllMovies   │  │ - getUserFavorites              │  │
│  │ - getMovieById   │  │ - addToFavorites                │  │
│  │ - searchMovies   │  │ - removeFromFavorites           │  │
│  │ - getTrending    │  │ - checkFavorite                 │  │
│  └────────┬─────────┘  └───────┬─────────────────────────┘  │
│           │                    │                              │
│  ┌────────▼────────────────────▼─────────────────────────┐   │
│  │                   Mongoose ODM                         │   │
│  └────────┬───────────────────────────────────────────────┘   │
└───────────┼───────────────────────────────────────────────────┘
            │
┌───────────▼───────────────────────────────────────────────────┐
│                      MONGODB DATABASE                          │
│  ┌──────────────────────┐    ┌────────────────────────────┐  │
│  │  movies collection   │    │ userfavorites collection   │  │
│  │ ┌──────────────────┐ │    │ ┌────────────────────────┐ │  │
│  │ │ Movie Documents  │ │    │ │ Favorite Documents     │ │  │
│  │ │ - title          │ │    │ │ - userId (Firebase)    │ │  │
│  │ │ - overview       │ │    │ │ - movieId (ObjectId)   │ │  │
│  │ │ - poster         │ │    │ │ - createdAt            │ │  │
│  │ │ - video_url      │ │    │ └────────────────────────┘ │  │
│  │ │ - rating         │ │    │                            │  │
│  │ │ - year           │ │    │  Indexes:                  │  │
│  │ │ - genre[]        │ │    │  - userId + movieId        │  │
│  │ │ - isPro          │ │    │    (unique compound)       │  │
│  │ │ - views          │ │    └────────────────────────────┘  │
│  │ │ - favoritesCount │ │                                    │
│  │ └──────────────────┘ │                                    │
│  │                      │                                    │
│  │  Indexes:            │                                    │
│  │  - title (text)      │                                    │
│  │  - genre             │                                    │
│  │  - year              │                                    │
│  │  - rating            │                                    │
│  └──────────────────────┘                                    │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                   FIREBASE AUTHENTICATION                       │
│  - User Login/Registration                                     │
│  - ID Token Generation                                         │
│  - Token Verification (via Firebase Admin SDK in Backend)     │
└────────────────────────────────────────────────────────────────┘
```

## 🔄 Request Flow

### 1. Get Movies (Public)

```
Flutter App
    │
    ├─► MovieApiService.getMovies()
    │
    ├─► HTTP GET /api/movies?page=1&limit=20
    │
    ▼
Backend Server
    │
    ├─► Express Router: /api/movies
    │
    ├─► MovieController.getAllMovies()
    │
    ├─► Movie.find().sort().skip().limit()
    │
    ▼
MongoDB
    │
    ├─► Query movies collection
    │
    ├─► Return documents
    │
    ▼
Backend Server
    │
    ├─► Format response: { success: true, data: [...] }
    │
    ▼
Flutter App
    │
    ├─► Parse response
    │
    ├─► Convert to Movie objects
    │
    └─► Update UI
```

### 2. Add to Favorites (Protected)

```
Flutter App
    │
    ├─► User logged in with Firebase
    │
    ├─► Get Firebase ID Token: user.getIdToken()
    │
    ├─► BackendFavoritesService.addToFavorites(movie)
    │
    ├─► HTTP POST /api/users/favorites
    │   Headers: { Authorization: "Bearer <token>" }
    │   Body: { movieId: "..." }
    │
    ▼
Backend Server
    │
    ├─► Auth Middleware: verifyFirebaseToken()
    │
    ├─► Firebase Admin SDK: admin.auth().verifyIdToken(token)
    │
    ├─► Extract userId from decoded token
    │
    ├─► FavoriteController.addToFavorites()
    │
    ├─► Check if movie exists
    │
    ├─► Check if already favorited
    │
    ├─► UserFavorite.create({ userId, movieId })
    │
    ├─► Increment movie.favoritesCount
    │
    ▼
MongoDB
    │
    ├─► Insert into userfavorites collection
    │
    ├─► Update movies collection (favoritesCount++)
    │
    ▼
Backend Server
    │
    ├─► Return { success: true, message: "Added" }
    │
    ▼
Flutter App
    │
    ├─► Update UI (show heart icon filled)
    │
    └─► Clear favorites cache
```

## 🏗️ Component Details

### Frontend (Flutter)

#### 1. UI Layer
- **HomePage**: Carousel trending, sections
- **MoviesPage**: Grid view tất cả phim
- **FavoritesPage**: Danh sách yêu thích
- **ProfilePage**: Thông tin user
- **DetailPage**: Chi tiết phim, video player

#### 2. Services Layer
```dart
MovieApiService:
  - getMovies(filters) → List<Movie>
  - getMovieById(id) → Movie
  - searchMovies(query) → List<Movie>
  - getTrendingMovies() → List<Movie>
  - getTopRatedMovies() → List<Movie>

BackendFavoritesService:
  - getFavorites() → List<Movie>
  - addToFavorites(movie) → bool
  - removeFromFavorites(movieId) → bool
  - isFavoriteMovie(movieId) → bool
  - toggleFavorite(movie) → bool
```

#### 3. Models
```dart
Movie:
  - mongoId: String (MongoDB _id)
  - id: int
  - title: String
  - posterPath: String
  - overview: String
  - voteAverage: double
  - releaseDate: String
  - mediaType: String
  - videoUrl: String?
  - year: int?
  - genre: List<String>?
  - isPro: bool?
  - views: int?
  - favoritesCount: int?
```

### Backend (Node.js)

#### 1. Middleware Stack
```javascript
1. CORS → Allow cross-origin requests
2. Body Parser → Parse JSON
3. Auth Middleware → Verify Firebase token (protected routes)
```

#### 2. Controllers
```javascript
MovieController:
  - getAllMovies(req, res): Query with filters, pagination
  - getMovieById(req, res): Find by _id, increment views
  - searchMovies(req, res): Text search
  - getTrendingMovies(req, res): Sort by views
  - getTopRatedMovies(req, res): Sort by rating

FavoriteController:
  - getUserFavorites(req, res): Find by userId
  - addToFavorites(req, res): Create favorite, update count
  - removeFromFavorites(req, res): Delete favorite, update count
  - checkFavorite(req, res): Check if exists
```

#### 3. Models (Mongoose)
```javascript
Movie Schema:
  - title: String (required)
  - overview: String (required)
  - poster: String (required)
  - video_url: String (required)
  - rating: Number (0-10, required)
  - year: Number (required)
  - genre: [String] (required)
  - isPro: Boolean (default: false)
  - views: Number (default: 0)
  - favoritesCount: Number (default: 0)
  - timestamps: true

UserFavorite Schema:
  - userId: String (required, indexed)
  - movieId: ObjectId (ref: Movie, required)
  - timestamps: true
  - Unique index: { userId, movieId }
```

### Database (MongoDB)

#### Collections

**movies**
```javascript
{
  _id: ObjectId("..."),
  title: "The Matrix",
  overview: "A computer hacker...",
  poster: "https://...",
  video_url: "https://...",
  rating: 8.7,
  year: 1999,
  genre: ["Action", "Sci-Fi"],
  isPro: false,
  views: 1250,
  favoritesCount: 89,
  createdAt: ISODate("2024-01-01"),
  updatedAt: ISODate("2024-01-10")
}
```

**userfavorites**
```javascript
{
  _id: ObjectId("..."),
  userId: "firebase-uid-123",
  movieId: ObjectId("movie-id-456"),
  createdAt: ISODate("2024-01-05"),
  updatedAt: ISODate("2024-01-05")
}
```

#### Indexes

**movies collection:**
- `{ title: "text", overview: "text" }` - Full-text search
- `{ genre: 1 }` - Genre filtering
- `{ year: -1 }` - Year sorting
- `{ rating: -1 }` - Rating sorting
- `{ views: -1 }` - Trending

**userfavorites collection:**
- `{ userId: 1, movieId: 1 }` - Unique, prevent duplicates
- `{ userId: 1 }` - User's favorites lookup
- `{ movieId: 1 }` - Movie's favorite count

## 🔐 Security Architecture

### Authentication Flow

```
User Login (Flutter)
    │
    ├─► Firebase Auth: signInWithEmailAndPassword()
    │
    ├─► Firebase returns ID Token (JWT)
    │
    ├─► Store token in memory (user.getIdToken())
    │
    ▼
API Request
    │
    ├─► Add header: Authorization: Bearer <token>
    │
    ├─► Send to Backend
    │
    ▼
Backend Verification
    │
    ├─► Extract token from header
    │
    ├─► Firebase Admin SDK: verifyIdToken(token)
    │
    ├─► Decode token → get userId, email
    │
    ├─► Attach user info to req.user
    │
    ├─► Continue to controller
    │
    ▼
Controller
    │
    ├─► Use req.user.uid for queries
    │
    └─► Return user-specific data
```

### Data Access Control

**Public Data:**
- All movies (read-only)
- Search, trending, top-rated

**Protected Data:**
- User's favorites (userId-scoped)
- Add/remove favorites (user can only modify their own)

**Validation:**
- Mongoose schema validation
- Required fields
- Data types
- Range validation (rating: 0-10)

## 📊 Data Flow Patterns

### Pagination
```
Request: /api/movies?page=2&limit=20

Backend:
  skip = (page - 1) * limit = 20
  limit = 20

  Movie.find().skip(20).limit(20)

Response:
  {
    success: true,
    data: [...20 movies...],
    pagination: {
      page: 2,
      limit: 20,
      total: 150,
      pages: 8
    }
  }
```

### Filtering
```
Request: /api/movies?genre=Action&year=2024&isPro=false

Backend:
  query = {
    genre: "Action",
    year: 2024,
    isPro: false
  }

  Movie.find(query)
```

### Sorting
```
Request: /api/movies?sort=-rating

Backend:
  Movie.find().sort('-rating')  // Descending

Options:
  - createdAt, -createdAt (newest/oldest)
  - rating, -rating (lowest/highest)
  - views, -views (least/most viewed)
  - year, -year
```

### Search
```
Request: /api/movies/search?q=matrix

Backend:
  Movie.find({
    $or: [
      { title: { $regex: 'matrix', $options: 'i' } },
      { overview: { $regex: 'matrix', $options: 'i' } }
    ]
  })
```

## 🚀 Performance Optimizations

### Backend
1. **Database Indexing**: Fast queries
2. **Pagination**: Limit data transfer
3. **Lean Queries**: Mongoose lean() for read-only
4. **Connection Pooling**: MongoDB native
5. **Caching**: Can add Redis (future)

### Frontend
1. **Service Singleton**: Single instance
2. **Cache**: Favorites cache
3. **Lazy Loading**: Pagination
4. **Efficient Parsing**: Direct JSON conversion

## 🔄 State Management

### Current (StatefulWidget)
- Local state in each page
- Service calls in initState()
- setState() for updates

### Future Improvements
- Provider / Riverpod
- BLoC pattern
- Global state management
- Real-time updates

## 📈 Scalability

### Horizontal Scaling
```
Load Balancer
    │
    ├─► Backend Server 1
    ├─► Backend Server 2
    ├─► Backend Server 3
    │
    └─► Shared MongoDB (or MongoDB cluster)
```

### Vertical Scaling
- Increase server RAM/CPU
- Optimize database queries
- Add caching layer (Redis)

### CDN Integration
```
Static Assets (posters, videos)
    │
    └─► CDN (CloudFlare, AWS CloudFront)
         - Faster delivery
         - Reduced server load
```

## 🧩 Extension Points

### 1. Admin Panel
```
New Backend Routes:
  POST /api/admin/movies          (Add movie)
  PUT /api/admin/movies/:id       (Update movie)
  DELETE /api/admin/movies/:id    (Delete movie)

New Middleware:
  isAdmin() - Check admin role
```

### 2. Comments & Ratings
```
New Model:
  Comment { userId, movieId, text, rating, createdAt }

New Routes:
  GET /api/movies/:id/comments
  POST /api/movies/:id/comments
```

### 3. Watch History
```
New Model:
  WatchHistory { userId, movieId, watchedAt, progress }

New Routes:
  GET /api/users/history
  POST /api/users/history
```

### 4. Recommendations
```
Algorithm:
  - Based on favorites genres
  - Based on watch history
  - Collaborative filtering

New Route:
  GET /api/users/recommendations
```

## 📱 Platform Specific

### Android
```dart
// Use localhost alias
ApiConfig.baseUrl = 'http://10.0.2.2:3000'
```

### iOS Simulator
```dart
// localhost works
ApiConfig.baseUrl = 'http://localhost:3000'
```

### Physical Device
```dart
// Use computer's local IP (same WiFi)
ApiConfig.baseUrl = 'http://192.168.1.100:3000'
```

### Production
```dart
// Use deployed URL
ApiConfig.baseUrl = 'https://api.yourdomain.com'
```

## 🎯 Architecture Benefits

1. **Separation of Concerns**: Clear layers
2. **Scalability**: Can scale independently
3. **Maintainability**: Easy to update components
4. **Testability**: Each layer can be tested
5. **Security**: Centralized auth
6. **Flexibility**: Can swap components (e.g., MongoDB → PostgreSQL)
7. **Performance**: Optimized queries, caching
8. **Developer Experience**: Clear structure, good docs

---

This architecture provides a solid foundation for a production-ready movie streaming app! 🎬🚀
