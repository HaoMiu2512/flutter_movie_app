# Changelog - Comments & Reviews Migration

## [2.0.0] - 2025-10-30

### 🎉 Major Feature: Chat → Comments & Reviews Migration

### Added
#### Backend
- **Models**
  - `backend/src/models/Comment.js` - MongoDB schema cho comments với threading support
  - `backend/src/models/Review.js` - MongoDB schema cho reviews với sentiment-based ratings

- **Controllers**
  - `backend/src/controllers/commentController.js` - 6 endpoints (getComments, getReplies, createComment, likeComment, deleteComment, getCommentStats)
  - `backend/src/controllers/reviewController.js` - 8 endpoints (getReviews, getUserReview, createReview, updateReview, deleteReview, voteReview, getReviewStats)

- **Routes**
  - `backend/src/routes/commentRoutes.js` - REST API routes cho comments
  - `backend/src/routes/reviewRoutes.js` - REST API routes cho reviews
  - Registered in `backend/index.js`

#### Flutter Models
- `lib/models/comment.dart` - Comment model với CommentStats
- `lib/models/review.dart` - Review model với SentimentDisplay (Vietnamese labels, emojis, colors)

#### Flutter Services
- `lib/services/comment_service.dart` - HTTP service để call Comment API
- `lib/services/review_service.dart` - HTTP service để call Review API

#### Flutter UI
- `lib/reapeatedfunction/discussion_tabs.dart` - Tab navigation widget (Comments ↔ Reviews)
- `lib/reapeatedfunction/comments_widget.dart` - Comments list với likes, replies, pagination
- `lib/reapeatedfunction/reviews_widget.dart` - Reviews list với sentiment badges, voting, stats
- `lib/reapeatedfunction/review_form_dialog.dart` - Full-screen form để write/edit reviews

#### Documentation
- `COMMENTS_REVIEWS_PROGRESS.md` - Implementation progress tracking
- `COMMENTS_REVIEWS_COMPLETE.md` - Complete API documentation & testing guide
- `COMMENTS_REVIEWS_SUMMARY.md` - Migration summary
- `QUICK_START_COMMENTS_REVIEWS.md` - Quick start & testing guide
- `CHANGELOG_COMMENTS_REVIEWS.md` - This file

### Changed
- `lib/details/moviesdetail.dart` - Replaced ChatRoom with DiscussionTabs
- `lib/details/tvseriesdetail.dart` - Replaced ChatRoom with DiscussionTabs
- `backend/index.js` - Added comment/review routes

### Removed
- `lib/models/chat_message.dart` - Replaced by Comment model
- `lib/services/chat_service.dart` - Replaced by Comment/Review services
- `lib/reapeatedfunction/chatroom.dart` - Replaced by DiscussionTabs

### Features
#### Comments
- ✅ Post comments với text input (max 500 chars)
- ✅ Like/unlike comments với toggle animation
- ✅ Reply to comments (threading support)
- ✅ Delete own comments (soft delete)
- ✅ Sort by: Newest | Oldest | Most Liked
- ✅ Pagination với infinite scroll
- ✅ Pull-to-refresh
- ✅ Reply count display

#### Reviews
- ✅ 6-level sentiment ratings: Tệ | Kém | Trung Bình | Tốt | Rất Tốt | Xuất Sắc
- ✅ Emoji badges với màu sắc tương ứng
- ✅ Title (optional) + Text (10-5000 chars)
- ✅ Spoiler warnings
- ✅ Helpful/Unhelpful voting (thumbs up/down)
- ✅ Edit/Delete own reviews
- ✅ Filter by sentiment
- ✅ Sort by: Newest | Oldest | Most Helpful | Sentiment
- ✅ Statistics bar với sentiment breakdown
- ✅ One review per user per media
- ✅ Pagination

### Database
#### Indexes Added
- Comment: `mediaId + mediaType + createdAt`
- Comment: `parentCommentId + createdAt`
- Comment: `userId + createdAt`
- Review: `mediaId + mediaType + createdAt`
- Review: **Unique** `mediaId + mediaType + userId`

#### Collections
- `comments` - Stores all comments và replies
- `reviews` - Stores all reviews

### API Endpoints (14 total)
#### Comments (6 endpoints)
- `GET /api/comments/:mediaType/:mediaId` - Get comments
- `GET /api/comments/:commentId/replies` - Get replies
- `POST /api/comments/:mediaType/:mediaId` - Create comment
- `PUT /api/comments/:commentId/like` - Like/unlike
- `DELETE /api/comments/:commentId` - Delete comment
- `GET /api/comments/:mediaType/:mediaId/stats` - Get stats

#### Reviews (8 endpoints)
- `GET /api/reviews/:mediaType/:mediaId` - Get reviews
- `GET /api/reviews/:mediaType/:mediaId/user/:userId` - Get user's review
- `POST /api/reviews/:mediaType/:mediaId` - Create review
- `PUT /api/reviews/:reviewId` - Update review
- `DELETE /api/reviews/:reviewId` - Delete review
- `PUT /api/reviews/:reviewId/vote` - Vote helpful/unhelpful
- `GET /api/reviews/:mediaType/:mediaId/stats` - Get review stats

### Technical Details
- **Backend**: Node.js + Express + MongoDB (Mongoose)
- **Frontend**: Flutter 3.9.2
- **Auth**: Firebase Auth (userId, userName, userPhotoUrl)
- **Database**: MongoDB với indexes cho performance
- **HTTP Client**: Dart http package
- **Date Formatting**: intl package (already installed)

### Migration Impact
- **Breaking Change**: ChatRoom widget hoàn toàn bị xóa
- **Database**: Cần MongoDB running (local hoặc Atlas)
- **Backend**: Cần backend running tại localhost:3000
- **Auth**: Comments/Reviews require Firebase Auth login

### Known Limitations
1. No nested replies UI (backend supports, UI shows count only)
2. No realtime updates (REST API instead of WebSocket)
3. No image upload support
4. No push notifications
5. No moderator dashboard

### Testing
- See `QUICK_START_COMMENTS_REVIEWS.md` for testing instructions
- Manual testing required for all features
- Backend API tested via Postman/cURL

### Next Steps (Optional)
- [ ] Implement nested replies UI with indentation
- [ ] Add WebSocket for realtime updates
- [ ] Implement push notifications
- [ ] Add image upload support
- [ ] Create moderator dashboard
- [ ] Add report/block features
- [ ] Write unit & integration tests

---

## Previous Versions

### [1.0.0] - 2025-10-29
- Firebase Chat Room implementation
- Firestore realtime messaging
- Simple chat UI
- **Replaced by Comments & Reviews system**

---

**Migration Status**: ✅ Complete  
**Version**: 2.0.0  
**Date**: October 30, 2025  
**Author**: Development Team
