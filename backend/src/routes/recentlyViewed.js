const express = require('express');
const router = express.Router();
const {
  getRecentlyViewed,
  trackView,
  removeRecentlyViewed,
  clearRecentlyViewed,
  getWatchProgress
} = require('../controllers/recentlyViewedController');

// Recently viewed routes
router.get('/:userId', getRecentlyViewed);
router.post('/', trackView);
router.delete('/:id', removeRecentlyViewed);
router.delete('/clear/:userId', clearRecentlyViewed);
router.get('/progress/:userId/:mediaType/:mediaId', getWatchProgress);

module.exports = router;
