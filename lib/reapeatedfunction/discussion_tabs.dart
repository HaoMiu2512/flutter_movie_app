import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/comment_service.dart';
import '../services/review_service.dart';
import '../models/comment.dart';
import '../models/review.dart';
import 'comments_widget.dart';
import 'reviews_widget.dart';

class DiscussionTabs extends StatefulWidget {
  final String mediaType; // 'movie' or 'tv'
  final int mediaId;

  const DiscussionTabs({
    Key? key,
    required this.mediaType,
    required this.mediaId,
  }) : super(key: key);

  @override
  State<DiscussionTabs> createState() => _DiscussionTabsState();
}

class _DiscussionTabsState extends State<DiscussionTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CommentStats? _commentStats;
  ReviewStats? _reviewStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final commentStats = await CommentService.getCommentStats(
        mediaType: widget.mediaType,
        mediaId: widget.mediaId,
      );

      final reviewStats = await ReviewService.getReviewStats(
        mediaType: widget.mediaType,
        mediaId: widget.mediaId,
      );

      setState(() {
        _commentStats = commentStats;
        _reviewStats = reviewStats;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  // Callback to refresh stats when new comment/review is added
  void _onContentUpdated() {
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0A1929),
                Color(0xFF0F1922),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.cyan.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.cyan,
            indicatorWeight: 3,
            labelColor: Colors.cyan.shade100,
            unselectedLabelColor: Colors.grey.shade400,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 20),
                    const SizedBox(width: 8),
                    const Text('Comments'),
                    if (_commentStats != null && _commentStats!.totalComments > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withValues(alpha: 0.3),
                              Colors.cyan.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${_commentStats!.totalComments}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rate_review, size: 20),
                    const SizedBox(width: 8),
                    const Text('Reviews'),
                    if (_reviewStats != null && _reviewStats!.total > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withValues(alpha: 0.3),
                              Colors.cyan.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${_reviewStats!.total}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CommentsWidget(
                mediaType: widget.mediaType,
                mediaId: widget.mediaId,
                userId: user?.uid ?? '',
                userName: user?.displayName ?? 'Anonymous',
                userPhotoUrl: user?.photoURL,
                onCommentAdded: _onContentUpdated,
              ),
              ReviewsWidget(
                mediaType: widget.mediaType,
                mediaId: widget.mediaId,
                userId: user?.uid ?? '',
                userName: user?.displayName ?? 'Anonymous',
                userPhotoUrl: user?.photoURL,
                onReviewAdded: _onContentUpdated,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
