const express = require('express');
const router = express.Router();
const tvSimilarController = require('../controllers/tvSimilarController');

// GET /api/tv/similar - Get all similar TV series
router.get('/', tvSimilarController.getTvSimilarSeries);

module.exports = router;
