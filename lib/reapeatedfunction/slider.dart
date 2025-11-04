import 'package:flutter/material.dart';
import 'package:flutter_movie_app/details/moviesdetail.dart';
import 'package:flutter_movie_app/details/tvseriesdetail.dart';
import '../pages/view_all_page.dart';
import '../utils/page_transitions.dart';
import '../widgets/cached_movie_image.dart';

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
                margin: EdgeInsets.only(left: 13),
                width: 170,
                child: Stack(
                  children: [
                    // Cached image with loading placeholder
                    CachedMoviePoster(
                      posterPath: firstlistname[index]['poster_path'] ?? '',
                      width: 170,
                      height: 250,
                    ),
                    // Date and Rating overlay
                    Positioned(
                      top: 2,
                      left: 6,
                      child: Text(
                        firstlistname[index]['date'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 15,
                            ),
                            SizedBox(width: 2),
                            Text(
                              firstlistname[index]['vote_average'].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
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
