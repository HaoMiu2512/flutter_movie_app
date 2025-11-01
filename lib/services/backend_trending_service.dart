import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendTrendingService {
  // Use localhost for emulator, replace with your actual backend URL in production
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  /// Get all trending (movies + TV series) with cache
  /// [timeWindow] can be 'day' or 'week'
  static Future<Map<String, dynamic>> getTrending({
    String timeWindow = 'week',
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/trending?timeWindow=$timeWindow&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Trending ($timeWindow) from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load trending: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching trending: $e');
      rethrow;
    }
  }
  
  /// Get trending movies only with cache
  /// [timeWindow] can be 'day' or 'week'
  static Future<Map<String, dynamic>> getTrendingMovies({
    String timeWindow = 'week',
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/trending/movies?timeWindow=$timeWindow&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Trending movies ($timeWindow) from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load trending movies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching trending movies: $e');
      rethrow;
    }
  }
  
  /// Get trending TV series only with cache
  /// [timeWindow] can be 'day' or 'week'
  static Future<Map<String, dynamic>> getTrendingTV({
    String timeWindow = 'week',
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/trending/tv?timeWindow=$timeWindow&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Trending TV ($timeWindow) from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to load trending TV: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching trending TV: $e');
      rethrow;
    }
  }
}
