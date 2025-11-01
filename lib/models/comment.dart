class Comment {
  final String id;
  final int mediaId;
  final String mediaType; // 'movie' or 'tv'
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final String? parentCommentId; // For replies
  final List<String> likes;
  final int likesCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Comment({
    required this.id,
    required this.mediaId,
    required this.mediaType,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    this.parentCommentId,
    required this.likes,
    required this.likesCount,
    required this.replyCount,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  // Factory constructor from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      mediaId: json['mediaId'] ?? 0,
      mediaType: json['mediaType'] ?? 'movie',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userPhotoUrl: json['userPhotoUrl'],
      text: json['text'] ?? '',
      parentCommentId: json['parentCommentId'],
      likes: List<String>.from(json['likes']?.map((l) => l['userId'].toString()) ?? []),
      likesCount: json['likesCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'mediaType': mediaType,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'parentCommentId': parentCommentId,
    };
  }

  // Check if current user liked this comment
  bool isLikedByUser(String userId) {
    return likes.contains(userId);
  }

  // Copy with method for immutability
  Comment copyWith({
    String? id,
    int? mediaId,
    String? mediaType,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? text,
    String? parentCommentId,
    List<String>? likes,
    int? likesCount,
    int? replyCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Comment(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      mediaType: mediaType ?? this.mediaType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class CommentStats {
  final int totalComments;
  final int topLevelComments;
  final int replies;

  CommentStats({
    required this.totalComments,
    required this.topLevelComments,
    required this.replies,
  });

  factory CommentStats.fromJson(Map<String, dynamic> json) {
    return CommentStats(
      totalComments: json['totalComments'] ?? 0,
      topLevelComments: json['topLevelComments'] ?? 0,
      replies: json['replies'] ?? 0,
    );
  }
}
