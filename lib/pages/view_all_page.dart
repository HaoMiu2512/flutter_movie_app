import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../details/checker.dart' show Descriptioncheckui;

class ViewAllPage extends StatefulWidget {
  final String title;
  final String apiEndpoint;
  final String mediaType; // 'movie' or 'tv'
  final bool useBackendApi; // New: Flag to use Backend API

  const ViewAllPage({
    super.key,
    required this.title,
    required this.apiEndpoint,
    required this.mediaType,
    this.useBackendApi = false, // Default to TMDB
  });

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  List<Map<String, dynamic>> items = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  bool hasError = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading && currentPage < totalPages) {
        _loadItems();
      }
    }
  }

  Future<void> _loadItems() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      String url;
      
      if (widget.useBackendApi) {
        // Backend API (paginated)
        url = '${ApiConfig.baseUrl}${widget.apiEndpoint}?page=$currentPage&limit=10';
      } else {
        // TMDB API
        final separator = widget.apiEndpoint.contains('?') ? '&' : '?';
        url = '${widget.apiEndpoint}${separator}page=$currentPage';
      }

      print('ViewAll: Loading from ${widget.useBackendApi ? "Backend" : "TMDB"}: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List results;
        int total;

        if (widget.useBackendApi) {
          // Backend API response format
          if (data['success'] == true && data['data'] != null) {
            results = data['data'] is List ? data['data'] : [];
            total = data['pagination']?['pages'] ?? 1;
          } else {
            results = [];
            total = 1;
          }
        } else {
          // TMDB API response format
          results = data['results'] ?? [];
          total = data['total_pages'] ?? 1;
        }

        setState(() {
          items.addAll(results.map((item) {
            if (widget.useBackendApi) {
              // Backend format - handle both Movies and TV Series
              String posterPath = '';
              if (item['poster'] != null) {
                // Movies use 'poster' field
                posterPath = (item['poster'] as String).replaceAll('https://image.tmdb.org/t/p/w500', '');
              } else if (item['posterPath'] != null) {
                // TV Series use 'posterPath' field
                posterPath = (item['posterPath'] as String).replaceAll('https://image.tmdb.org/t/p/w500', '');
              }

              return {
                'id': item['tmdbId'] ?? item['id'],
                'poster_path': posterPath,
                'title': item['title'] ?? item['name'] ?? 'Unknown',
                'vote_average': ((item['rating'] ?? item['voteAverage']) ?? 0.0).toDouble(),
                'release_date': item['year']?.toString() ?? item['firstAirDate'] ?? '',
                'overview': item['overview'] ?? '',
              };
            } else {
              // TMDB format
              return {
                'id': item['id'],
                'poster_path': item['poster_path'],
                'title': item['title'] ?? item['name'] ?? 'Unknown',
                'vote_average': item['vote_average']?.toDouble() ?? 0.0,
                'release_date': item['release_date'] ?? item['first_air_date'] ?? '',
                'overview': item['overview'] ?? '',
              };
            }
          }).toList());
          totalPages = total;
          currentPage++;
          isLoading = false;
        });

        print('ViewAll: Loaded ${results.length} items (page ${currentPage-1}/$totalPages)');
      } else {
        print('ViewAll: Error ${response.statusCode}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('ViewAll: Exception $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: hasError && items.isEmpty
          ? _buildErrorWidget()
          : items.isEmpty && isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: items.length + (isLoading && currentPage <= totalPages ? 3 : 0),
                        itemBuilder: (context, index) {
                          if (index >= items.length) {
                            return _buildLoadingCard();
                          }
                          return _buildMovieCard(items[index]);
                        },
                      ),
                    ),
                    if (!isLoading && currentPage > totalPages && items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No more items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Descriptioncheckui(
              item['id'],
              widget.mediaType,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1929),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item['poster_path'] != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        item['vote_average'].toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load items',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                items.clear();
                currentPage = 1;
              });
              _loadItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
