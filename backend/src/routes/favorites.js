const express = require('express');
const router = express.Router();
const {
  getUserFavorites,
  addFavorite,
  removeFavorite,
  removeFavoriteByMedia,
  checkFavorite,
  clearAllFavorites
} = require('../controllers/favoritesController');

// Favorites routes
router.get('/:userId', getUserFavorites);
router.post('/', addFavorite);
router.delete('/:id', removeFavorite);
router.post('/remove', removeFavoriteByMedia);
router.get('/check/:userId/:mediaType/:mediaId', checkFavorite);
router.delete('/clear/:userId', clearAllFavorites);

module.exports = router;
