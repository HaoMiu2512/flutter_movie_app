import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/config/api_config.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';

class Upcoming extends StatefulWidget {
  const Upcoming({super.key});

  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  List<Map<String, dynamic>> getUpcomminglist = [];

  final String upcomingmoviesurl = '${ApiConfig.baseUrl}/api/movies/upcoming';

  Future<void> getUpcomming() async {
    // Clear list before loading to prevent duplicates
    getUpcomminglist.clear();

    // Try Backend API first
    try {
      var response = await http.get(Uri.parse(upcomingmoviesurl));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        
        // Check if Backend API response (check for 'data' field)
        if (json.containsKey('success') && json['success'] == true && json.containsKey('data')) {
          print('✅ Loading upcoming from Backend...');
          for (var i = 0; i < json['data'].length; i++) {
            getUpcomminglist.add({
              "poster_path": json['data'][i]['poster']?.replaceAll('https://image.tmdb.org/t/p/w500', '') ?? '',
              "name": json['data'][i]['title'],
              "vote_average": json['data'][i]['rating'] ?? json['data'][i]['voteAverage'],
              "date": json['data'][i]['releaseDate'] ?? json['data'][i]['year'],
              "id": json['data'][i]['tmdbId'] ?? json['data'][i]['id'],
            });
          }
          return; // Success - exit early
        }
      }
    } catch (e) {
      print('❌ Error loading upcoming from Backend: $e');
      print('⚠️  Falling back to TMDB...');
    }

    // Fallback to TMDB API
    var tmdbUrl = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$apikey';
    var url = Uri.parse(tmdbUrl);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      for (var i = 0; i < json['results'].length; i++) {
        getUpcomminglist.add({
          "poster_path": json['results'][i]['poster_path'],
          "name": json['results'][i]['title'],
          "vote_average": json['results'][i]['vote_average'],
          "date": json['results'][i]['release_date'],
          "id": json['results'][i]['id'],
        });
      }
    } else {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUpcomming(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sliderlist(
                getUpcomminglist,
                "Upcomming",
                "movie",
                getUpcomminglist.length,
                apiEndpoint: '/api/movies/upcoming',
                context: context,
                useBackendApi: true, // Use Backend API for View All
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 15, bottom: 40),
                child: Text("Many More Coming Soon... "),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator(color: Colors.cyan));
        }
      },
    );
  }
}
