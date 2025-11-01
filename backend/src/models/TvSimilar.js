const mongoose = require('mongoose');

const tvSimilarSchema = new mongoose.Schema({
  tmdbId: {
    type: Number,
    required: true,
    unique: true
  },
  title: {
    type: String,
    required: true,
    index: true
  },
  overview: String,
  posterPath: String,
  backdropPath: String,
  voteAverage: Number,
  voteCount: Number,
  popularity: Number,
  firstAirDate: String,
  originCountry: [String],
  originalLanguage: String,
  originalName: String,
  genreIds: [Number],
  genre: {
    type: [String],
    index: true
  },
  // Videos
  videos: [{
    id: { type: String },
    key: { type: String },
    name: { type: String },
    site: { type: String },
    type: { type: String },
    official: { type: Boolean },
    publishedAt: { type: String }
  }],
  // Credits
  cast: [{
    id: { type: Number },
    name: { type: String },
    character: { type: String },
    profilePath: { type: String },
    order: { type: Number }
  }],
  crew: [{
    id: { type: Number },
    name: { type: String },
    job: { type: String },
    department: { type: String },
    profilePath: { type: String }
  }],
  // Series-specific fields
  numberOfSeasons: Number,
  numberOfEpisodes: Number,
  episodeRunTime: [Number],
  status: String,
  type: String,
  createdBy: [{
    id: { type: Number },
    name: { type: String },
    profilePath: { type: String }
  }],
  networks: [{
    id: { type: Number },
    name: { type: String },
    logoPath: { type: String },
    originCountry: { type: String }
  }],
  productionCompanies: [{
    id: { type: Number },
    name: { type: String },
    logoPath: { type: String },
    originCountry: { type: String }
  }],
  seasons: [{
    id: { type: Number },
    name: { type: String },
    seasonNumber: { type: Number },
    episodeCount: { type: Number },
    airDate: { type: String },
    posterPath: { type: String },
    overview: { type: String }
  }],
  // Additional fields
  homepage: String,
  inProduction: Boolean,
  languages: [String],
  lastAirDate: String,
  tagline: String,
  adult: Boolean
}, {
  timestamps: true
});

// Indexes for better query performance
tvSimilarSchema.index({ title: 'text' });
tvSimilarSchema.index({ genre: 1 });
tvSimilarSchema.index({ voteAverage: -1 });
tvSimilarSchema.index({ popularity: -1 });
tvSimilarSchema.index({ firstAirDate: -1 });

module.exports = mongoose.model('TvSimilar', tvSimilarSchema);
