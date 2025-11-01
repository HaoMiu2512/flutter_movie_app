import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';
import 'package:flutter_movie_app/config/api_config.dart';

class TvSeries extends StatefulWidget {
  const TvSeries({super.key});

  @override
  State<TvSeries> createState() => _TvSeriesState();
}

class _TvSeriesState extends State<TvSeries> {
  List<Map<String, dynamic>> populartvseries = [];
  List<Map<String, dynamic>> topratedtvseries = [];
  List<Map<String, dynamic>> ontheairtvseries = [];

  // Use Backend API for Popular, Top Rated, and On The Air TV Series
  var populartvseriesurl = '/api/tv-series';
  var topratedtvseriesurl = '/api/tv-series/top-rated';
  var ontheairtvseriesurl = '/api/tv-series/on-the-air';

  Future<void> tvseriesfunction() async {
    // Clear lists before loading to prevent duplicates
    populartvseries.clear();
    topratedtvseries.clear();
    ontheairtvseries.clear();
    
    // Load Popular TV Series from Backend with fallback to TMDB
    try {
      print('📺 Loading Popular TV Series from Backend...');
      var backendUrl = '${ApiConfig.baseUrl}$populartvseriesurl';
      var response = await http.get(Uri.parse(backendUrl));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Loaded ${data['data'].length} popular TV series from Backend');
          for (var series in data['data']) {
            populartvseries.add({
              'name': series['name'],
              'poster_path': series['posterPath']?.replaceAll('https://image.tmdb.org/t/p/w500', '') ?? '',
              'vote_average': series['voteAverage'],
              'date': series['firstAirDate'],
              'id': series['tmdbId'],
            });
          }
        } else {
          throw Exception('Backend response not successful');
        }
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Backend failed for Popular TV Series, using TMDB fallback: $e');
      var tmdbUrl = 'https://api.themoviedb.org/3/tv/popular?api_key=$apikey';
      var response = await http.get(Uri.parse(tmdbUrl));
      if (response.statusCode == 200) {
        var tempdata = jsonDecode(response.body);
        var populartvjson = tempdata['results'];
        for (var i = 0; i < populartvjson.length; i++) {
          populartvseries.add({
            'name': populartvjson[i]['name'],
            'poster_path': populartvjson[i]['poster_path'],
            'vote_average': populartvjson[i]['vote_average'],
            'date': populartvjson[i]['first_air_date'],
            'id': populartvjson[i]['id'],
          });
        }
      }
    }

    // Load Top Rated TV Series from Backend with fallback to TMDB
    try {
      print('📺 Loading Top Rated TV Series from Backend...');
      var backendUrl = '${ApiConfig.baseUrl}$topratedtvseriesurl';
      var response = await http.get(Uri.parse(backendUrl));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Loaded ${data['data'].length} top rated TV series from Backend');
          for (var series in data['data']) {
            topratedtvseries.add({
              'name': series['name'],
              'poster_path': series['posterPath']?.replaceAll('https://image.tmdb.org/t/p/w500', '') ?? '',
              'vote_average': series['voteAverage'],
              'date': series['firstAirDate'],
              'id': series['tmdbId'],
            });
          }
        } else {
          throw Exception('Backend response not successful');
        }
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Backend failed for Top Rated TV Series, using TMDB fallback: $e');
      var tmdbUrl = 'https://api.themoviedb.org/3/tv/top_rated?api_key=$apikey';
      var response = await http.get(Uri.parse(tmdbUrl));
      if (response.statusCode == 200) {
        var tempdata = jsonDecode(response.body);
        var topratedtvjson = tempdata['results'];
        for (var i = 0; i < topratedtvjson.length; i++) {
          topratedtvseries.add({
            'name': topratedtvjson[i]['name'],
            'poster_path': topratedtvjson[i]['poster_path'],
            'vote_average': topratedtvjson[i]['vote_average'],
            'date': topratedtvjson[i]['first_air_date'],
            'id': topratedtvjson[i]['id'],
          });
        }
      }
    }

    // Load On The Air TV Series from Backend with fallback to TMDB
    try {
      print('📺 Loading On The Air TV Series from Backend...');
      var backendUrl = '${ApiConfig.baseUrl}$ontheairtvseriesurl';
      var response = await http.get(Uri.parse(backendUrl));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Loaded ${data['data'].length} on the air TV series from Backend');
          for (var series in data['data']) {
            ontheairtvseries.add({
              'name': series['name'],
              'poster_path': series['posterPath']?.replaceAll('https://image.tmdb.org/t/p/w500', '') ?? '',
              'vote_average': series['voteAverage'],
              'date': series['firstAirDate'],
              'id': series['tmdbId'],
            });
          }
        } else {
          throw Exception('Backend response not successful');
        }
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Backend failed for On The Air TV Series, using TMDB fallback: $e');
      var tmdbUrl = 'https://api.themoviedb.org/3/tv/on_the_air?api_key=$apikey';
      var response = await http.get(Uri.parse(tmdbUrl));
      if (response.statusCode == 200) {
        var tempdata = jsonDecode(response.body);
        var ontheairtvjson = tempdata['results'];
        for (var i = 0; i < ontheairtvjson.length; i++) {
          ontheairtvseries.add({
            'name': ontheairtvjson[i]['name'],
            'poster_path': ontheairtvjson[i]['poster_path'],
            'vote_average': ontheairtvjson[i]['vote_average'],
            'date': ontheairtvjson[i]['first_air_date'],
            'id': ontheairtvjson[i]['id'],
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tvseriesfunction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.cyan.shade400),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              sliderlist(
                populartvseries,
                "Popular TV Series",
                "tv",
                populartvseries.length,
                apiEndpoint: populartvseriesurl,
                context: context,
                useBackendApi: true,
              ),
              sliderlist(
                topratedtvseries,
                "Top Rated TV Series",
                "tv",
                topratedtvseries.length,
                apiEndpoint: topratedtvseriesurl,
                context: context,
                useBackendApi: true,
              ),
              sliderlist(
                ontheairtvseries,
                "On The Air TV Series",
                "tv",
                ontheairtvseries.length,
                apiEndpoint: ontheairtvseriesurl,
                context: context,
                useBackendApi: true, // Now using Backend API!
              ),
            ],
          );
        }
      },
    );
  }
}
