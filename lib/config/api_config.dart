/// API Configuration for Backend Server
class ApiConfig {
  // Base URLs
  static const String _localBaseUrl = 'http://localhost:3000';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:3000';
  
  // Current base URL (change based on your environment)
  // Use _androidEmulatorBaseUrl when running on Android emulator
  // Use _localBaseUrl when running on iOS simulator or web
  static const String baseUrl = _androidEmulatorBaseUrl;
  
  // API version
  static const String apiVersion = '/api';
  
  // Full base URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // Endpoints
  
  // User Profile
  static const String userProfile = '/users/profile';
  static const String userCreate = '/users/create';
  static const String userStats = '/users/stats';
  static const String userDelete = '/users';
  
  // Favorites
  static const String favorites = '/users/favorites';
  static const String favoritesCheck = '/users/favorites/check';
  static const String favoritesClear = '/users/favorites/clear';
  static const String favoritesRemove = '/users/favorites/remove';
  
  // Recently Viewed
  static const String recentlyViewed = '/recently-viewed';
  static const String recentlyViewedClear = '/recently-viewed/clear';
  static const String recentlyViewedProgress = '/recently-viewed/progress';
  
  // Upload
  static const String uploadAvatar = '/upload/avatar';
  static const String uploadAvatarDelete = '/upload/avatar';
  
  // Reviews
  static const String reviews = '/reviews';
  static const String reviewStats = '/reviews';
  
  // Comments
  static const String comments = '/comments';
  
  // Movies
  static const String movies = '/movies';
  static const String movieDetail = '/movies';
  static const String moviesUpcoming = '/movies/upcoming';
  static const String moviesTopRated = '/movies/top-rated';
  
  // TV Series
  static const String tvSeries = '/tv-series';
  static const String tvSeriesDetail = '/tv-series/tmdb';
  static const String tvSeriesTopRated = '/tv-series/top-rated';
  
  // Search
  static const String search = '/search';
  static const String searchMovies = '/search/movies';
  static const String searchTv = '/search/tv';
  
  // Trending
  static const String trending = '/trending';
  static const String trendingMovies = '/trending/movies';
  static const String trendingTv = '/trending/tv';
  
  // Similar & Recommended
  static const String similar = '/similar';
  static const String recommended = '/recommended';
  static const String tvSimilar = '/tv/similar';
  static const String tvRecommended = '/tv/recommended';
  
  // Helper methods
  
  /// Get full URL for user profile
  static String getUserProfileUrl(String userId) => 
      '$apiBaseUrl$userProfile/$userId';
  
  /// Get full URL for user stats
  static String getUserStatsUrl(String userId) => 
      '$apiBaseUrl$userStats/$userId';
  
  /// Get full URL for favorites
  static String getFavoritesUrl(String userId, {String? mediaType, int? page, int? limit}) {
    var url = '$apiBaseUrl$favorites/$userId';
    final params = <String>[];
    
    if (mediaType != null) params.add('mediaType=$mediaType');
    if (page != null) params.add('page=$page');
    if (limit != null) params.add('limit=$limit');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    return url;
  }
  
  /// Get full URL for checking favorite
  static String getCheckFavoriteUrl(String userId, String mediaType, int mediaId) => 
      '$apiBaseUrl$favoritesCheck/$userId/$mediaType/$mediaId';
  
  /// Get full URL for recently viewed
  static String getRecentlyViewedUrl(String userId, {String? mediaType, int? page, int? limit}) {
    var url = '$apiBaseUrl$recentlyViewed/$userId';
    final params = <String>[];
    
    if (mediaType != null) params.add('mediaType=$mediaType');
    if (page != null) params.add('page=$page');
    if (limit != null) params.add('limit=$limit');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    return url;
  }
  
  /// Get full URL for watch progress
  static String getWatchProgressUrl(String userId, String mediaType, int mediaId) => 
      '$apiBaseUrl$recentlyViewedProgress/$userId/$mediaType/$mediaId';
  
  /// Get full URL for avatar
  static String getAvatarUrl(String filename) => 
      '$baseUrl/uploads/avatars/$filename';
  
  /// Get full URL for reviews
  static String getReviewsUrl(String mediaType, int mediaId) => 
      '$apiBaseUrl$reviews/$mediaType/$mediaId';
  
  /// Get full URL for comments
  static String getCommentsUrl(String mediaType, int mediaId) => 
      '$apiBaseUrl$comments/$mediaType/$mediaId';
  
  // Headers
  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };
  
  // Legacy methods (for backward compatibility)
  static String get moviesUrl => '$apiBaseUrl$movies';
  static String movieDetailUrl(String id) => '$apiBaseUrl$movieDetail/$id';
  static String get searchUrl => '$apiBaseUrl$search';
  static String get trendingUrl => '$apiBaseUrl$trending';
  static String get topRatedUrl => '$apiBaseUrl$moviesTopRated';
  static String get favoritesUrl => '$apiBaseUrl$favorites';
  static String removeFavoriteUrl(String movieId) => '$apiBaseUrl$favorites/$movieId';
  static String checkFavoriteUrl(String movieId) => '$apiBaseUrl$favoritesCheck/$movieId';
}
