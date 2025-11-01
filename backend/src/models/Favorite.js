const mongoose = require('mongoose');

const favoriteSchema = new mongoose.Schema({
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
  
  // Cached media data (for quick display without TMDB call)
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
  
  genres: [{
    type: String
  }],
  
  // Metadata
  addedAt: {
    type: Date,
    default: Date.now,
    index: true
  }
  
}, {
  timestamps: true
});

// Compound index to prevent duplicates
favoriteSchema.index({ userId: 1, mediaType: 1, mediaId: 1 }, { unique: true });

// Index for querying user's favorites
favoriteSchema.index({ userId: 1, addedAt: -1 });

// Index for querying by media type
favoriteSchema.index({ userId: 1, mediaType: 1, addedAt: -1 });

const Favorite = mongoose.model('Favorite', favoriteSchema);

module.exports = Favorite;
