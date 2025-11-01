import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/tv_series_detail.dart';

class TvSeriesDetailService {
  // Get TV series detail by TMDB ID from Backend
  static Future<TvSeriesDetail?> getTvSeriesDetailByTmdbId(int tmdbId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/tv-series/tmdb/$tmdbId');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return TvSeriesDetail.fromJson(data['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching TV series detail by TMDB ID: $e');
      return null;
    }
  }

  // Get TV series detail by MongoDB ID from Backend
  static Future<TvSeriesDetail?> getTvSeriesDetailByMongoId(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/tv-series/$id');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return TvSeriesDetail.fromJson(data['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching TV series detail by Mongo ID: $e');
      return null;
    }
  }
}
