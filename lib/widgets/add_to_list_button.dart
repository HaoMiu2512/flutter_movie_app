import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/watchlist.dart';
import '../services/watchlist_service.dart';
import 'custom_snackbar.dart';

class AddToListButton extends StatefulWidget {
  final String itemId;
  final String itemType; // 'movie', 'tv', 'trending', 'upcoming'
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final Color iconColor;
  final double iconSize;

  const AddToListButton({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    this.iconColor = Colors.white,
    this.iconSize = 26,
  });

  @override
  State<AddToListButton> createState() => _AddToListButtonState();
}

class _AddToListButtonState extends State<AddToListButton> {
  bool _isInList = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkIfInList();
  }

  Future<void> _checkIfInList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isChecking = false;
      });
      return;
    }

    try {
      final result = await WatchlistService.checkItemInWatchlists(
        itemId: widget.itemId,
        itemType: widget.itemType,
      );

      if (mounted) {
        setState(() {
          _isInList = result?.isInAnyList ?? false;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _showAddToListDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBar.showError(context, 'Please login to add to lists');
      return;
    }

    // Load watchlists
    final watchlists = await WatchlistService.getUserWatchlists();

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AddToListDialog(
        itemId: widget.itemId,
        itemType: widget.itemType,
        title: widget.title,
        posterPath: widget.posterPath,
        backdropPath: widget.backdropPath,
        overview: widget.overview,
        releaseDate: widget.releaseDate,
        voteAverage: widget.voteAverage,
        watchlists: watchlists,
      ),
    );

    if (result == true) {
      _checkIfInList(); // Refresh status
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.iconColor.withValues(alpha: 0.5),
        ),
      );
    }

    return IconButton(
      onPressed: _showAddToListDialog,
      icon: Icon(
        _isInList ? Icons.bookmark : Icons.bookmark_border,
      ),
      iconSize: widget.iconSize,
      color: _isInList ? Colors.cyan : widget.iconColor,
      tooltip: _isInList ? 'In your lists' : 'Add to list',
    );
  }
}

class _AddToListDialog extends StatefulWidget {
  final String itemId;
  final String itemType;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final List<Watchlist> watchlists;

  const _AddToListDialog({
    required this.itemId,
    required this.itemType,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    required this.watchlists,
  });

  @override
  State<_AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<_AddToListDialog> {
  bool _isCreatingNew = false;
  final _newListNameController = TextEditingController();

  @override
  void dispose() {
    _newListNameController.dispose();
    super.dispose();
  }

  Future<void> _addToList(Watchlist watchlist) async {
    // Check if already in this list
    if (watchlist.containsItem(widget.itemId, widget.itemType)) {
      CustomSnackBar.showAlreadyExists(context, 'Already in "${watchlist.name}"');
      return;
    }

    final success = await WatchlistService.addItemToWatchlist(
      watchlistId: watchlist.id,
      itemId: widget.itemId,
      itemType: widget.itemType,
      title: widget.title,
      posterPath: widget.posterPath,
      backdropPath: widget.backdropPath,
      overview: widget.overview,
      releaseDate: widget.releaseDate,
      voteAverage: widget.voteAverage,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      CustomSnackBar.showSuccess(context, 'Added to "${watchlist.name}"');
    } else if (mounted) {
      CustomSnackBar.showError(context, 'Failed to add to list');
    }
  }

  Future<void> _createNewListAndAdd() async {
    final name = _newListNameController.text.trim();
    if (name.isEmpty) {
      CustomSnackBar.showError(context, 'Please enter a list name');
      return;
    }

    // Create new list
    final newWatchlist = await WatchlistService.createWatchlist(name: name);
    if (newWatchlist == null) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Failed to create list');
      }
      return;
    }

    // Add item to the new list
    final success = await WatchlistService.addItemToWatchlist(
      watchlistId: newWatchlist.id,
      itemId: widget.itemId,
      itemType: widget.itemType,
      title: widget.title,
      posterPath: widget.posterPath,
      backdropPath: widget.backdropPath,
      overview: widget.overview,
      releaseDate: widget.releaseDate,
      voteAverage: widget.voteAverage,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      CustomSnackBar.showSuccess(context, 'Created "$name" and added item');
    } else if (mounted) {
      CustomSnackBar.showWarning(context, 'List created but failed to add item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 25, 25, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      title: Row(
        children: [
          const Icon(Icons.bookmark_add, color: Colors.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add to List',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  if (widget.posterPath != null && widget.posterPath!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w92${widget.posterPath}',
                        height: 60,
                        width: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 42,
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, color: Colors.grey, size: 20),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 60,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.movie, color: Colors.grey, size: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.itemType.toUpperCase(),
                          style: TextStyle(
                            color: Colors.cyan.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Lists
            if (widget.watchlists.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No lists yet. Create one below!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.watchlists.length,
                  itemBuilder: (context, index) {
                    final watchlist = widget.watchlists[index];
                    final isInList = watchlist.containsItem(widget.itemId, widget.itemType);
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isInList ? Icons.check_circle : Icons.playlist_add,
                        color: isInList ? Colors.green : Colors.cyan,
                      ),
                      title: Text(
                        watchlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${watchlist.itemCount} items',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      trailing: isInList
                          ? const Text(
                              'Already added',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: isInList ? null : () => _addToList(watchlist),
                      enabled: !isInList,
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.cyan, height: 1),
            const SizedBox(height: 16),
            
            // Create new list
            if (!_isCreatingNew)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isCreatingNew = true;
                  });
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.cyan),
                label: const Text(
                  'Create New List',
                  style: TextStyle(color: Colors.cyan),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _newListNameController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'New List Name',
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isCreatingNew = false;
                            _newListNameController.clear();
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _createNewListAndAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create & Add'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Close',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }
}
