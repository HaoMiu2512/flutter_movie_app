import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendSearchService {
  // Use localhost for emulator, replace with your actual backend URL in production
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  /// Search multi (movies + TV series) with cache
  /// Searches MongoDB cache first, then falls back to TMDB if not found
  static Future<Map<String, dynamic>> searchMulti(
    String query, {
    bool forceRefresh = false,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Search query cannot be empty',
          'results': [],
          'total': 0,
        };
      }
      
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$baseUrl/search?query=$encodedQuery&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Search "$query" from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching: $e');
      rethrow;
    }
  }
  
  /// Search movies only with cache
  static Future<Map<String, dynamic>> searchMovies(
    String query, {
    bool forceRefresh = false,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Search query cannot be empty',
          'results': [],
          'total': 0,
        };
      }
      
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$baseUrl/search/movies?query=$encodedQuery&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Search movies "$query" from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching movies: $e');
      rethrow;
    }
  }
  
  /// Search TV series only with cache
  static Future<Map<String, dynamic>> searchTV(
    String query, {
    bool forceRefresh = false,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Search query cannot be empty',
          'results': [],
          'total': 0,
        };
      }
      
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$baseUrl/search/tv?query=$encodedQuery&forceRefresh=$forceRefresh');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Search TV "$query" from ${data['source']} (${data['total']} results)');
        return data;
      } else {
        throw Exception('Failed to search TV: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching TV: $e');
      rethrow;
    }
  }
}
