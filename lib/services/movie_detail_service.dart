import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/movie_detail.dart';

class MovieDetailService {
  // Get movie details from Backend API by TMDB ID
  static Future<MovieDetail?> getMovieDetailByTmdbId(int tmdbId) async {
    try {
      print('🔍 Fetching movie details from Backend API for TMDB ID: $tmdbId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}/api/movies/tmdb/$tmdbId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          print('✅ Loaded movie details from Backend');
          return MovieDetail.fromJson(jsonData['data']);
        } else {
          print('⚠️  Backend returned success=false');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('⚠️  Movie not found in Backend (404)');
        return null;
      } else {
        print('⚠️  Backend error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching movie details from Backend: $e');
      return null;
    }
  }

  // Get movie details from Backend API by MongoDB ID
  static Future<MovieDetail?> getMovieDetailByMongoId(String mongoId) async {
    try {
      print('🔍 Fetching movie details from Backend API for Mongo ID: $mongoId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}/api/movies/$mongoId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          print('✅ Loaded movie details from Backend');
          return MovieDetail.fromJson(jsonData['data']);
        } else {
          print('⚠️  Backend returned success=false');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('⚠️  Movie not found in Backend (404)');
        return null;
      } else {
        print('⚠️  Backend error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching movie details from Backend: $e');
      return null;
    }
  }
}
