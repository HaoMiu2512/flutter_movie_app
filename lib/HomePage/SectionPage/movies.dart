import 'package:flutter/material.dart';
import 'package:flutter_movie_app/reapeatedfunction/slider.dart';
import 'package:flutter_movie_app/services/unified_movie_service.dart';
import 'package:flutter_movie_app/models/movie.dart';

/// Movies Section - Migrated to Backend API ✅
/// Uses UnifiedMovieService for automatic fallback
class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  final UnifiedMovieService _movieService = UnifiedMovieService();
  
  List<Map<String, dynamic>> popularmovies = [];
  List<Map<String, dynamic>> nowplayingmovies = [];
  List<Map<String, dynamic>> topratedmovies = [];
  bool _isLoading = false;
  bool _isLoaded = false;

  // Convert Movie object to Map for compatibility with sliderlist
  Map<String, dynamic> _movieToMap(Movie movie) {
    return {
      "name": movie.title,
      "poster_path": movie.posterPath.startsWith('http')
          ? movie.posterPath
          : movie.posterPath, // Already has full URL from backend
      "vote_average": movie.voteAverage,
      "date": movie.releaseDate,
      "id": movie.id,
    };
  }

  Future<void> moviesfunction() async {
    if (_isLoading || _isLoaded) return; // Prevent multiple calls
    
    setState(() {
      _isLoading = true;
    });

    // Clear lists before loading to prevent duplicates
    popularmovies.clear();
    nowplayingmovies.clear();
    topratedmovies.clear();

    try {
      // Fetch all categories from Backend API (with automatic TMDB fallback)
      final results = await Future.wait([
        _movieService.getPopularMovies(limit: 10),
        _movieService.getNowPlayingMovies(limit: 10),
        _movieService.getTopRatedMovies(limit: 10),
      ]);

      if (mounted) {
        setState(() {
          popularmovies = results[0].map((movie) => _movieToMap(movie)).toList();
          nowplayingmovies = results[1].map((movie) => _movieToMap(movie)).toList();
          topratedmovies = results[2].map((movie) => _movieToMap(movie)).toList();
          _isLoading = false;
          _isLoaded = true;
        });

        print('Movies Section: ✅ Loaded ${popularmovies.length} popular, '
            '${nowplayingmovies.length} now playing, '
            '${topratedmovies.length} top rated movies from Backend');
      }
    } catch (e) {
      print('Movies Section Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    moviesfunction(); // Load once on init
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: Colors.cyan.shade400));
    }

    if (!_isLoaded || popularmovies.isEmpty) {
      return const Center(
        child: Text(
          'No movies available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sliderlist(
            popularmovies,
            "Popular Now",
            "movie",
            popularmovies.length,
            apiEndpoint: '/api/movies/popular', // Backend endpoint for popular
            context: context,
            useBackendApi: true, // Use Backend API
          ),
          sliderlist(
            nowplayingmovies,
            "Now Playing",
            "movie",
            nowplayingmovies.length,
            apiEndpoint: '/api/movies/now-playing', // Backend endpoint for now playing
            context: context,
            useBackendApi: true, // Use Backend API
          ),
          sliderlist(
            topratedmovies,
            "Top Rated",
            "movie",
            topratedmovies.length,
            apiEndpoint: '/api/movies/top-rated', // Backend endpoint
            context: context,
            useBackendApi: true, // Use Backend API
          )
        ]);
  }
}
