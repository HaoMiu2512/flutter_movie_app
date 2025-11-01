import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recently_viewed.dart';

/// Service for managing recently viewed items via backend API
class BackendRecentlyViewedService {
  /// Get recently viewed items for a user
  static Future<List<RecentlyViewed>> getRecentlyViewed(
    String userId, {
    String? mediaType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = ApiConfig.getRecentlyViewedUrl(
        userId,
        mediaType: mediaType,
        page: page,
        limit: limit,
      );
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['recentlyViewed'] != null) {
          final List<dynamic> recentlyViewedJson = data['recentlyViewed'];
          return recentlyViewedJson
              .map((json) => RecentlyViewed.fromJson(json))
              .toList();
        }
      }

      print('Failed to get recently viewed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error getting recently viewed: $e');
      return [];
    }
  }

  /// Track a view (create or update)
  static Future<bool> trackView({
    required String userId,
    required String mediaType,
    required int mediaId,
    required String title,
    String? posterPath,
    String? backdropPath,
    String? overview,
    double? rating,
    String? releaseDate,
    int? watchProgress,
    int? lastWatchPosition,
  }) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.recentlyViewed}';
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
        body: json.encode({
          'userId': userId,
          'mediaType': mediaType,
          'mediaId': mediaId,
          'title': title,
          'posterPath': posterPath,
          'backdropPath': backdropPath,
          'overview': overview,
          'rating': rating,
          'releaseDate': releaseDate,
          'watchProgress': watchProgress,
          'lastWatchPosition': lastWatchPosition,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to track view: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error tracking view: $e');
      return false;
    }
  }

  /// Remove a single recently viewed item
  static Future<bool> removeRecentlyViewed(String recentlyViewedId) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.recentlyViewed}/$recentlyViewedId';
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to remove recently viewed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error removing recently viewed: $e');
      return false;
    }
  }

  /// Clear all recently viewed for a user
  static Future<bool> clearRecentlyViewed(String userId) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.recentlyViewedClear}/$userId';
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to clear recently viewed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error clearing recently viewed: $e');
      return false;
    }
  }

  /// Get watch progress for a specific media
  static Future<Map<String, dynamic>?> getWatchProgress({
    required String userId,
    required String mediaType,
    required int mediaId,
  }) async {
    try {
      final url = ApiConfig.getWatchProgressUrl(userId, mediaType, mediaId);
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['progress'] != null) {
          return data['progress'] as Map<String, dynamic>;
        }
      }

      print('Failed to get watch progress: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting watch progress: $e');
      return null;
    }
  }

  /// Get recently viewed movies only
  static Future<List<RecentlyViewed>> getRecentlyViewedMovies(String userId) async {
    return getRecentlyViewed(userId, mediaType: 'movie');
  }

  /// Get recently viewed TV shows only
  static Future<List<RecentlyViewed>> getRecentlyViewedTVShows(String userId) async {
    return getRecentlyViewed(userId, mediaType: 'tv');
  }
}
