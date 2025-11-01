# Quick Testing Guide - Comments & Reviews System

## 🚀 Before You Start

### 1. Ensure Backend is Running
```bash
cd backend
npm start
```
- Server should be running on `http://localhost:3000`
- Check terminal for "Server is running on port 3000"
- MongoDB connection should be established

### 2. Check MongoDB
- Ensure MongoDB is running locally OR
- Verify MongoDB Atlas connection string in `backend/.env`

### 3. Build and Run Flutter App
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Testing Checklist

### ✅ Comments Tab

#### Post Comment
1. Navigate to any movie/TV detail page
2. Tap "Comments" tab
3. Type in the text field at bottom: "This is a test comment"
4. Tap send icon
5. **Verify**: Comment appears with your avatar, username, timestamp
6. **Verify**: "Just now" timestamp displays

#### Like Comment
1. Find any comment
2. Tap the heart/like button
3. **Verify**: Button turns red/filled
4. **Verify**: Like count increases by 1
5. Tap again to unlike
6. **Verify**: Button returns to outline, count decreases

#### Reply to Comment
1. Find any comment
2. Tap "Reply" button
3. Dialog appears with "Reply to [Username]"
4. Type: "This is a reply"
5. Tap "Send"
6. **Verify**: Reply appears indented under parent comment
7. **Verify**: "1 replies" badge shows on parent

#### Sort Comments
1. Tap sort dropdown (top of comments)
2. Select "Newest" → **Verify**: Most recent comments first
3. Select "Oldest" → **Verify**: Oldest comments first
4. Select "Most Liked" → **Verify**: Comments sorted by like count

#### Pagination
1. Scroll to bottom of comments list
2. **Verify**: "Load more" button appears (if >10 comments)
3. Tap "Load more"
4. **Verify**: Next page loads, more comments appear

---

### ⭐ Reviews Tab

#### Write Review
1. Navigate to movie/TV detail page
2. Tap "Reviews" tab
3. Tap floating "Write Review" button (bottom right)
4. Dialog opens

**Test Form**:
- **Sentiment**: Tap each emotion (Terrible → Excellent)
  - **Verify**: Card highlights with gradient + shadow
- **Title**: Type "Great Movie!" (optional)
  - **Verify**: Character counter shows "11/200"
- **Content**: Type review text (min 10 chars)
  - **Verify**: Required field validation works
- **Spoiler**: Tap checkbox
  - **Verify**: Checkbox turns orange, background changes
- Tap "Post" button
- **Verify**: Dialog closes, review appears in list
- **Verify**: Sentiment badge shows correct emoji + color

#### Edit Review
1. Find your own review (has edit/delete buttons)
2. Tap edit icon (blue pencil)
3. Change sentiment to different level
4. Modify text
5. Tap "Update"
6. **Verify**: Review updates immediately
7. **Verify**: "Just now" timestamp resets

#### Delete Review
1. Find your own review
2. Tap delete icon (red trash)
3. Confirm deletion (if prompt exists)
4. **Verify**: Review disappears from list
5. **Verify**: Stats bar updates (total count decreases)

#### Vote on Reviews
1. Find any review (not yours)
2. **Helpful Vote**:
   - Tap thumbs up icon
   - **Verify**: Button highlights blue, count increases
   - Tap again → **Verify**: Vote removed
3. **Unhelpful Vote**:
   - Tap thumbs down icon
   - **Verify**: Button highlights red, count increases
   - Tap again → **Verify**: Vote removed
4. **Switch Vote**:
   - Vote helpful, then vote unhelpful
   - **Verify**: Helpful vote removed, unhelpful added

#### Filter Reviews
1. Tap filter chips at top:
   - "All" → Shows all reviews
   - "😊 Good" → Shows only Good reviews
   - "🤩 Excellent" → Shows only Excellent reviews
2. **Verify**: List updates to show filtered results
3. **Verify**: Selected chip has cyan gradient background

#### Sort Reviews
1. Tap sort dropdown:
   - "Newest" → Most recent first
   - "Oldest" → Oldest first
   - "Helpful" → Most helpful votes first
   - "Rating" → Best sentiment first
2. **Verify**: List re-orders correctly

#### Stats Bar
1. After posting multiple reviews (different sentiments)
2. **Verify**: Stats bar shows:
   - Total count: "5 reviews"
   - Average sentiment badge with emoji
   - Progress bars for each sentiment level
   - Percentages add up to 100%
   - Individual counts: (3), (2), etc.

---

### 🎨 UI Visual Tests

#### Theme Consistency
- **Verify**: All containers use cyan accents
- **Verify**: Gradients visible (#0A1929 → #0F1922)
- **Verify**: Borders are cyan with transparency
- **Verify**: Shadows provide depth on cards

#### Typography
- **Verify**: Usernames in cyan.shade200
- **Verify**: Timestamps in grey.shade400
- **Verify**: Body text readable (white/grey.shade200)

#### Interactive Elements
- **Verify**: All buttons have hover/tap feedback
- **Verify**: Decorated containers have proper padding
- **Verify**: Icons are properly sized and colored
- **Verify**: Dropdowns have correct styling

#### Form Dialog
- **Verify**: Dialog has rounded corners (20px)
- **Verify**: Cyan border visible around dialog
- **Verify**: Header has gradient background
- **Verify**: Close button in top-right corner
- **Verify**: Submit button has gradient + shadow
- **Verify**: Form fields have cyan borders

---

### 🌍 English Translation Tests

#### Comments
- [ ] "Sort by:" label visible
- [ ] Dropdown: "Newest", "Oldest", "Most Liked"
- [ ] Empty state: "No comments yet"
- [ ] Placeholder: "Write a comment..."
- [ ] Button: "Reply"
- [ ] Time: "Just now", "5 min ago", "2 hr ago"
- [ ] Validation: "Comment must be at least 1 character"
- [ ] Badge: "3 replies"

#### Reviews
- [ ] "Filter:" label
- [ ] Chips: "All", sentiment names in English
- [ ] Sort: "Newest", "Oldest", "Helpful", "Rating"
- [ ] Empty: "No reviews yet"
- [ ] Button: "Write Review", "Edit Review"
- [ ] Stats: "5 reviews"
- [ ] Badge: "Contains Spoiler"
- [ ] Sentiments: "Terrible", "Bad", "Average", "Good", "Great", "Excellent"

#### Review Form
- [ ] Title: "Write Review" / "Edit Review"
- [ ] Section: "Your Rating"
- [ ] Field: "Title (Optional)"
- [ ] Placeholder: "Summarize your review..."
- [ ] Field: "Review Content *"
- [ ] Placeholder: "Share your thoughts about this movie..."
- [ ] Checkbox: "This review contains spoilers"
- [ ] Buttons: "Cancel", "Post", "Update"
- [ ] Validation: "Please enter review content"
- [ ] Validation: "Review must be at least 10 characters"

#### Tabs
- [ ] Tab 1: "Comments"
- [ ] Tab 2: "Reviews"

---

## 🐛 Common Issues & Fixes

### Backend Not Responding
**Symptom**: Reviews/comments don't post, infinite loading  
**Fix**:
```bash
cd backend
npm start
# Check server.log for errors
```

### MongoDB Connection Failed
**Symptom**: Console shows "Failed to connect to MongoDB"  
**Fix**:
- Start local MongoDB: `mongod`
- OR check `.env` file for correct Atlas URI
- Verify network connection

### API 404 Errors
**Symptom**: "Failed to load reviews/comments"  
**Fix**:
- Check `lib/config/api_config.dart`
- Android Emulator: Use `10.0.2.2:3000`
- iOS Simulator: Use `localhost:3000`
- Physical Device: Use computer's IP address

### Empty Lists
**Symptom**: "No comments yet" even after posting  
**Check**:
1. Backend logs for errors
2. Network tab in browser DevTools
3. MongoDB data: `db.comments.find()` / `db.reviews.find()`
4. Console logs in Flutter app

### Styling Issues
**Symptom**: Colors not matching, gradients missing  
**Fix**:
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Rebuild app

---

## 📊 Test Scenarios

### Scenario 1: New User Experience
1. Open app as new user (no login)
2. Browse to movie detail
3. **Verify**: Comment/Review fields show login prompt OR placeholder
4. Login with Firebase Auth
5. **Verify**: Full functionality available

### Scenario 2: Heavy Load
1. Post 20+ comments rapidly
2. **Verify**: All comments save
3. **Verify**: Pagination works correctly
4. **Verify**: No duplicate entries

### Scenario 3: Offline → Online
1. Turn off network
2. Try posting comment
3. **Verify**: Error message shows
4. Turn on network
5. Retry posting
6. **Verify**: Comment posts successfully

### Scenario 4: Edit Spam Prevention
1. Post review
2. Edit review immediately
3. Edit again within 1 minute
4. **Verify**: All edits save with updated timestamp

---

## ✅ Success Criteria

### Functionality
- ✅ All CRUD operations work (Create, Read, Update, Delete)
- ✅ Real-time updates (comments appear immediately)
- ✅ Pagination loads correctly
- ✅ Sorting/filtering produces correct results
- ✅ Validation prevents invalid inputs

### UI/UX
- ✅ Theme colors consistent across all components
- ✅ Smooth animations (fade in, slide up)
- ✅ Touch targets large enough (min 48x48 dp)
- ✅ Text readable in dark mode
- ✅ Loading states visible

### Performance
- ✅ Lists scroll smoothly (60 FPS)
- ✅ Images load efficiently
- ✅ No memory leaks
- ✅ API responses < 2 seconds

### Translation
- ✅ All text in English
- ✅ No Vietnamese text remaining
- ✅ Grammar correct in all messages
- ✅ Sentiment labels accurate

---

## 📝 Reporting Issues

If you find bugs, report with:
1. **What happened**: Describe the issue
2. **Expected**: What should have happened
3. **Steps**: How to reproduce
4. **Screenshots**: Visual proof
5. **Console logs**: Error messages
6. **Environment**: Device, OS, Flutter version

---

**Happy Testing!** 🎉
