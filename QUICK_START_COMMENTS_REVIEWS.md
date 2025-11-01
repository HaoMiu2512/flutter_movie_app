# ⚡ Quick Start Guide - Comments & Reviews

## 🚀 Chạy ứng dụng

### 1. Start MongoDB (nếu dùng local)
```bash
# Windows
net start MongoDB

# Mac/Linux
sudo systemctl start mongod
```

### 2. Start Backend
```bash
cd backend
npm run dev
```

✅ Backend sẽ chạy tại: `http://localhost:3000`

### 3. Start Flutter App
```bash
# Terminal mới
flutter run
```

---

## 🧪 Test Nhanh (5 phút)

### Test Comments (2 phút)

1. **Login** vào app với Firebase Auth
2. **Chọn phim** Fight Club (ID: 550)
3. **Scroll xuống** phần "Bình Luận & Đánh Giá"
4. Tab **"Bình Luận"**:
   - ✅ Nhập text: "Great movie!" → Click Send
   - ✅ Verify comment xuất hiện trong list
   - ✅ Click ❤️ icon → Verify count tăng
   - ✅ Click "Trả lời" → Nhập reply → Gửi
   - ✅ Verify "1 câu trả lời" hiển thị
   - ✅ Click 🗑️ icon → Xóa comment

### Test Reviews (3 phút)

5. Tab **"Đánh Giá"**:
   - ✅ Click FAB "Viết đánh giá"
   - ✅ Chọn sentiment **"Rất Tốt" 😄**
   - ✅ Nhập tiêu đề: "Phim hay"
   - ✅ Nhập nội dung: "Phim rất hay, diễn viên xuất sắc..."
   - ✅ Check "Có spoiler"
   - ✅ Click "Đăng"
   - ✅ Verify review xuất hiện với badge màu xanh
   - ✅ Click 👍 "Hữu ích" → Verify count tăng
   - ✅ Click filter chip "Rất Tốt" → Verify chỉ hiển thị reviews 😄
   - ✅ Click ✏️ icon → Edit → Đổi sentiment → Cập nhật

---

## 🐛 Troubleshooting

### Backend không chạy
```bash
# Check MongoDB running
mongosh
# Hoặc
mongo

# Nếu lỗi connection, check MongoDB service
```

### Flutter build error
```bash
# Clear build cache
flutter clean
flutter pub get
flutter run
```

### API 404 error
- Check backend running tại `http://localhost:3000`
- Check `lib/config/api_config.dart`:
  ```dart
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
  // hoặc
  static const String baseUrl = 'http://localhost:3000'; // iOS Simulator
  ```

### Comments/Reviews không load
- Check terminal backend có log request không
- Check userId từ Firebase Auth:
  ```dart
  final user = FirebaseAuth.instance.currentUser;
  print('User ID: ${user?.uid}'); // Should not be empty
  ```

---

## 📱 Demo Data

### Sample Movie IDs (TMDB)
- Fight Club: `550`
- The Dark Knight: `155`
- Inception: `27205`
- Interstellar: `157336`

### Sample TV IDs (TMDB)
- Breaking Bad: `1396`
- Game of Thrones: `1399`
- Stranger Things: `66732`

---

## 🎯 What to Test

### Must Test ✅
- [x] Login/Logout
- [x] Post comment
- [x] Like comment
- [x] Reply comment
- [x] Delete comment
- [x] Write review
- [x] Vote helpful/unhelpful
- [x] Edit review
- [x] Delete review
- [x] Filter by sentiment
- [x] Sort reviews

### Nice to Test (Optional)
- [ ] Pagination (scroll xuống load thêm)
- [ ] Pull-to-refresh
- [ ] Switch giữa Movies và TV Series
- [ ] Test với nhiều users khác nhau
- [ ] Check stats bar cập nhật đúng
- [ ] Spoiler warning hiển thị

---

## 📊 Expected Results

### Comments
- Mỗi comment hiển thị:
  - Avatar + userName
  - Text content
  - Timestamp ("Vừa xong", "5 phút trước"...)
  - ❤️ Like count
  - "Trả lời" button
  - "X câu trả lời" nếu có replies
  - 🗑️ Delete button (chỉ own comments)

### Reviews
- Mỗi review hiển thị:
  - Avatar + userName
  - Sentiment badge với emoji + text (e.g., 😄 Rất Tốt)
  - Title (bold)
  - Text content
  - ⚠️ "Có Spoiler" badge (nếu có)
  - 👍 Helpful count
  - 👎 Unhelpful count
  - ✏️ Edit button (own review)
  - 🗑️ Delete button (own review)

### Stats Bar
- Tổng số reviews
- Average sentiment (emoji + text)
- Progress bars cho từng sentiment
- Percentages (%Tệ, %Kém, %Trung Bình...)

---

## 🎉 Success Criteria

Nếu tất cả items sau hoạt động → **Migration thành công!**

- ✅ Backend API responds (200 OK)
- ✅ Comments load và hiển thị
- ✅ Reviews load và hiển thị
- ✅ Post comment thành công
- ✅ Write review thành công
- ✅ Like/Vote works
- ✅ Edit/Delete works (own content)
- ✅ Filter/Sort works
- ✅ Stats display correctly
- ✅ No errors in console
- ✅ ChatRoom không còn xuất hiện

---

## 📝 Notes

- **Login required**: Phải login mới post comment/review
- **One review per user**: Mỗi user chỉ được 1 review/media
- **Can't vote own content**: Không thể like/vote chính mình
- **Soft delete**: Xóa không mất dữ liệu (isDeleted=true)

---

## 💡 Tips

1. **Test với nhiều accounts**: Để test vote, reply giữa users
2. **Check backend logs**: Xem requests trong terminal
3. **Use Postman**: Test API trực tiếp nếu UI có vấn đề
4. **MongoDB Compass**: Xem data trong database

---

**Ready to test? Let's go! 🚀**

Nếu có lỗi, check `COMMENTS_REVIEWS_COMPLETE.md` để debug.
