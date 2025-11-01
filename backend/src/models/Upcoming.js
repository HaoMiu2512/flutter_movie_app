const mongoose = require('mongoose');

const upcomingSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true },
  poster_path: String,
  backdrop_path: String,
  title: { type: String, required: true },
  vote_average: Number,
  overview: String,
  release_date: String,
  popularity: Number,
  genre_ids: [Number],
  original_language: String,
  adult: Boolean,
  video: Boolean,
  vote_count: Number,
}, { 
  timestamps: true,
  collection: 'upcomings'
});

// Index for faster queries
upcomingSchema.index({ release_date: 1 });
upcomingSchema.index({ popularity: -1 });

module.exports = mongoose.model('Upcoming', upcomingSchema);
