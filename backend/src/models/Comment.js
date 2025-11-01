const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
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

  // Comment Content
  text: {
    type: String,
    required: true,
    maxlength: 2000
  },

  // Parent Comment (for replies/threading)
  parentCommentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Comment',
    default: null
  },

  // Engagement
  likes: [{
    userId: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  likesCount: {
    type: Number,
    default: 0
  },

  // Reply Count (for top-level comments)
  replyCount: {
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

// Indexes for performance
commentSchema.index({ mediaId: 1, mediaType: 1, createdAt: -1 });
commentSchema.index({ parentCommentId: 1, createdAt: -1 });
commentSchema.index({ userId: 1, createdAt: -1 });

// Virtual for replies (if needed)
commentSchema.virtual('replies', {
  ref: 'Comment',
  localField: '_id',
  foreignField: 'parentCommentId'
});

// Increment parent's reply count
commentSchema.pre('save', async function(next) {
  if (this.isNew && this.parentCommentId) {
    await mongoose.model('Comment').findByIdAndUpdate(
      this.parentCommentId,
      { $inc: { replyCount: 1 } }
    );
  }
  next();
});

// Update likesCount when likes array changes
commentSchema.pre('save', function(next) {
  this.likesCount = this.likes.length;
  next();
});

module.exports = mongoose.model('Comment', commentSchema);
