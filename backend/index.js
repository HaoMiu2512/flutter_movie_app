require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const connectDB = require('./src/config/database');
require('./src/config/firebase'); // Initialize Firebase Admin

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files (for avatar uploads)
app.use('/uploads', express.static('uploads'));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/movies', require('./src/routes/movies'));
app.use('/api/tv-series', require('./src/routes/tvSeries'));
app.use('/api/trending', require('./src/routes/trending'));
app.use('/api/similar', require('./src/routes/similar'));
app.use('/api/recommended', require('./src/routes/recommended'));
app.use('/api/tv/similar', require('./src/routes/tvSimilar'));
app.use('/api/tv/recommended', require('./src/routes/tvRecommended'));
app.use('/api/search', require('./src/routes/search'));

// User & profile routes
app.use('/api/users', require('./src/routes/users'));
app.use('/api/users/favorites', require('./src/routes/favorites'));
app.use('/api/recently-viewed', require('./src/routes/recentlyViewed'));
app.use('/api/upload', require('./src/routes/upload'));

// Review & comment routes
app.use('/api/comments', require('./src/routes/commentRoutes'));
app.use('/api/reviews', require('./src/routes/reviewRoutes'));

// Watchlist routes
app.use('/api/watchlists', require('./src/routes/watchlistRoutes'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Flutter Movie API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to Flutter Movie API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      movies: '/api/movies',
      movieDetail: '/api/movies/:id',
      tvSeries: '/api/tv-series',
      tvSeriesDetail: '/api/tv-series/tmdb/:tmdbId',
      topRatedTvSeries: '/api/tv-series/top-rated',
      search: '/api/search?q=query',
      searchMovies: '/api/search/movies?q=query',
      searchTv: '/api/search/tv?q=query',
      trending: '/api/trending',
      trendingMovies: '/api/trending/movies',
      trendingTv: '/api/trending/tv',
      similar: '/api/similar',
      recommended: '/api/recommended',
      tvSimilar: '/api/tv/similar',
      tvRecommended: '/api/tv/recommended',
      upcomingMovies: '/api/movies/upcoming',
      topRated: '/api/movies/top-rated',
      favorites: '/api/users/favorites',
      addFavorite: 'POST /api/users/favorites',
      removeFavorite: 'DELETE /api/users/favorites/:movieId',
      checkFavorite: '/api/users/favorites/check/:movieId',
      comments: '/api/comments/:mediaType/:mediaId',
      createComment: 'POST /api/comments/:mediaType/:mediaId',
      reviews: '/api/reviews/:mediaType/:mediaId',
      createReview: 'POST /api/reviews/:mediaType/:mediaId',
      reviewStats: '/api/reviews/:mediaType/:mediaId/stats',
      watchlists: '/api/watchlists',
      createWatchlist: 'POST /api/watchlists',
      addToWatchlist: 'POST /api/watchlists/:id/items',
      checkInWatchlist: '/api/watchlists/check?itemId=xxx&itemType=movie'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Connect to MongoDB and start server
connectDB().then(() => {
  // Listen on 0.0.0.0 to allow connections from Android emulator (10.0.2.2)
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 Server is running on port ${PORT}`);
    console.log(`📱 API available at:`);
    console.log(`   - http://localhost:${PORT} (local)`);
    console.log(`   - http://10.0.2.2:${PORT} (Android emulator)`);
    console.log(`🏥 Health check: http://localhost:${PORT}/health\n`);
  });
}).catch((error) => {
  console.error('Failed to connect to database:', error);
  process.exit(1);
});
