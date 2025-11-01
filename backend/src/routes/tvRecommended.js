const express = require('express');
const router = express.Router();
const tvRecommendedController = require('../controllers/tvRecommendedController');

// GET /api/tv/recommended - Get all recommended TV series
router.get('/', tvRecommendedController.getTvRecommendedSeries);

module.exports = router;
