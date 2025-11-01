const express = require('express');
const router = express.Router();
const similarController = require('../controllers/similarController');

// Get all similar movies
router.get('/', similarController.getSimilarMovies);

// Get similar movie by TMDB ID
router.get('/:tmdbId', similarController.getSimilarMovieByTmdbId);

module.exports = router;
