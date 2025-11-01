const express = require('express');
const router = express.Router();
const recommendedController = require('../controllers/recommendedController');

// Get all recommended movies
router.get('/', recommendedController.getRecommendedMovies);

// Get recommended movie by TMDB ID
router.get('/:tmdbId', recommendedController.getRecommendedMovieByTmdbId);

module.exports = router;
