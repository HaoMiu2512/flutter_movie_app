const express = require('express');
const router = express.Router();
const tvSeriesController = require('../controllers/tvSeriesController');

// New controllers with cache logic
const {
  getPopularTVSeries,
  getTopRatedTVSeries,
  getOnTheAirTVSeries,
  getTVSeriesDetails,
  getTVSeriesVideos
} = require('../controllers/tvSeriesControllerNew');

// Public routes with cache (NEW - using cached controllers)
router.get('/popular', getPopularTVSeries); // Popular TV with cache
router.get('/top-rated', getTopRatedTVSeries); // Top rated TV with cache
router.get('/on-the-air', getOnTheAirTVSeries); // On the air TV with cache
router.get('/tmdb/:tmdbId/videos', getTVSeriesVideos); // TV videos with cache
router.get('/tmdb/:tmdbId', getTVSeriesDetails); // TV details with cache

// Old routes (backward compatibility)
router.get('/', tvSeriesController.getAllTvSeries);
router.get('/:id', tvSeriesController.getTvSeriesById);

module.exports = router;
