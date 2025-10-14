import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../details/moviesdetail.dart';
import '../details/tvseriesdetail.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Movie> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(Movie movie) async {
    final success = await _favoritesService.removeFromFavorites(
      movie.id,
      movie.mediaType,
    );

    if (success) {
      setState(() {
        _favorites.removeWhere(
          (m) => m.id == movie.id && m.mediaType == movie.mediaType,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie.title} removed from favorites'),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToDetail(Movie movie) {
    if (movie.mediaType == 'movie') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoviesDetail(
            id: movie.id.toString(),
          ),
        ),
      ).then((_) => _loadFavorites()); // Refresh after returning
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TvSeriesDetail(
            id: movie.id.toString(),
          ),
        ),
      ).then((_) => _loadFavorites()); // Refresh after returning
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A1929),
        elevation: 0,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Clear all favorites',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF001E3C),
                    title: const Text(
                      'Clear All Favorites?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'This will remove all movies from your favorites list.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _favoritesService.clearAllFavorites();
                          Navigator.pop(context);
                          _loadFavorites();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyan,
                ),
              )
            : _favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding movies to your favorites!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      color: Colors.cyan,
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final movie = _favorites[index];
          return _buildFavoriteCard(movie);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Movie movie) {
    return Card(
      color: const Color(0xFF001E3C),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToDetail(movie),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: movie.posterPath.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
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
                      movie.title,
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
                        color: movie.mediaType == 'movie'
                            ? Colors.blue[900]
                            : Colors.purple[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie.mediaType == 'movie' ? 'MOVIE' : 'TV SERIES',
                        style: const TextStyle(
                          color: Colors.white,
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
                          movie.voteAverage.toStringAsFixed(1),
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
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate.split('-')[0]
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
                      movie.overview,
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
              const SizedBox(width: 8),

              // Remove Button
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28,
                ),
                onPressed: () => _removeFromFavorites(movie),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
