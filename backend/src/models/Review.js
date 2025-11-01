const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  // Media Info
  mediaId: {
    type: Number,
    required: true,
    index: true
  },
  mediaType: {
    type: String,
    required: true,
    enum: ['movie', 'tv', 'trending', 'upcoming']
  },

  // User Info
  userId: {
    type: String,
    required: true,
    index: true
  },
  userName: {
    type: String,
    required: true
  },
  userPhotoUrl: {
    type: String,
    default: 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'
  },

  // Review Content
  sentiment: {
    type: String,
    required: true,
    enum: ['terrible', 'bad', 'average', 'good', 'great', 'excellent'],
    index: true
  },
  title: {
    type: String,
    maxlength: 200,
    default: ''
  },
  text: {
    type: String,
    required: true,
    minlength: 10,
    maxlength: 5000
  },

  // Spoiler Warning
  containsSpoilers: {
    type: Boolean,
    default: false
  },

  // Engagement
  helpfulVotes: [{
    userId: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  helpfulCount: {
    type: Number,
    default: 0
  },

  unhelpfulVotes: [{
    userId: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  unhelpfulCount: {
    type: Number,
    default: 0
  },

  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },

  // Soft Delete
  isDeleted: {
    type: Boolean,
    default: false
  }
});

// Composite index for unique user review per media
reviewSchema.index({ mediaId: 1, mediaType: 1, userId: 1 }, { unique: true });

// Indexes for sorting/filtering
reviewSchema.index({ mediaId: 1, mediaType: 1, sentiment: 1, createdAt: -1 });
reviewSchema.index({ mediaId: 1, mediaType: 1, helpfulCount: -1 });

// Update counts when votes change
reviewSchema.pre('save', function(next) {
  this.helpfulCount = this.helpfulVotes.length;
  this.unhelpfulCount = this.unhelpfulVotes.length;
  next();
});

// Sentiment mappings for display
reviewSchema.statics.SENTIMENT_DISPLAY = {
  terrible: { vi: 'Tệ', en: 'Terrible', emoji: '😞', color: '#FF3B30' },
  bad: { vi: 'Kém', en: 'Bad', emoji: '😕', color: '#FF9500' },
  average: { vi: 'Trung Bình', en: 'Average', emoji: '😐', color: '#FFCC00' },
  good: { vi: 'Tốt', en: 'Good', emoji: '😊', color: '#34C759' },
  great: { vi: 'Rất Tốt', en: 'Great', emoji: '😄', color: '#00C7BE' },
  excellent: { vi: 'Xuất Sắc', en: 'Excellent', emoji: '🤩', color: '#5856D6' }
};

module.exports = mongoose.model('Review', reviewSchema);
