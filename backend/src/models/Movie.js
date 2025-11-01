const mongoose = require('mongoose');

const movieSchema = new mongoose.Schema({
  // TMDB Data
  tmdbId: {
    type: Number,
    required: true,
    index: true  // Removed unique: true (will use compound index below)
  },
  title: {
    type: String,
    required: true,
    trim: true,
    index: true
  },
  originalTitle: {
    type: String,
    trim: true
  },
  overview: {
    type: String,
    default: ''
  },
  posterPath: {
    type: String,
    default: null
  },
  backdropPath: {
    type: String,
    default: null
  },
  // Legacy field for backward compatibility
  poster: {
    type: String,
    default: null
  },
  video_url: {
    type: String,
    default: null
  },
  voteAverage: {
    type: Number,
    default: 0,
    min: 0,
    max: 10
  },
  voteCount: {
    type: Number,
    default: 0
  },
  // Legacy field for backward compatibility
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 10
  },
  popularity: {
    type: Number,
    default: 0,
    index: true
  },
  releaseDate: {
    type: String,
    default: null
  },
  year: {
    type: Number,
    index: true
  },
  genreIds: {
    type: [Number],
    default: []
  },
  // Legacy field for backward compatibility
  genre: {
    type: [String],
    default: []
  },
  adult: {
    type: Boolean,
    default: false
  },
  originalLanguage: {
    type: String,
    default: 'en'
  },
  isPro: {
    type: Boolean,
    default: false
  },
  views: {
    type: Number,
    default: 0
  },
  favoritesCount: {
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
  tagline: {
    type: String,
    default: ''
  },
  homepage: {
    type: String,
    default: ''
  },
  status: {
    type: String,
    default: 'Released'
  },
  originalLanguage: {
    type: String,
    default: 'en'
  },
  // Cast and Crew  
  cast: [{
    id: {type: Number},
    name: {type: String},
    character: {type: String},
    profilePath: {type: String},
    order: {type: Number}
  }],
  crew: [{
    id: {type: Number},
    name: {type: String},
    job: {type: String},
    department: {type: String},
    profilePath: {type: String}
  }],
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
  }],
  // Cache metadata
  cacheType: {
    type: String,
    enum: ['popular', 'top_rated', 'upcoming', 'now_playing', 'trending', 'search', 'details'],
    default: 'details'
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
  timestamps: true
});

// Index for searching
movieSchema.index({ title: 'text', overview: 'text' });
movieSchema.index({ genreIds: 1 });
movieSchema.index({ year: -1 });
movieSchema.index({ voteAverage: -1 });
movieSchema.index({ popularity: -1 });
movieSchema.index({ cacheType: 1, lastFetched: -1 });

// Compound unique index: same movie can exist with different cacheTypes
movieSchema.index({ tmdbId: 1, cacheType: 1 }, { unique: true });

// Helper method to check if cache is expired
movieSchema.methods.isCacheExpired = function() {
  return !this.cacheExpiry || new Date() > this.cacheExpiry;
};

module.exports = mongoose.model('Movie', movieSchema);
