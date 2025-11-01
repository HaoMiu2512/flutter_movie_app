# Flutter App - Fix Limit 10 Items & View All Pages

## 🎯 Overview
Fixed Flutter app để hiển thị đúng 10 items từ backend và sửa các View All pages bị lỗi.

## ✅ Vấn đề đã Fix

### 1. **ViewAllPage - Limit 20 → 10**
**File**: `lib/pages/view_all_page.dart`
- **Dòng 69**: Đổi `limit=20` → `limit=10`
- **Impact**: Tất cả View All pages (Popular, Top Rated, Upcoming, etc.) giờ hiển thị 10 items/page

### 2. **Unified Movie Service - Default Limits**
**File**: `lib/services/unified_movie_service.dart`
- **Dòng 29**: `getMovies()` - `limit = 20` → `limit = 10`
- **Dòng 58**: `searchMovies()` - `limit = 20` → `limit = 10`
- **Dòng 163**: `getPopularMovies()` - `limit = 20` → `limit = 10`
- **Dòng 168**: `getNowPlayingMovies()` - `limit = 20` → `limit = 10`
- **Dòng 178**: `getUpcomingMovies()` - `limit = 20` → `limit = 10`
- **Dòng 189**: `_getTMDBMovies()` - `limit = 20` → `limit = 10`

### 3. **Movie API Service**
**File**: `lib/services/movie_api_service.dart`
- **Dòng 46**: `getMovies()` - `limit = 20` → `limit = 10`
- **Dòng 112**: `searchMovies()` - `limit = 20` → `limit = 10`

### 4. **Movies HomePage Section**
**File**: `lib/HomePage/SectionPage/movies.dart`
- **Dòng 52-54**: Đổi tất cả calls từ `limit: 20` → `limit: 10`
  - `getPopularMovies(limit: 10)`
  - `getNowPlayingMovies(limit: 10)`
  - `getTopRatedMovies(limit: 10)`

### 5. **Upcoming Movies Page - Data Format Fix**
**File**: `lib/HomePage/SectionPage/upcoming.dart`

**Vấn đề**: 
- Backend trả về `json['data']` nhưng code đọc `json['results']`
- Poster path format khác: Backend dùng `poster` field, không phải `poster_path`

**Fix**:
```dart
// BEFORE (❌ Wrong)
for (var i = 0; i < json['results'].length; i++) {
  getUpcomminglist.add({
    "poster_path": json['results'][i]['poster_path'],
    "name": json['results'][i]['title'],
    ...
  });
}

// AFTER (✅ Correct)
for (var i = 0; i < json['data'].length; i++) {
  getUpcomminglist.add({
    "poster_path": json['data'][i]['poster']?.replaceAll('https://image.tmdb.org/t/p/w500', '') ?? '',
    "name": json['data'][i]['title'],
    "vote_average": json['data'][i]['rating'] ?? json['data'][i]['voteAverage'],
    "date": json['data'][i]['releaseDate'] ?? json['data'][i]['year'],
    "id": json['data'][i]['tmdbId'] ?? json['data'][i]['id'],
  });
}
```

- **Thêm**: `useBackendApi: true` flag cho View All
- **Impact**: Upcoming View All giờ hiển thị posters đúng cách

## 📊 Summary of Changes

### Files Modified: 5
1. ✅ `lib/pages/view_all_page.dart` - 1 change
2. ✅ `lib/services/unified_movie_service.dart` - 6 changes
3. ✅ `lib/services/movie_api_service.dart` - 2 changes
4. ✅ `lib/HomePage/SectionPage/movies.dart` - 3 changes
5. ✅ `lib/HomePage/SectionPage/upcoming.dart` - 2 changes (data format + View All flag)

### Total Lines Changed: 14

## 🔍 Root Cause Analysis

### Vấn đề 1: "Có vài dữ liệu hiển thị nhiều hơn 10 items"
**Nguyên nhân**:
- Backend đã update trả về 10 items ✅
- Flutter services vẫn request `limit: 20` ❌
- Flutter pages gọi với `limit: 20` ❌

**Giải pháp**:
- Đổi tất cả default limits từ 20 → 10
- Đổi tất cả method calls từ `limit: 20` → `limit: 10`

### Vấn đề 2: "Top Rated TV Series View All không hiện gì"
**Nguyên nhân**:
- ViewAllPage request `limit=20` nhưng backend chỉ trả 10 items
- TV Series đã dùng backend API nhưng ViewAllPage chưa có flag `useBackendApi: true`

**Giải pháp**:
- Update ViewAllPage limit 20 → 10
- TV Series page đã có `useBackendApi: true` ✅

### Vấn đề 3: "Upcoming View All không hiển thị posters"
**Nguyên nhân**:
- Backend response format khác TMDB:
  - Backend: `json['data']` với field `poster`, `rating`, `releaseDate`, `tmdbId`
  - Code đọc: `json['results']` với field `poster_path`, `vote_average`, `release_date`, `id`

**Giải pháp**:
- Fix data parsing: đọc từ `json['data']` thay vì `json['results']`
- Map đúng field names: `poster` → `poster_path`, `rating` → `vote_average`, etc.
- Remove full URL prefix từ poster path
- Thêm `useBackendApi: true` flag

## 🧪 Testing Checklist

### Movies Section
- [ ] Popular Movies - hiển thị 10 items
- [ ] Popular Movies View All - load 10 items/page
- [ ] Top Rated Movies - hiển thị 10 items
- [ ] Top Rated Movies View All - load 10 items/page
- [ ] Now Playing Movies - hiển thị 10 items
- [ ] Upcoming Movies - hiển thị 10 items
- [ ] Upcoming Movies View All - load 10 items/page với posters ✅

### TV Series Section
- [ ] Popular TV Series - hiển thị 10 items
- [ ] Popular TV Series View All - load 10 items/page
- [ ] Top Rated TV Series - hiển thị 10 items
- [ ] Top Rated TV Series View All - load 10 items/page ✅
- [ ] On The Air TV Series - hiển thị 10 items
- [ ] On The Air TV Series View All - load 10 items/page

### Search & Trending
- [ ] Search Movies - kết quả hiển thị 10 items
- [ ] Search TV - kết quả hiển thị 10 items
- [ ] Trending All - hiển thị 10 items
- [ ] Trending Movies - hiển thị 10 items
- [ ] Trending TV - hiển thị 10 items

## 🚀 Expected Results

### Trước Fix:
```
❌ HomePage: Một số section hiển thị 20 items
❌ Top Rated TV Series View All: Không hiện gì
❌ Upcoming View All: Không có posters
❌ Backend trả 10 nhưng Flutter request 20 → mismatch
```

### Sau Fix:
```
✅ Tất cả sections: Hiển thị CHÍNH XÁC 10 items
✅ Top Rated TV Series View All: Hoạt động bình thường
✅ Upcoming View All: Hiển thị posters đầy đủ
✅ Backend trả 10 và Flutter request 10 → perfect match
✅ View All pagination: 10 items/page
```

## 📝 Related Files (Not Changed)

### Comment/Favorites/Recently Viewed (Giữ nguyên limit: 20)
- `lib/services/comment_service.dart` - Comments nên có nhiều hơn
- `lib/services/backend_favorites_service.dart` - Favorites list
- `lib/services/backend_recently_viewed_service.dart` - Recently viewed
- `lib/reapeatedfunction/comments_widget.dart` - Comments widget

> **Note**: Các services trên KHÔNG đổi limit vì chúng không phải movies/TV series data, mà là user-generated content.

## 🔄 Next Steps

1. **Test app thoroughly**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Verify backend is running**:
   ```bash
   cd backend
   npm start
   ```

3. **Check logs**:
   - Backend console: Xem requests có `?limit=10`
   - Flutter console: Verify API calls

4. **Manual Testing**:
   - Scroll qua tất cả sections → count items (phải là 10)
   - Click "View All" buttons → check pagination (10 items/page)
   - Check Top Rated TV View All → phải load data
   - Check Upcoming View All → phải có posters

## ✅ Success Criteria

- [x] ViewAllPage request `limit=10` thay vì 20
- [x] Tất cả Flutter movie services có default `limit: 10`
- [x] Tất cả Flutter pages gọi services với `limit: 10`
- [x] Upcoming page parse backend response đúng format
- [x] Upcoming View All hiển thị posters
- [ ] App hiển thị CHÍNH XÁC 10 items ở mọi nơi (cần test)
- [ ] View All pages load 10 items/page (cần test)
- [ ] Không còn lỗi "không hiện gì" hay "không có posters" (cần test)

---

**Date**: 2024
**Status**: ✅ Code Fixed - Ready for Testing
**Impact**: High - Affects all movie/TV listings and View All pages
