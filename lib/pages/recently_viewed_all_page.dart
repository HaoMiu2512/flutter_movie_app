import 'package:flutter/material.dart';
import '../services/recently_viewed_service.dart';
import '../models/movie.dart';
import '../details/moviesdetail.dart';
import '../details/tvseriesdetail.dart';

class RecentlyViewedAllPage extends StatefulWidget {
  const RecentlyViewedAllPage({super.key});

  @override
  State<RecentlyViewedAllPage> createState() => _RecentlyViewedAllPageState();
}

class _RecentlyViewedAllPageState extends State<RecentlyViewedAllPage> {
  final RecentlyViewedService _recentlyViewedService = RecentlyViewedService();

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1929),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 28),
            const SizedBox(width: 12),
            const Text(
              'Clear History?',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all recently viewed movies? This action cannot be undone.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _recentlyViewedService.clearAllRecentlyViewed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Recently viewed cleared successfully'
                  : 'Failed to clear recently viewed',
            ),
            backgroundColor: success ? Colors.green[700] : Colors.red[700],
            duration: const Duration(seconds: 2),
          ),
        );
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E3C),
      appBar: AppBar(
        title: const Text(
          'Recently Viewed',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A1929),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _confirmClearAll,
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[300],
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1929),
              Color(0xFF001E3C),
              Color(0xFF000000),
            ],
          ),
        ),
        child: StreamBuilder<List<Movie>>(
          stream: _recentlyViewedService.getRecentlyViewedStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyan),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading recently viewed',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final movies = snapshot.data ?? [];

            if (movies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No recently viewed movies',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Movies you view will appear here',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return _buildMovieCard(movie);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    // Ensure posterPath starts with /
    final posterUrl = movie.posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath.startsWith('/') ? movie.posterPath : '/${movie.posterPath}'}'
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => movie.mediaType == 'tv'
                ? TvSeriesDetail(id: movie.id)
                : MoviesDetail(id: movie.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.cyan,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: ${movie.posterPath}');
                              print('Error: $error');
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No poster',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                // Media type badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: movie.mediaType == 'tv'
                          ? Colors.purple[700]
                          : Colors.blue[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      movie.mediaType == 'tv' ? 'TV' : 'MOVIE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Movie Title
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Rating
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
