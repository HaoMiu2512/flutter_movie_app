const express = require('express');
const router = express.Router();

// New controllers with cache logic
const {
  searchMulti,
  searchMovies,
  searchTV
} = require('../controllers/searchControllerNew');

// Search all (movies + TV series) with cache
router.get('/', searchMulti);

// Search movies only with cache
router.get('/movies', searchMovies);

// Search TV series only with cache
router.get('/tv', searchTV);

module.exports = router;
