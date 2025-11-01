const RecentlyViewed = require('../models/RecentlyViewed');

// Get recently viewed items for a user
const getRecentlyViewed = async (req, res) => {
  try {
    const { userId } = req.params;
    const { mediaType, page = 1, limit = 20 } = req.query;
    
    const query = { userId };
    if (mediaType) {
      query.mediaType = mediaType;
    }
    
    const skip = (page - 1) * limit;
    
    const [recentlyViewed, total] = await Promise.all([
      RecentlyViewed.find(query)
        .sort({ viewedAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      RecentlyViewed.countDocuments(query)
    ]);
    
    res.json({ 
      success: true, 
      recentlyViewed,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
    
  } catch (error) {
    console.error('Get recently viewed error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get recently viewed', 
      error: error.message 
    });
  }
};

// Track a view (add or update)
const trackView = async (req, res) => {
  try {
    const { 
      userId, 
      mediaType, 
      mediaId, 
      title, 
      posterPath,
      backdropPath,
      overview,
      rating,
      releaseDate,
      watchProgress,
      lastWatchPosition
    } = req.body;
    
    // Check if already exists
    let recentlyViewed = await RecentlyViewed.findOne({ 
      userId, 
      mediaType, 
      mediaId 
    });
    
    if (recentlyViewed) {
      // Update existing record
      recentlyViewed.viewedAt = new Date();
      recentlyViewed.viewCount += 1;
      
      // Update optional fields if provided
      if (watchProgress !== undefined) {
        recentlyViewed.watchProgress = watchProgress;
      }
      if (lastWatchPosition !== undefined) {
        recentlyViewed.lastWatchPosition = lastWatchPosition;
      }
      
      // Update cached data
      recentlyViewed.title = title;
      recentlyViewed.posterPath = posterPath;
      recentlyViewed.backdropPath = backdropPath;
      recentlyViewed.overview = overview;
      recentlyViewed.rating = rating;
      recentlyViewed.releaseDate = releaseDate;
      
      await recentlyViewed.save();
      
      return res.json({ 
        success: true, 
        message: 'View updated',
        recentlyViewed 
      });
    }
    
    // Create new record
    recentlyViewed = new RecentlyViewed({
      userId,
      mediaType,
      mediaId,
      title,
      posterPath,
      backdropPath,
      overview,
      rating,
      releaseDate,
      watchProgress: watchProgress || 0,
      lastWatchPosition: lastWatchPosition || 0
    });
    
    await recentlyViewed.save();
    
    res.status(201).json({ 
      success: true, 
      message: 'View tracked',
      recentlyViewed 
    });
    
  } catch (error) {
    console.error('Track view error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to track view', 
      error: error.message 
    });
  }
};

// Remove a single recently viewed item
const removeRecentlyViewed = async (req, res) => {
  try {
    const { id } = req.params; // Recently viewed document ID
    
    const recentlyViewed = await RecentlyViewed.findByIdAndDelete(id);
    
    if (!recentlyViewed) {
      return res.status(404).json({ 
        success: false, 
        message: 'Recently viewed item not found' 
      });
    }
    
    res.json({ 
      success: true, 
      message: 'Removed from recently viewed' 
    });
    
  } catch (error) {
    console.error('Remove recently viewed error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to remove recently viewed', 
      error: error.message 
    });
  }
};

// Clear all recently viewed for a user
const clearRecentlyViewed = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await RecentlyViewed.deleteMany({ userId });
    
    res.json({ 
      success: true, 
      message: `Cleared ${result.deletedCount} recently viewed items` 
    });
    
  } catch (error) {
    console.error('Clear recently viewed error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to clear recently viewed', 
      error: error.message 
    });
  }
};

// Get watch progress for a specific media
const getWatchProgress = async (req, res) => {
  try {
    const { userId, mediaType, mediaId } = req.params;
    
    const recentlyViewed = await RecentlyViewed.findOne({ 
      userId, 
      mediaType, 
      mediaId: parseInt(mediaId) 
    });
    
    if (!recentlyViewed) {
      return res.json({ 
        success: true, 
        progress: {
          watchProgress: 0,
          lastWatchPosition: 0,
          viewCount: 0
        }
      });
    }
    
    res.json({ 
      success: true, 
      progress: {
        watchProgress: recentlyViewed.watchProgress,
        lastWatchPosition: recentlyViewed.lastWatchPosition,
        viewCount: recentlyViewed.viewCount,
        viewedAt: recentlyViewed.viewedAt
      }
    });
    
  } catch (error) {
    console.error('Get watch progress error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get watch progress', 
      error: error.message 
    });
  }
};

module.exports = {
  getRecentlyViewed,
  trackView,
  removeRecentlyViewed,
  clearRecentlyViewed,
  getWatchProgress
};
