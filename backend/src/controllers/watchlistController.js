const Watchlist = require('../models/Watchlist');
const User = require('../models/User');

// Get all watchlists for a user
exports.getUserWatchlists = async (req, res) => {
  try {
    const userId = req.user.uid;
    
    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    // Get all watchlists for user
    const watchlists = await Watchlist.find({ userId: user._id })
      .sort({ createdAt: -1 })
      .lean();

    res.json({
      success: true,
      data: watchlists
    });
  } catch (error) {
    console.error('Error getting watchlists:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get watchlists',
      error: error.message
    });
  }
};

// Get a specific watchlist
exports.getWatchlist = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.uid;
    
    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    const watchlist = await Watchlist.findOne({ 
      _id: id, 
      userId: user._id 
    }).lean();

    if (!watchlist) {
      return res.status(404).json({
        success: false,
        message: 'Watchlist not found'
      });
    }

    res.json({
      success: true,
      data: watchlist
    });
  } catch (error) {
    console.error('Error getting watchlist:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get watchlist',
      error: error.message
    });
  }
};

// Create a new watchlist
exports.createWatchlist = async (req, res) => {
  try {
    const { name, description, isPublic } = req.body;
    const userId = req.user.uid;

    console.log('🔵 Creating watchlist for user:', userId);
    console.log('Request body:', { name, description, isPublic });

    if (!name) {
      console.log('❌ Name is missing');
      return res.status(400).json({
        success: false,
        message: 'Watchlist name is required'
      });
    }

    // Find or create user in database
    console.log('🔍 Looking for user with firebaseUid:', userId);
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    console.log('✅ User found/created:', user._id);

    // Create new watchlist
    const watchlist = new Watchlist({
      userId: user._id,
      name,
      description: description || '',
      isPublic: isPublic || false,
      items: []
    });

    await watchlist.save();
    console.log('✅ Watchlist created:', watchlist._id);

    res.status(201).json({
      success: true,
      message: 'Watchlist created successfully',
      data: watchlist
    });
  } catch (error) {
    console.error('❌ Error creating watchlist:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create watchlist',
      error: error.message
    });
  }
};

// Update watchlist
exports.updateWatchlist = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, isPublic } = req.body;
    const userId = req.user.uid;

    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    const watchlist = await Watchlist.findOne({ 
      _id: id, 
      userId: user._id 
    });

    if (!watchlist) {
      return res.status(404).json({
        success: false,
        message: 'Watchlist not found'
      });
    }

    // Update fields
    if (name !== undefined) watchlist.name = name;
    if (description !== undefined) watchlist.description = description;
    if (isPublic !== undefined) watchlist.isPublic = isPublic;

    await watchlist.save();

    res.json({
      success: true,
      message: 'Watchlist updated successfully',
      data: watchlist
    });
  } catch (error) {
    console.error('Error updating watchlist:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update watchlist',
      error: error.message
    });
  }
};

// Delete watchlist
exports.deleteWatchlist = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.uid;

    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    const watchlist = await Watchlist.findOneAndDelete({ 
      _id: id, 
      userId: user._id 
    });

    if (!watchlist) {
      return res.status(404).json({
        success: false,
        message: 'Watchlist not found'
      });
    }

    res.json({
      success: true,
      message: 'Watchlist deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting watchlist:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete watchlist',
      error: error.message
    });
  }
};

// Add item to watchlist
exports.addItemToWatchlist = async (req, res) => {
  try {
    const { id } = req.params;
    const { itemId, itemType, title, posterPath, backdropPath, overview, releaseDate, voteAverage } = req.body;
    const userId = req.user.uid;

    if (!itemId || !itemType || !title) {
      return res.status(400).json({
        success: false,
        message: 'itemId, itemType, and title are required'
      });
    }

    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    const watchlist = await Watchlist.findOne({ 
      _id: id, 
      userId: user._id 
    });

    if (!watchlist) {
      return res.status(404).json({
        success: false,
        message: 'Watchlist not found'
      });
    }

    // Check if item already exists
    const existingItem = watchlist.items.find(
      item => item.itemId === itemId && item.itemType === itemType
    );

    if (existingItem) {
      return res.status(400).json({
        success: false,
        message: 'Item already exists in this watchlist'
      });
    }

    // Add item
    const newItem = {
      itemId,
      itemType,
      title,
      posterPath: posterPath || '',
      backdropPath: backdropPath || '',
      overview: overview || '',
      releaseDate: releaseDate || '',
      voteAverage: voteAverage || 0
    };

    console.log('📦 Adding item to watchlist:', newItem);
    
    watchlist.items.push(newItem);

    await watchlist.save();

    console.log('✅ Item added successfully. Total items:', watchlist.items.length);

    res.json({
      success: true,
      message: 'Item added to watchlist successfully',
      data: watchlist
    });
  } catch (error) {
    console.error('Error adding item to watchlist:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add item to watchlist',
      error: error.message
    });
  }
};

// Remove item from watchlist
exports.removeItemFromWatchlist = async (req, res) => {
  try {
    const { id, itemId } = req.params;
    const userId = req.user.uid;

    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    const watchlist = await Watchlist.findOne({ 
      _id: id, 
      userId: user._id 
    });

    if (!watchlist) {
      return res.status(404).json({
        success: false,
        message: 'Watchlist not found'
      });
    }

    // Remove item
    watchlist.items = watchlist.items.filter(
      item => item._id.toString() !== itemId
    );

    await watchlist.save();

    res.json({
      success: true,
      message: 'Item removed from watchlist successfully',
      data: watchlist
    });
  } catch (error) {
    console.error('Error removing item from watchlist:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove item from watchlist',
      error: error.message
    });
  }
};

// Check if item is in any watchlist
exports.checkItemInWatchlists = async (req, res) => {
  try {
    const { itemId, itemType } = req.query;
    const userId = req.user.uid;

    if (!itemId || !itemType) {
      return res.status(400).json({
        success: false,
        message: 'itemId and itemType are required'
      });
    }

    // Find or create user in database
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        firebaseUid: userId,
        email: req.user.email || '',
        displayName: req.user.name || req.user.email || 'User'
      },
      { upsert: true, new: true }
    );

    // Find all watchlists containing this item
    const watchlists = await Watchlist.find({
      userId: user._id,
      'items.itemId': itemId,
      'items.itemType': itemType
    }).select('_id name').lean();

    res.json({
      success: true,
      data: {
        inWatchlists: watchlists,
        isInAnyList: watchlists.length > 0
      }
    });
  } catch (error) {
    console.error('Error checking item in watchlists:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check item in watchlists',
      error: error.message
    });
  }
};
