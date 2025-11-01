const mongoose = require('mongoose');

const recommendedSchema = new mongoose.Schema({
  tmdbId: {
    type: Number,
    required: true,
    unique: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  overview: {
    type: String,
    required: true
  },
  poster: {
    type: String,
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 0,
    max: 10
  },
  year: {
    type: Number,
    required: true
  },
  genre: {
    type: [String],
    required: true
  },
  popularity: {
    type: Number,
    default: 0
  },
  // Detailed information
  runtime: {
    type: Number, // in minutes
    default: 0
  },
  budget: {
    type: Number,
    default: 0
  },
  revenue: {
    type: Number,
    default: 0
  },
  // Videos (trailers, teasers)
  videos: [{
    id: {type: String},
    key: {type: String},
    name: {type: String},
    site: {type: String},
    type: {type: String},
    official: {type: Boolean}
  }],
  // Production companies
  productionCompanies: [{
    id: {type: Number},
    name: {type: String},
    logoPath: {type: String}
  }]
}, {
  timestamps: true,
  collection: 'recommendeds'
});

// Index for faster queries
recommendedSchema.index({ tmdbId: 1 });
recommendedSchema.index({ title: 'text', overview: 'text' });
recommendedSchema.index({ popularity: -1 });
recommendedSchema.index({ rating: -1 });

module.exports = mongoose.model('Recommended', recommendedSchema);
