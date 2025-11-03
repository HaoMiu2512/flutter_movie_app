const express = require('express');
const router = express.Router();
const watchlistController = require('../controllers/watchlistController');
const { verifyFirebaseToken } = require('../middleware/auth');

// All routes require authentication
router.use(verifyFirebaseToken);

// Watchlist routes
router.get('/', watchlistController.getUserWatchlists);
router.get('/check', watchlistController.checkItemInWatchlists);
router.get('/:id', watchlistController.getWatchlist);
router.post('/', watchlistController.createWatchlist);
router.put('/:id', watchlistController.updateWatchlist);
router.delete('/:id', watchlistController.deleteWatchlist);

// Item routes
router.post('/:id/items', watchlistController.addItemToWatchlist);
router.delete('/:id/items/:itemId', watchlistController.removeItemFromWatchlist);

module.exports = router;
