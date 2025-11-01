const mongoose = require('mongoose');

const tvSeriesSchema = new mongoose.Schema({
  tmdbId: {
    type: Number,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  overview: String,
  posterPath: String,
  backdropPath: String,
  voteAverage: Number,
  voteCount: Number,
  firstAirDate: String,
  genres: [{
    id: { type: Number },
    name: { type: String }
  }],
  
  // Seasons information
  seasons: [{
    id: { type: Number },
    name: { type: String },
    overview: { type: String },
    posterPath: { type: String },
    seasonNumber: { type: Number },
    episodeCount: { type: Number },
    airDate: { type: String }
  }],
  
  // Cast (up to 20 actors)
  cast: [{
    id: { type: Number },
    name: { type: String },
    character: { type: String },
    profilePath: { type: String },
    order: { type: Number }
  }],
  
  // Crew (up to 15 key crew members)
  crew: [{
    id: { type: Number },
    name: { type: String },
    job: { type: String },
    department: { type: String },
    profilePath: { type: String }
  }],
  
  // Videos (up to 5 YouTube trailers/teasers)
  videos: [{
    id: { type: String },
    key: { type: String },
    name: { type: String },
    site: { type: String },
    type: { type: String },
    official: { type: Boolean }
  }],
  
  // Production Companies
  productionCompanies: [{
    id: { type: Number },
    name: { type: String },
    logoPath: { type: String },
    originCountry: { type: String }
  }],
  
  // Additional TV Series specific fields
  episodeRunTime: [Number],
  numberOfSeasons: Number,
  numberOfEpisodes: Number,
  status: String,
  type: String,
  originalLanguage: String,
  tagline: String,
  homepage: String,
  inProduction: Boolean, // Currently airing/in production
  
  // Metadata
  views: {
    type: Number,
    default: 0
  },
  popularity: {
    type: Number,
    default: 0,
    index: true
  },
  // Cache metadata
  cacheType: {
    type: String,
    enum: ['popular', 'top_rated', 'on_the_air', 'airing_today', 'trending', 'search', 'details'],
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
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Index for faster queries
tvSeriesSchema.index({ tmdbId: 1 });
tvSeriesSchema.index({ voteAverage: -1 });
tvSeriesSchema.index({ firstAirDate: -1 });
tvSeriesSchema.index({ popularity: -1 });
tvSeriesSchema.index({ cacheType: 1, lastFetched: -1 });
tvSeriesSchema.index({ name: 'text', overview: 'text' });

// Helper method to check if cache is expired
tvSeriesSchema.methods.isCacheExpired = function() {
  return !this.cacheExpiry || new Date() > this.cacheExpiry;
};

module.exports = mongoose.model('TvSeries', tvSeriesSchema);
