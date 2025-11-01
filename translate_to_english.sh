#!/bin/bash

# Script to translate Vietnamese text to English in Comments & Reviews widgets

# Comments Widget translations
sed -i "s/'Sắp xếp:'/'Sort by:'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Mới nhất'/'Newest'/g" lib/reapeatedfunction/comments_widget.dart  
sed -i "s/'Cũ nhất'/'Oldest'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Nhiều thích nhất'/'Most Liked'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Nhiều like'/'Most Liked'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Chưa có bình luận nào'/'No comments yet'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Viết bình luận...'/'Write a comment...'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Trả lời'/'Reply'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Xem thêm'/'Load more'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Vừa xong'/'Just now'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/' phút trước'/' min ago'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/' giờ trước'/' hr ago'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/' ngày trước'/' day ago'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Bình luận phải có ít nhất 1 ký tự'/'Comment must be at least 1 character'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Bình luận không được vượt quá 500 ký tự'/'Comment cannot exceed 500 characters'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Trả lời bình luận'/'Reply to comment'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Trả lời cho'/'Reply to'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Hủy'/'Cancel'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/'Gửi'/'Send'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/' phản hồi'/' replies'/g" lib/reapeatedfunction/comments_widget.dart
sed -i "s/' phản hồi'/' reply'/g" lib/reapeatedfunction/comments_widget.dart

# Reviews Widget translations
sed -i "s/'Lọc theo:'/'Filter:'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Tất cả'/'All'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Mới nhất'/'Newest'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Cũ nhất'/'Oldest'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Hữu ích'/'Helpful'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Đánh giá'/'Rating'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Chưa có đánh giá'/'No reviews yet'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Viết đánh giá'/'Write Review'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Sửa đánh giá'/'Edit Review'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/' đánh giá'/' reviews'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Có Spoiler'/'Contains Spoiler'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/'Vừa xong'/'Just now'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/' phút trước'/' min ago'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/' giờ trước'/' hr ago'/g" lib/reapeatedfunction/reviews_widget.dart
sed -i "s/' ngày trước'/' day ago'/g" lib/reapeatedfunction/reviews_widget.dart

# Review Form Dialog translations
sed -i "s/'Chỉnh sửa đánh giá'/'Edit Review'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Viết đánh giá'/'Write Review'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Đánh giá của bạn'/'Your Rating'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Tiêu đề (Tùy chọn)'/'Title (Optional)'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Tóm tắt đánh giá của bạn...'/'Summarize your review...'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Nội dung đánh giá \*'/'Review Content \*'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Chia sẻ suy nghĩ của bạn về bộ phim...'/'Share your thoughts about this movie...'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Vui lòng nhập nội dung đánh giá'/'Please enter review content'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Đánh giá phải có ít nhất 10 ký tự'/'Review must be at least 10 characters'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Đánh giá này có chứa spoiler'/'This review contains spoilers'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Hủy'/'Cancel'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Cập nhật'/'Update'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Đăng'/'Post'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Đã lưu đánh giá'/'Review saved'/g" lib/reapeatedfunction/review_form_dialog.dart
sed -i "s/'Lỗi khi lưu đánh giá'/'Error saving review'/g" lib/reapeatedfunction/review_form_dialog.dart

# Discussion Tabs translations
sed -i "s/'Bình Luận'/'Comments'/g" lib/reapeatedfunction/discussion_tabs.dart
sed -i "s/'Đánh Giá'/'Reviews'/g" lib/reapeatedfunction/discussion_tabs.dart

echo "Translation completed!"
