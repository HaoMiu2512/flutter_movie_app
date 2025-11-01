const User = require('../models/User');

// Get user profile by Firebase UID
const getUserProfile = async (req, res) => {
  try {
    const { userId } = req.params; // Firebase UID
    
    const user = await User.findOne({ firebaseUid: userId });
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }
    
    res.json({ success: true, user });
    
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get user profile', 
      error: error.message 
    });
  }
};

// Create or update user profile
const updateUserProfile = async (req, res) => {
  try {
    const { userId } = req.params; // Firebase UID
    const updates = req.body;
    
    // Fields that can be updated
    const allowedUpdates = [
      'displayName', 'photoURL', 'bio', 'phoneNumber', 
      'dateOfBirth', 'country', 'favoriteGenres',
      'emailNotifications', 'pushNotifications'
    ];
    
    // Filter out non-allowed fields
    const filteredUpdates = {};
    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        filteredUpdates[field] = updates[field];
      }
    });
    
    // Find and update or create new user
    const user = await User.findOneAndUpdate(
      { firebaseUid: userId },
      { 
        $set: filteredUpdates,
        $setOnInsert: { 
          firebaseUid: userId,
          email: updates.email || '',
          displayName: updates.displayName || 'User'
        }
      },
      { 
        new: true, // Return updated document
        upsert: true, // Create if doesn't exist
        runValidators: true 
      }
    );
    
    res.json({ 
      success: true, 
      message: 'Profile updated successfully',
      user 
    });
    
  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update user profile', 
      error: error.message 
    });
  }
};

// Create user (called after Firebase registration)
const createUser = async (req, res) => {
  try {
    const { firebaseUid, email, displayName, photoURL } = req.body;
    
    // Check if user already exists
    let user = await User.findOne({ firebaseUid });
    
    if (user) {
      return res.json({ 
        success: true, 
        message: 'User already exists',
        user 
      });
    }
    
    // Create new user
    user = new User({
      firebaseUid,
      email,
      displayName: displayName || email.split('@')[0],
      photoURL: photoURL || null
    });
    
    await user.save();
    
    res.status(201).json({ 
      success: true, 
      message: 'User created successfully',
      user 
    });
    
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to create user', 
      error: error.message 
    });
  }
};

// Delete user profile
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findOneAndDelete({ firebaseUid: userId });
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }
    
    res.json({ 
      success: true, 
      message: 'User deleted successfully' 
    });
    
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to delete user', 
      error: error.message 
    });
  }
};

// Get user stats
const getUserStats = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findOne({ firebaseUid: userId })
      .select('totalFavorites totalReviews totalComments joinDate lastActive');
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'User not found' 
      });
    }
    
    res.json({ success: true, stats: user });
    
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to get user stats', 
      error: error.message 
    });
  }
};

module.exports = {
  getUserProfile,
  updateUserProfile,
  createUser,
  deleteUser,
  getUserStats
};
