import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Service for uploading files to backend
class BackendUploadService {
  /// Upload avatar image
  static Future<Map<String, dynamic>?> uploadAvatar({
    required File imageFile,
    required String userId,
    String? oldAvatarPath,
  }) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.uploadAvatar}';
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'avatar',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
      
      // Add userId field
      request.fields['userId'] = userId;
      
      // Add oldAvatarPath if exists (for deletion)
      if (oldAvatarPath != null && oldAvatarPath.isNotEmpty) {
        request.fields['oldAvatarPath'] = oldAvatarPath;
      }
      
      // Send request
      print('Uploading avatar for user: $userId');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('Avatar uploaded successfully');
          return data['data'] as Map<String, dynamic>;
        }
      }

      print('Failed to upload avatar: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Delete avatar image
  static Future<bool> deleteAvatar(String filename) async {
    try {
      final url = '${ApiConfig.apiBaseUrl}${ApiConfig.uploadAvatarDelete}/$filename';
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      print('Failed to delete avatar: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error deleting avatar: $e');
      return false;
    }
  }

  /// Get avatar URL from filename
  static String getAvatarUrl(String filename) {
    return ApiConfig.getAvatarUrl(filename);
  }

  /// Get avatar URL from path (extracts filename)
  static String? getAvatarUrlFromPath(String? path) {
    if (path == null || path.isEmpty) return null;
    
    // If it's already a full URL, return it
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Extract filename from path like "/uploads/avatars/filename.jpg"
    final filename = path.split('/').last;
    return ApiConfig.getAvatarUrl(filename);
  }
}
