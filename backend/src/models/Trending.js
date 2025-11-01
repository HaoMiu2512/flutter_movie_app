const mongoose = require('mongoose');

const trendingSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  poster_path: String,
  backdrop_path: String,
  title: String, // For movies
  name: String, // For TV series
  vote_average: Number,
  media_type: { type: String, enum: ['movie', 'tv'], required: true },
  overview: String,
  release_date: String, // For movies
  first_air_date: String, // For TV series
  popularity: Number,
  genre_ids: [Number],
  original_language: String,
  adult: Boolean,
  video: Boolean,
  vote_count: Number,
  // Cache metadata
  timeWindow: {
    type: String,
    enum: ['day', 'week'],
    default: 'week'
  },
  lastFetched: {
    type: Date,
    default: Date.now,
    index: true
  },
  cacheExpiry: {
    type: Date,
    index: true
  }
}, { 
  timestamps: true,
  collection: 'trendings'
});

// Index for faster queries
trendingSchema.index({ popularity: -1 });
trendingSchema.index({ vote_average: -1 });
trendingSchema.index({ media_type: 1 });
trendingSchema.index({ lastFetched: -1 });

// Helper method to check if cache is expired
trendingSchema.methods.isCacheExpired = function() {
  return !this.cacheExpiry || new Date() > this.cacheExpiry;
};

module.exports = mongoose.model('Trending', trendingSchema);
