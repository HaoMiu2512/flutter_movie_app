import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import '../config/api_config.dart';

class CommentService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Get comments for a media
  static Future<Map<String, dynamic>> getComments({
    required String mediaType,
    required int mediaId,
    int page = 1,
    int limit = 20,
    String sortBy = 'newest', // newest, oldest, mostLiked
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/api/comments/$mediaType/$mediaId?page=$page&limit=$limit&sortBy=$sortBy');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          final comments = (data['data'] as List)
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList();
          
          return {
            'success': true,
            'comments': comments,
            'pagination': data['pagination'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to load comments',
        'comments': <Comment>[],
      };
    } catch (e) {
      print('Error getting comments: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'comments': <Comment>[],
      };
    }
  }

  // Get replies for a comment
  static Future<Map<String, dynamic>> getReplies({
    required String commentId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/api/comments/$commentId/replies?page=$page&limit=$limit');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          final replies = (data['data'] as List)
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList();
          
          return {
            'success': true,
            'replies': replies,
            'pagination': data['pagination'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to load replies',
        'replies': <Comment>[],
      };
    } catch (e) {
      print('Error getting replies: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'replies': <Comment>[],
      };
    }
  }

  // Create a comment
  static Future<Map<String, dynamic>> createComment({
    required String mediaType,
    required int mediaId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/comments/$mediaType/$mediaId');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'userName': userName,
          'userPhotoUrl': userPhotoUrl,
          'text': text,
          'parentCommentId': parentCommentId,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return {
            'success': true,
            'comment': Comment.fromJson(data['data']),
            'message': data['message'],
          };
        }
      }

      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Failed to post comment',
      };
    } catch (e) {
      print('Error creating comment: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Like/unlike a comment
  static Future<Map<String, dynamic>> likeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/comments/$commentId/like');
      
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return {
            'success': true,
            'data': data['data'],
            'message': data['message'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to update like',
      };
    } catch (e) {
      print('Error liking comment: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Delete a comment
  static Future<Map<String, dynamic>> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/comments/$commentId');
      
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return {
            'success': true,
            'message': data['message'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to delete comment',
      };
    } catch (e) {
      print('Error deleting comment: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get comment statistics
  static Future<CommentStats?> getCommentStats({
    required String mediaType,
    required int mediaId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/comments/$mediaType/$mediaId/stats');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return CommentStats.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error getting comment stats: $e');
      return null;
    }
  }
}
