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
import 'package:flutter_movie_app/models/movie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  bool _isFavorite = false;

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

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E3C),
      body: FutureBuilder(
          future: tvseriesdetailfunc(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CustomScrollView(
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
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                    (route) => false);
                              },
                              icon: Icon(FontAwesomeIcons.houseUser),
                              iconSize: 25,
                              color: Colors.white)
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
                      // addtofavoriate(
                      //   id: widget.id,
                      //   type: 'tv',
                      //   Details: TvSeriesDetails,
                      // ),
                      Row(children: [
                        Container(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: tvseriesdetaildata['genres']!.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      margin: EdgeInsets.only(right: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.cyan.withValues(alpha: 0.2),
                                              Colors.teal.withValues(alpha: 0.1),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.cyan.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                      ),
                                      child: Text(
                                          TvSeriesDetails[index + 1]['genre']
                                              .toString()));
                                }))
                      ]),
                      Container(
                          padding: EdgeInsets.only(left: 10, top: 12),
                          child: Text("Series Overview : ")),

                      Container(
                          padding: EdgeInsets.only(left: 10, top: 20),
                          child: Text(
                              TvSeriesDetails[0]['overview'].toString())),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 10),
                        child: UserReview(reviewDetails: TvSeriesReview),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 10, top: 20),
                          child: Text(
                              "Status : ${TvSeriesDetails[0]['status']}")),
                      //created by
                      // Container(
                      //     padding: EdgeInsets.only(left: 10, top: 20),
                      //     child: Text("Created By : ")),
                      // Container(
                      //     padding: EdgeInsets.only(left: 10, top: 10),
                      //     height: 150,
                      //     width: MediaQuery.of(context).size.width,
                      //     child: ListView.builder(
                      //         physics: BouncingScrollPhysics(),
                      //         scrollDirection: Axis.horizontal,
                      //         itemCount:
                      //             tvseriesdetaildata['created_by']!.length,
                      //         itemBuilder: (context, index) {
                      //           //generes box
                      //           return Container(
                      //               margin: EdgeInsets.only(right: 10),
                      //               padding: EdgeInsets.all(8),
                      //               decoration: BoxDecoration(
                      //                   color: Color.fromRGBO(25, 25, 25, 1),
                      //                   borderRadius:
                      //                       BorderRadius.circular(10)),
                      //               child: Row(children: [
                      //                 Column(children: [
                      //                   CircleAvatar(
                      //                       radius: 45,
                      //                       backgroundImage: NetworkImage(
                      //                           'https://image.tmdb.org/t/p/w500${TvSeriesDetails[index + 4]['creatorprofile']}')),
                      //                   SizedBox(height: 10),
                      //                   Text(TvSeriesDetails[index + 4]
                      //                           ['creator']
                      //                       .toString())
                      //                 ])
                      //               ]));
                      //         })),
                      Container(
                          padding: EdgeInsets.only(left: 10, top: 20),
                          child: Text(
                              "Total Seasons : ${tvseriesdetaildata['seasons'].length}")),
                      //airdate
                      Container(
                          padding: EdgeInsets.only(left: 10, top: 20),
                          child: Text(
                              "Release date : ${TvSeriesDetails[0]['releasedate']}")),
                      sliderlist(similarserieslist, 'Similar Series', 'tv',
                          similarserieslist.length),
                      sliderlist(recommendserieslist, 'Recommended Series',
                          'tv', recommendserieslist.length),
                      Container(
                          //     height: 50,
                          //     child: Center(child: normaltext("By Niranjan Dahal"))
                          )
                    ]))
                  ]);
            } else {
              return Center(
                  child:
                      CircularProgressIndicator(color: Colors.amber.shade400));
            }
          }),
    );
  }
}