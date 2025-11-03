import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/config/api_config.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';
import 'package:flutter_movie_app/main_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_movie_app/reapeatedfunction/trailerui.dart';
import 'package:flutter_movie_app/reapeatedfunction/discussion_tabs.dart';
import 'package:flutter_movie_app/services/backend_favorites_service.dart';
import 'package:flutter_movie_app/services/backend_recently_viewed_service.dart';
import 'package:flutter_movie_app/services/movie_detail_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_movie_app/widgets/custom_snackbar.dart';
import 'package:flutter_movie_app/widgets/add_to_list_button.dart';

class MoviesDetail extends StatefulWidget {
  var id;
  MoviesDetail({super.key, this.id});

  @override
  State<MoviesDetail> createState() => _MoviesDetailState();
}

class _MoviesDetailState extends State<MoviesDetail> {
  List<Map<String, dynamic>> MovieDetails = [];
  List<Map<String, dynamic>> similarmovieslist = [];
  List<Map<String, dynamic>> recommendedmovieslist = [];
  List<Map<String, dynamic>> movietrailerslist = [];

  List MoviesGeneres = [];

  // Favorites
  bool _isFavorite = false;
  bool _isLoading = true;
  
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Helper method to check if video type is acceptable for playback
  bool _isAcceptableVideoType(String type) {
    // Accept trailers first, then teasers, clips, and featurettes
    const acceptableTypes = ['Trailer', 'Teaser', 'Clip', 'Featurette'];
    return acceptableTypes.contains(type);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Moviedetails();
    await _checkFavoriteStatus();
    await _addToRecentlyViewed();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addToRecentlyViewed() async {
    if (MovieDetails.isEmpty || currentUser == null) {
      print('MoviesDetail: Cannot add to recently viewed - MovieDetails is empty or user not logged in');
      return;
    }

    try {
      final movieId = widget.id is int ? widget.id : int.parse(widget.id.toString());
      final title = MovieDetails[0]['title'] ?? 'Unknown';
      final posterPath = MovieDetails[0]['poster_path'] ?? MovieDetails[0]['backdrop_path'] ?? '';
      final overview = MovieDetails[0]['overview'] ?? '';
      final voteAverage = (MovieDetails[0]['vote_average'] as num?)?.toDouble() ?? 0.0;
      final releaseDate = MovieDetails[0]['release_date'] ?? '';
      final backdropPath = MovieDetails[0]['backdrop_path'] ?? '';

      print('MoviesDetail: Tracking view - $title');
      
      final success = await BackendRecentlyViewedService.trackView(
        userId: currentUser!.uid,
        mediaType: 'movie',
        mediaId: movieId,
        title: title,
        posterPath: posterPath,
        backdropPath: backdropPath,
        overview: overview,
        rating: voteAverage,
        releaseDate: releaseDate,
      );
      
      print('MoviesDetail: Track view result: $success');
    } catch (e) {
      print('MoviesDetail: Error tracking view: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (currentUser == null) return;
    
    final movieId = widget.id is int ? widget.id : int.parse(widget.id.toString());
    final isFav = await BackendFavoritesService.isFavorite(
      userId: currentUser!.uid,
      mediaType: 'movie',
      mediaId: movieId,
    );
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (MovieDetails.isEmpty || currentUser == null) return;

    final movieId = widget.id is int ? widget.id : int.parse(widget.id.toString());

    if (_isFavorite) {
      // Remove from favorites
      await BackendFavoritesService.removeFavoriteByMedia(
        userId: currentUser!.uid,
        mediaType: 'movie',
        mediaId: movieId,
      );
    } else {
      // Add to favorites
      await BackendFavoritesService.addFavorite(
        userId: currentUser!.uid,
        mediaType: 'movie',
        mediaId: movieId,
        title: MovieDetails[0]['title'] ?? '',
        posterPath: MovieDetails[0]['poster_path'] ?? MovieDetails[0]['backdrop_path'] ?? '',
        backdropPath: MovieDetails[0]['backdrop_path'] ?? '',
        overview: MovieDetails[0]['overview'] ?? '',
        rating: (MovieDetails[0]['vote_average'] as num?)?.toDouble() ?? 0.0,
        releaseDate: MovieDetails[0]['release_date'] ?? '',
      );
    }

    await _checkFavoriteStatus();

    if (mounted) {
      CustomSnackBar.showSuccess(
        context,
        _isFavorite ? 'Added to favorites' : 'Removed from favorites',
      );
    }
  }

  Future<void> _shareMovie() async {
    if (MovieDetails.isEmpty) return;

    final movieId = widget.id is int ? widget.id : int.parse(widget.id.toString());
    final title = MovieDetails[0]['title'];
    final rating = MovieDetails[0]['vote_average'];
    final overview = MovieDetails[0]['overview'];

    // TMDB movie link
    final movieLink = 'https://www.themoviedb.org/movie/$movieId';

    // Share text
    final shareText = '''
🎬 $title

⭐ Rating: $rating/10

📝 $overview

🔗 View more: $movieLink

Shared from Flick Movie App
''';

    // Show bottom sheet with share options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1929),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.cyan[300], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Share Movie',
                    style: TextStyle(
                      color: Colors.cyan[300],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Copy Link option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.link, color: Colors.blue, size: 24),
              ),
              title: const Text(
                'Copy Link',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                movieLink,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                Navigator.pop(context);
                await _copyMovieLink();
              },
            ),
            Divider(color: Colors.grey[800], height: 1),
            // Share via apps option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share, color: Colors.green, size: 24),
              ),
              title: const Text(
                'Share via...',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'WhatsApp, Messenger, Email, etc.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await Share.share(
                    shareText,
                    subject: 'Check out this movie: $title',
                  );
                } catch (e) {
                  print('Error sharing: $e');
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _copyMovieLink() async {
    if (MovieDetails.isEmpty) return;

    final movieId = widget.id is int ? widget.id : int.parse(widget.id.toString());
    final movieLink = 'https://www.themoviedb.org/movie/$movieId';

    try {
      await Clipboard.setData(ClipboardData(text: movieLink));

      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Link copied!',
        );
      }
    } catch (e) {
      print('Error copying link: $e');
    }
  }

  Future Moviedetails() async {
    // Try Backend API first
    try {
      print('🎬 Loading movie details from Backend API...');
      final movieDetail = await MovieDetailService.getMovieDetailByTmdbId(
        widget.id is int ? widget.id : int.parse(widget.id.toString()),
      );

      if (movieDetail != null) {
        print('✅ Loaded from Backend! Title: ${movieDetail.title}');
        
        // Populate MovieDetails from Backend
        MovieDetails.add({
          "backdrop_path": movieDetail.poster.replaceAll('https://image.tmdb.org/t/p/w500', ''),
          "poster_path": movieDetail.poster.replaceAll('https://image.tmdb.org/t/p/w500', ''),
          "title": movieDetail.title,
          "vote_average": movieDetail.rating,
          "overview": movieDetail.overview,
          "release_date": movieDetail.year.toString(),
          "runtime": movieDetail.runtime,
          "budget": movieDetail.budget,
          "revenue": movieDetail.revenue,
        });

        // Populate genres
        MoviesGeneres.addAll(movieDetail.genre);

        // Note: For now, keep UserReviews and similar/recommended from TMDB
        // as Backend doesn't store these yet
        
        // Load additional data from TMDB (reviews, similar, recommended)
        await _loadAdditionalDataFromTMDB();
        
        return;
      } else {
        print('⚠️  Movie not found in Backend, falling back to TMDB...');
      }
    } catch (e) {
      print('❌ Error loading from Backend: $e');
      print('⚠️  Falling back to TMDB...');
    }

    // Fallback to original TMDB API
    var moviedetailurl =
        'https://api.themoviedb.org/3/movie/${widget.id}?api_key=$apikey';
    
    // Try Backend API first for similar/recommended, fallback to TMDB
    var similarmoviesurl = '${ApiConfig.baseUrl}/api/similar';
    var similarmoviesurl_tmdb =
        'https://api.themoviedb.org/3/movie/${widget.id}/similar?api_key=$apikey';
    var recommendedmoviesurl = '${ApiConfig.baseUrl}/api/recommended';
    var recommendedmoviesurl_tmdb =
        'https://api.themoviedb.org/3/movie/${widget.id}/recommendations?api_key=$apikey';
    
    // Try Backend API first for videos, fallback to TMDB
    var movietrailersurl = '${ApiConfig.baseUrl}/api/movies/tmdb/${widget.id}/videos';

    var moviedetailresponse = await http.get(Uri.parse(moviedetailurl));
    if (moviedetailresponse.statusCode == 200) {
      var moviedetailjson = jsonDecode(moviedetailresponse.body);
      for (var i = 0; i < 1; i++) {
        MovieDetails.add({
          "backdrop_path": moviedetailjson['backdrop_path'],
          "poster_path": moviedetailjson['poster_path'],
          "title": moviedetailjson['title'],
          "vote_average": moviedetailjson['vote_average'],
          "overview": moviedetailjson['overview'],
          "release_date": moviedetailjson['release_date'],
          "runtime": moviedetailjson['runtime'],
          "budget": moviedetailjson['budget'],
          "revenue": moviedetailjson['revenue'],
        });
      }
      for (var i = 0; i < moviedetailjson['genres'].length; i++) {
        MoviesGeneres.add(moviedetailjson['genres'][i]['name']);
      }
    } else {}

    // Load Similar movies from Backend first, fallback to TMDB
    try {
      var similarmoviesresponse = await http.get(Uri.parse(similarmoviesurl));
      if (similarmoviesresponse.statusCode == 200) {
        var similarmoviesjson = jsonDecode(similarmoviesresponse.body);
        
        // Check if Backend API response (has 'success' field)
        if (similarmoviesjson.containsKey('success') && similarmoviesjson['success'] == true) {
          print('✅ Loading Similar movies from Backend...');
          var results = similarmoviesjson['results'];
          print('📽️ Found ${results.length} similar movies from Backend');
          
          for (var i = 0; i < results.length; i++) {
            similarmovieslist.add({
              "poster_path": results[i]['poster_path'],
              "name": results[i]['title'],
              "vote_average": results[i]['vote_average'],
              "date": results[i]['release_date'],
              "id": results[i]['id'],
            });
          }
        } else {
          // Unexpected response format, fallback to TMDB
          print('⚠️  Unexpected Backend response, falling back to TMDB...');
          throw Exception('Invalid Backend response');
        }
      } else {
        print('⚠️  Backend returned status ${similarmoviesresponse.statusCode}, falling back to TMDB...');
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('❌ Error loading Similar from Backend: $e');
      print('⚠️  Falling back to TMDB for Similar movies...');
      
      // Fallback to TMDB
      try {
        var similarmoviesresponse_tmdb = await http.get(Uri.parse(similarmoviesurl_tmdb));
        if (similarmoviesresponse_tmdb.statusCode == 200) {
          var similarmoviesjson = jsonDecode(similarmoviesresponse_tmdb.body);
          print('📽️ TMDB Fallback: Found ${similarmoviesjson['results'].length} similar movies');
          
          for (var i = 0; i < similarmoviesjson['results'].length; i++) {
            similarmovieslist.add({
              "poster_path": similarmoviesjson['results'][i]['poster_path'],
              "name": similarmoviesjson['results'][i]['title'],
              "vote_average": similarmoviesjson['results'][i]['vote_average'],
              "date": similarmoviesjson['results'][i]['release_date'],
              "id": similarmoviesjson['results'][i]['id'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback also failed: $tmdbError');
      }
    }

    // Load Recommended movies from Backend first, fallback to TMDB
    try {
      var recommendedmoviesresponse = await http.get(Uri.parse(recommendedmoviesurl));
      if (recommendedmoviesresponse.statusCode == 200) {
        var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse.body);
        
        // Check if Backend API response (has 'success' field)
        if (recommendedmoviesjson.containsKey('success') && recommendedmoviesjson['success'] == true) {
          print('✅ Loading Recommended movies from Backend...');
          var results = recommendedmoviesjson['results'];
          print('📽️ Found ${results.length} recommended movies from Backend');
          
          for (var i = 0; i < results.length; i++) {
            recommendedmovieslist.add({
              "poster_path": results[i]['poster_path'],
              "name": results[i]['title'],
              "vote_average": results[i]['vote_average'],
              "date": results[i]['release_date'],
              "id": results[i]['id'],
            });
          }
        } else {
          // Unexpected response format, fallback to TMDB
          print('⚠️  Unexpected Backend response, falling back to TMDB...');
          throw Exception('Invalid Backend response');
        }
      } else {
        print('⚠️  Backend returned status ${recommendedmoviesresponse.statusCode}, falling back to TMDB...');
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('❌ Error loading Recommended from Backend: $e');
      print('⚠️  Falling back to TMDB for Recommended movies...');
      
      // Fallback to TMDB
      try {
        var recommendedmoviesresponse_tmdb = await http.get(Uri.parse(recommendedmoviesurl_tmdb));
        if (recommendedmoviesresponse_tmdb.statusCode == 200) {
          var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse_tmdb.body);
          print('📽️ TMDB Fallback: Found ${recommendedmoviesjson['results'].length} recommended movies');
          
          for (var i = 0; i < recommendedmoviesjson['results'].length; i++) {
            recommendedmovieslist.add({
              "poster_path": recommendedmoviesjson['results'][i]['poster_path'],
              "name": recommendedmoviesjson['results'][i]['title'],
              "vote_average": recommendedmoviesjson['results'][i]['vote_average'],
              "date": recommendedmoviesjson['results'][i]['release_date'],
              "id": recommendedmoviesjson['results'][i]['id'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback also failed: $tmdbError');
      }
    }

    // Try Backend API first for videos, fallback to TMDB
    bool loadedFromBackend = false;
    try {
      var movietrailersresponse = await http.get(Uri.parse(movietrailersurl));
      if (movietrailersresponse.statusCode == 200) {
        var movietrailersjson = jsonDecode(movietrailersresponse.body);
        
        // Check if Backend API response (has 'success' field)
        if (movietrailersjson.containsKey('success') && movietrailersjson['success'] == true) {
          print('✅ Loading videos from Backend...');
          var results = movietrailersjson['data']['results'];
          print('📹 Found ${results.length} videos from Backend');
          
          // First try to find a Trailer
          for (var i = 0; i < results.length; i++) {
            print('  - Type: ${results[i]['type']}, Name: ${results[i]['name']}');
            if (results[i]['type'] == "Trailer" && results[i]['key'] != null) {
              movietrailerslist.add({"key": results[i]['key']});
            }
          }
          
          // If no trailers found, accept other video types (Teaser, Clip, Featurette)
          if (movietrailerslist.isEmpty) {
            for (var i = 0; i < results.length; i++) {
              if (_isAcceptableVideoType(results[i]['type']) && results[i]['key'] != null) {
                movietrailerslist.add({"key": results[i]['key']});
                break; // Only add first acceptable video
              }
            }
          }
          
          loadedFromBackend = true;
        } else {
          // TMDB response format
          print('📹 Found ${movietrailersjson['results'].length} videos from TMDB');
          
          // First try to find a Trailer
          for (var i = 0; i < movietrailersjson['results'].length; i++) {
            print('  - Type: ${movietrailersjson['results'][i]['type']}, Name: ${movietrailersjson['results'][i]['name']}');
            if (movietrailersjson['results'][i]['type'] == "Trailer" && movietrailersjson['results'][i]['key'] != null) {
              movietrailerslist.add({"key": movietrailersjson['results'][i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (movietrailerslist.isEmpty) {
            for (var i = 0; i < movietrailersjson['results'].length; i++) {
              if (_isAcceptableVideoType(movietrailersjson['results'][i]['type']) && 
                  movietrailersjson['results'][i]['key'] != null) {
                movietrailerslist.add({"key": movietrailersjson['results'][i]['key']});
                break; // Only add first acceptable video
              }
            }
          }
          
          loadedFromBackend = true;
        }
      } else {
        print('⚠️  Backend returned status ${movietrailersresponse.statusCode}, falling back to TMDB...');
      }
    } catch (e) {
      print('❌ Error loading videos from Backend: $e');
      print('⚠️  Falling back to TMDB for videos...');
    }
    
    // If not loaded from Backend, fallback to TMDB
    if (!loadedFromBackend) {
      var tmdbVideosUrl = 'https://api.themoviedb.org/3/movie/${widget.id}/videos?api_key=$apikey';
      try {
        var tmdbResponse = await http.get(Uri.parse(tmdbVideosUrl));
        if (tmdbResponse.statusCode == 200) {
          var tmdbJson = jsonDecode(tmdbResponse.body);
          print('📹 TMDB Fallback: Found ${tmdbJson['results'].length} videos');
          
          // First try to find a Trailer
          for (var i = 0; i < tmdbJson['results'].length; i++) {
            print('  - Type: ${tmdbJson['results'][i]['type']}, Name: ${tmdbJson['results'][i]['name']}');
            if (tmdbJson['results'][i]['type'] == "Trailer" && tmdbJson['results'][i]['key'] != null) {
              movietrailerslist.add({"key": tmdbJson['results'][i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (movietrailerslist.isEmpty) {
            for (var i = 0; i < tmdbJson['results'].length; i++) {
              if (_isAcceptableVideoType(tmdbJson['results'][i]['type']) && 
                  tmdbJson['results'][i]['key'] != null) {
                movietrailerslist.add({"key": tmdbJson['results'][i]['key']});
                break;
              }
            }
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback also failed: $tmdbError');
      }
    }
    
    // Only add demo trailer if absolutely no videos found
    if (movietrailerslist.isEmpty) {
      print('⚠️  No videos found, adding demo trailer');
      movietrailerslist.add({'key': 'aJ0cZTcTh90'});
    } else {
      print('✅ Found ${movietrailerslist.length} video(s) to display');
    }
    print('Final movietrailerslist: ${movietrailerslist.map((v) => v['key']).toList()}');
  }

  // Load additional data from TMDB (similar, recommended, trailers)
  Future<void> _loadAdditionalDataFromTMDB() async {
    // Try Backend API first for similar/recommended, fallback to TMDB
    var similarmoviesurl = '${ApiConfig.baseUrl}/api/similar';
    var similarmoviesurl_tmdb =
        'https://api.themoviedb.org/3/movie/${widget.id}/similar?api_key=$apikey';
    var recommendedmoviesurl = '${ApiConfig.baseUrl}/api/recommended';
    var recommendedmoviesurl_tmdb =
        'https://api.themoviedb.org/3/movie/${widget.id}/recommendations?api_key=$apikey';
    
    // Try Backend API first for videos, fallback to TMDB
    var movietrailersurl = '${ApiConfig.baseUrl}/api/movies/tmdb/${widget.id}/videos';

    // Load Similar movies from Backend first, fallback to TMDB
    try {
      var similarmoviesresponse = await http.get(Uri.parse(similarmoviesurl));
      if (similarmoviesresponse.statusCode == 200) {
        var similarmoviesjson = jsonDecode(similarmoviesresponse.body);
        
        if (similarmoviesjson.containsKey('success') && similarmoviesjson['success'] == true) {
          print('✅ [Additional] Loading Similar movies from Backend...');
          var results = similarmoviesjson['results'];
          
          for (var i = 0; i < results.length; i++) {
            similarmovieslist.add({
              "poster_path": results[i]['poster_path'],
              "name": results[i]['title'],
              "vote_average": results[i]['vote_average'],
              "date": results[i]['release_date'],
              "id": results[i]['id'],
            });
          }
        } else {
          throw Exception('Invalid Backend response');
        }
      } else {
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('⚠️  [Additional] Falling back to TMDB for Similar...');
      try {
        var similarmoviesresponse_tmdb = await http.get(Uri.parse(similarmoviesurl_tmdb));
        if (similarmoviesresponse_tmdb.statusCode == 200) {
          var similarmoviesjson = jsonDecode(similarmoviesresponse_tmdb.body);
          for (var i = 0; i < similarmoviesjson['results'].length; i++) {
            similarmovieslist.add({
              "poster_path": similarmoviesjson['results'][i]['poster_path'],
              "name": similarmoviesjson['results'][i]['title'],
              "vote_average": similarmoviesjson['results'][i]['vote_average'],
              "date": similarmoviesjson['results'][i]['release_date'],
              "id": similarmoviesjson['results'][i]['id'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback failed: $tmdbError');
      }
    }

    // Load Recommended movies from Backend first, fallback to TMDB
    try {
      var recommendedmoviesresponse = await http.get(Uri.parse(recommendedmoviesurl));
      if (recommendedmoviesresponse.statusCode == 200) {
        var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse.body);
        
        if (recommendedmoviesjson.containsKey('success') && recommendedmoviesjson['success'] == true) {
          print('✅ [Additional] Loading Recommended movies from Backend...');
          var results = recommendedmoviesjson['results'];
          
          for (var i = 0; i < results.length; i++) {
            recommendedmovieslist.add({
              "poster_path": results[i]['poster_path'],
              "name": results[i]['title'],
              "vote_average": results[i]['vote_average'],
              "date": results[i]['release_date'],
              "id": results[i]['id'],
            });
          }
        } else {
          throw Exception('Invalid Backend response');
        }
      } else {
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('⚠️  [Additional] Falling back to TMDB for Recommended...');
      try {
        var recommendedmoviesresponse_tmdb = await http.get(Uri.parse(recommendedmoviesurl_tmdb));
        if (recommendedmoviesresponse_tmdb.statusCode == 200) {
          var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse_tmdb.body);
          for (var i = 0; i < recommendedmoviesjson['results'].length; i++) {
            recommendedmovieslist.add({
              "poster_path": recommendedmoviesjson['results'][i]['poster_path'],
              "name": recommendedmoviesjson['results'][i]['title'],
              "vote_average": recommendedmoviesjson['results'][i]['vote_average'],
              "date": recommendedmoviesjson['results'][i]['release_date'],
              "id": recommendedmoviesjson['results'][i]['id'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback failed: $tmdbError');
      }
    }

    // Try Backend API first for videos, fallback to TMDB
    bool loadedFromBackend = false;
    try {
      var movietrailersresponse = await http.get(Uri.parse(movietrailersurl));
      if (movietrailersresponse.statusCode == 200) {
        var movietrailersjson = jsonDecode(movietrailersresponse.body);
        
        // Check if Backend API response (has 'success' field)
        if (movietrailersjson.containsKey('success') && movietrailersjson['success'] == true) {
          print('✅ [TMDB Additional] Loading videos from Backend...');
          var results = movietrailersjson['data']['results'];
          print('📹 Found ${results.length} videos from Backend');
          
          // First try to find a Trailer
          for (var i = 0; i < results.length; i++) {
            print('  - Type: ${results[i]['type']}, Name: ${results[i]['name']}');
            if (results[i]['type'] == "Trailer" && results[i]['key'] != null) {
              movietrailerslist.add({"key": results[i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (movietrailerslist.isEmpty) {
            for (var i = 0; i < results.length; i++) {
              if (_isAcceptableVideoType(results[i]['type']) && results[i]['key'] != null) {
                movietrailerslist.add({"key": results[i]['key']});
                break;
              }
            }
          }
          
          loadedFromBackend = true;
        } else {
          // TMDB response format
          print('📹 [TMDB Additional] Found ${movietrailersjson['results'].length} videos from TMDB');
          
          // First try to find a Trailer
          for (var i = 0; i < movietrailersjson['results'].length; i++) {
            print('  - Type: ${movietrailersjson['results'][i]['type']}, Name: ${movietrailersjson['results'][i]['name']}');
            if (movietrailersjson['results'][i]['type'] == "Trailer" && movietrailersjson['results'][i]['key'] != null) {
              movietrailerslist.add({"key": movietrailersjson['results'][i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (movietrailerslist.isEmpty) {
            for (var i = 0; i < movietrailersjson['results'].length; i++) {
              if (_isAcceptableVideoType(movietrailersjson['results'][i]['type']) && 
                  movietrailersjson['results'][i]['key'] != null) {
                movietrailerslist.add({"key": movietrailersjson['results'][i]['key']});
                break;
              }
            }
          }
          
          loadedFromBackend = true;
        }
      } else {
        print('⚠️  [TMDB Additional] Backend returned status ${movietrailersresponse.statusCode}, falling back to TMDB...');
      }
    } catch (e) {
      print('❌ Error loading videos from Backend: $e');
      print('⚠️  Falling back to TMDB for videos...');
    }
    
    // If not loaded from Backend, fallback to TMDB
    if (!loadedFromBackend) {
      var tmdbVideosUrl = 'https://api.themoviedb.org/3/movie/${widget.id}/videos?api_key=$apikey';
      try {
        var tmdbResponse = await http.get(Uri.parse(tmdbVideosUrl));
        if (tmdbResponse.statusCode == 200) {
          var tmdbJson = jsonDecode(tmdbResponse.body);
          print('📹 TMDB Fallback: Found ${tmdbJson['results'].length} videos');
          
          // First try to find a Trailer
          for (var i = 0; i < tmdbJson['results'].length; i++) {
            print('  - Type: ${tmdbJson['results'][i]['type']}, Name: ${tmdbJson['results'][i]['name']}');
            if (tmdbJson['results'][i]['type'] == "Trailer" && tmdbJson['results'][i]['key'] != null) {
              movietrailerslist.add({"key": tmdbJson['results'][i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (movietrailerslist.isEmpty) {
            for (var i = 0; i < tmdbJson['results'].length; i++) {
              if (_isAcceptableVideoType(tmdbJson['results'][i]['type']) && 
                  tmdbJson['results'][i]['key'] != null) {
                movietrailerslist.add({"key": tmdbJson['results'][i]['key']});
                break;
              }
            }
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback also failed: $tmdbError');
      }
    }
    
    // Only add demo trailer if absolutely no videos found
    if (movietrailerslist.isEmpty) {
      print('⚠️  No videos found, adding demo trailer');
      movietrailerslist.add({'key': 'aJ0cZTcTh90'});
    } else {
      print('✅ Found ${movietrailerslist.length} video(s) to display');
    }
    print(movietrailerslist);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A1929),
            const Color(0xFF0F1922).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null || amount == 0) return 'N/A';
    final value = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    if (value >= 1000000000) {
      return '\$${(value / 1000000000).toStringAsFixed(2)}B';
    } else if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(2)}K';
    }
    return '\$$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E3C),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(FontAwesomeIcons.circleArrowLeft),
                    iconSize: 28,
                    color: Colors.white,
                  ),
                  actions: [
                    IconButton(
                      onPressed: _shareMovie,
                      icon: const Icon(Icons.share),
                      iconSize: 26,
                      color: Colors.white,
                      tooltip: 'Share movie',
                    ),
                    if (MovieDetails.isNotEmpty)
                      AddToListButton(
                        itemId: widget.id.toString(),
                        itemType: 'movie',
                        title: MovieDetails[0]['title']?.toString() ?? 
                               MovieDetails[0]['original_title']?.toString() ?? 
                               'Unknown Movie',
                        posterPath: MovieDetails[0]['poster_path']?.toString(),
                        backdropPath: MovieDetails[0]['backdrop_path']?.toString(),
                        overview: MovieDetails[0]['overview']?.toString(),
                        releaseDate: MovieDetails[0]['release_date']?.toString(),
                        voteAverage: (MovieDetails[0]['vote_average'] as num?)?.toDouble(),
                        iconColor: Colors.white,
                        iconSize: 26,
                      ),
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      iconSize: 28,
                      color: _isFavorite ? Colors.red : Colors.white,
                      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false,
                        );
                      },
                      icon: Icon(FontAwesomeIcons.houseUser),
                      iconSize: 25,
                      color: Colors.white,
                      tooltip: 'Home',
                    ),
                  ],
                  backgroundColor: const Color(0xFF0A1929).withValues(alpha: 0.95),
                  centerTitle: false,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: FittedBox(
                      fit: BoxFit.fill,
                      child: movietrailerslist.isNotEmpty
                        ? trailerwatch(
                            trailerytid: movietrailerslist[0]['key'],
                          )
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Movie Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        MovieDetails[0]['title'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Rating and Runtime Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Rating Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.2),
                                  Colors.orange.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  MovieDetails[0]['vote_average'].toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  ' / 10',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Runtime Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan.withValues(alpha: 0.2),
                                  Colors.teal.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.cyan.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.cyan, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${MovieDetails[0]['runtime']} min',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Genres
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: MoviesGeneres.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withValues(alpha: 0.3),
                                  Colors.deepPurple.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.purple.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Overview Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.cyan, Colors.teal],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Text(
                        MovieDetails[0]['overview'].toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    // Movie Info Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          _buildInfoCard(
                            icon: Icons.calendar_today,
                            iconColor: Colors.blue,
                            title: 'Release Date',
                            value: MovieDetails[0]['release_date'],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.attach_money,
                            iconColor: Colors.green,
                            title: 'Budget',
                            value: _formatCurrency(MovieDetails[0]['budget']),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.trending_up,
                            iconColor: Colors.orange,
                            title: 'Revenue',
                            value: _formatCurrency(MovieDetails[0]['revenue']),
                          ),
                        ],
                      ),
                    ),

                    // Chat Room Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.cyan, Colors.teal],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Discussion',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF001E3C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: DiscussionTabs(
                            mediaId: widget.id is int ? widget.id : int.parse(widget.id.toString()),
                            mediaType: 'movie',
                          ),
                        ),
                      ),
                    ),

                    sliderlist(
                      similarmovieslist,
                      "Similar Movies",
                      "movie",
                      similarmovieslist.length,
                    ),
                    sliderlist(
                      recommendedmovieslist,
                      "Recommended Movies",
                      "movie",
                      recommendedmovieslist.length,
                    ),
                  ]),
                ),
              ],
            ),
    );
  }
}
