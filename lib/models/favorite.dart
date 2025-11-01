/// Favorite Model
class Favorite {
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
  final List<String>? genres;
  final DateTime addedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Favorite({
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
    this.genres,
    required this.addedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
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
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
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
      'genres': genres,
      'addedAt': addedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isMovie => mediaType == 'movie';
  bool get isTVShow => mediaType == 'tv';
}
