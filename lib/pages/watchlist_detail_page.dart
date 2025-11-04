import 'package:flutter/material.dart';
import '../models/watchlist.dart';
import '../services/watchlist_service.dart';
import '../utils/page_transitions.dart';
import '../details/moviesdetail.dart';
import '../details/tvseriesdetail.dart';
import '../widgets/custom_snackbar.dart';

class WatchlistDetailPage extends StatefulWidget {
  final Watchlist watchlist;

  const WatchlistDetailPage({super.key, required this.watchlist});

  @override
  State<WatchlistDetailPage> createState() => _WatchlistDetailPageState();
}

class _WatchlistDetailPageState extends State<WatchlistDetailPage> {
  late Watchlist _watchlist;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _watchlist = widget.watchlist;
  }

  Future<void> _refreshWatchlist() async {
    setState(() {
      _isLoading = true;
    });

    final watchlist = await WatchlistService.getWatchlist(_watchlist.id);
    if (watchlist != null && mounted) {
      setState(() {
        _watchlist = watchlist;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(WatchlistItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 25, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Text(
          'Remove Item',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${item.title}" from this list?',
          style: const TextStyle(color: Colors.white70),
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
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && item.id != null) {
      final success = await WatchlistService.removeItemFromWatchlist(
        watchlistId: _watchlist.id,
        itemId: item.id!,
      );

      if (success && mounted) {
        CustomSnackBar.showSuccess(context, 'Item removed');
        _refreshWatchlist();
      } else if (mounted) {
        CustomSnackBar.showError(context, 'Failed to remove item');
      }
    }
  }

  void _openItemDetail(WatchlistItem item) {
    // Parse the itemId back to int for detail pages
    final itemId = int.tryParse(item.itemId) ?? 0;
    
    if (item.itemType == 'movie' || item.itemType == 'upcoming' || item.itemType == 'trending') {
      context.smoothToPage(
        MoviesDetail(
          id: itemId.toString(),
        ),
      );
    } else if (item.itemType == 'tv') {
      context.smoothToPage(
        TvSeriesDetail(
          id: itemId.toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 15, 25),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 20, 35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _watchlist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_watchlist.itemCount} items',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color.fromARGB(255, 25, 25, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteWatchlist();
              } else if (value == 'edit') {
                _editWatchlist();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.cyan, size: 20),
                    SizedBox(width: 12),
                    Text('Edit List', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete List', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )
          : _watchlist.items.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this list',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding movies and TV shows!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _watchlist.items.length,
      itemBuilder: (context, index) {
        final item = _watchlist.items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(WatchlistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => _openItemDetail(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster
              if (item.posterPath != null && item.posterPath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w200${item.posterPath}',
                    height: 100,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 70,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 100,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.itemType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (item.voteAverage != null && item.voteAverage! > 0) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                item.voteAverage!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    if (item.releaseDate != null && item.releaseDate!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.releaseDate!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Remove button
              IconButton(
                onPressed: () => _removeItem(item),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteWatchlist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 25, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        title: const Text(
          'Delete List',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${_watchlist.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
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
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await WatchlistService.deleteWatchlist(_watchlist.id);
      if (success && mounted) {
        Navigator.pop(context, true); // Return true to signal deletion
        CustomSnackBar.showSuccess(
          context,
          'List deleted',
        );
      } else if (mounted) {
        CustomSnackBar.showError(
          context,
          'Failed to delete list',
        );
      }
    }
  }

  Future<void> _editWatchlist() async {
    final nameController = TextEditingController(text: _watchlist.name);
    bool isPublic = _watchlist.isPublic;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 25, 25, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.cyan),
              SizedBox(width: 12),
              Text(
                'Edit List',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'List Name',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.cyan),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: isPublic,
                    onChanged: (value) {
                      setDialogState(() {
                        isPublic = value;
                      });
                    },
                    activeColor: Colors.cyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Make list public',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ],
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
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final watchlist = await WatchlistService.updateWatchlist(
        watchlistId: _watchlist.id,
        name: nameController.text.trim(),
        description: _watchlist.description, // Keep existing description
        isPublic: isPublic,
      );

      if (watchlist != null && mounted) {
        setState(() {
          _watchlist = watchlist;
        });
        CustomSnackBar.showSuccess(
          context,
          'List updated',
        );
      } else if (mounted) {
        CustomSnackBar.showError(
          context,
          'Failed to update list',
        );
      }
    }
  }
}
