import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_movie_app/apikey/apikey.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_movie_app/details/checker.dart';

class Searchbarfunction extends StatefulWidget {
  const Searchbarfunction({super.key});

  @override
  State<Searchbarfunction> createState() => _SearchbarfunctionState();
}

class _SearchbarfunctionState extends State<Searchbarfunction> {
  List<Map<String, dynamic>> searchresult = [];

  Future<void> searchlistfunction(val) async {
    var searchurl =
        'https://api.themoviedb.org/3/search/multi?api_key=$apikey&query=$val';
    var searchresponse = await http.get(Uri.parse(searchurl));
    if (searchresponse.statusCode == 200) {
      var tempdata = jsonDecode(searchresponse.body);
      var searchjson = tempdata['results'];
      for (var i = 0; i < searchjson.length; i++) {
        //only add value if all are present
        if (searchjson[i]['id'] != null &&
            searchjson[i]['poster_path'] != null &&
            searchjson[i]['vote_average'] != null &&
            searchjson[i]['media_type'] != null) {
          searchresult.add({
            'id': searchjson[i]['id'],
            'poster_path': searchjson[i]['poster_path'],
            'vote_average': searchjson[i]['vote_average'],
            'media_type': searchjson[i]['media_type'],
            'popularity': searchjson[i]['popularity'],
            'overview': searchjson[i]['overview'],
            'title': searchjson[i]['title'] ?? searchjson[i]['name'] ?? 'Unknown',
            'release_date': searchjson[i]['release_date'] ?? searchjson[i]['first_air_date'] ?? '',
          });

          if (searchresult.length > 20) {
            searchresult.removeRange(20, searchresult.length);
          }
        } else {
          print('null value found');
        }
      }
    }
  }

  final TextEditingController searchtext = TextEditingController();
  bool showlist = false;
  var val1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        showlist = !showlist;
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          top: 30,
          bottom: 20,
          right: 10,
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                autofocus: false,
                controller: searchtext,
                onSubmitted: (value) {
                  searchresult.clear();
                  setState(() {
                    val1 = value;
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
                onChanged: (value) {
                  searchresult.clear();

                  setState(() {
                    val1 = value;
                  });
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(
                        webBgColor: "#000000",
                        webPosition: "center",
                        webShowClose: true,
                        msg: "Search Cleared",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                      setState(() {
                        searchtext.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                      });
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.cyan.withValues(alpha: 0.6),
                    ),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.cyan),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            //
            //
            SizedBox(height: 5),

            searchtext.text.isNotEmpty
                ? FutureBuilder(
                    future: searchlistfunction(val1),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          height: 400,
                          child: ListView.builder(
                            itemCount: searchresult.length,
                            scrollDirection: Axis.vertical,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final result = searchresult[index];
                              return _buildSearchResultCard(context, result);
                            },
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.cyan),
                        );
                      }
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // Build beautiful search result card similar to favorites page
  Widget _buildSearchResultCard(BuildContext context, Map<String, dynamic> result) {
    return Card(
      color: const Color(0xFF001E3C),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Descriptioncheckui(
                result['id'],
                result['media_type'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: result['poster_path'] != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${result['poster_path']}',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Movie Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      result['title'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Media Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: result['media_type'] == 'movie'
                            ? Colors.blue.withValues(alpha: 0.3)
                            : Colors.purple.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: result['media_type'] == 'movie'
                              ? Colors.blue
                              : Colors.purple,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        result['media_type'] == 'movie' ? 'MOVIE' : 'TV SERIES',
                        style: TextStyle(
                          color: result['media_type'] == 'movie'
                              ? Colors.blue[200]
                              : Colors.purple[200],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating & Release Date
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result['vote_average'] != null
                              ? result['vote_average'].toStringAsFixed(1)
                              : 'N/A',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            result['release_date'] != null && result['release_date'].toString().isNotEmpty
                                ? result['release_date'].toString().split('-')[0]
                                : 'N/A',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Overview
                    Text(
                      result['overview'] ?? 'No description available',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
