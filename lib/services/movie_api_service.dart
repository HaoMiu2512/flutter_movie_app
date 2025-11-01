import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../config/api_config.dart';

class MovieApiService {
  // Singleton pattern
  static final MovieApiService _instance = MovieApiService._internal();
  factory MovieApiService() => _instance;
  MovieApiService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get Firebase auth token
  Future<String?> _getAuthToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Get headers with optional authorization
  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requireAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Get all movies with pagination and filters
  Future<List<Movie>> getMovies({
    int page = 1,
    int limit = 10,
    String? genre,
    int? year,
    bool? isPro,
    String sort = '-createdAt',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        if (genre != null) 'genre': genre,
        if (year != null) 'year': year.toString(),
        if (isPro != null) 'isPro': isPro.toString(),
      };

      final uri = Uri.parse(ApiConfig.moviesUrl).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error fetching movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }

  // Get movie by ID
  Future<Movie?> getMovieById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.movieDetailUrl(id)),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Movie.fromBackendApi(data['data']);
        }
      }

      print('Error fetching movie detail: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching movie detail: $e');
      return null;
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query, {int page = 1, int limit = 10}) async {
    try {
      final uri = Uri.parse(ApiConfig.searchUrl).replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error searching movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  // Get trending movies
  Future<List<Movie>> getTrendingMovies({int limit = 10}) async {
    try {
      final uri = Uri.parse(ApiConfig.trendingUrl).replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error fetching trending movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching trending movies: $e');
      return [];
    }
  }

  // Get popular movies
  Future<List<Movie>> getPopularMovies({int limit = 10}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/movies/popular').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('MovieApiService: Loaded ${(data['data'] as List).length} popular movies from /api/movies/popular');
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error fetching popular movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching popular movies: $e');
      return [];
    }
  }

  // Get top rated movies
  Future<List<Movie>> getTopRatedMovies({int limit = 10}) async {
    try {
      final uri = Uri.parse(ApiConfig.topRatedUrl).replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error fetching top rated movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching top rated movies: $e');
      return [];
    }
  }

  // Get now playing movies
  Future<List<Movie>> getNowPlayingMovies({int limit = 10}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/movies/now-playing').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error fetching now playing movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching now playing movies: $e');
      return [];
    }
  }

  // Get upcoming movies
  Future<List<Movie>> getUpcomingMovies({int limit = 10}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/movies/upcoming').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Movie.fromBackendApi(json))
              .toList();
        }
      }

      print('Error fetching upcoming movies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching upcoming movies: $e');
      return [];
    }
  }
}
