import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class FavoritesService {
  // Singleton pattern
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache for favorites
  List<Movie>? _cachedFavorites;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get favorites collection reference for current user
  CollectionReference? get _favoritesCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('favorites');
  }

  // Get all favorite movies
  Future<List<Movie>> getFavorites() async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('FavoritesService: User not logged in');
        return [];
      }

      print('FavoritesService: Fetching favorites for user $_userId');
      final snapshot = await _favoritesCollection!
          .orderBy('addedAt', descending: true)
          .get();

      _cachedFavorites = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();

      print('FavoritesService: Found ${_cachedFavorites!.length} favorites');
      return _cachedFavorites!;
    } catch (e) {
      print('FavoritesService Error getting favorites: $e');
      // Clear cache on error
      _cachedFavorites = null;
      return [];
    }
  }

  // Add movie to favorites
  Future<bool> addToFavorites(Movie movie) async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('FavoritesService: Cannot add - user not logged in');
        return false;
      }

      // Check if already exists
      final docId = '${movie.mediaType}_${movie.id}';
      final existingDoc = await _favoritesCollection!.doc(docId).get();

      if (existingDoc.exists) {
        print('FavoritesService: Movie already in favorites: $docId');
        return false; // Already in favorites
      }

      // Add to Firestore
      final movieData = movie.toJson();
      movieData['addedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _favoritesCollection!.doc(docId).set(movieData);

      print('FavoritesService: Added to favorites: ${movie.title} ($docId)');

      // Clear cache to force refresh
      _cachedFavorites = null;

      return true;
    } catch (e) {
      print('FavoritesService Error adding to favorites: $e');
      return false;
    }
  }

  // Remove movie from favorites
  Future<bool> removeFromFavorites(int movieId, String mediaType) async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('FavoritesService: Cannot remove - user not logged in');
        return false;
      }

      final docId = '${mediaType}_$movieId';
      await _favoritesCollection!.doc(docId).delete();

      print('FavoritesService: Removed from favorites: $docId');

      // Clear cache to force refresh
      _cachedFavorites = null;

      return true;
    } catch (e) {
      print('FavoritesService Error removing from favorites: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Movie movie) async {
    final isFavorite = await isFavoriteMovie(movie.id, movie.mediaType);

    if (isFavorite) {
      return await removeFromFavorites(movie.id, movie.mediaType);
    } else {
      return await addToFavorites(movie);
    }
  }

  // Check if movie is in favorites
  Future<bool> isFavoriteMovie(int movieId, String mediaType) async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        return false;
      }

      final docId = '${mediaType}_$movieId';
      final doc = await _favoritesCollection!.doc(docId).get();

      return doc.exists;
    } catch (e) {
      print('FavoritesService Error checking favorite status: $e');
      return false;
    }
  }

  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('FavoritesService: Cannot clear - user not logged in');
        return false;
      }

      final snapshot = await _favoritesCollection!.get();

      if (snapshot.docs.isEmpty) {
        print('FavoritesService: No favorites to clear');
        return true;
      }

      // Delete all documents in batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('FavoritesService: Cleared ${snapshot.docs.length} favorites');

      // Clear cache
      _cachedFavorites = [];

      return true;
    } catch (e) {
      print('FavoritesService Error clearing favorites: $e');
      return false;
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        return 0;
      }

      final snapshot = await _favoritesCollection!.get();
      final count = snapshot.docs.length;

      print('FavoritesService: Total favorites count: $count');
      return count;
    } catch (e) {
      print('FavoritesService Error getting favorites count: $e');
      return 0;
    }
  }

  // Refresh cache (call after external changes)
  Future<void> refreshCache() async {
    _cachedFavorites = null;
    await getFavorites();
  }

  // Stream of favorites for real-time updates
  Stream<List<Movie>> getFavoritesStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _favoritesCollection!
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();
    });
  }
}
