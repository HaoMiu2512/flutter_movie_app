import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_movie_app/reapeatedfunction/userreview.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';
import 'package:flutter_movie_app/HomePage/HomePage.dart';
import 'package:flutter_movie_app/reapeatedfunction/trailerui.dart';
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/services/favorites_service.dart';
import 'package:flutter_movie_app/services/recently_viewed_service.dart';
import 'package:flutter_movie_app/models/movie.dart';
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
  List<Map<String, dynamic>> TvSeriesReview = [];
  List<Map<String, dynamic>> similarserieslist = [];
  List<Map<String, dynamic>> recommendserieslist = [];
  List<Map<String, dynamic>> seriestrailerslist = [];

  // Favorites
  final FavoritesService _favoritesService = FavoritesService();
  final RecentlyViewedService _recentlyViewedService = RecentlyViewedService();
  bool _isFavorite = false;
  bool _isLoading = true;

  Future<void> tvseriesdetailfunc() async {
    var tvseriesdetailurl =
        'https://api.themoviedb.org/3/tv/${widget.id}?api_key=${apikey}';
    var tvseriesreviewurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/reviews?api_key=${apikey}';
    var similarseriesurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/similar?api_key=${apikey}';
    var recommendseriesurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/recommendations?api_key=${apikey}';
    var seriestrailersurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/videos?api_key=${apikey}';

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
    } else {}

    var tvseriesreviewresponse = await http.get(Uri.parse(tvseriesreviewurl));
    if (tvseriesreviewresponse.statusCode == 200) {
      var tvseriesreviewdata = jsonDecode(tvseriesreviewresponse.body);
      for (var i = 0; i < tvseriesreviewdata['results'].length; i++) {
        TvSeriesReview.add({
          'name': tvseriesreviewdata['results'][i]['author'],
          'review': tvseriesreviewdata['results'][i]['content'],
          "rating": tvseriesreviewdata['results'][i]['author_details']
                      ['rating'] ==
                  null
              ? "Not Rated"
              : tvseriesreviewdata['results'][i]['author_details']['rating']
                  .toString(),
          "avatarphoto": tvseriesreviewdata['results'][i]['author_details']
                      ['avatar_path'] ==
                  null
              ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
              : "https://image.tmdb.org/t/p/w500" +
                  tvseriesreviewdata['results'][i]['author_details']
                      ['avatar_path'],
          "creationdate":
              tvseriesreviewdata['results'][i]['created_at'].substring(0, 10),
          "fullreviewurl": tvseriesreviewdata['results'][i]['url'],
        });
      }
    } else {}

    var similarseriesresponse = await http.get(Uri.parse(similarseriesurl));
    if (similarseriesresponse.statusCode == 200) {
      var similarseriesdata = jsonDecode(similarseriesresponse.body);
      for (var i = 0; i < similarseriesdata['results'].length; i++) {
        similarserieslist.add({
          'poster_path': similarseriesdata['results'][i]['poster_path'],
          'name': similarseriesdata['results'][i]['original_name'],
          'vote_average': similarseriesdata['results'][i]['vote_average'],
          'id': similarseriesdata['results'][i]['id'],
          'date': similarseriesdata['results'][i]['first_air_date'],
        });
      }
    } else {}

    var recommendseriesresponse = await http.get(Uri.parse(recommendseriesurl));
    if (recommendseriesresponse.statusCode == 200) {
      var recommendseriesdata = jsonDecode(recommendseriesresponse.body);
      for (var i = 0; i < recommendseriesdata['results'].length; i++) {
        recommendserieslist.add({
          'poster_path': recommendseriesdata['results'][i]['poster_path'],
          'name': recommendseriesdata['results'][i]['original_name'],
          'vote_average': recommendseriesdata['results'][i]['vote_average'],
          'id': recommendseriesdata['results'][i]['id'],
          'date': recommendseriesdata['results'][i]['first_air_date'],
        });
      }
    } else {}

    var tvseriestrailerresponse = await http.get(Uri.parse(seriestrailersurl));
    if (tvseriestrailerresponse.statusCode == 200) {
      var tvseriestrailerdata = jsonDecode(tvseriestrailerresponse.body);
      // print(tvseriestrailerdata);
      for (var i = 0; i < tvseriestrailerdata['results'].length; i++) {
        //add only if type is trailer
        if (tvseriestrailerdata['results'][i]['type'] == "Trailer") {
          seriestrailerslist.add({
            'key': tvseriestrailerdata['results'][i]['key'],
          });
        }
      }
      seriestrailerslist.add({'key': 'aJ0cZTcTh90'});
    } else {}
    print(seriestrailerslist);
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavoriteMovie(
      widget.id is int ? widget.id : int.parse(widget.id.toString()),
      'tv',
    );
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (TvSeriesDetails.isEmpty) return;

    final movie = Movie(
      id: widget.id is int ? widget.id : int.parse(widget.id.toString()),
      title: TvSeriesDetails[0]['title'],
      posterPath: TvSeriesDetails[0]['backdrop_path'] ?? '',
      overview: TvSeriesDetails[0]['overview'],
      voteAverage: (TvSeriesDetails[0]['vote_average'] as num).toDouble(),
      releaseDate: TvSeriesDetails[0]['releasedate'],
      mediaType: 'tv',
    );

    await _favoritesService.toggleFavorite(movie);
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
    if (TvSeriesDetails.isEmpty) {
      print('TvSeriesDetail: Cannot add to recently viewed - TvSeriesDetails is empty');
      return;
    }

    try {
      final movie = Movie(
        id: widget.id is int ? widget.id : int.parse(widget.id.toString()),
        title: TvSeriesDetails[0]['title'],
        posterPath: tvseriesdetaildata['poster_path'] ?? TvSeriesDetails[0]['backdrop_path'] ?? '',
        overview: TvSeriesDetails[0]['overview'],
        voteAverage: (TvSeriesDetails[0]['vote_average'] as num).toDouble(),
        releaseDate: TvSeriesDetails[0]['releasedate'],
        mediaType: 'tv',
      );

      print('TvSeriesDetail: Adding to recently viewed - ${movie.title}');
      final success = await _recentlyViewedService.addToRecentlyViewed(movie);
      print('TvSeriesDetail: Add to recently viewed result: $success');
    } catch (e) {
      print('TvSeriesDetail: Error adding to recently viewed: $e');
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
                                        builder: (context) => HomePage()),
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
                            child: trailerwatch(
                              trailerytid: seriestrailerslist[0]['key'],
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
                            tvseriesdetaildata['genres']!.length,
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
                              value: '${tvseriesdetaildata['seasons'].length} Seasons',
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

                      // User Reviews
                      if (TvSeriesReview.isNotEmpty)
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
                                'User Reviews',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (TvSeriesReview.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 10),
                          child: UserReview(reviewDetails: TvSeriesReview),
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