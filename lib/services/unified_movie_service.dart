import 'package:flutter_movie_app/models/movie.dart';
import 'package:flutter_movie_app/services/movie_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Unified Movie Service
/// Ưu tiên sử dụng Backend API, fallback về TMDB nếu cần
/// 
/// Migration Strategy:
/// - Movies: Use Backend (migrated) ✅
/// - TV Series: Use TMDB (not migrated yet) ⏳
class UnifiedMovieService {
  // Singleton pattern
  static final UnifiedMovieService _instance = UnifiedMovieService._internal();
  factory UnifiedMovieService() => _instance;
  UnifiedMovieService._internal();

  final MovieApiService _backendService = MovieApiService();
  
  // TMDB Configuration (fallback only)
  static const String _tmdbApiKey = 'e956f0d34451feb0d2ac9e6b5dab6823';
  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';

  bool _useBackend = true; // Flag to control backend usage

  /// Get all movies (Backend with TMDB fallback)
  Future<List<Movie>> getMovies({
    int page = 1,
    int limit = 10,
    String? genre,
    int? year,
    bool? isPro,
  }) async {
    if (_useBackend) {
      try {
        final movies = await _backendService.getMovies(
          page: page,
          limit: limit,
          genre: genre,
          year: year,
          isPro: isPro,
        );
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Loaded ${movies.length} movies from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend failed, trying TMDB fallback... ⚠️');
      }
    }

    // Fallback to TMDB
    return _getTMDBMovies('/movie/popular', page: page);
  }

  /// Search movies (Backend with TMDB fallback)
  Future<List<Movie>> searchMovies(String query, {int page = 1, int limit = 10}) async {
    if (_useBackend && query.isNotEmpty) {
      try {
        final movies = await _backendService.searchMovies(query, page: page, limit: limit);
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Search found ${movies.length} movies from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend search failed, trying TMDB... ⚠️');
      }
    }

    // Fallback to TMDB
    if (query.isEmpty) return [];
    
    try {
      final url = '$_tmdbBaseUrl/search/movie?api_key=$_tmdbApiKey&query=${Uri.encodeComponent(query)}&page=$page';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => _convertTMDBToMovie(json)).toList();
      }
    } catch (e) {
      print('UnifiedMovieService: TMDB search error: $e');
    }
    
    return [];
  }

  /// Get trending movies (Backend with TMDB fallback)
  Future<List<Movie>> getTrendingMovies({int limit = 10}) async {
    if (_useBackend) {
      try {
        final movies = await _backendService.getTrendingMovies(limit: limit);
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Loaded ${movies.length} trending from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend trending failed, trying TMDB... ⚠️');
      }
    }

    // Fallback to TMDB
    return _getTMDBMovies('/trending/movie/week', limit: limit);
  }

  /// Get top rated movies (Backend with TMDB fallback)
  Future<List<Movie>> getTopRatedMovies({int limit = 10}) async {
    if (_useBackend) {
      try {
        final movies = await _backendService.getTopRatedMovies(limit: limit);
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Loaded ${movies.length} top rated from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend top rated failed, trying TMDB... ⚠️');
      }
    }

    // Fallback to TMDB
    return _getTMDBMovies('/movie/top_rated', limit: limit);
  }

  /// Get movie by ID (Backend with TMDB fallback)
  Future<Movie?> getMovieById(String id) async {
    if (_useBackend) {
      try {
        final movie = await _backendService.getMovieById(id);
        
        if (movie != null) {
          print('UnifiedMovieService: Loaded movie details from Backend ✅');
          return movie;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend movie detail failed, trying TMDB... ⚠️');
      }
    }

    // Fallback to TMDB (if id is numeric TMDB ID)
    if (int.tryParse(id) != null) {
      try {
        final url = '$_tmdbBaseUrl/movie/$id?api_key=$_tmdbApiKey';
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          return _convertTMDBToMovie(json);
        }
      } catch (e) {
        print('UnifiedMovieService: TMDB movie detail error: $e');
      }
    }
    
    return null;
  }

  /// Get popular movies (for compatibility)
  /// Get popular movies (Backend or TMDB)
  Future<List<Movie>> getPopularMovies({int page = 1, int limit = 10}) async {
    if (_useBackend) {
      try {
        final movies = await _backendService.getPopularMovies(limit: limit);
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Loaded ${movies.length} popular movies from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend popular movies failed, trying TMDB... ⚠️');
      }
    }
    
    // Fallback to TMDB
    return _getTMDBMovies('/movie/popular', page: page, limit: limit);
  }

  /// Get now playing movies (Backend or TMDB)
  Future<List<Movie>> getNowPlayingMovies({int page = 1, int limit = 10}) async {
    if (_useBackend) {
      try {
        final movies = await _backendService.getNowPlayingMovies(limit: limit);
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Loaded ${movies.length} now playing from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend now playing failed, trying TMDB... ⚠️');
      }
    }
    
    return _getTMDBMovies('/movie/now_playing', page: page, limit: limit);
  }

  /// Get upcoming movies (Backend or TMDB)
  Future<List<Movie>> getUpcomingMovies({int page = 1, int limit = 10}) async {
    if (_useBackend) {
      try {
        final movies = await _backendService.getUpcomingMovies(limit: limit);
        
        if (movies.isNotEmpty) {
          print('UnifiedMovieService: Loaded ${movies.length} upcoming from Backend ✅');
          return movies;
        }
      } catch (e) {
        print('UnifiedMovieService: Backend upcoming failed, trying TMDB... ⚠️');
      }
    }
    
    return _getTMDBMovies('/movie/upcoming', page: page, limit: limit);
  }

  // ========== TMDB Helper Methods (Private) ==========

  Future<List<Movie>> _getTMDBMovies(String endpoint, {int page = 1, int limit = 10}) async {
    try {
      final url = '$_tmdbBaseUrl$endpoint?api_key=$_tmdbApiKey&page=$page';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List).take(limit).toList();
        
        print('UnifiedMovieService: Loaded ${results.length} movies from TMDB (fallback) 🔄');
        
        return results.map((json) => _convertTMDBToMovie(json)).toList();
      }
    } catch (e) {
      print('UnifiedMovieService: TMDB error: $e');
    }
    
    return [];
  }

  Movie _convertTMDBToMovie(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['original_title'] ?? 'Unknown',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      mongoId: '', // TMDB movies don't have MongoDB ID
      videoUrl: '', // TMDB doesn't provide direct video URLs
      year: json['release_date'] != null && json['release_date'].toString().length >= 4
          ? int.tryParse(json['release_date'].toString().substring(0, 4)) ?? 0
          : 0,
      genre: [], // Will be populated from genreIds if needed
      isPro: false,
      views: 0,
      favoritesCount: 0,
    );
  }

  // ========== Configuration Methods ==========

  /// Enable/Disable backend usage
  void setUseBackend(bool value) {
    _useBackend = value;
    print('UnifiedMovieService: Backend usage ${value ? "enabled" : "disabled"}');
  }

  /// Check if backend is being used
  bool isUsingBackend() => _useBackend;
}
