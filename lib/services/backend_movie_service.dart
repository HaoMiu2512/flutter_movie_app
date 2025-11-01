import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendMovieService {
  // Use localhost for emulator, replace with your actual backend URL in production
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  /// Get popular movies with cache
  /// Returns cached data if available, otherwise fetches from TMDB
  static Future<Map<String, dynamic>> getPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/movies/popular?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Popular movies from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching popular movies: $e');
      rethrow;
    }
  }
  
  /// Get top rated movies with cache
  static Future<Map<String, dynamic>> getTopRatedMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/movies/top-rated?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Top rated movies from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load top rated movies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching top rated movies: $e');
      rethrow;
    }
  }
  
  /// Get upcoming movies with cache
  static Future<Map<String, dynamic>> getUpcomingMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/movies/upcoming?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Upcoming movies from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load upcoming movies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching upcoming movies: $e');
      rethrow;
    }
  }
  
  /// Get now playing movies with cache
  static Future<Map<String, dynamic>> getNowPlayingMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/movies/now-playing?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Now playing movies from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load now playing movies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching now playing movies: $e');
      rethrow;
    }
  }
  
  /// Get movie details with cache (includes cast, crew, videos, production companies)
  static Future<Map<String, dynamic>> getMovieDetails(int tmdbId, {bool forceRefresh = false}) async {
    try {
      final url = Uri.parse('$baseUrl/movies/tmdb/$tmdbId?forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Movie details from ${data['source']} for TMDB ID: $tmdbId');
        return data;
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching movie details: $e');
      rethrow;
    }
  }
  
  /// Get movie videos with cache (trailers, teasers, etc.)
  static Future<Map<String, dynamic>> getMovieVideos(int tmdbId, {bool forceRefresh = false}) async {
    try {
      final url = Uri.parse('$baseUrl/movies/tmdb/$tmdbId/videos?forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Movie videos from ${data['source']} for TMDB ID: $tmdbId');
        return data;
      } else {
        throw Exception('Failed to load movie videos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching movie videos: $e');
      rethrow;
    }
  }
}
