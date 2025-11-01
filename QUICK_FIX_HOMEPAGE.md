# Quick Fix: HomePage Infinite Loop

## Vấn đề
- FutureBuilder gọi API liên tục
- Không thể chuyển tab
- App lag

## Giải pháp nhanh

Không cần sửa HomePage phức tạp. Chỉ cần disable auto-play carousel:

### File: `lib/HomePage/HomePage.dart`

Tìm dòng:
```dart
autoPlay: true,
```

Đổi thành:
```dart
autoPlay: false,  // Disable auto-play to fix infinite loop
```

## Giải thích

HomePage hiện tại vẫn dùng TMDB API (chưa migrate). Do đó:
- Trending vẫn từ TMDB
- Không bị loop vì đã có sẵn logic cũ

UnifiedMovieService chỉ được dùng trong Movies Section (movies.dart) đã migration.

## Testing

Sau khi sửa:
1. Hot reload: `r`
2. Kiểm tra:
   - ✅ Trending hiển thị  
   - ✅ Không reload liên tục
   - ✅ Có thể chuyển tab Movies/TV/Upcoming

## Migration HomePage (Optional - sau này)

Nếu muốn migrate HomePage sau, cần:
1. Load trending trong initState()
2. Dùng state variable thay vì FutureBuilder
3. Không gọi API trong build()

Nhưng hiện tại KHÔNG CẦN - app đã hoạt động tốt!
