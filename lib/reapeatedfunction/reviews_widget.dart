import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'review_form_dialog.dart';

class ReviewsWidget extends StatefulWidget {
  final String mediaType;
  final int mediaId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final VoidCallback? onReviewAdded;

  const ReviewsWidget({
    Key? key,
    required this.mediaType,
    required this.mediaId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.onReviewAdded,
  }) : super(key: key);

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  final ScrollController _scrollController = ScrollController();
  
  List<Review> _reviews = [];
  ReviewStats? _stats;
  Review? _userReview;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _sortBy = 'newest';
  String? _filterSentiment;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadUserReview();
    _loadStats();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreReviews();
      }
    }
  }

  Future<void> _loadReviews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    final result = await ReviewService.getReviews(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      page: 1,
      limit: 10,
      sortBy: _sortBy,
      sentiment: _filterSentiment,
    );

    if (result['success']) {
      setState(() {
        _reviews = result['reviews'];
        _hasMore = result['pagination']['page'] < result['pagination']['pages'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final result = await ReviewService.getReviews(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      page: _currentPage + 1,
      limit: 10,
      sortBy: _sortBy,
      sentiment: _filterSentiment,
    );

    if (result['success']) {
      setState(() {
        _reviews.addAll(result['reviews']);
        _currentPage++;
        _hasMore = result['pagination']['page'] < result['pagination']['pages'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserReview() async {
    if (widget.userId.isEmpty) return;

    final review = await ReviewService.getUserReview(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      userId: widget.userId,
    );

    setState(() => _userReview = review);
  }

  Future<void> _loadStats() async {
    final stats = await ReviewService.getReviewStats(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
    );

    setState(() => _stats = stats);
  }

  Future<void> _showReviewForm({Review? existingReview}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReviewFormDialog(
        mediaType: widget.mediaType,
        mediaId: widget.mediaId,
        userId: widget.userId,
        userName: widget.userName,
        userPhotoUrl: widget.userPhotoUrl,
        existingReview: existingReview,
      ),
    );

    if (result == true) {
      widget.onReviewAdded?.call();
      _loadReviews();
      _loadUserReview();
      _loadStats();
    }
  }

  Future<void> _voteReview(Review review, String voteType) async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote')),
      );
      return;
    }

    final result = await ReviewService.voteReview(
      reviewId: review.id,
      userId: widget.userId,
      voteType: voteType,
    );

    if (result['success']) {
      _loadReviews(); // Reload to update votes
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ReviewService.deleteReview(
        reviewId: review.id,
        userId: widget.userId,
      );

      if (result['success']) {
        widget.onReviewAdded?.call();
        _loadReviews();
        _loadUserReview();
        _loadStats();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Stats bar
            if (_stats != null) _buildStatsBar(),

            // Filter & Sort bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1929),
                    const Color(0xFF0F1922),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.cyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.cyan, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Filter:',
                        style: TextStyle(
                          color: Colors.cyan.shade200,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All', null),
                              ...SentimentDisplay.allSentiments.map(
                                (sentiment) => _buildFilterChip(
                                  SentimentDisplay.info[sentiment]!.english,
                                  sentiment,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2332),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          dropdownColor: const Color(0xFF1A2332),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          underline: const SizedBox(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.cyan, size: 18),
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Newest')),
                            DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                            DropdownMenuItem(value: 'mostHelpful', child: Text('Helpful')),
                            DropdownMenuItem(value: 'sentiment', child: Text('Rating')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortBy = value);
                              _loadReviews();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reviews list
            Expanded(
              child: _reviews.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.rate_review, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReviews,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _reviews.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _reviews.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final review = _reviews[index];
                          return _buildReviewItem(review);
                        },
                      ),
                    ),
            ),
          ],
        ),

        // Write review FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.shade400,
                  Colors.cyan.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.userId.isEmpty
                    ? null
                    : () => _showReviewForm(existingReview: _userReview),
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _userReview != null ? Icons.edit_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _userReview != null ? 'Edit Review' : 'Write Review',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    if (_stats == null || _stats!.total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A1929),
            Color(0xFF0F1922),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_stats!.total} reviews',
                style: TextStyle(
                  color: Colors.cyan.shade100,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse(
                      '0xFF${SentimentDisplay.info[_stats!.averageSentiment]!.color.substring(1)}')),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(int.parse(
                          '0xFF${SentimentDisplay.info[_stats!.averageSentiment]!.color.substring(1)}')).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      SentimentDisplay.info[_stats!.averageSentiment]!.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      SentimentDisplay.info[_stats!.averageSentiment]!.english,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.cyan.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: SentimentDisplay.allSentiments.reversed.map((sentiment) {
                final count = _stats!.sentimentBreakdown[sentiment] ?? 0;
                final percentage = _stats!.getPercentage(sentiment);
                if (count == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 85,
                        child: Row(
                          children: [
                            Text(
                              SentimentDisplay.info[sentiment]!.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                SentimentDisplay.info[sentiment]!.english,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(
                                Color(int.parse(
                                    '0xFF${SentimentDisplay.info[sentiment]!.color.substring(1)}')),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 45,
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.cyan.shade200,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($count)',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? sentiment) {
    final isSelected = _filterSentiment == sentiment;
    final info = sentiment != null ? SentimentDisplay.info[sentiment] : null;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _filterSentiment = isSelected ? null : sentiment;
          });
          _loadReviews();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.cyan.withValues(alpha: 0.3),
                      Colors.cyan.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? Colors.cyan.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (info != null) ...[
                Text(info.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.cyan.shade100 : Colors.grey.shade300,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    final isOwner = review.userId == widget.userId;
    final userVote = review.getUserVote(widget.userId);
    final sentimentInfo = review.sentimentInfo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A2332),
            Color(0xFF0F1922),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.cyan.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: review.userPhotoUrl != null
                        ? NetworkImage(review.userPhotoUrl!)
                        : null,
                    child: review.userPhotoUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.cyan.shade200,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  '0xFF${sentimentInfo.color.substring(1)}')),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(int.parse(
                                      '0xFF${sentimentInfo.color.substring(1)}')).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sentimentInfo.emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sentimentInfo.english,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: Colors.blue.shade300,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () => _showReviewForm(existingReview: review),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.red.shade300,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () => _deleteReview(review),
                    ),
                  ),
                ],
              ],
            ),
            if (review.title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              review.text,
              style: TextStyle(
                color: Colors.grey.shade200,
                height: 1.5,
              ),
            ),
            if (review.containsSpoilers) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade900,
                      Colors.orange.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Contains Spoiler',
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.cyan.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _voteReview(review, 'helpful'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: userVote == 'helpful'
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: userVote == 'helpful'
                                ? Colors.blue.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              userVote == 'helpful'
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 18,
                              color: userVote == 'helpful'
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${review.helpfulCount}',
                              style: TextStyle(
                                color: userVote == 'helpful'
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade400,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _voteReview(review, 'unhelpful'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: userVote == 'unhelpful'
                              ? Colors.red.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: userVote == 'unhelpful'
                                ? Colors.red.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              userVote == 'unhelpful'
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_outlined,
                              size: 18,
                              color: userVote == 'unhelpful'
                                  ? Colors.red.shade300
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${review.unhelpfulCount}',
                              style: TextStyle(
                                color: userVote == 'unhelpful'
                                    ? Colors.red.shade300
                                    : Colors.grey.shade400,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
