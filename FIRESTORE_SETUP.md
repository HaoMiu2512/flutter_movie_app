# Hướng dẫn cấu hình Firebase Firestore cho tính năng Yêu thích

## 1. Giới thiệu

Ứng dụng sử dụng Firebase Firestore để lưu trữ danh sách phim yêu thích của người dùng trên cloud. Điều này cho phép:
- Đồng bộ dữ liệu giữa các thiết bị
- Lưu trữ an toàn trên cloud
- Truy cập nhanh chóng và realtime

## 2. Cấu trúc dữ liệu Firestore

```
users/
  └── {userId}/
      └── favorites/
          ├── movie_123
          │   ├── id: 123
          │   ├── title: "Ten Movie Name"
          │   ├── posterPath: "/path.jpg"
          │   ├── overview: "Movie description..."
          │   ├── voteAverage: 8.5
          │   ├── releaseDate: "2024-01-01"
          │   ├── mediaType: "movie"
          │   └── addedAt: 1234567890
          └── tv_456
              ├── id: 456
              ├── title: "TV Series Name"
              ├── posterPath: "/path.jpg"
              ├── overview: "Series description..."
              ├── voteAverage: 9.0
              ├── releaseDate: "2024-01-01"
              ├── mediaType: "tv"
              └── addedAt: 1234567891
```

## 3. Cấu hình Firestore Security Rules

### Bước 1: Truy cập Firebase Console

1. Mở trình duyệt và truy cập: https://console.firebase.google.com/
2. Chọn project của bạn
3. Vào menu **Firestore Database** ở thanh bên trái
4. Click tab **Rules** ở phía trên

### Bước 2: Cấu hình Rules

Thay thế nội dung hiện tại bằng rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Rules cho favorites
    match /users/{userId}/favorites/{favoriteId} {
      // Cho phép đọc và ghi nếu:
      // 1. User đã đăng nhập (request.auth != null)
      // 2. User ID trong request trùng với userId trong path
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Block tất cả các requests khác
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Bước 3: Publish Rules

1. Click nút **Publish** để áp dụng rules
2. Đợi vài giây để rules được cập nhật

## 4. Kiểm tra Rules

Bạn có thể test rules ngay trên Firebase Console:

1. Click tab **Rules playground**
2. Chọn operation (read/write)
3. Nhập path: `/users/{userId}/favorites/movie_123`
4. Set authentication (Authenticated, Custom claims, etc.)
5. Click **Run** để test

### Ví dụ test case:

**Test 1: User đọc favorites của chính mình (PASS)**
- Location: `/users/abc123/favorites/movie_1`
- Auth: `uid = "abc123"`
- Operation: `read`
- Result: ✅ Allowed

**Test 2: User đọc favorites của người khác (FAIL)**
- Location: `/users/xyz789/favorites/movie_1`
- Auth: `uid = "abc123"`
- Operation: `read`
- Result: ❌ Denied

**Test 3: User chưa đăng nhập (FAIL)**
- Location: `/users/abc123/favorites/movie_1`
- Auth: `null`
- Operation: `read`
- Result: ❌ Denied

## 5. Giải thích Rules

```javascript
// Chỉ cho phép truy cập nếu user đã đăng nhập
request.auth != null

// Chỉ cho phép user truy cập favorites của chính họ
request.auth.uid == userId
```

## 6. Advanced Rules (Tùy chọn)

Nếu muốn thêm validation cho dữ liệu:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId}/favorites/{favoriteId} {
      allow read: if request.auth != null && request.auth.uid == userId;

      allow create: if request.auth != null
                    && request.auth.uid == userId
                    && request.resource.data.id is int
                    && request.resource.data.title is string
                    && request.resource.data.mediaType in ['movie', 'tv']
                    && request.resource.data.addedAt is int;

      allow update, delete: if request.auth != null
                          && request.auth.uid == userId;
    }
  }
}
```

## 7. Monitoring và Debug

### Xem logs trong Firebase Console:

1. Vào **Firestore Database** > **Usage**
2. Xem số lượng reads/writes
3. Kiểm tra quota limit

### Debug trong ứng dụng:

Tất cả operations trong `FavoritesService` đều có logging. Mở DevTools Console để xem:

```
FavoritesService: Fetching favorites for user abc123
FavoritesService: Found 5 favorites
FavoritesService: Added to favorites: Inception (movie_27205)
FavoritesService: Removed from favorites: tv_94605
```

## 8. Troubleshooting

### Lỗi: "Missing or insufficient permissions"

**Nguyên nhân:** Firestore rules chưa được cấu hình đúng

**Giải pháp:**
1. Kiểm tra lại rules ở bước 3
2. Đảm bảo đã publish rules
3. Kiểm tra user đã đăng nhập chưa (`FirebaseAuth.instance.currentUser != null`)

### Lỗi: "User not logged in"

**Nguyên nhân:** User chưa đăng nhập Firebase Auth

**Giải pháp:**
1. Đăng nhập bằng email/password hoặc Google Sign-In
2. Kiểm tra `AuthService.isLoggedIn()` trả về `true`

### Lỗi: "Quota exceeded"

**Nguyên nhân:** Vượt quá giới hạn free tier của Firebase

**Giải pháp:**
1. Kiểm tra usage trong Firebase Console
2. Optimize code để giảm số lượng reads/writes
3. Upgrade lên Blaze plan nếu cần

## 9. Best Practices

### 1. Cache dữ liệu

`FavoritesService` đã implement caching:
```dart
List<Movie>? _cachedFavorites;
```

### 2. Batch operations

Khi xóa nhiều items, sử dụng batch:
```dart
final batch = _firestore.batch();
for (var doc in snapshot.docs) {
  batch.delete(doc.reference);
}
await batch.commit();
```

### 3. Error handling

Luôn wrap Firestore operations trong try-catch:
```dart
try {
  await _favoritesCollection.add(data);
} catch (e) {
  print('Error: $e');
}
```

## 10. Tính năng trong tương lai

- [ ] Real-time sync với `StreamBuilder`
- [ ] Offline support với persistence
- [ ] Search và filter favorites
- [ ] Share favorites với bạn bè
- [ ] Backup và restore

## 11. Liên kết hữu ích

- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Pricing](https://firebase.google.com/pricing)
- [Cloud Firestore Limits](https://firebase.google.com/docs/firestore/quotas)
