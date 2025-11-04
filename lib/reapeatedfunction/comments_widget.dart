import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../widgets/custom_snackbar.dart';

class CommentsWidget extends StatefulWidget {
  final String mediaType;
  final int mediaId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final VoidCallback? onCommentAdded;

  const CommentsWidget({
    Key? key,
    required this.mediaType,
    required this.mediaId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.onCommentAdded,
  }) : super(key: key);

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isPosting = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _sortBy = 'newest';
  Set<String> _expandedComments = {}; // Track expanded comments
  Map<String, List<Comment>> _repliesCache = {}; // Cache replies
  Set<String> _loadingReplies = {}; // Track loading state for replies

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreComments();
      }
    }
  }

  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    final result = await CommentService.getComments(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      page: 1,
      limit: 20,
      sortBy: _sortBy,
    );

    if (result['success']) {
      setState(() {
        _comments = result['comments'];
        _hasMore = result['pagination']['page'] < result['pagination']['pages'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final result = await CommentService.getComments(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      page: _currentPage + 1,
      limit: 20,
      sortBy: _sortBy,
    );

    if (result['success']) {
      setState(() {
        _comments.addAll(result['comments']);
        _currentPage++;
        _hasMore = result['pagination']['page'] < result['pagination']['pages'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment({String? parentCommentId}) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || widget.userId.isEmpty) return;

    setState(() => _isPosting = true);

    final result = await CommentService.createComment(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      userId: widget.userId,
      userName: widget.userName,
      userPhotoUrl: widget.userPhotoUrl,
      text: text,
      parentCommentId: parentCommentId,
    );

    setState(() => _isPosting = false);

    if (result['success']) {
      _commentController.clear();
      widget.onCommentAdded?.call();
      _loadComments(); // Reload to show new comment
      
      CustomSnackBar.showSuccess(context, 'Comment posted');
    } else {
      CustomSnackBar.showError(context, result['message'] ?? 'Error posting comment');
    }
  }

  Future<void> _toggleLike(Comment comment) async {
    if (widget.userId.isEmpty) {
      CustomSnackBar.showError(context, 'Please login to like comments');
      return;
    }

    final result = await CommentService.likeComment(
      commentId: comment.id,
      userId: widget.userId,
    );

    if (result['success']) {
      // Update comment in list
      setState(() {
        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index != -1) {
          final isLiked = comment.isLikedByUser(widget.userId);
          final newLikes = isLiked
              ? comment.likes.where((id) => id != widget.userId).toList()
              : [...comment.likes, widget.userId];
          
          _comments[index] = comment.copyWith(
            likes: newLikes,
            likesCount: newLikes.length,
          );
        }
      });
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
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
      final result = await CommentService.deleteComment(
        commentId: comment.id,
        userId: widget.userId,
      );

      if (result['success']) {
        widget.onCommentAdded?.call();
        _loadComments();
        
        CustomSnackBar.showSuccess(context, 'Comment deleted');
      } else {
        CustomSnackBar.showError(context, result['message'] ?? 'Error deleting comment');
      }
    }
  }

  void _showReplyDialog(Comment parentComment) {
    final replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${parentComment.userName}'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final text = replyController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                
                final result = await CommentService.createComment(
                  mediaType: widget.mediaType,
                  mediaId: widget.mediaId,
                  userId: widget.userId,
                  userName: widget.userName,
                  userPhotoUrl: widget.userPhotoUrl,
                  text: text,
                  parentCommentId: parentComment.id,
                );

                if (result['success']) {
                  widget.onCommentAdded?.call();
                  _loadComments();
                  
                  CustomSnackBar.showSuccess(context, 'Reply posted');
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadReplies(String parentCommentId) async {
    if (_repliesCache.containsKey(parentCommentId)) {
      return; // Already loaded
    }

    setState(() {
      _loadingReplies.add(parentCommentId);
    });

    try {
      print('Loading replies for comment: $parentCommentId');
      final result = await CommentService.getReplies(
        commentId: parentCommentId,
      );

      print('Replies result success: ${result['success']}');
      print('Replies data type: ${result['replies'].runtimeType}');
      print('Replies count: ${(result['replies'] as List?)?.length ?? 0}');

      if (result['success'] && mounted) {
        final repliesList = result['replies'];
        if (repliesList is List<Comment>) {
          setState(() {
            _repliesCache[parentCommentId] = repliesList;
            _loadingReplies.remove(parentCommentId);
          });
          print('✅ Cached ${_repliesCache[parentCommentId]?.length ?? 0} replies');
        } else if (repliesList is List) {
          // Try to convert if it's a generic List
          final convertedReplies = repliesList.cast<Comment>();
          setState(() {
            _repliesCache[parentCommentId] = convertedReplies;
            _loadingReplies.remove(parentCommentId);
          });
          print('✅ Cached ${_repliesCache[parentCommentId]?.length ?? 0} replies (converted)');
        } else {
          print('❌ Replies is not a List: ${repliesList.runtimeType}');
          setState(() {
            _loadingReplies.remove(parentCommentId);
          });
        }
      } else {
        print('❌ Result not successful or widget not mounted');
        setState(() {
          _loadingReplies.remove(parentCommentId);
        });
      }
    } catch (e) {
      print('Error loading replies: $e');
      setState(() {
        _loadingReplies.remove(parentCommentId);
      });
      if (mounted) {
        CustomSnackBar.showError(context, 'Failed to load replies: $e');
      }
    }
  }

  void _toggleReplies(Comment comment) async {
    if (_expandedComments.contains(comment.id)) {
      // Collapse
      setState(() {
        _expandedComments.remove(comment.id);
      });
    } else {
      // Expand - always add to expanded first
      setState(() {
        _expandedComments.add(comment.id);
      });
      
      // Load replies if not cached
      if (!_repliesCache.containsKey(comment.id)) {
        print('Comment ${comment.id} has ${comment.replyCount} replies, loading...');
        await _loadReplies(comment.id);
      } else {
        print('Using cached ${_repliesCache[comment.id]?.length ?? 0} replies');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sort dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Row(
            children: [
              Icon(Icons.sort, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Sort by:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    DropdownMenuItem(value: 'mostLiked', child: Text('Most Liked')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortBy = value);
                      _loadComments();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Comments list
        Expanded(
          child: _comments.isEmpty && !_isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_bubble_outline,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No comments yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadComments,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _comments.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _comments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final comment = _comments[index];
                      return _buildCommentItem(comment);
                    },
                  ),
                ),
        ),

        // Post comment input
        Container(
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
              top: BorderSide(
                color: Colors.cyan.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
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
                  radius: 18,
                  backgroundColor: const Color(0xFF1A2332),
                  backgroundImage: widget.userPhotoUrl != null
                      ? NetworkImage(widget.userPhotoUrl!)
                      : null,
                  child: widget.userPhotoUrl == null
                      ? Icon(Icons.person, size: 20, color: Colors.cyan)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.cyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      suffixIcon: widget.userId.isNotEmpty && !_isPosting
                          ? IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color: Colors.cyan,
                                size: 20,
                              ),
                              onPressed: () => _postComment(),
                            )
                          : _isPosting
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                )
                              : null,
                    ),
                    maxLines: null,
                    maxLength: 500,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    enabled: widget.userId.isNotEmpty && !_isPosting,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final isOwner = comment.userId == widget.userId;
    final isLiked = comment.isLikedByUser(widget.userId);
    final isExpanded = _expandedComments.contains(comment.id);
    final replies = _repliesCache[comment.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2332),
            const Color(0xFF0F1922),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.2),
          width: 1,
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
                    backgroundColor: const Color(0xFF0A1929),
                    backgroundImage: comment.userPhotoUrl != null
                        ? NetworkImage(comment.userPhotoUrl!)
                        : null,
                    child: comment.userPhotoUrl == null
                        ? Icon(Icons.person, color: Colors.cyan.shade200)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan.shade200,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red.shade300,
                      onPressed: () => _deleteComment(comment),
                      tooltip: 'Delete',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _toggleLike(comment),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLiked
                              ? Colors.red.withValues(alpha: 0.5)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${comment.likesCount}',
                            style: TextStyle(
                              color: isLiked ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: widget.userId.isNotEmpty
                        ? () => _showReplyDialog(comment)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply_rounded,
                            size: 18,
                            color: Colors.cyan.shade300,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.cyan.shade300,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (comment.replyCount > 0) ...[
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _toggleReplies(comment),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _expandedComments.contains(comment.id)
                              ? Colors.cyan.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: _expandedComments.contains(comment.id)
                              ? Border.all(
                                  color: Colors.cyan.withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _expandedComments.contains(comment.id)
                                  ? Icons.expand_less
                                  : Icons.chat_bubble_outline,
                              size: 14,
                              color: _expandedComments.contains(comment.id)
                                  ? Colors.cyan.shade300
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment.replyCount}',
                              style: TextStyle(
                                color: _expandedComments.contains(comment.id)
                                    ? Colors.cyan.shade300
                                    : Colors.grey.shade400,
                                fontSize: 12,
                                fontWeight: _expandedComments.contains(comment.id)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
        // Replies section
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 12, bottom: 8),
            child: _loadingReplies.contains(comment.id)
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      ),
                    ),
                  )
                : replies.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1922),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No replies yet',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Column(
                        children: replies.map((reply) => _buildReplyItem(reply)).toList(),
                      ),
          ),
      ],
    );
  }

  Widget _buildReplyItem(Comment reply) {
    final isOwner = reply.userId == widget.userId;
    final isLiked = reply.isLikedByUser(widget.userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1922),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF0A1929),
                backgroundImage: reply.userPhotoUrl != null
                    ? NetworkImage(reply.userPhotoUrl!)
                    : null,
                child: reply.userPhotoUrl == null
                    ? Icon(Icons.person, color: Colors.cyan.shade200, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan.shade300,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _formatDateTime(reply.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  color: Colors.red.shade300,
                  onPressed: () => _deleteComment(reply),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () => _toggleLike(reply),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reply.likesCount}',
                      style: TextStyle(
                        color: isLiked ? Colors.red : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
