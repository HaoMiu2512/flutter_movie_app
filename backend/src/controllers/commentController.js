const Comment = require('../models/Comment');

// Get comments for a media (with pagination)
exports.getComments = async (req, res) => {
  try {
    const { mediaId, mediaType } = req.params;
    const { page = 1, limit = 20, sortBy = 'newest' } = req.query;

    const skip = (page - 1) * limit;

    // Sort options
    let sort = {};
    switch (sortBy) {
      case 'oldest':
        sort = { createdAt: 1 };
        break;
      case 'mostLiked':
        sort = { likesCount: -1, createdAt: -1 };
        break;
      case 'newest':
      default:
        sort = { createdAt: -1 };
    }

    // Get top-level comments only (parentCommentId is null)
    const comments = await Comment.find({
      mediaId: parseInt(mediaId),
      mediaType,
      parentCommentId: null,
      isDeleted: false
    })
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Comment.countDocuments({
      mediaId: parseInt(mediaId),
      mediaType,
      parentCommentId: null,
      isDeleted: false
    });

    res.json({
      success: true,
      data: comments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error getting comments:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting comments',
      error: error.message
    });
  }
};

// Get replies for a comment
exports.getReplies = async (req, res) => {
  try {
    const { commentId } = req.params;
    const { page = 1, limit = 10 } = req.query;

    const skip = (page - 1) * limit;

    const replies = await Comment.find({
      parentCommentId: commentId,
      isDeleted: false
    })
      .sort({ createdAt: 1 }) // Oldest first for replies
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Comment.countDocuments({
      parentCommentId: commentId,
      isDeleted: false
    });

    res.json({
      success: true,
      data: replies,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error getting replies:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting replies',
      error: error.message
    });
  }
};

// Create a comment
exports.createComment = async (req, res) => {
  try {
    const { mediaId, mediaType } = req.params;
    const { userId, userName, userPhotoUrl, text, parentCommentId } = req.body;

    // Validation
    if (!userId || !userName || !text) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId, userName, text'
      });
    }

    if (text.length > 2000) {
      return res.status(400).json({
        success: false,
        message: 'Comment text too long (max 2000 characters)'
      });
    }

    // Check if parent comment exists (if replying)
    if (parentCommentId) {
      const parentComment = await Comment.findById(parentCommentId);
      if (!parentComment) {
        return res.status(404).json({
          success: false,
          message: 'Parent comment not found'
        });
      }
    }

    const comment = new Comment({
      mediaId: parseInt(mediaId),
      mediaType,
      userId,
      userName,
      userPhotoUrl,
      text,
      parentCommentId: parentCommentId || null
    });

    await comment.save();

    res.status(201).json({
      success: true,
      data: comment,
      message: parentCommentId ? 'Reply posted successfully' : 'Comment posted successfully'
    });
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating comment',
      error: error.message
    });
  }
};

// Like/Unlike a comment
exports.likeComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing userId'
      });
    }

    const comment = await Comment.findById(commentId);
    if (!comment) {
      return res.status(404).json({
        success: false,
        message: 'Comment not found'
      });
    }

    // Check if user already liked
    const likeIndex = comment.likes.findIndex(like => like.userId === userId);

    if (likeIndex > -1) {
      // Unlike
      comment.likes.splice(likeIndex, 1);
    } else {
      // Like
      comment.likes.push({ userId });
    }

    await comment.save();

    res.json({
      success: true,
      data: {
        commentId: comment._id,
        liked: likeIndex === -1,
        likesCount: comment.likesCount
      },
      message: likeIndex === -1 ? 'Comment liked' : 'Comment unliked'
    });
  } catch (error) {
    console.error('Error liking comment:', error);
    res.status(500).json({
      success: false,
      message: 'Error liking comment',
      error: error.message
    });
  }
};

// Delete a comment (soft delete)
exports.deleteComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing userId'
      });
    }

    const comment = await Comment.findById(commentId);
    if (!comment) {
      return res.status(404).json({
        success: false,
        message: 'Comment not found'
      });
    }

    // Check ownership
    if (comment.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own comments'
      });
    }

    // Soft delete
    comment.isDeleted = true;
    comment.text = '[Comment deleted]';
    await comment.save();

    res.json({
      success: true,
      message: 'Comment deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting comment',
      error: error.message
    });
  }
};

// Get comment statistics for a media
exports.getCommentStats = async (req, res) => {
  try {
    const { mediaId, mediaType } = req.params;

    const totalComments = await Comment.countDocuments({
      mediaId: parseInt(mediaId),
      mediaType,
      isDeleted: false
    });

    const topLevelComments = await Comment.countDocuments({
      mediaId: parseInt(mediaId),
      mediaType,
      parentCommentId: null,
      isDeleted: false
    });

    res.json({
      success: true,
      data: {
        totalComments,
        topLevelComments,
        replies: totalComments - topLevelComments
      }
    });
  } catch (error) {
    console.error('Error getting comment stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting comment stats',
      error: error.message
    });
  }
};
