import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_profile.dart';

/// Service for managing user profiles via backend API
class BackendUserService {
  /// Get user profile by Firebase UID
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final url = ApiConfig.getUserProfileUrl(userId);
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserProfile.fromJson(data['user']);
        }
      } else if (response.statusCode == 404) {
        // User not found, return null
        return null;
      }

      print('Failed to get user profile: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Create new user profile (called after Firebase registration)
  static Future<UserProfile?> createUser({
    required String firebaseUid,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.userCreate}';
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
        body: json.encode({
          'firebaseUid': firebaseUid,
          'email': email,
          'displayName': displayName ?? email.split('@')[0],
          'photoURL': photoURL,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserProfile.fromJson(data['user']);
        }
      }

      print('Failed to create user: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  /// Update user profile (create if doesn't exist - upsert)
  static Future<UserProfile?> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final url = ApiConfig.getUserProfileUrl(userId);
      final response = await http.put(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserProfile.fromJson(data['user']);
        }
      }

      print('Failed to update user profile: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  /// Get user statistics
  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final url = ApiConfig.getUserStatsUrl(userId);
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['stats'] != null) {
          return data['stats'] as Map<String, dynamic>;
        }
      }

      print('Failed to get user stats: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  /// Delete user profile
  static Future<bool> deleteUser(String userId) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.userDelete}/$userId';
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to delete user: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
