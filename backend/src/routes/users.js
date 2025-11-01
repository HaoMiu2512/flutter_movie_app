const express = require('express');
const router = express.Router();
const {
  getUserProfile,
  updateUserProfile,
  createUser,
  deleteUser,
  getUserStats
} = require('../controllers/userController');

// User profile routes
router.get('/profile/:userId', getUserProfile);
router.put('/profile/:userId', updateUserProfile);
router.post('/create', createUser);
router.delete('/:userId', deleteUser);
router.get('/stats/:userId', getUserStats);

module.exports = router;
