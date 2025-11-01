const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');

// Get reviews for a media
// GET /api/reviews/:mediaType/:mediaId?page=1&limit=10&sortBy=newest&sentiment=good
router.get('/:mediaType/:mediaId', reviewController.getReviews);

// Get user's review for a media
// GET /api/reviews/:mediaType/:mediaId/user/:userId
router.get('/:mediaType/:mediaId/user/:userId', reviewController.getUserReview);

// Get review statistics
// GET /api/reviews/:mediaType/:mediaId/stats
router.get('/:mediaType/:mediaId/stats', reviewController.getReviewStats);

// Create a review
// POST /api/reviews/:mediaType/:mediaId
router.post('/:mediaType/:mediaId', reviewController.createReview);

// Update a review
// PUT /api/reviews/:reviewId
router.put('/:reviewId', reviewController.updateReview);

// Delete a review
// DELETE /api/reviews/:reviewId
router.delete('/:reviewId', reviewController.deleteReview);

// Vote on a review (helpful/unhelpful)
// PUT /api/reviews/:reviewId/vote
router.put('/:reviewId/vote', reviewController.voteReview);

module.exports = router;
