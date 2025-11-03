const mongoose = require('mongoose');

const watchlistItemSchema = new mongoose.Schema({
  itemId: {
    type: String,
    required: true
  },
  itemType: {
    type: String,
    enum: ['movie', 'tv', 'trending', 'upcoming'],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  posterPath: String,
  backdropPath: String,
  overview: String,
  releaseDate: String,
  voteAverage: Number,
  addedAt: {
    type: Date,
    default: Date.now
  }
});

const watchlistSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    trim: true,
    default: ''
  },
  isPublic: {
    type: Boolean,
    default: false
  },
  items: [watchlistItemSchema],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for faster queries
watchlistSchema.index({ userId: 1, createdAt: -1 });
watchlistSchema.index({ userId: 1, name: 1 });

// Update updatedAt on save
watchlistSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

const Watchlist = mongoose.model('Watchlist', watchlistSchema);

module.exports = Watchlist;
