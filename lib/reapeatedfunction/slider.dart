import 'package:flutter/material.dart';
import 'package:flutter_movie_app/details/moviesdetail.dart';
import 'package:flutter_movie_app/details/tvseriesdetail.dart';
import '../pages/view_all_page.dart';
import '../utils/page_transitions.dart';

Widget sliderlist(
  List firstlistname,
  String categorytitle,
  String type,
  int itemcount, {
  String? apiEndpoint,
  BuildContext? context,
  bool useBackendApi = false, // New parameter
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 15, right: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categorytitle.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.cyan[300],
              ),
            ),
            if (apiEndpoint != null && apiEndpoint.isNotEmpty && context != null)
              GestureDetector(
                onTap: () {
                  // Smooth transition to View All page
                  context.slideUpToPage(
                    ViewAllPage(
                      title: categorytitle,
                      apiEndpoint: apiEndpoint,
                      mediaType: type,
                      useBackendApi: useBackendApi, // Pass the flag
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan.withValues(alpha: 0.3), Colors.teal.withValues(alpha: 0.2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.cyan.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.cyan[200],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.cyan[200],
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 30),
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
                  // Smooth transition to movie details
                  context.smoothToPage(
                    MoviesDetail(id: firstlistname[index]['id']),
                  );
                } else if (type == 'tv') {
                  // Smooth transition to TV series details
                  context.smoothToPage(
                    TvSeriesDetail(id: firstlistname[index]['id']),
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
                          color: Colors.cyan.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.5),
                            width: 1,
                          ),
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
                                color: Colors.amber,
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
