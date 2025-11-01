const mongoose = require('mongoose');

const userFavoriteSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  movieId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Movie',
    required: true
  }
}, {
  timestamps: true
});

// Compound index to ensure a user can't favorite the same movie twice
userFavoriteSchema.index({ userId: 1, movieId: 1 }, { unique: true });

module.exports = mongoose.model('UserFavorite', userFavoriteSchema);
