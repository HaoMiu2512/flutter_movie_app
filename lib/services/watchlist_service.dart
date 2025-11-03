import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/watchlist.dart';

/// Service for managing watchlists via backend API
class WatchlistService {
  /// Get Firebase auth token
  static Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  /// Get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all watchlists for current user
  static Future<List<Watchlist>> getUserWatchlists() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> watchlistsJson = data['data'];
          return watchlistsJson.map((json) => Watchlist.fromJson(json)).toList();
        }
      }

      print('Failed to get watchlists: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error getting watchlists: $e');
      return [];
    }
  }

  /// Get a specific watchlist
  static Future<Watchlist?> getWatchlist(String watchlistId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists/$watchlistId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('🔵 Getting watchlist $watchlistId...');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Watchlist data: ${data['data']}');
          return Watchlist.fromJson(data['data']);
        }
      }

      print('Failed to get watchlist: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting watchlist: $e');
      return null;
    }
  }

  /// Create a new watchlist
  static Future<Watchlist?> createWatchlist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists';
      
      print('🔵 Creating watchlist...');
      print('URL: $url');
      print('Name: $name');
      print('Headers: $headers');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'name': name,
          'description': description ?? '',
          'isPublic': isPublic,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Watchlist created successfully');
          return Watchlist.fromJson(data['data']);
        }
      }

      print('❌ Failed to create watchlist: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('❌ Error creating watchlist: $e');
      return null;
    }
  }

  /// Update a watchlist
  static Future<Watchlist?> updateWatchlist({
    required String watchlistId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists/$watchlistId';
      
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (isPublic != null) body['isPublic'] = isPublic;

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Watchlist.fromJson(data['data']);
        }
      }

      print('Failed to update watchlist: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error updating watchlist: $e');
      return null;
    }
  }

  /// Delete a watchlist
  static Future<bool> deleteWatchlist(String watchlistId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists/$watchlistId';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to delete watchlist: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error deleting watchlist: $e');
      return false;
    }
  }

  /// Add item to watchlist
  static Future<bool> addItemToWatchlist({
    required String watchlistId,
    required String itemId,
    required String itemType,
    required String title,
    String? posterPath,
    String? backdropPath,
    String? overview,
    String? releaseDate,
    double? voteAverage,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists/$watchlistId/items';
      
      final requestBody = {
        'itemId': itemId,
        'itemType': itemType,
        'title': title,
        'posterPath': posterPath,
        'backdropPath': backdropPath,
        'overview': overview,
        'releaseDate': releaseDate,
        'voteAverage': voteAverage,
      };
      
      print('🔵 Adding item to watchlist...');
      print('Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to add item to watchlist: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error adding item to watchlist: $e');
      return false;
    }
  }

  /// Remove item from watchlist
  static Future<bool> removeItemFromWatchlist({
    required String watchlistId,
    required String itemId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists/$watchlistId/items/$itemId';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to remove item from watchlist: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error removing item from watchlist: $e');
      return false;
    }
  }

  /// Check if item is in any watchlist
  static Future<WatchlistCheckResult?> checkItemInWatchlists({
    required String itemId,
    required String itemType,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/watchlists/check?itemId=$itemId&itemType=$itemType';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return WatchlistCheckResult.fromJson(data['data']);
        }
      }

      print('Failed to check item in watchlists: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error checking item in watchlists: $e');
      return null;
    }
  }
}
