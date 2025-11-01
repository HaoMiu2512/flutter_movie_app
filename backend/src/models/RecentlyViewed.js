const mongoose = require('mongoose');

const recentlyViewedSchema = new mongoose.Schema({
  // User reference
  userId: {
    type: String, // Firebase UID
    required: true,
    index: true
  },
  
  // Media info
  mediaType: {
    type: String,
    required: true,
    enum: ['movie', 'tv'],
    index: true
  },
  
  mediaId: {
    type: Number, // TMDB ID
    required: true,
    index: true
  },
  
  // Cached media data (for quick display)
  title: {
    type: String,
    required: true
  },
  
  posterPath: {
    type: String,
    default: null
  },
  
  backdropPath: {
    type: String,
    default: null
  },
  
  overview: {
    type: String,
    default: ''
  },
  
  rating: {
    type: Number,
    default: 0
  },
  
  releaseDate: {
    type: String,
    default: null
  },
  
  // View tracking
  viewedAt: {
    type: Date,
    default: Date.now,
    index: true
  },
  
  viewCount: {
    type: Number,
    default: 1
  },
  
  // Progress tracking (optional - for future enhancement)
  watchProgress: {
    type: Number, // Percentage watched (0-100)
    default: 0
  },
  
  lastWatchPosition: {
    type: Number, // Seconds
    default: 0
  }
  
}, {
  timestamps: true
});

// Compound index to prevent duplicates
recentlyViewedSchema.index({ userId: 1, mediaType: 1, mediaId: 1 }, { unique: true });

// Index for querying recent views (most important query)
recentlyViewedSchema.index({ userId: 1, viewedAt: -1 });

// Index for querying by media type
recentlyViewedSchema.index({ userId: 1, mediaType: 1, viewedAt: -1 });

const RecentlyViewed = mongoose.model('RecentlyViewed', recentlyViewedSchema);

module.exports = RecentlyViewed;
