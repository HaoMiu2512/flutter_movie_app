/// Recently Viewed Model
class RecentlyViewed {
  final String id;
  final String userId;
  final String mediaType; // 'movie' or 'tv'
  final int mediaId;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final double rating;
  final String? releaseDate;
  final DateTime viewedAt;
  final int viewCount;
  final int watchProgress; // Percentage 0-100
  final int lastWatchPosition; // Seconds
  final DateTime createdAt;
  final DateTime updatedAt;

  RecentlyViewed({
    required this.id,
    required this.userId,
    required this.mediaType,
    required this.mediaId,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.rating = 0,
    this.releaseDate,
    required this.viewedAt,
    this.viewCount = 1,
    this.watchProgress = 0,
    this.lastWatchPosition = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecentlyViewed.fromJson(Map<String, dynamic> json) {
    return RecentlyViewed(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      mediaType: json['mediaType'] ?? '',
      mediaId: json['mediaId'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['posterPath'],
      backdropPath: json['backdropPath'],
      overview: json['overview'],
      rating: (json['rating'] ?? 0).toDouble(),
      releaseDate: json['releaseDate'],
      viewedAt: DateTime.parse(json['viewedAt'] ?? DateTime.now().toIso8601String()),
      viewCount: json['viewCount'] ?? 1,
      watchProgress: json['watchProgress'] ?? 0,
      lastWatchPosition: json['lastWatchPosition'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'mediaType': mediaType,
      'mediaId': mediaId,
      'title': title,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'overview': overview,
      'rating': rating,
      'releaseDate': releaseDate,
      'viewedAt': viewedAt.toIso8601String(),
      'viewCount': viewCount,
      'watchProgress': watchProgress,
      'lastWatchPosition': lastWatchPosition,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isMovie => mediaType == 'movie';
  bool get isTVShow => mediaType == 'tv';
  
  bool get hasWatchProgress => watchProgress > 0;
  bool get isCompleted => watchProgress >= 90; // Consider 90%+ as completed
}
