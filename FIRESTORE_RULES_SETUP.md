# Firestore Security Rules Setup for Recently Viewed Feature

## Vấn đề
Tính năng Recently Viewed không hoạt động vì Firestore Security Rules chưa cho phép ghi vào collection `recently_viewed`.

## Giải pháp

### Bước 1: Vào Firebase Console
1. Truy cập: https://console.firebase.google.com/
2. Chọn project: **flutter-movie-app-253e7**
3. Vào menu **Firestore Database** (ở thanh bên trái)
4. Click vào tab **Rules** (ở trên cùng)

### Bước 2: Cập nhật Security Rules

Thay thế rules hiện tại bằng rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profile rules
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Favorites subcollection
      match /favorites/{favoriteId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Recently Viewed subcollection
      match /recently_viewed/{movieId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Block all other requests
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Bước 3: Publish Rules
1. Click nút **Publish** để lưu rules

### Bước 4: Test lại app
1. Hot restart app (R trong Flutter)
2. Đăng nhập vào app
3. Click vào một bộ phim để xem chi tiết
4. Kiểm tra console logs để xem có message thành công không:
   ```
   MoviesDetail: Adding to recently viewed - [Movie Title]
   RecentlyViewedService: Added to recently viewed: [Movie Title]
   MoviesDetail: Add to recently viewed result: true
   ```
5. Vào Profile page để xem Recently Viewed section

## Kiểm tra Firestore Data

### Cách 1: Qua Firebase Console
1. Vào **Firestore Database** > **Data** tab
2. Mở collection: `users` > `{your-user-id}` > `recently_viewed`
3. Bạn sẽ thấy các document với cấu trúc:
   ```
   movie_12345
   ├── id: 12345
   ├── title: "Movie Name"
   ├── posterPath: "/path/to/poster.jpg"
   ├── overview: "Description..."
   ├── voteAverage: 8.5
   ├── releaseDate: "2024-01-01"
   ├── mediaType: "movie"
   └── viewedAt: 1234567890 (timestamp)
   ```

### Cách 2: Qua Console Logs
Khi click vào phim, bạn sẽ thấy logs:
```
MoviesDetail: Adding to recently viewed - [Title]
RecentlyViewedService: User not logged in  // Nếu chưa đăng nhập
HOẶC
RecentlyViewedService: Added to recently viewed: [Title] (movie_123)
```

## Lưu ý quan trọng

1. **Phải đăng nhập**: Recently Viewed chỉ hoạt động khi user đã đăng nhập
2. **Giới hạn 20 phim**: Tự động chỉ giữ 20 phim gần nhất
3. **Cập nhật timestamp**: Nếu xem lại phim đã xem, timestamp sẽ được cập nhật
4. **Real-time updates**: Profile page sẽ tự động cập nhật khi có phim mới được xem

## Troubleshooting

### Nếu vẫn không hoạt động:

1. **Kiểm tra authentication**:
   ```dart
   // Trong console log, kiểm tra:
   RecentlyViewedService: User not logged in
   // Nếu thấy message này, bạn cần đăng nhập lại
   ```

2. **Kiểm tra permissions**:
   - Vào Firebase Console > Firestore Database > Rules
   - Đảm bảo rules đã được publish

3. **Hard restart app**:
   - Stop app hoàn toàn
   - `flutter clean`
   - `flutter pub get`
   - Run lại app

4. **Kiểm tra internet connection**:
   - Firestore cần internet để sync data

5. **Xem chi tiết lỗi**:
   - Kiểm tra console logs để xem error message cụ thể
   - Tìm dòng: `RecentlyViewedService Error adding to recently viewed: [error]`
