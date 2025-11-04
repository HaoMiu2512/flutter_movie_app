import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/watchlist.dart';
import '../services/watchlist_service.dart';
import 'watchlist_detail_page.dart';
import '../utils/page_transitions.dart';
import '../widgets/custom_snackbar.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  List<Watchlist> _watchlists = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadWatchlists();
  }

  Future<void> _checkAuthAndLoadWatchlists() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });

    if (_isLoggedIn) {
      await _loadWatchlists();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWatchlists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final watchlists = await WatchlistService.getUserWatchlists();
      if (mounted) {
        setState(() {
          _watchlists = watchlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackBar.showError(context, 'Error loading watchlists: $e');
      }
    }
  }

  Future<void> _showCreateListDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 25, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Icon(Icons.playlist_add, color: Colors.cyan),
            SizedBox(width: 12),
            Text(
              'Create New List',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'List Name',
            hintText: 'Enter list name',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.cyan, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final watchlist = await WatchlistService.createWatchlist(
        name: nameController.text.trim(),
      );

      if (watchlist != null) {
        if (mounted) {
          CustomSnackBar.showSuccess(context, 'List created successfully');
          _loadWatchlists();
        }
      } else {
        if (mounted) {
          CustomSnackBar.showError(context, 'Failed to create list');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 15, 15, 25),
              Color.fromARGB(255, 25, 25, 40),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Please login to create lists',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 15, 15, 25),
              Color.fromARGB(255, 25, 25, 40),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.cyan),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 15, 15, 25),
            Color.fromARGB(255, 25, 25, 40),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadWatchlists,
        color: Colors.cyan,
        child: _watchlists.isEmpty
            ? _buildEmptyState()
            : _buildWatchlistGrid(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_filter_outlined,
                size: 80,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No lists yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first list to organize movies & TV shows',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreateListDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistGrid() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Lists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _showCreateListDialog,
              icon: const Icon(Icons.add_circle, color: Colors.cyan, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _watchlists.length,
          itemBuilder: (context, index) {
            final watchlist = _watchlists[index];
            return _buildWatchlistCard(watchlist);
          },
        ),
      ],
    );
  }

  Widget _buildWatchlistCard(Watchlist watchlist) {
    // Get first item's poster
    final firstPoster = watchlist.items.isNotEmpty && 
                        watchlist.items.first.posterPath != null &&
                        watchlist.items.first.posterPath!.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${watchlist.items.first.posterPath}'
        : null;

    return GestureDetector(
      onTap: () async {
        final result = await context.smoothToPage(WatchlistDetailPage(watchlist: watchlist));
        // If list was deleted or modified, reload the list
        if (result == true && mounted) {
          _loadWatchlists();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.withValues(alpha: 0.1),
              Colors.teal.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Single Poster Preview
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: firstPoster != null
                    ? Image.network(
                        firstPoster,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Icon(
                            Icons.movie_filter_outlined,
                            size: 60,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
              ),
            ),
            
            // List Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            watchlist.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (watchlist.isPublic)
                          Icon(
                            Icons.public,
                            color: Colors.cyan.withValues(alpha: 0.7),
                            size: 16,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.movie_outlined,
                          color: Colors.cyan,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${watchlist.itemCount} items',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
