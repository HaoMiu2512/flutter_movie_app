import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class RecentlyViewedService {
  // Singleton pattern
  static final RecentlyViewedService _instance = RecentlyViewedService._internal();
  factory RecentlyViewedService() => _instance;
  RecentlyViewedService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Maximum number of recently viewed items to keep
  static const int maxRecentlyViewed = 20;

  // Cache for recently viewed movies
  List<Movie>? _cachedRecentlyViewed;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get recently viewed collection reference for current user
  CollectionReference? get _recentlyViewedCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('recently_viewed');
  }

  // Get all recently viewed movies
  Future<List<Movie>> getRecentlyViewed() async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('RecentlyViewedService: User not logged in');
        return [];
      }

      print('RecentlyViewedService: Fetching recently viewed for user $_userId');
      final snapshot = await _recentlyViewedCollection!
          .orderBy('viewedAt', descending: true)
          .limit(maxRecentlyViewed)
          .get();

      _cachedRecentlyViewed = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();

      print('RecentlyViewedService: Found ${_cachedRecentlyViewed!.length} recently viewed movies');
      return _cachedRecentlyViewed!;
    } catch (e) {
      print('RecentlyViewedService Error getting recently viewed: $e');
      // Clear cache on error
      _cachedRecentlyViewed = null;
      return [];
    }
  }

  // Add movie to recently viewed
  Future<bool> addToRecentlyViewed(Movie movie) async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('RecentlyViewedService: Cannot add - user not logged in');
        return false;
      }

      final docId = '${movie.mediaType}_${movie.id}';

      // Add or update the movie with current timestamp
      final movieData = movie.toJson();
      movieData['viewedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _recentlyViewedCollection!.doc(docId).set(movieData);

      print('RecentlyViewedService: Added to recently viewed: ${movie.title} ($docId)');

      // Clean up old entries if exceeding max limit
      await _cleanupOldEntries();

      // Clear cache to force refresh
      _cachedRecentlyViewed = null;

      return true;
    } catch (e) {
      print('RecentlyViewedService Error adding to recently viewed: $e');
      return false;
    }
  }

  // Clean up old entries to keep only the most recent ones
  Future<void> _cleanupOldEntries() async {
    try {
      if (_userId == null) return;

      final snapshot = await _recentlyViewedCollection!
          .orderBy('viewedAt', descending: true)
          .get();

      if (snapshot.docs.length > maxRecentlyViewed) {
        // Delete older entries
        final batch = _firestore.batch();
        for (int i = maxRecentlyViewed; i < snapshot.docs.length; i++) {
          batch.delete(snapshot.docs[i].reference);
        }
        await batch.commit();
        print('RecentlyViewedService: Cleaned up ${snapshot.docs.length - maxRecentlyViewed} old entries');
      }
    } catch (e) {
      print('RecentlyViewedService Error cleaning up old entries: $e');
    }
  }

  // Remove movie from recently viewed
  Future<bool> removeFromRecentlyViewed(int movieId, String mediaType) async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('RecentlyViewedService: Cannot remove - user not logged in');
        return false;
      }

      final docId = '${mediaType}_$movieId';
      await _recentlyViewedCollection!.doc(docId).delete();

      print('RecentlyViewedService: Removed from recently viewed: $docId');

      // Clear cache to force refresh
      _cachedRecentlyViewed = null;

      return true;
    } catch (e) {
      print('RecentlyViewedService Error removing from recently viewed: $e');
      return false;
    }
  }

  // Clear all recently viewed
  Future<bool> clearAllRecentlyViewed() async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        print('RecentlyViewedService: Cannot clear - user not logged in');
        return false;
      }

      final snapshot = await _recentlyViewedCollection!.get();

      if (snapshot.docs.isEmpty) {
        print('RecentlyViewedService: No recently viewed to clear');
        return true;
      }

      // Delete all documents in batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('RecentlyViewedService: Cleared ${snapshot.docs.length} recently viewed');

      // Clear cache
      _cachedRecentlyViewed = [];

      return true;
    } catch (e) {
      print('RecentlyViewedService Error clearing recently viewed: $e');
      return false;
    }
  }

  // Get recently viewed count
  Future<int> getRecentlyViewedCount() async {
    try {
      // Check if user is logged in
      if (_userId == null) {
        return 0;
      }

      final snapshot = await _recentlyViewedCollection!.get();
      final count = snapshot.docs.length;

      print('RecentlyViewedService: Total recently viewed count: $count');
      return count;
    } catch (e) {
      print('RecentlyViewedService Error getting recently viewed count: $e');
      return 0;
    }
  }

  // Refresh cache (call after external changes)
  Future<void> refreshCache() async {
    _cachedRecentlyViewed = null;
    await getRecentlyViewed();
  }

  // Stream of recently viewed for real-time updates
  Stream<List<Movie>> getRecentlyViewedStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _recentlyViewedCollection!
        .orderBy('viewedAt', descending: true)
        .limit(maxRecentlyViewed)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();
    });
  }
}
