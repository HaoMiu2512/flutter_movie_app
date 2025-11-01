const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  // Firebase UID as primary identifier
  firebaseUid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  
  // User basic info (from Firebase Auth)
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  
  displayName: {
    type: String,
    required: true,
    trim: true
  },
  
  // Profile info
  photoURL: {
    type: String,
    default: null // URL to avatar (local file path or external URL)
  },
  
  bio: {
    type: String,
    maxlength: 500,
    default: ''
  },
  
  // Additional profile fields
  phoneNumber: {
    type: String,
    default: null
  },
  
  dateOfBirth: {
    type: Date,
    default: null
  },
  
  country: {
    type: String,
    default: null
  },
  
  favoriteGenres: [{
    type: String
  }],
  
  // Account metadata
  joinDate: {
    type: Date,
    default: Date.now
  },
  
  lastActive: {
    type: Date,
    default: Date.now
  },
  
  // Settings
  emailNotifications: {
    type: Boolean,
    default: true
  },
  
  pushNotifications: {
    type: Boolean,
    default: true
  },
  
  // Stats
  totalFavorites: {
    type: Number,
    default: 0
  },
  
  totalReviews: {
    type: Number,
    default: 0
  },
  
  totalComments: {
    type: Number,
    default: 0
  }
  
}, {
  timestamps: true // Adds createdAt and updatedAt
});

// Indexes for better query performance
userSchema.index({ email: 1 });
userSchema.index({ lastActive: -1 });

// Update lastActive on every query
userSchema.pre('save', function(next) {
  this.lastActive = Date.now();
  next();
});

const User = mongoose.model('User', userSchema);

module.exports = User;
