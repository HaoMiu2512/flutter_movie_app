const Favorite = require('../models/Favorite');
const User = require('../models/User');

// Get all favorites for a user
const getUserFavorites = async (req, res) => {
  try {
    const { userId } = req.params;
    const { mediaType, page = 1, limit = 20 } = req.query;
    
    const query = { userId };
    if (mediaType) {
      query.mediaType = mediaType;
    }
    
    const skip = (page - 1) * limit;
    
    const [favorites, total] = await Promise.all([
      Favorite.find(query)
        .sort({ addedAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Favorite.countDocuments(query)
    ]);
    
    res.json({ 
      success: true, 
      favorites,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
    
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get favorites', 
      error: error.message 
    });
  }
};

// Add a favorite
const addFavorite = async (req, res) => {
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
      genres
    } = req.body;
    
    // Check if already favorited
    const existing = await Favorite.findOne({ userId, mediaType, mediaId });
    
    if (existing) {
      return res.status(400).json({ 
        success: false, 
        message: 'Already in favorites',
        favorite: existing
      });
    }
    
    // Create new favorite
    const favorite = new Favorite({
      userId,
      mediaType,
      mediaId,
      title,
      posterPath,
      backdropPath,
      overview,
      rating,
      releaseDate,
      genres
    });
    
    await favorite.save();
    
    // Update user's total favorites count
    await User.findOneAndUpdate(
      { firebaseUid: userId },
      { $inc: { totalFavorites: 1 } }
    );
    
    res.status(201).json({ 
      success: true, 
      message: 'Added to favorites',
      favorite 
    });
    
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to add favorite', 
      error: error.message 
    });
  }
};

// Remove a favorite
const removeFavorite = async (req, res) => {
  try {
    const { id } = req.params; // Favorite document ID
    
    const favorite = await Favorite.findByIdAndDelete(id);
    
    if (!favorite) {
      return res.status(404).json({ 
        success: false, 
        message: 'Favorite not found' 
      });
    }
    
    // Update user's total favorites count
    await User.findOneAndUpdate(
      { firebaseUid: favorite.userId },
      { $inc: { totalFavorites: -1 } }
    );
    
    res.json({ 
      success: true, 
      message: 'Removed from favorites' 
    });
    
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to remove favorite', 
      error: error.message 
    });
  }
};

// Remove favorite by userId and mediaId
const removeFavoriteByMedia = async (req, res) => {
  try {
    const { userId, mediaType, mediaId } = req.body;
    
    const favorite = await Favorite.findOneAndDelete({ 
      userId, 
      mediaType, 
      mediaId: parseInt(mediaId) 
    });
    
    if (!favorite) {
      return res.status(404).json({ 
        success: false, 
        message: 'Favorite not found' 
      });
    }
    
    // Update user's total favorites count
    await User.findOneAndUpdate(
      { firebaseUid: userId },
      { $inc: { totalFavorites: -1 } }
    );
    
    res.json({ 
      success: true, 
      message: 'Removed from favorites' 
    });
    
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to remove favorite', 
      error: error.message 
    });
  }
};

// Check if media is favorited
const checkFavorite = async (req, res) => {
  try {
    const { userId, mediaType, mediaId } = req.params;
    
    const favorite = await Favorite.findOne({ 
      userId, 
      mediaType, 
      mediaId: parseInt(mediaId) 
    });
    
    res.json({ 
      success: true, 
      isFavorite: !!favorite,
      favorite: favorite || null
    });
    
  } catch (error) {
    console.error('Check favorite error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to check favorite', 
      error: error.message 
    });
  }
};

// Clear all favorites for a user
const clearAllFavorites = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await Favorite.deleteMany({ userId });
    
    // Reset user's total favorites count
    await User.findOneAndUpdate(
      { firebaseUid: userId },
      { $set: { totalFavorites: 0 } }
    );
    
    res.json({ 
      success: true, 
      message: `Cleared ${result.deletedCount} favorites` 
    });
    
  } catch (error) {
    console.error('Clear favorites error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to clear favorites', 
      error: error.message 
    });
  }
};

module.exports = {
  getUserFavorites,
  addFavorite,
  removeFavorite,
  removeFavoriteByMedia,
  checkFavorite,
  clearAllFavorites
};
