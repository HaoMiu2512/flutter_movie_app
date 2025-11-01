import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendTVService {
  // Use localhost for emulator, replace with your actual backend URL in production
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  /// Get popular TV series with cache
  static Future<Map<String, dynamic>> getPopularTVSeries({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/tv-series/popular?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Popular TV from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load popular TV series: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching popular TV series: $e');
      rethrow;
    }
  }
  
  /// Get top rated TV series with cache
  static Future<Map<String, dynamic>> getTopRatedTVSeries({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/tv-series/top-rated?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Top rated TV from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load top rated TV series: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching top rated TV series: $e');
      rethrow;
    }
  }
  
  /// Get on the air TV series with cache (currently airing shows)
  static Future<Map<String, dynamic>> getOnTheAirTVSeries({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/tv-series/on-the-air?page=$page&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ On the air TV from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load on the air TV series: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching on the air TV series: $e');
      rethrow;
    }
  }
  
  /// Get TV series details with cache (includes seasons, cast, crew, videos)
  static Future<Map<String, dynamic>> getTVSeriesDetails(int tmdbId, {bool forceRefresh = false}) async {
    try {
      final url = Uri.parse('$baseUrl/tv-series/tmdb/$tmdbId?forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ TV series details from ${data['source']} for TMDB ID: $tmdbId');
        return data;
      } else {
        throw Exception('Failed to load TV series details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching TV series details: $e');
      rethrow;
    }
  }
  
  /// Get TV series videos with cache (trailers, teasers, etc.)
  static Future<Map<String, dynamic>> getTVSeriesVideos(int tmdbId, {bool forceRefresh = false}) async {
    try {
      final url = Uri.parse('$baseUrl/tv-series/tmdb/$tmdbId/videos?forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ TV series videos from ${data['source']} for TMDB ID: $tmdbId');
        return data;
      } else {
        throw Exception('Failed to load TV series videos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching TV series videos: $e');
      rethrow;
    }
  }
}
