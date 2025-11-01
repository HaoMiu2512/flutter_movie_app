import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/reapeatedfunction/discussion_tabs.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';
import 'package:flutter_movie_app/main_screen.dart';
import 'package:flutter_movie_app/reapeatedfunction/trailerui.dart';
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/config/api_config.dart';
import 'package:flutter_movie_app/services/backend_favorites_service.dart';
import 'package:flutter_movie_app/services/backend_recently_viewed_service.dart';
import 'package:flutter_movie_app/services/tv_series_detail_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TvSeriesDetail extends StatefulWidget {
  var id;
  TvSeriesDetail({super.key, this.id});

  @override
  State<TvSeriesDetail> createState() => _TvSeriesDetailState();
}

class _TvSeriesDetailState extends State<TvSeriesDetail> {
  var tvseriesdetaildata;
  List<Map<String, dynamic>> TvSeriesDetails = [];
  List<Map<String, dynamic>> similarserieslist = [];
  List<Map<String, dynamic>> recommendserieslist = [];
  List<Map<String, dynamic>> seriestrailerslist = [];

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

  Future<void> tvseriesdetailfunc() async {
    // Try Backend API first
    try {
      print('📺 Loading TV series details from Backend API...');
      final tvSeriesDetail = await TvSeriesDetailService.getTvSeriesDetailByTmdbId(
        widget.id is int ? widget.id : int.parse(widget.id.toString()),
      );

      if (tvSeriesDetail != null) {
        print('✅ Loaded from Backend! Title: ${tvSeriesDetail.name}');
        
        // Populate TvSeriesDetails from Backend
        TvSeriesDetails.add({
          'backdrop_path': tvSeriesDetail.backdropPath?.replaceAll('https://image.tmdb.org/t/p/w500', '') ?? '',
          'title': tvSeriesDetail.name,
          'vote_average': tvSeriesDetail.voteAverage,
          'overview': tvSeriesDetail.overview,
          'status': tvSeriesDetail.status,
          'releasedate': tvSeriesDetail.firstAirDate ?? '',
        });

        // Add genres
        for (var genre in tvSeriesDetail.genres) {
          TvSeriesDetails.add({
            'genre': genre.name,
          });
        }

        // Add creators from crew (filter for Creator or Executive Producer)
        final creators = tvSeriesDetail.crew
            .where((c) => c.job == 'Creator' || c.job == 'Executive Producer')
            .toList();
        for (var creator in creators) {
          TvSeriesDetails.add({
            'creator': creator.name,
            'creatorprofile': creator.profilePath,
          });
        }

        // Add seasons
        for (var season in tvSeriesDetail.seasons) {
          TvSeriesDetails.add({
            'season': season.name,
            'episode_count': season.episodeCount,
          });
        }

        // Add trailers from videos
        for (var video in tvSeriesDetail.trailers) {
          seriestrailerslist.add({
            'key': video.key,
          });
        }
        // Add fallback trailer if no trailers
        if (seriestrailerslist.isEmpty) {
          seriestrailerslist.add({'key': 'aJ0cZTcTh90'});
        }

        // Load additional data from TMDB (reviews, similar, recommended)
        await _loadAdditionalDataFromTMDB();
        
        return;
      } else {
        print('⚠️  TV series not found in Backend, falling back to TMDB...');
      }
    } catch (e) {
      print('❌ Error loading from Backend: $e');
      print('⚠️  Falling back to TMDB...');
    }

    // Fallback to original TMDB API
    var tvseriesdetailurl =
        'https://api.themoviedb.org/3/tv/${widget.id}?api_key=${apikey}';
    
    // Backend-first URLs for Similar and Recommended
    var similarseriesurl = '${ApiConfig.baseUrl}/api/tv/similar';
    var recommendseriesurl = '${ApiConfig.baseUrl}/api/tv/recommended';
    
    // TMDB fallback URLs
    var similarseriesurl_tmdb =
        'https://api.themoviedb.org/3/tv/${widget.id}/similar?api_key=${apikey}';
    var recommendseriesurl_tmdb =
        'https://api.themoviedb.org/3/tv/${widget.id}/recommendations?api_key=${apikey}';
    
    // Try Backend API first for videos, fallback to TMDB
    var seriestrailersurl = '${ApiConfig.baseUrl}/api/tv-series/tmdb/${widget.id}/videos';

    var tvseriesdetailresponse = await http.get(Uri.parse(tvseriesdetailurl));
    if (tvseriesdetailresponse.statusCode == 200) {
      tvseriesdetaildata = jsonDecode(tvseriesdetailresponse.body);
      for (var i = 0; i < 1; i++) {
        TvSeriesDetails.add({
          'backdrop_path': tvseriesdetaildata['backdrop_path'],
          'title': tvseriesdetaildata['original_name'],
          'vote_average': tvseriesdetaildata['vote_average'],
          'overview': tvseriesdetaildata['overview'],
          'status': tvseriesdetaildata['status'],
          'releasedate': tvseriesdetaildata['first_air_date'],
        });
      }
      
      // Only process TMDB-specific data if tvseriesdetaildata is available
      if (tvseriesdetaildata != null) {
        for (var i = 0; i < tvseriesdetaildata['genres'].length; i++) {
          TvSeriesDetails.add({
            'genre': tvseriesdetaildata['genres'][i]['name'],
          });
        }
        for (var i = 0; i < tvseriesdetaildata['created_by'].length; i++) {
          TvSeriesDetails.add({
            'creator': tvseriesdetaildata['created_by'][i]['name'],
            'creatorprofile': tvseriesdetaildata['created_by'][i]['profile_path'],
          });
        }
        for (var i = 0; i < tvseriesdetaildata['seasons'].length; i++) {
          TvSeriesDetails.add({
            'season': tvseriesdetaildata['seasons'][i]['name'],
            'episode_count': tvseriesdetaildata['seasons'][i]['episode_count'],
          });
        }
      }
    } else {}

    // Load Similar series from Backend first, fallback to TMDB
    try {
      print('📊 Loading TV Similar from Backend...');
      var similarseriesresponse = await http.get(Uri.parse(similarseriesurl));
      if (similarseriesresponse.statusCode == 200) {
        var similarseriesdata = jsonDecode(similarseriesresponse.body);
        
        if (similarseriesdata.containsKey('success') && similarseriesdata['success'] == true) {
          print('✅ TV Similar loaded from Backend');
          var results = similarseriesdata['results'];
          
          for (var i = 0; i < results.length; i++) {
            similarserieslist.add({
              'poster_path': results[i]['poster_path'],
              'name': results[i]['original_name'] ?? results[i]['name'],
              'vote_average': results[i]['vote_average'],
              'id': results[i]['id'],
              'date': results[i]['first_air_date'],
            });
          }
        } else {
          throw Exception('Invalid Backend response');
        }
      } else {
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('⚠️  TV Similar falling back to TMDB: $e');
      try {
        var similarseriesresponse_tmdb = await http.get(Uri.parse(similarseriesurl_tmdb));
        if (similarseriesresponse_tmdb.statusCode == 200) {
          var similarseriesdata = jsonDecode(similarseriesresponse_tmdb.body);
          for (var i = 0; i < similarseriesdata['results'].length; i++) {
            similarserieslist.add({
              'poster_path': similarseriesdata['results'][i]['poster_path'],
              'name': similarseriesdata['results'][i]['original_name'],
              'vote_average': similarseriesdata['results'][i]['vote_average'],
              'id': similarseriesdata['results'][i]['id'],
              'date': similarseriesdata['results'][i]['first_air_date'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback failed: $tmdbError');
      }
    }

    // Load Recommended series from Backend first, fallback to TMDB
    try {
      print('📊 Loading TV Recommended from Backend...');
      var recommendseriesresponse = await http.get(Uri.parse(recommendseriesurl));
      if (recommendseriesresponse.statusCode == 200) {
        var recommendseriesdata = jsonDecode(recommendseriesresponse.body);
        
        if (recommendseriesdata.containsKey('success') && recommendseriesdata['success'] == true) {
          print('✅ TV Recommended loaded from Backend');
          var results = recommendseriesdata['results'];
          
          for (var i = 0; i < results.length; i++) {
            recommendserieslist.add({
              'poster_path': results[i]['poster_path'],
              'name': results[i]['original_name'] ?? results[i]['name'],
              'vote_average': results[i]['vote_average'],
              'id': results[i]['id'],
              'date': results[i]['first_air_date'],
            });
          }
        } else {
          throw Exception('Invalid Backend response');
        }
      } else {
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('⚠️  TV Recommended falling back to TMDB: $e');
      try {
        var recommendseriesresponse_tmdb = await http.get(Uri.parse(recommendseriesurl_tmdb));
        if (recommendseriesresponse_tmdb.statusCode == 200) {
          var recommendseriesdata = jsonDecode(recommendseriesresponse_tmdb.body);
          for (var i = 0; i < recommendseriesdata['results'].length; i++) {
            recommendserieslist.add({
              'poster_path': recommendseriesdata['results'][i]['poster_path'],
              'name': recommendseriesdata['results'][i]['original_name'],
              'vote_average': recommendseriesdata['results'][i]['vote_average'],
              'id': recommendseriesdata['results'][i]['id'],
              'date': recommendseriesdata['results'][i]['first_air_date'],
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
      var tvseriestrailerresponse = await http.get(Uri.parse(seriestrailersurl));
      if (tvseriestrailerresponse.statusCode == 200) {
        var tvseriestrailerdata = jsonDecode(tvseriestrailerresponse.body);
        
        // Check if Backend API response (has 'success' field)
        if (tvseriestrailerdata.containsKey('success') && tvseriestrailerdata['success'] == true) {
          print('✅ Loading TV videos from Backend...');
          var results = tvseriestrailerdata['data']['results'];
          print('📹 Found ${results.length} videos from Backend');
          
          // First try to find a Trailer
          for (var i = 0; i < results.length; i++) {
            print('  - Type: ${results[i]['type']}, Name: ${results[i]['name']}');
            if (results[i]['type'] == "Trailer" && results[i]['key'] != null) {
              seriestrailerslist.add({'key': results[i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (seriestrailerslist.isEmpty) {
            for (var i = 0; i < results.length; i++) {
              if (_isAcceptableVideoType(results[i]['type']) && results[i]['key'] != null) {
                seriestrailerslist.add({'key': results[i]['key']});
                break;
              }
            }
          }
          
          loadedFromBackend = true;
        } else {
          // TMDB response format
          print('📹 Found ${tvseriestrailerdata['results'].length} videos from TMDB');
          
          // First try to find a Trailer
          for (var i = 0; i < tvseriestrailerdata['results'].length; i++) {
            print('  - Type: ${tvseriestrailerdata['results'][i]['type']}, Name: ${tvseriestrailerdata['results'][i]['name']}');
            if (tvseriestrailerdata['results'][i]['type'] == "Trailer" && tvseriestrailerdata['results'][i]['key'] != null) {
              seriestrailerslist.add({'key': tvseriestrailerdata['results'][i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (seriestrailerslist.isEmpty) {
            for (var i = 0; i < tvseriestrailerdata['results'].length; i++) {
              if (_isAcceptableVideoType(tvseriestrailerdata['results'][i]['type']) && 
                  tvseriestrailerdata['results'][i]['key'] != null) {
                seriestrailerslist.add({'key': tvseriestrailerdata['results'][i]['key']});
                break;
              }
            }
          }
          
          loadedFromBackend = true;
        }
      } else {
        print('⚠️  Backend returned status ${tvseriestrailerresponse.statusCode}, falling back to TMDB...');
      }
    } catch (e) {
      print('❌ Error loading videos from Backend: $e');
      print('⚠️  Falling back to TMDB for videos...');
    }
    
    // If not loaded from Backend, fallback to TMDB
    if (!loadedFromBackend) {
      var tmdbVideosUrl = 'https://api.themoviedb.org/3/tv/${widget.id}/videos?api_key=${apikey}';
      try {
        var tmdbResponse = await http.get(Uri.parse(tmdbVideosUrl));
        if (tmdbResponse.statusCode == 200) {
          var tmdbData = jsonDecode(tmdbResponse.body);
          print('📹 TMDB Fallback: Found ${tmdbData['results'].length} videos');
          
          // First try to find a Trailer
          for (var i = 0; i < tmdbData['results'].length; i++) {
            print('  - Type: ${tmdbData['results'][i]['type']}, Name: ${tmdbData['results'][i]['name']}');
            if (tmdbData['results'][i]['type'] == "Trailer" && tmdbData['results'][i]['key'] != null) {
              seriestrailerslist.add({'key': tmdbData['results'][i]['key']});
            }
          }
          
          // If no trailers found, accept other video types
          if (seriestrailerslist.isEmpty) {
            for (var i = 0; i < tmdbData['results'].length; i++) {
              if (_isAcceptableVideoType(tmdbData['results'][i]['type']) && 
                  tmdbData['results'][i]['key'] != null) {
                seriestrailerslist.add({'key': tmdbData['results'][i]['key']});
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
    if (seriestrailerslist.isEmpty) {
      print('⚠️  No videos found, adding demo trailer');
      seriestrailerslist.add({'key': 'aJ0cZTcTh90'});
    } else {
      print('✅ Found ${seriestrailerslist.length} video(s) to display');
    }
    print('Final seriestrailerslist: ${seriestrailerslist.map((v) => v['key']).toList()}');
  }

  // Load additional data from TMDB (similar, recommended)
  Future<void> _loadAdditionalDataFromTMDB() async {
    // Backend-first URLs for Similar and Recommended
    var similarseriesurl = '${ApiConfig.baseUrl}/api/tv/similar';
    var recommendseriesurl = '${ApiConfig.baseUrl}/api/tv/recommended';
    
    // TMDB fallback URLs
    var similarseriesurl_tmdb =
        'https://api.themoviedb.org/3/tv/${widget.id}/similar?api_key=${apikey}';
    var recommendseriesurl_tmdb =
        'https://api.themoviedb.org/3/tv/${widget.id}/recommendations?api_key=${apikey}';

    // Load Similar series from Backend first, fallback to TMDB
    try {
      print('📊 [Additional] Loading TV Similar from Backend...');
      var similarseriesresponse = await http.get(Uri.parse(similarseriesurl));
      if (similarseriesresponse.statusCode == 200) {
        var similarseriesdata = jsonDecode(similarseriesresponse.body);
        
        if (similarseriesdata.containsKey('success') && similarseriesdata['success'] == true) {
          print('✅ [Additional] TV Similar loaded from Backend');
          var results = similarseriesdata['results'];
          
          for (var i = 0; i < results.length; i++) {
            similarserieslist.add({
              'poster_path': results[i]['poster_path'],
              'name': results[i]['original_name'] ?? results[i]['name'],
              'vote_average': results[i]['vote_average'],
              'id': results[i]['id'],
              'date': results[i]['first_air_date'],
            });
          }
        } else {
          throw Exception('Invalid Backend response');
        }
      } else {
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('⚠️  [Additional] TV Similar falling back to TMDB: $e');
      try {
        var similarseriesresponse_tmdb = await http.get(Uri.parse(similarseriesurl_tmdb));
        if (similarseriesresponse_tmdb.statusCode == 200) {
          var similarseriesdata = jsonDecode(similarseriesresponse_tmdb.body);
          for (var i = 0; i < similarseriesdata['results'].length; i++) {
            similarserieslist.add({
              'poster_path': similarseriesdata['results'][i]['poster_path'],
              'name': similarseriesdata['results'][i]['original_name'],
              'vote_average': similarseriesdata['results'][i]['vote_average'],
              'id': similarseriesdata['results'][i]['id'],
              'date': similarseriesdata['results'][i]['first_air_date'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback failed: $tmdbError');
      }
    }

    // Load Recommended series from Backend first, fallback to TMDB
    try {
      print('📊 [Additional] Loading TV Recommended from Backend...');
      var recommendseriesresponse = await http.get(Uri.parse(recommendseriesurl));
      if (recommendseriesresponse.statusCode == 200) {
        var recommendseriesdata = jsonDecode(recommendseriesresponse.body);
        
        if (recommendseriesdata.containsKey('success') && recommendseriesdata['success'] == true) {
          print('✅ [Additional] TV Recommended loaded from Backend');
          var results = recommendseriesdata['results'];
          
          for (var i = 0; i < results.length; i++) {
            recommendserieslist.add({
              'poster_path': results[i]['poster_path'],
              'name': results[i]['original_name'] ?? results[i]['name'],
              'vote_average': results[i]['vote_average'],
              'id': results[i]['id'],
              'date': results[i]['first_air_date'],
            });
          }
        } else {
          throw Exception('Invalid Backend response');
        }
      } else {
        throw Exception('Backend not available');
      }
    } catch (e) {
      print('⚠️  [Additional] TV Recommended falling back to TMDB: $e');
      try {
        var recommendseriesresponse_tmdb = await http.get(Uri.parse(recommendseriesurl_tmdb));
        if (recommendseriesresponse_tmdb.statusCode == 200) {
          var recommendseriesdata = jsonDecode(recommendseriesresponse_tmdb.body);
          for (var i = 0; i < recommendseriesdata['results'].length; i++) {
            recommendserieslist.add({
              'poster_path': recommendseriesdata['results'][i]['poster_path'],
              'name': recommendseriesdata['results'][i]['original_name'],
              'vote_average': recommendseriesdata['results'][i]['vote_average'],
              'id': recommendseriesdata['results'][i]['id'],
              'date': recommendseriesdata['results'][i]['first_air_date'],
            });
          }
        }
      } catch (tmdbError) {
        print('❌ TMDB fallback failed: $tmdbError');
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (currentUser == null) return;
    
    final seriesId = widget.id is int ? widget.id : int.parse(widget.id.toString());
    final isFav = await BackendFavoritesService.isFavorite(
      userId: currentUser!.uid,
      mediaType: 'tv',
      mediaId: seriesId,
    );
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (TvSeriesDetails.isEmpty || currentUser == null) return;

    final seriesId = widget.id is int ? widget.id : int.parse(widget.id.toString());

    if (_isFavorite) {
      // Remove from favorites
      await BackendFavoritesService.removeFavoriteByMedia(
        userId: currentUser!.uid,
        mediaType: 'tv',
        mediaId: seriesId,
      );
    } else {
      // Add to favorites
      await BackendFavoritesService.addFavorite(
        userId: currentUser!.uid,
        mediaType: 'tv',
        mediaId: seriesId,
        title: TvSeriesDetails[0]['title'] ?? '',
        posterPath: TvSeriesDetails[0]['poster_path'] ?? TvSeriesDetails[0]['backdrop_path'] ?? '',
        backdropPath: TvSeriesDetails[0]['backdrop_path'] ?? '',
        overview: TvSeriesDetails[0]['overview'] ?? '',
        rating: (TvSeriesDetails[0]['vote_average'] as num?)?.toDouble() ?? 0.0,
        releaseDate: TvSeriesDetails[0]['releasedate'] ?? '',
      );
    }

    await _checkFavoriteStatus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          backgroundColor: _isFavorite ? Colors.green[700] : Colors.orange[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareTvSeries() async {
    if (TvSeriesDetails.isEmpty) return;

    final seriesId = widget.id is int ? widget.id : int.parse(widget.id.toString());
    final title = TvSeriesDetails[0]['title'];
    final rating = TvSeriesDetails[0]['vote_average'];
    final overview = TvSeriesDetails[0]['overview'];

    // TMDB TV series link
    final seriesLink = 'https://www.themoviedb.org/tv/$seriesId';

    // Share text
    final shareText = '''
📺 $title

⭐ Rating: $rating/10

📝 $overview

🔗 View more: $seriesLink

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
                    'Share TV Series',
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
                seriesLink,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                Navigator.pop(context);
                await _copyTvSeriesLink();
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
                    subject: 'Check out this TV series: $title',
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

  Future<void> _copyTvSeriesLink() async {
    if (TvSeriesDetails.isEmpty) return;

    final seriesId = widget.id is int ? widget.id : int.parse(widget.id.toString());
    final seriesLink = 'https://www.themoviedb.org/tv/$seriesId';

    try {
      await Clipboard.setData(ClipboardData(text: seriesLink));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Link copied!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seriesLink,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error copying link: $e');
    }
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

  @override
  void initState() {
    super.initState();
    _loadData();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _loadData() async {
    await tvseriesdetailfunc();
    await _checkFavoriteStatus();
    await _addToRecentlyViewed();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addToRecentlyViewed() async {
    if (TvSeriesDetails.isEmpty || currentUser == null) {
      print('TvSeriesDetail: Cannot add to recently viewed - TvSeriesDetails is empty or user not logged in');
      return;
    }

    try {
      // Get poster path - check tvseriesdetaildata first (TMDB), then use backdrop from Backend
      String posterPath = '';
      if (tvseriesdetaildata != null && tvseriesdetaildata['poster_path'] != null) {
        posterPath = tvseriesdetaildata['poster_path'];
      } else if (TvSeriesDetails[0]['backdrop_path'] != null) {
        posterPath = TvSeriesDetails[0]['backdrop_path'];
      }

      final seriesId = widget.id is int ? widget.id : int.parse(widget.id.toString());
      final title = TvSeriesDetails[0]['title'] ?? 'Unknown';
      final overview = TvSeriesDetails[0]['overview'] ?? '';
      final voteAverage = (TvSeriesDetails[0]['vote_average'] as num?)?.toDouble() ?? 0.0;
      final releaseDate = TvSeriesDetails[0]['releasedate'] ?? '';
      final backdropPath = TvSeriesDetails[0]['backdrop_path'] ?? '';

      print('TvSeriesDetail: Tracking view - $title');
      
      final success = await BackendRecentlyViewedService.trackView(
        userId: currentUser!.uid,
        mediaType: 'tv',
        mediaId: seriesId,
        title: title,
        posterPath: posterPath,
        backdropPath: backdropPath,
        overview: overview,
        rating: voteAverage,
        releaseDate: releaseDate,
      );
      
      print('TvSeriesDetail: Track view result: $success');
    } catch (e) {
      print('TvSeriesDetail: Error tracking view: $e');
    }
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
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                        automaticallyImplyLeading: false,
                        leading:

                            IconButton(
                                onPressed: () {
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.manual,
                                      overlays: [SystemUiOverlay.bottom]);

                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.portraitUp,
                                    DeviceOrientation.portraitDown,
                                  ]);
                                  Navigator.pop(context);
                                },
                                icon: Icon(FontAwesomeIcons.circleArrowLeft),
                                iconSize: 28,
                                color: Colors.white),
                        actions: [
                          IconButton(
                            onPressed: _copyTvSeriesLink,
                            icon: const Icon(Icons.link),
                            iconSize: 26,
                            color: Colors.white,
                            tooltip: 'Copy link',
                          ),
                          IconButton(
                            onPressed: _shareTvSeries,
                            icon: const Icon(Icons.share),
                            iconSize: 26,
                            color: Colors.white,
                            tooltip: 'Share TV series',
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
                                    MaterialPageRoute(
                                        builder: (context) => const MainScreen()),
                                    (route) => false);
                              },
                              icon: Icon(FontAwesomeIcons.houseUser),
                              iconSize: 25,
                              color: Colors.white,
                              tooltip: 'Home')
                        ],
                        backgroundColor: const Color(0xFF0A1929).withValues(alpha: 0.95),
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.35,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: FittedBox(
                            fit: BoxFit.fill,
                            child: seriestrailerslist.isNotEmpty
                              ? trailerwatch(
                                  trailerytid: seriestrailerslist[0]['key'],
                                )
                              : Container(
                                  color: Colors.black,
                                  child: const Center(
                                    child: Icon(
                                      Icons.tv,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          ),
                        )),
                    SliverList(
                        delegate: SliverChildListDelegate([
                      // TV Series Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          TvSeriesDetails[0]['title'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      // Rating Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                TvSeriesDetails[0]['vote_average'].toStringAsFixed(1),
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
                      ),

                      // Genres
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            TvSeriesDetails.where((item) => item.containsKey('genre')).length,
                            (index) => Container(
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
                                TvSeriesDetails[index + 1]['genre'].toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
                          TvSeriesDetails[0]['overview'].toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.white70,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      // Series Info Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            _buildInfoCard(
                              icon: Icons.info_outline,
                              iconColor: Colors.blue,
                              title: 'Status',
                              value: TvSeriesDetails[0]['status'],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.live_tv,
                              iconColor: Colors.purple,
                              title: 'Total Seasons',
                              value: '${TvSeriesDetails.where((item) => item.containsKey('season')).length} Seasons',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.calendar_today,
                              iconColor: Colors.green,
                              title: 'First Air Date',
                              value: TvSeriesDetails[0]['releasedate'],
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
                              mediaType: 'tv',
                            ),
                          ),
                        ),
                      ),

                      sliderlist(similarserieslist, 'Similar Series', 'tv',
                          similarserieslist.length),
                      sliderlist(recommendserieslist, 'Recommended Series',
                          'tv', recommendserieslist.length),
                      Container(
                          //     height: 50,
                          //     child: Center(child: normaltext("By Niranjan Dahal"))
                          )
                    ]))
                  ]),
    );
  }
}