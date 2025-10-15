import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';
import 'package:flutter_movie_app/HomePage/homepage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_movie_app/reapeatedfunction/trailerui.dart';
import 'package:flutter_movie_app/reapeatedfunction/userreview.dart';
import 'package:flutter_movie_app/services/favorites_service.dart';
import 'package:flutter_movie_app/models/movie.dart';

class MoviesDetail extends StatefulWidget {
  var id;
  MoviesDetail({super.key, this.id});

  @override
  State<MoviesDetail> createState() => _MoviesDetailState();
}

class _MoviesDetailState extends State<MoviesDetail> {
  List<Map<String, dynamic>> MovieDetails = [];
  List<Map<String, dynamic>> UserReviews = [];
  List<Map<String, dynamic>> similarmovieslist = [];
  List<Map<String, dynamic>> recommendedmovieslist = [];
  List<Map<String, dynamic>> movietrailerslist = [];

  List MoviesGeneres = [];

  // Favorites
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavoriteMovie(
      widget.id is int ? widget.id : int.parse(widget.id.toString()),
      'movie',
    );
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (MovieDetails.isEmpty) return;

    final movie = Movie(
      id: widget.id is int ? widget.id : int.parse(widget.id.toString()),
      title: MovieDetails[0]['title'],
      posterPath: MovieDetails[0]['backdrop_path'] ?? '',
      overview: MovieDetails[0]['overview'],
      voteAverage: (MovieDetails[0]['vote_average'] as num).toDouble(),
      releaseDate: MovieDetails[0]['release_date'],
      mediaType: 'movie',
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

  Future Moviedetails() async {
    var moviedetailurl =
        'https://api.themoviedb.org/3/movie/${widget.id}?api_key=$apikey';
    var UserReviewurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/reviews?api_key=$apikey';
    var similarmoviesurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/similar?api_key=$apikey';
    var recommendedmoviesurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/recommendations?api_key=$apikey';
    var movietrailersurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/videos?api_key=$apikey';

    var moviedetailresponse = await http.get(Uri.parse(moviedetailurl));
    if (moviedetailresponse.statusCode == 200) {
      var moviedetailjson = jsonDecode(moviedetailresponse.body);
      for (var i = 0; i < 1; i++) {
        MovieDetails.add({
          "backdrop_path": moviedetailjson['backdrop_path'],
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

    var UserReviewresponse = await http.get(Uri.parse(UserReviewurl));
    if (UserReviewresponse.statusCode == 200) {
      var UserReviewjson = jsonDecode(UserReviewresponse.body);
      for (var i = 0; i < UserReviewjson['results'].length; i++) {
        UserReviews.add({
          "name": UserReviewjson['results'][i]['author'],
          "review": UserReviewjson['results'][i]['content'],
          "rating":
              UserReviewjson['results'][i]['author_details']['rating'] == null
              ? "Not Rated"
              : UserReviewjson['results'][i]['author_details']['rating']
                    .toString(),
          "avatarphoto":
              UserReviewjson['results'][i]['author_details']['avatar_path'] ==
                  null
              ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
              : "https://image.tmdb.org/t/p/w500" +
                    UserReviewjson['results'][i]['author_details']['avatar_path'],
          "creationdate": UserReviewjson['results'][i]['created_at'].substring(
            0,
            10,
          ),
          "fullreviewurl": UserReviewjson['results'][i]['url'],
        });
      }
    } else {}

    var similarmoviesresponse = await http.get(Uri.parse(similarmoviesurl));
    if (similarmoviesresponse.statusCode == 200) {
      var similarmoviesjson = jsonDecode(similarmoviesresponse.body);
      for (var i = 0; i < similarmoviesjson['results'].length; i++) {
        similarmovieslist.add({
          "poster_path": similarmoviesjson['results'][i]['poster_path'],
          "name": similarmoviesjson['results'][i]['title'],
          "vote_average": similarmoviesjson['results'][i]['vote_average'],
          "date": similarmoviesjson['results'][i]['release_date'],
          "id": similarmoviesjson['results'][i]['id'],
        });
      }
    } else {}

    var recommendedmoviesresponse = await http.get(
      Uri.parse(recommendedmoviesurl),
    );
    if (recommendedmoviesresponse.statusCode == 200) {
      var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse.body);
      for (var i = 0; i < recommendedmoviesjson['results'].length; i++) {
        recommendedmovieslist.add({
          "poster_path": recommendedmoviesjson['results'][i]['poster_path'],
          "name": recommendedmoviesjson['results'][i]['title'],
          "vote_average": recommendedmoviesjson['results'][i]['vote_average'],
          "date": recommendedmoviesjson['results'][i]['release_date'],
          "id": recommendedmoviesjson['results'][i]['id'],
        });
      }
    } else {}

    var movietrailersresponse = await http.get(Uri.parse(movietrailersurl));
    if (movietrailersresponse.statusCode == 200) {
      var movietrailersjson = jsonDecode(movietrailersresponse.body);
      for (var i = 0; i < movietrailersjson['results'].length; i++) {
        if (movietrailersjson['results'][i]['type'] == "Trailer") {
          movietrailerslist.add({
            "key": movietrailersjson['results'][i]['key'],
          });
        }
      }
      movietrailerslist.add({'key': 'aJ0cZTcTh90'});
    } else {}
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
      body: FutureBuilder(
        future: Moviedetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CustomScrollView(
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
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      iconSize: 28,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false,
                        );
                      },
                      icon: Icon(FontAwesomeIcons.houseUser),
                      iconSize: 25,
                      color: Colors.white,
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
                      child: trailerwatch(
                        trailerytid: movietrailerslist[0]['key'],
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

                    // User Reviews
                    if (UserReviews.isNotEmpty)
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
                    if (UserReviews.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: UserReview(reviewDetails: UserReviews),
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
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
        },
      ),
    );
  }
}
