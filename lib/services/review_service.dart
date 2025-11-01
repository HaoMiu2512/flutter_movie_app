import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../config/api_config.dart';

class ReviewService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Get reviews for a media
  static Future<Map<String, dynamic>> getReviews({
    required String mediaType,
    required int mediaId,
    int page = 1,
    int limit = 10,
    String sortBy = 'newest', // newest, oldest, mostHelpful, sentiment
    String? sentiment, // Filter by specific sentiment
  }) async {
    try {
      var queryParams = 'page=$page&limit=$limit&sortBy=$sortBy';
      if (sentiment != null) {
        queryParams += '&sentiment=$sentiment';
      }
      
      final uri = Uri.parse(
          '$baseUrl/api/reviews/$mediaType/$mediaId?$queryParams');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          final reviews = (data['data'] as List)
              .map((reviewJson) => Review.fromJson(reviewJson))
              .toList();
          
          return {
            'success': true,
            'reviews': reviews,
            'pagination': data['pagination'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to load reviews',
        'reviews': <Review>[],
      };
    } catch (e) {
      print('Error getting reviews: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'reviews': <Review>[],
      };
    }
  }

  // Get user's review for a media
  static Future<Review?> getUserReview({
    required String mediaType,
    required int mediaId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/api/reviews/$mediaType/$mediaId/user/$userId');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return Review.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error getting user review: $e');
      return null;
    }
  }

  // Create a review
  static Future<Map<String, dynamic>> createReview({
    required String mediaType,
    required int mediaId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String sentiment,
    required String title,
    required String text,
    bool containsSpoilers = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/$mediaType/$mediaId');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'userName': userName,
          'userPhotoUrl': userPhotoUrl,
          'sentiment': sentiment,
          'title': title,
          'text': text,
          'containsSpoilers': containsSpoilers,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return {
            'success': true,
            'review': Review.fromJson(data['data']),
            'message': data['message'],
          };
        }
      }

      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Failed to post review',
      };
    } catch (e) {
      print('Error creating review: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Update a review
  static Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required String userId,
    String? sentiment,
    String? title,
    String? text,
    bool? containsSpoilers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/$reviewId');
      
      final Map<String, dynamic> body = {'userId': userId};
      if (sentiment != null) body['sentiment'] = sentiment;
      if (title != null) body['title'] = title;
      if (text != null) body['text'] = text;
      if (containsSpoilers != null) body['containsSpoilers'] = containsSpoilers;
      
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return {
            'success': true,
            'review': Review.fromJson(data['data']),
            'message': data['message'],
          };
        }
      }

      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Failed to update review',
      };
    } catch (e) {
      print('Error updating review: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Delete a review
  static Future<Map<String, dynamic>> deleteReview({
    required String reviewId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/$reviewId');
      
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
        'message': 'Failed to delete review',
      };
    } catch (e) {
      print('Error deleting review: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Vote on a review
  static Future<Map<String, dynamic>> voteReview({
    required String reviewId,
    required String userId,
    required String voteType, // 'helpful' or 'unhelpful'
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/$reviewId/vote');
      
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'voteType': voteType,
        }),
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
        'message': 'Failed to update vote',
      };
    } catch (e) {
      print('Error voting on review: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get review statistics
  static Future<ReviewStats?> getReviewStats({
    required String mediaType,
    required int mediaId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/$mediaType/$mediaId/stats');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success']) {
          return ReviewStats.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error getting review stats: $e');
      return null;
    }
  }
}
