const express = require('express');
const router = express.Router();

// New controllers with cache logic
const {
  getTrending,
  getTrendingMovies,
  getTrendingTV
} = require('../controllers/trendingControllerNew');

// Get all trending (movies + TV) with cache
router.get('/', getTrending);

// Get trending movies only with cache
router.get('/movies', getTrendingMovies);

// Get trending TV series only with cache
router.get('/tv', getTrendingTV);

module.exports = router;
