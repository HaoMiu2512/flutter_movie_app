const express = require('express');
const router = express.Router();
const {
  getAllMovies,
  getMovieById,
  getMovieByTmdbId,
  searchMovies,
  getTrendingMovies
} = require('../controllers/movieController');

// New controllers with cache logic
const {
  getPopularMovies,
  getTopRatedMovies,
  getUpcomingMovies,
  getNowPlayingMovies,
  getMovieDetails,
  getMovieVideos
} = require('../controllers/movieControllerNew');

const { verifyFirebaseToken } = require('../middleware/auth');

// Public routes with cache (NEW - using cached controllers)
router.get('/popular', getPopularMovies); // Popular movies with cache
router.get('/top-rated', getTopRatedMovies); // Top rated with cache
router.get('/upcoming', getUpcomingMovies); // Upcoming with cache
router.get('/now-playing', getNowPlayingMovies); // Now playing with cache
router.get('/tmdb/:tmdbId/videos', getMovieVideos); // Videos with cache
router.get('/tmdb/:tmdbId', getMovieDetails); // Movie details with cache

// Old routes (backward compatibility)
router.get('/', getAllMovies);
router.get('/search', searchMovies);
router.get('/trending', getTrendingMovies);
router.get('/:id', getMovieById); // Get by MongoDB ID

module.exports = router;
