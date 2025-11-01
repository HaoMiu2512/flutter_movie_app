import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/favorite.dart';

/// Service for managing favorites via backend API
class BackendFavoritesService {
  /// Get all favorites for a user
  static Future<List<Favorite>> getUserFavorites(
    String userId, {
    String? mediaType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = ApiConfig.getFavoritesUrl(
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
        if (data['success'] == true && data['favorites'] != null) {
          final List<dynamic> favoritesJson = data['favorites'];
          return favoritesJson.map((json) => Favorite.fromJson(json)).toList();
        }
      }

      print('Failed to get favorites: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  /// Add to favorites
  static Future<bool> addFavorite({
    required String userId,
    required String mediaType,
    required int mediaId,
    required String title,
    String? posterPath,
    String? backdropPath,
    String? overview,
    double? rating,
    String? releaseDate,
    List<String>? genres,
  }) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.favorites}';
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
          'genres': genres,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to add favorite: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  /// Remove favorite by ID
  static Future<bool> removeFavorite(String favoriteId) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.favorites}/$favoriteId';
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to remove favorite: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  /// Remove favorite by media ID
  static Future<bool> removeFavoriteByMedia({
    required String userId,
    required String mediaType,
    required int mediaId,
  }) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.favoritesRemove}';
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
        body: json.encode({
          'userId': userId,
          'mediaType': mediaType,
          'mediaId': mediaId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to remove favorite by media: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error removing favorite by media: $e');
      return false;
    }
  }

  /// Check if media is favorited
  static Future<bool> isFavorite({
    required String userId,
    required String mediaType,
    required int mediaId,
  }) async {
    try {
      final url = ApiConfig.getCheckFavoriteUrl(userId, mediaType, mediaId);
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['isFavorite'] == true;
        }
      }

      print('Failed to check favorite: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  /// Clear all favorites for a user
  static Future<bool> clearAllFavorites(String userId) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.favoritesClear}/$userId';
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to clear favorites: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  /// Get favorite movies only
  static Future<List<Favorite>> getFavoriteMovies(String userId) async {
    return getUserFavorites(userId, mediaType: 'movie');
  }

  /// Get favorite TV shows only
  static Future<List<Favorite>> getFavoriteTVShows(String userId) async {
    return getUserFavorites(userId, mediaType: 'tv');
  }
}
