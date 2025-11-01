const Review = require('../models/Review');

// Get reviews for a media
exports.getReviews = async (req, res) => {
  try {
    const { mediaId, mediaType } = req.params;
    const { 
      page = 1, 
      limit = 10, 
      sortBy = 'newest',
      sentiment = null // Filter by sentiment
    } = req.query;

    const skip = (page - 1) * limit;

    // Build query
    const query = {
      mediaId: parseInt(mediaId),
      mediaType,
      isDeleted: false
    };

    if (sentiment) {
      query.sentiment = sentiment;
    }

    // Sort options
    let sort = {};
    switch (sortBy) {
      case 'oldest':
        sort = { createdAt: 1 };
        break;
      case 'mostHelpful':
        sort = { helpfulCount: -1, createdAt: -1 };
        break;
      case 'sentiment':
        // Custom sort order: excellent -> great -> good -> average -> bad -> terrible
        sort = { sentiment: 1, createdAt: -1 };
        break;
      case 'newest':
      default:
        sort = { createdAt: -1 };
    }

    const reviews = await Review.find(query)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Review.countDocuments(query);

    res.json({
      success: true,
      data: reviews,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error getting reviews:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting reviews',
      error: error.message
    });
  }
};

// Create a review
exports.createReview = async (req, res) => {
  try {
    const { mediaId, mediaType } = req.params;
    const { 
      userId, 
      userName, 
      userPhotoUrl, 
      sentiment, 
      title,
      text,
      containsSpoilers 
    } = req.body;

    // Validation
    if (!userId || !userName || !sentiment || !text) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId, userName, sentiment, text'
      });
    }

    const validSentiments = ['terrible', 'bad', 'average', 'good', 'great', 'excellent'];
    if (!validSentiments.includes(sentiment)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid sentiment. Must be one of: ' + validSentiments.join(', ')
      });
    }

    if (text.length < 10) {
      return res.status(400).json({
        success: false,
        message: 'Review text too short (minimum 10 characters)'
      });
    }

    if (text.length > 5000) {
      return res.status(400).json({
        success: false,
        message: 'Review text too long (maximum 5000 characters)'
      });
    }

    // Check if user already reviewed this media
    const existingReview = await Review.findOne({
      mediaId: parseInt(mediaId),
      mediaType,
      userId
    });

    if (existingReview && !existingReview.isDeleted) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this. Please edit your existing review instead.'
      });
    }

    const review = new Review({
      mediaId: parseInt(mediaId),
      mediaType,
      userId,
      userName,
      userPhotoUrl,
      sentiment,
      title: title || '',
      text,
      containsSpoilers: containsSpoilers || false
    });

    await review.save();

    res.status(201).json({
      success: true,
      data: review,
      message: 'Review posted successfully'
    });
  } catch (error) {
    console.error('Error creating review:', error);
    
    // Handle duplicate key error (unique index)
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this. Please edit your existing review instead.'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Error creating review',
      error: error.message
    });
  }
};

// Update a review
exports.updateReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { userId, sentiment, title, text, containsSpoilers } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing userId'
      });
    }

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Check ownership
    if (review.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only edit your own reviews'
      });
    }

    // Update fields
    if (sentiment) review.sentiment = sentiment;
    if (title !== undefined) review.title = title;
    if (text) review.text = text;
    if (containsSpoilers !== undefined) review.containsSpoilers = containsSpoilers;
    
    review.updatedAt = Date.now();
    await review.save();

    res.json({
      success: true,
      data: review,
      message: 'Review updated successfully'
    });
  } catch (error) {
    console.error('Error updating review:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating review',
      error: error.message
    });
  }
};

// Delete a review
exports.deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing userId'
      });
    }

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Check ownership
    if (review.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own reviews'
      });
    }

    // Soft delete
    review.isDeleted = true;
    await review.save();

    res.json({
      success: true,
      message: 'Review deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting review',
      error: error.message
    });
  }
};

// Vote on a review (helpful/unhelpful)
exports.voteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { userId, voteType } = req.body; // voteType: 'helpful' or 'unhelpful'

    if (!userId || !voteType) {
      return res.status(400).json({
        success: false,
        message: 'Missing userId or voteType'
      });
    }

    if (!['helpful', 'unhelpful'].includes(voteType)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid voteType. Must be "helpful" or "unhelpful"'
      });
    }

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Remove existing votes from this user (can't vote both)
    const helpfulIndex = review.helpfulVotes.findIndex(v => v.userId === userId);
    const unhelpfulIndex = review.unhelpfulVotes.findIndex(v => v.userId === userId);

    if (helpfulIndex > -1) review.helpfulVotes.splice(helpfulIndex, 1);
    if (unhelpfulIndex > -1) review.unhelpfulVotes.splice(unhelpfulIndex, 1);

    // Add new vote
    if (voteType === 'helpful') {
      if (helpfulIndex === -1) { // Only add if wasn't already helpful
        review.helpfulVotes.push({ userId });
      }
    } else {
      if (unhelpfulIndex === -1) { // Only add if wasn't already unhelpful
        review.unhelpfulVotes.push({ userId });
      }
    }

    await review.save();

    res.json({
      success: true,
      data: {
        reviewId: review._id,
        helpfulCount: review.helpfulCount,
        unhelpfulCount: review.unhelpfulCount,
        userVote: (helpfulIndex === -1 && voteType === 'helpful') || 
                  (unhelpfulIndex === -1 && voteType === 'unhelpful') ? voteType : null
      },
      message: 'Vote recorded successfully'
    });
  } catch (error) {
    console.error('Error voting on review:', error);
    res.status(500).json({
      success: false,
      message: 'Error voting on review',
      error: error.message
    });
  }
};

// Get review statistics
exports.getReviewStats = async (req, res) => {
  try {
    const { mediaId, mediaType } = req.params;

    const query = {
      mediaId: parseInt(mediaId),
      mediaType,
      isDeleted: false
    };

    // Count by sentiment
    const sentimentCounts = await Review.aggregate([
      { $match: query },
      { $group: { _id: '$sentiment', count: { $sum: 1 } } }
    ]);

    const total = await Review.countDocuments(query);

    // Calculate average sentiment score
    const sentimentScores = {
      terrible: 1,
      bad: 2,
      average: 3,
      good: 4,
      great: 5,
      excellent: 6
    };

    const sentimentBreakdown = {};
    let totalScore = 0;

    sentimentCounts.forEach(item => {
      sentimentBreakdown[item._id] = item.count;
      totalScore += sentimentScores[item._id] * item.count;
    });

    const averageScore = total > 0 ? (totalScore / total).toFixed(2) : 0;

    res.json({
      success: true,
      data: {
        total,
        sentimentBreakdown,
        averageScore,
        averageSentiment: getAverageSentiment(parseFloat(averageScore))
      }
    });
  } catch (error) {
    console.error('Error getting review stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting review stats',
      error: error.message
    });
  }
};

// Helper function to get average sentiment from score
function getAverageSentiment(score) {
  if (score <= 1.5) return 'terrible';
  if (score <= 2.5) return 'bad';
  if (score <= 3.5) return 'average';
  if (score <= 4.5) return 'good';
  if (score <= 5.5) return 'great';
  return 'excellent';
}

// Get user's review for a media
exports.getUserReview = async (req, res) => {
  try {
    const { mediaId, mediaType, userId } = req.params;

    const review = await Review.findOne({
      mediaId: parseInt(mediaId),
      mediaType,
      userId,
      isDeleted: false
    });

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    res.json({
      success: true,
      data: review
    });
  } catch (error) {
    console.error('Error getting user review:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting user review',
      error: error.message
    });
  }
};
