import 'package:flutter/material.dart';
import 'package:flutter_movie_app/details/moviesdetail.dart';
import 'package:flutter_movie_app/details/tvseriesdetail.dart';

Widget sliderlist(
  List firstlistname,
  String categorytitle,
  String type,
  int itemcount,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 15, bottom: 40),
        child: Text(categorytitle.toString()),
      ),
      SizedBox(
        height: 250,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: itemcount,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (type == 'movie') {
                  // print(firstlistname[index]['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MoviesDetail(id: firstlistname[index]['id']),
                    ),
                  );
                } else if (type == 'tv') {
                  // print(firstlistname[index]['id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TvSeriesDetail(id: firstlistname[index]['id']),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.2),
                      BlendMode.darken,
                    ),
                    image: NetworkImage(
                      'https://image.tmdb.org/t/p/w500${firstlistname[index]['poster_path']}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: EdgeInsets.only(left: 13),
                width: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 6),
                      child: Text(firstlistname[index]['date']),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 2.0,
                            bottom: 2.0,
                            left: 5.0,
                            right: 5.0,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 15,
                              ),
                              SizedBox(width: 2),
                              Text(
                                firstlistname[index]['vote_average'].toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
