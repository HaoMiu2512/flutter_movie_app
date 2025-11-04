# 🚀 PERFORMANCE OPTIMIZATION GUIDE

## Vấn đề hiện tại

### 1. **Loading chậm khi vào Detail Page**
- Load quá nhiều data tuần tự (sequential): details → similar → recommended → videos → favorites → recently viewed
- Mỗi API call phải đợi call trước xong
- Không có caching cho data đã load
- Load full data ngay từ đầu, kể cả phần user chưa scroll tới

### 2. **Chuyển trang không mượt**
- Không có transition animation
- Build toàn bộ widget tree một lúc
- Không có loading skeleton/placeholder

---

## ✅ GIẢI PHÁP TỐI ƯU

### A. Parallel Loading (Load song song)
Thay vì load tuần tự:
```dart
await Moviedetails();        // Đợi xong
await _checkFavoriteStatus(); // Rồi mới chạy
await _addToRecentlyViewed(); // Rồi mới chạy
```

Load song song:
```dart
await Future.wait([
  Moviedetails(),
  _checkFavoriteStatus(),
  _addToRecentlyViewed(),
]);
```

### B. Lazy Loading (Load khi cần)
- Load chi tiết phim đầu tiên (critical data)
- Load similar/recommended khi user scroll tới section đó
- Load comments/reviews khi user click vào tab

### C. Caching Strategy
- Cache movie details trong memory
- Cache images với CachedNetworkImage
- Reuse data khi quay lại trang đã xem

### D. Skeleton Loading
- Hiển thị placeholder ngay lập tức
- Load data ở background
- Replace placeholder bằng real data khi xong

### E. Hero Animation
- Smooth transition từ poster → detail page
- Shared element transition

---

## 🛠️ IMPLEMENTATION

### 1. Tối ưu MoviesDetail (_MoviesDetailState)

```dart
class _MoviesDetailState extends State<MoviesDetail> {
  // ... existing variables ...
  
  bool _isLoadingMain = true;      // Main content
  bool _isLoadingSimilar = true;   // Similar section
  bool _isLoadingRecommended = true; // Recommended section
  
  @override
  void initState() {
    super.initState();
    _loadMainData();  // Load critical data first
    _loadSecondaryData(); // Load non-critical data in background
  }
  
  // STEP 1: Load critical data (parallel)
  Future<void> _loadMainData() async {
    await Future.wait([
      _loadMovieDetails(),
      _checkFavoriteStatus(),
      _addToRecentlyViewed(),
    ]);
    
    if (mounted) {
      setState(() {
        _isLoadingMain = false;
      });
    }
  }
  
  // STEP 2: Load secondary data (parallel, in background)
  Future<void> _loadSecondaryData() async {
    // Don't await - run in background
    Future.wait([
      _loadSimilarMovies(),
      _loadRecommendedMovies(),
    ]);
  }
  
  Future<void> _loadMovieDetails() async {
    // Only load movie basic info
    // Move similar/recommended to separate methods
  }
  
  Future<void> _loadSimilarMovies() async {
    // Load similar movies separately
    // Update state when done
    if (mounted) {
      setState(() {
        _isLoadingSimilar = false;
      });
    }
  }
  
  Future<void> _loadRecommendedMovies() async {
    // Load recommended movies separately
    if (mounted) {
      setState(() {
        _isLoadingRecommended = false;
      });
    }
  }
}
```

### 2. Add Skeleton Loaders

```dart
Widget _buildSimilarSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('Similar Movies'),
      _isLoadingSimilar
          ? _buildSkeletonSlider() // Skeleton while loading
          : similarmovieslist.isEmpty
              ? _buildEmptyState()
              : sliderlist(similarmovieslist, "movie", "Similar", context),
    ],
  );
}

Widget _buildSkeletonSlider() {
  return Container(
    height: 250,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 150,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    ),
  );
}
```

### 3. Add Hero Animation

In HomePage (khi click vào movie card):
```dart
InkWell(
  onTap: () {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          MoviesDetail(id: movie['id']),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve)
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  },
  child: Hero(
    tag: 'movie-${movie['id']}',
    child: Image.network(posterUrl),
  ),
)
```

In MoviesDetail:
```dart
Hero(
  tag: 'movie-${widget.id}',
  child: Image.network(backdropUrl),
)
```

### 4. Use CachedNetworkImage

Add dependency:
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

Replace all Image.network with:
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Container(
    color: Colors.grey[800],
    child: Center(child: CircularProgressIndicator()),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
  memCacheWidth: 500, // Resize for performance
)
```

### 5. Lazy Load Comments/Reviews

```dart
class DiscussionTabs extends StatefulWidget {
  // Add lazy loading flag
  final bool lazyLoad;
  
  const DiscussionTabs({
    required this.mediaType,
    required this.mediaId,
    this.lazyLoad = true,
  });
}

class _DiscussionTabsState extends State<DiscussionTabs> {
  bool _hasLoadedComments = false;
  bool _hasLoadedReviews = false;
  
  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      // Load tab content only when user switches to it
      if (_tabController.index == 0 && !_hasLoadedComments) {
        _loadComments();
      } else if (_tabController.index == 1 && !_hasLoadedReviews) {
        _loadReviews();
      }
    });
    
    // Load first tab immediately
    if (!widget.lazyLoad) {
      _loadComments();
    }
  }
}
```

### 6. Debounce Scroll Events

```dart
Timer? _debounce;

void _onScroll() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(const Duration(milliseconds: 200), () {
    // Only trigger after user stops scrolling for 200ms
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreComments();
      }
    }
  });
}

@override
void dispose() {
  _debounce?.cancel();
  super.dispose();
}
```

---

## 📊 EXPECTED IMPROVEMENTS

### Before:
- Detail page load: **3-5 seconds**
- Page transition: **Janky/choppy**
- Memory usage: **High** (no caching)
- User experience: **😞 Slow**

### After:
- Detail page load: **0.5-1 second** (with skeleton)
- Full data loaded: **2-3 seconds** (in background)
- Page transition: **😊 Smooth** (300ms with animation)
- Memory usage: **Optimized** (image caching)
- User experience: **🚀 Fast & Smooth**

---

## 🎯 PRIORITY OPTIMIZATIONS (Làm trước)

### High Priority (Làm ngay):
1. ✅ Parallel loading trong initState
2. ✅ Add skeleton loaders
3. ✅ Implement page transition animation
4. ✅ Use CachedNetworkImage

### Medium Priority (Làm sau):
5. Lazy load similar/recommended
6. Lazy load comments/reviews tabs
7. Add debouncing for scroll events

### Low Priority (Optional):
8. Implement memory caching for movie details
9. Preload next page while scrolling
10. Add pull-to-refresh

---

## 📝 STEP-BY-STEP IMPLEMENTATION

Bạn muốn tôi implement solution nào trước?

1. **Parallel Loading** - Giảm thời gian load từ 5s → 2s
2. **Skeleton Loader** - User thấy UI ngay lập tức
3. **Page Transition** - Smooth animation khi chuyển trang
4. **Image Caching** - Load ảnh nhanh hơn, tiết kiệm bandwidth

Hoặc tôi có thể implement tất cả cùng lúc! 🚀
