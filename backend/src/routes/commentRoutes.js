const express = require('express');
const router = express.Router();
const commentController = require('../controllers/commentController');

// Get comments for a media
// GET /api/comments/:mediaType/:mediaId?page=1&limit=20&sortBy=newest
router.get('/:mediaType/:mediaId', commentController.getComments);

// Get replies for a comment
// GET /api/comments/:commentId/replies?page=1&limit=10
router.get('/:commentId/replies', commentController.getReplies);

// Create a comment
// POST /api/comments/:mediaType/:mediaId
router.post('/:mediaType/:mediaId', commentController.createComment);

// Like/unlike a comment
// PUT /api/comments/:commentId/like
router.put('/:commentId/like', commentController.likeComment);

// Delete a comment
// DELETE /api/comments/:commentId
router.delete('/:commentId', commentController.deleteComment);

// Get comment statistics
// GET /api/comments/:mediaType/:mediaId/stats
router.get('/:mediaType/:mediaId/stats', commentController.getCommentStats);

module.exports = router;
