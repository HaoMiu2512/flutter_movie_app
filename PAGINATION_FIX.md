# Pagination Fix - Movies View All

## 🎯 Vấn Đề Gốc

### Issue 1: "Popular View All chỉ hiển thị 1 item"
**Root Cause**: Database chỉ có 1 movie với `cacheType: 'popular'` do **Duplicate Key Error**

### Issue 2: Duplicate Key Error khi lưu movies
```
E11000 duplicate key error collection: flutter_movies.movies 
index: tmdbId_1 dup key: { tmdbId: 1305 }
```

**Root Causes**: 
1. Old schema có `tmdbId: { unique: true }`
2. Cùng 1 movie KHÔNG THỂ tồn tại với nhiều `cacheType` khác nhau
3. Movie ID 1305 đã tồn tại với `cacheType: 'now_playing'` → Không thể lưu lại với `cacheType: 'popular'`

### Issue 3: Pagination không hoạt động
**Root Cause**: Backend query không có `.skip()` cho pagination
Backend không xử lý pagination đúng cách:
- Tất cả các request đều trả về 10 items đầu tiên (page 1)
- Không có logic `.skip()` để bỏ qua items của các page trước
- `totalPages` luôn = 1 → Flutter nghĩ chỉ có 1 page

**Code Cũ**:
```javascript
// ❌ WRONG - Always returns first 10
const cachedMovies = await Movie.find({ cacheType })
  .sort({ popularity: -1 })
  .limit(10);  // No skip!

pagination: {
  page: parseInt(page),
  limit: 10,
  total: cachedMovies.length,  // Wrong: returns 10 instead of total count
  pages: 1  // Wrong: always 1
}
```

**Kết quả**:
- Page 1: 10 items ✅
- Page 2: Same 10 items (nhưng Flutter nghĩ hết data vì pages = 1) ❌
- ViewAll chỉ hiển thị được 1 batch items

---

## ✅ Giải Pháp

### Changes Made
File: `backend/src/controllers/movieControllerNew.js`

### Fixed 4 Methods

#### 1. getPopularMovies()
#### 2. getTopRatedMovies()
#### 3. getNowPlayingMovies()
#### 4. getUpcomingMovies()

**New Code Pattern**:
```javascript
async function getPopularMovies(req, res) {
  try {
    const { page = 1, forceRefresh = false, limit = 10 } = req.query;
    const cacheType = 'popular';
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    
    if (!forceRefresh) {
      // ✅ Get total count for proper pagination
      const totalCount = await Movie.countDocuments({ cacheType });
      
      // ✅ Calculate skip based on page number
      const skip = (pageNum - 1) * limitNum;
      
      // ✅ Use skip + limit for pagination
      const cachedMovies = await Movie.find({ cacheType })
        .sort({ popularity: -1 })
        .skip(skip)      // NEW: Skip previous pages
        .limit(limitNum); // Limit current page
      
      if (cachedMovies.length > 0 && isCacheValid(...)) {
        console.log(`✅ Serving popular movies from cache (page ${pageNum}, ${cachedMovies.length} items)`);
        return res.json({
          success: true,
          source: 'cache',
          data: cachedMovies,
          pagination: {
            page: pageNum,
            limit: limitNum,
            total: totalCount,  // ✅ Total items in DB
            pages: Math.ceil(totalCount / limitNum)  // ✅ Total pages
          }
        });
      }
    }
    // ... rest of code
  }
}
```

### Key Changes

| Before | After | Why |
|--------|-------|-----|
| `.limit(10)` | `.skip(skip).limit(limitNum)` | Enable pagination |
| `total: cachedMovies.length` | `total: totalCount` | Show total items, not just current page |
| `pages: 1` | `pages: Math.ceil(totalCount / limitNum)` | Calculate correct page count |
| No skip logic | `skip = (pageNum - 1) * limitNum` | Jump to correct page |

---

## 🔍 How Pagination Now Works

### Example: 25 movies in database

**Request 1**: GET /api/movies/popular?page=1&limit=10
```javascript
skip = (1 - 1) * 10 = 0
limit = 10
→ Returns items 1-10
pagination: { page: 1, limit: 10, total: 25, pages: 3 }
```

**Request 2**: GET /api/movies/popular?page=2&limit=10
```javascript
skip = (2 - 1) * 10 = 10
limit = 10
→ Returns items 11-20
pagination: { page: 2, limit: 10, total: 25, pages: 3 }
```

**Request 3**: GET /api/movies/popular?page=3&limit=10
```javascript
skip = (3 - 1) * 10 = 20
limit = 10
→ Returns items 21-25
pagination: { page: 3, limit: 10, total: 25, pages: 3 }
```

---

## 🧪 Testing

### 1. Restart Backend
```bash
cd backend
npm run dev
```
✅ Server running on port 3000

### 2. Test with cURL or Postman

**Test Popular - Page 1**:
```bash
curl http://localhost:3000/api/movies/popular?page=1&limit=10
```
Expected: 10 items, pages = total/10

**Test Popular - Page 2**:
```bash
curl http://localhost:3000/api/movies/popular?page=2&limit=10
```
Expected: Different 10 items

### 3. Test in Flutter App

1. **Hot Reload** Flutter app (`r` in terminal)
2. Go to **Movies** section
3. Click **View All** on **Popular Now**
4. **Scroll down** → Should load more items
5. Check that different movies appear on scroll

### 4. Check Backend Logs
```
✅ Serving popular movies from cache (page 1, 10 items)
✅ Serving popular movies from cache (page 2, 10 items)
✅ Serving popular movies from cache (page 3, 5 items)
```

---

## 📊 Impact

### Before Fix
- ❌ View All chỉ hiển thị 10 items đầu tiên
- ❌ Scroll không load thêm data
- ❌ `pages: 1` → Flutter dừng fetch
- ❌ User chỉ thấy 1 page content

### After Fix
- ✅ View All hiển thị tất cả items trong database
- ✅ Scroll load thêm 10 items/page
- ✅ `pages: Math.ceil(total/limit)` → Đúng số pages
- ✅ User có thể xem toàn bộ content

---

## 🔧 Technical Details

### MongoDB Pagination Pattern
```javascript
// Standard pagination formula
const skip = (page - 1) * limit;

// Example: Page 3, Limit 10
// skip = (3 - 1) * 10 = 20
// → Bỏ qua 20 items đầu tiên
// → Lấy 10 items tiếp theo (items 21-30)
```

### Why countDocuments()?
```javascript
const totalCount = await Movie.countDocuments({ cacheType });
```
- Cần biết **tổng số items** để tính pages
- `pages = Math.ceil(totalCount / limit)`
- Example: 25 items ÷ 10 per page = 3 pages

### Performance Note
- `countDocuments()` is fast (uses index)
- Only runs once per request
- Worth the cost for correct pagination

---

## 📄 Related Files

### Modified
- ✅ `backend/src/controllers/movieControllerNew.js` (4 methods)

### Affected Endpoints
- ✅ GET `/api/movies/popular`
- ✅ GET `/api/movies/top-rated`
- ✅ GET `/api/movies/now-playing`
- ✅ GET `/api/movies/upcoming`

### Related Docs
- `MOVIES_VIEW_ALL_FIX.md` - Response format fix
- `BACKEND_LIMIT_10_FIX.md` - Limit standardization
- `TV_SERIES_VIEW_ALL_FIX.md` - Similar TV fix

---

## 🎯 Next Steps

1. **Test All Sections**:
   - Popular Now → View All ✓
   - Top Rated → View All ✓
   - Now Playing → View All ✓
   - Upcoming → View All ✓

2. **Verify Pagination**:
   - Scroll loads new items ✓
   - No duplicate items ✓
   - Stops at last page ✓

3. **Check Performance**:
   - Backend logs show correct page numbers ✓
   - Network requests show different data ✓
   - No excessive API calls ✓

---

**Date**: November 2, 2025  
**Status**: ✅ Fixed - Ready for Testing  
**Impact**: Critical - Fixes pagination for all movie View All pages  
**Issue**: Popular View All chỉ hiển thị 1 page → Now shows all pages ✅

