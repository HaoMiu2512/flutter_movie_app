import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_movie_app/details/checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie_app/reapeatedfunction/searchbarfunction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:flutter_movie_app/HomePage/SectionPage/movies.dart';
import 'package:flutter_movie_app/HomePage/SectionPage/tvseries.dart';
import 'package:flutter_movie_app/HomePage/SectionPage/upcoming.dart';
import 'package:flutter_movie_app/LoginPage/login_page.dart';
import 'package:flutter_movie_app/pages/favorites_page.dart';
import 'package:flutter_movie_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final String? username;
  const HomePage({super.key, this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> trendingweek = [];
  int uval = 1;

  Future<void> trendinglist(int checkerno) async {
    if (checkerno == 1) {
      var trendingweekurl =
          'https://api.themoviedb.org/3/trending/all/week?api_key=$apikey';
      var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
      if (trendingweekresponse.statusCode == 200) {
        var tempdata = jsonDecode(trendingweekresponse.body);
        var trendingweekjson = tempdata['results'];
        for (var i = 0; i < trendingweekjson.length; i++) {
          trendingweek.add({
            'id': trendingweekjson[i]['id'],
            'poster_path': trendingweekjson[i]['poster_path'],
            'vote_average': trendingweekjson[i]['vote_average'],
            'media_type': trendingweekjson[i]['media_type'],
            'indexno': i,
          });
        }
      }
    } else if (checkerno == 2) {
      var trendingweekurl =
          'https://api.themoviedb.org/3/trending/all/day?api_key=${apikey}';
      var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
      if (trendingweekresponse.statusCode == 200) {
        var tempdata = jsonDecode(trendingweekresponse.body);
        var trendingweekjson = tempdata['results'];
        for (var i = 0; i < trendingweekjson.length; i++) {
          trendingweek.add({
            'id': trendingweekjson[i]['id'],
            'poster_path': trendingweekjson[i]['poster_path'],
            'vote_average': trendingweekjson[i]['vote_average'],
            'media_type': trendingweekjson[i]['media_type'],
            'indexno': i,
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A1929),
      child: Column(
        children: [
          // Header với logo và tên người dùng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.cyan.withValues(alpha: 0.3),
                  Colors.teal.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.cyan, Colors.tealAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.movie_filter,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Greeting
                  const Text(
                    'Hello,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Username
                  Text(
                    widget.username ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Menu items
          // Home button
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.home,
                color: Colors.cyan[400],
                size: 24,
              ),
            ),
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Favorites button
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.red[400],
                size: 24,
              ),
            ),
            title: const Text(
              'My Favorites',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
            },
          ),

          // Profile button
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                color: Colors.purple[400],
                size: 24,
              ),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),

          const Spacer(),

          // Divider
          Divider(
            color: Colors.cyan.withValues(alpha: 0.3),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          // Logout button
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout,
                color: Colors.red[400],
                size: 24,
              ),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF0A1929),
                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.cyan[400]),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);

    return Scaffold(
        backgroundColor: const Color(0xFF001E3C),
        drawer: _buildDrawer(context),
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  backgroundColor: const Color(0xFF0A1929).withValues(alpha: 0.95),
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trending Title với gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.cyan, Colors.tealAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'TRENDING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fire icon với animation
                        const Text(
                          '🔥',
                          style: TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 16),
                        // Dropdown với design mới
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan.withValues(alpha: 0.2),
                                Colors.teal.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: DropdownButton(
                            autofocus: true,
                            underline: Container(height: 0),
                            dropdownColor: Colors.black.withValues(alpha: 0.9),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                            value: uval,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text(
                                  'Weekly',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text(
                                  'Daily',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                trendingweek.clear();
                                uval = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  toolbarHeight: 60,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.5,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: FutureBuilder(
                      future: trendinglist(uval),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CarouselSlider(
                            options: CarouselOptions(
                                viewportFraction: 1,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 2),
                                height: MediaQuery.of(context).size.height),
                            items: trendingweek.map((i) {
                              return Builder(builder: (BuildContext context) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Descriptioncheckui(i['id'],
                                                      i['media_type'])));
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                colorFilter: ColorFilter.mode(
                                                    Colors.black
                                                        .withValues(alpha: 0.3),
                                                    BlendMode.darken),
                                                image: NetworkImage(
                                                    'https://image.tmdb.org/t/p/w500${i['poster_path']}'),
                                                fit: BoxFit.cover)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(alpha: 0.7),
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            left: 16,
                                                            bottom: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.amber
                                                              .withValues(alpha: 0.9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          '# ${i['indexno'] + 1}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 16,
                                                                  bottom: 10),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.6),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .amber
                                                                  .withValues(
                                                                      alpha: 0.5),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber,
                                                                    size: 18),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                    '${i['vote_average'].toStringAsFixed(1)}',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600))
                                                              ]))
                                                    ])
                                              ]),
                                        )));
                              });
                            }).toList(),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Colors.amber,
                          ));
                        }
                      },
                    ),
                  )),
              SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A1929),
                        Color(0xFF001E3C),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Searchbarfunction(),
                      const SizedBox(height: 20),
                      // Tabs với design mới
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.cyan.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: TabBar(
                            dividerColor: Colors.transparent,
                            physics: const BouncingScrollPhysics(),
                            labelPadding: EdgeInsets.zero,
                            controller: tabController,
                            indicator: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan.withValues(alpha: 0.6),
                                  Colors.teal.withValues(alpha: 0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor:
                                Colors.white.withValues(alpha: 0.5),
                            tabs: const [
                              Tab(
                                  child: Center(
                                      child: Text('TV SERIES',
                                          textAlign: TextAlign.center))),
                              Tab(
                                  child: Center(
                                      child: Text('MOVIES',
                                          textAlign: TextAlign.center))),
                              Tab(
                                  child: Center(
                                      child: Text('UPCOMING',
                                          textAlign: TextAlign.center))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                          height: 1100,
                          width: MediaQuery.of(context).size.width,
                          child: TabBarView(
                              controller: tabController,
                              children: const [
                                TvSeries(),
                                Movies(),
                                Upcoming(),
                              ]))
                    ],
                  ),
                ),
              ]))
            ]));
  }
}