class Review {
  final String id;
  final int mediaId;
  final String mediaType; // 'movie' or 'tv'
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String sentiment; // terrible, bad, average, good, great, excellent
  final String title;
  final String text;
  final bool containsSpoilers;
  final List<String> helpfulVotes;
  final List<String> unhelpfulVotes;
  final int helpfulCount;
  final int unhelpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Review({
    required this.id,
    required this.mediaId,
    required this.mediaType,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.sentiment,
    required this.title,
    required this.text,
    this.containsSpoilers = false,
    required this.helpfulVotes,
    required this.unhelpfulVotes,
    required this.helpfulCount,
    required this.unhelpfulCount,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  // Factory constructor from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      mediaId: json['mediaId'] ?? 0,
      mediaType: json['mediaType'] ?? 'movie',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userPhotoUrl: json['userPhotoUrl'],
      sentiment: json['sentiment'] ?? 'average',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      containsSpoilers: json['containsSpoilers'] ?? false,
      helpfulVotes: List<String>.from(
          json['helpfulVotes']?.map((v) => v['userId'].toString()) ?? []),
      unhelpfulVotes: List<String>.from(
          json['unhelpfulVotes']?.map((v) => v['userId'].toString()) ?? []),
      helpfulCount: json['helpfulCount'] ?? 0,
      unhelpfulCount: json['unhelpfulCount'] ?? 0,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
      'sentiment': sentiment,
      'title': title,
      'text': text,
      'containsSpoilers': containsSpoilers,
    };
  }

  // Get sentiment display info
  SentimentInfo get sentimentInfo {
    return SentimentDisplay.info[sentiment] ?? SentimentDisplay.info['average']!;
  }

  // Check user's vote status
  String? getUserVote(String userId) {
    if (helpfulVotes.contains(userId)) return 'helpful';
    if (unhelpfulVotes.contains(userId)) return 'unhelpful';
    return null;
  }

  // Copy with method for immutability
  Review copyWith({
    String? id,
    int? mediaId,
    String? mediaType,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? sentiment,
    String? title,
    String? text,
    bool? containsSpoilers,
    List<String>? helpfulVotes,
    List<String>? unhelpfulVotes,
    int? helpfulCount,
    int? unhelpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Review(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      mediaType: mediaType ?? this.mediaType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      sentiment: sentiment ?? this.sentiment,
      title: title ?? this.title,
      text: text ?? this.text,
      containsSpoilers: containsSpoilers ?? this.containsSpoilers,
      helpfulVotes: helpfulVotes ?? this.helpfulVotes,
      unhelpfulVotes: unhelpfulVotes ?? this.unhelpfulVotes,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      unhelpfulCount: unhelpfulCount ?? this.unhelpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class SentimentInfo {
  final String vietnamese;
  final String english;
  final String emoji;
  final String color; // Hex color code

  const SentimentInfo({
    required this.vietnamese,
    required this.english,
    required this.emoji,
    required this.color,
  });
}

class SentimentDisplay {
  static const Map<String, SentimentInfo> info = {
    'terrible': SentimentInfo(
      vietnamese: 'Tệ',
      english: 'Terrible',
      emoji: '😡',
      color: '#D32F2F',
    ),
    'bad': SentimentInfo(
      vietnamese: 'Kém',
      english: 'Bad',
      emoji: '😞',
      color: '#F57C00',
    ),
    'average': SentimentInfo(
      vietnamese: 'Trung Bình',
      english: 'Average',
      emoji: '😐',
      color: '#FBC02D',
    ),
    'good': SentimentInfo(
      vietnamese: 'Tốt',
      english: 'Good',
      emoji: '😊',
      color: '#7CB342',
    ),
    'great': SentimentInfo(
      vietnamese: 'Rất Tốt',
      english: 'Great',
      emoji: '😄',
      color: '#43A047',
    ),
    'excellent': SentimentInfo(
      vietnamese: 'Xuất Sắc',
      english: 'Excellent',
      emoji: '🤩',
      color: '#1976D2',
    ),
  };

  static List<String> get allSentiments =>
      ['terrible', 'bad', 'average', 'good', 'great', 'excellent'];
}

class ReviewStats {
  final int total;
  final Map<String, int> sentimentBreakdown;
  final double averageScore;
  final String averageSentiment;

  ReviewStats({
    required this.total,
    required this.sentimentBreakdown,
    required this.averageScore,
    required this.averageSentiment,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      total: json['total'] ?? 0,
      sentimentBreakdown:
          Map<String, int>.from(json['sentimentBreakdown'] ?? {}),
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      averageSentiment: json['averageSentiment'] ?? 'average',
    );
  }

  // Get percentage for a sentiment
  double getPercentage(String sentiment) {
    if (total == 0) return 0;
    final count = sentimentBreakdown[sentiment] ?? 0;
    return (count / total) * 100;
  }
}
