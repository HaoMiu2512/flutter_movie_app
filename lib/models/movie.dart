class Movie {
  final String mongoId; // MongoDB _id
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final String mediaType; // 'movie' or 'tv'
  final String? videoUrl;
  final int? year;
  final List<String>? genre;
  final bool? isPro;
  final int? views;
  final int? favoritesCount;

  Movie({
    this.mongoId = '',
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    this.mediaType = 'movie',
    this.videoUrl,
    this.year,
    this.genre,
    this.isPro,
    this.views,
    this.favoritesCount,
  });

  // Convert Movie object to Map (for storage)
  Map<String, dynamic> toJson() {
    return {
      if (mongoId.isNotEmpty) '_id': mongoId,
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'mediaType': mediaType,
      if (videoUrl != null) 'video_url': videoUrl,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (isPro != null) 'isPro': isPro,
      if (views != null) 'views': views,
      if (favoritesCount != null) 'favoritesCount': favoritesCount,
    };
  }

  // Create Movie object from Map (from storage or backend)
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      mongoId: json['_id'] as String? ?? '',
      id: json['id'] as int? ?? 0,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String? ?? json['poster'] as String? ?? '',
      overview: json['overview'] as String,
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ??
                    (json['rating'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['releaseDate'] as String? ??
                   (json['year']?.toString() ?? ''),
      mediaType: json['mediaType'] as String? ?? 'movie',
      videoUrl: json['video_url'] as String?,
      year: json['year'] as int?,
      genre: (json['genre'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isPro: json['isPro'] as bool?,
      views: json['views'] as int?,
      favoritesCount: json['favoritesCount'] as int?,
    );
  }

  // Create Movie from backend API response
  factory Movie.fromBackendApi(Map<String, dynamic> json) {
    return Movie(
      mongoId: json['_id'] as String? ?? '',
      id: json['tmdbId'] as int? ?? json['id'] as int? ?? 0, // Use tmdbId if available
      title: json['title'] as String? ?? 'Unknown',
      posterPath: json['poster'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['rating'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['year']?.toString() ?? '',
      mediaType: 'movie',
      videoUrl: json['video_url'] as String?,
      year: json['year'] as int?,
      genre: (json['genre'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isPro: json['isPro'] as bool?,
      views: json['views'] as int?,
      favoritesCount: json['favoritesCount'] as int?,
    );
  }

  // Create Movie from TMDB API response (legacy support)
  factory Movie.fromApi(Map<String, dynamic> json, {String mediaType = 'movie'}) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      posterPath: json['poster_path'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? json['first_air_date'] as String? ?? '',
      mediaType: mediaType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie && runtimeType == other.runtimeType &&
      (mongoId.isNotEmpty ? mongoId == other.mongoId : id == other.id && mediaType == other.mediaType);

  @override
  int get hashCode => mongoId.isNotEmpty ? mongoId.hashCode : (id.hashCode ^ mediaType.hashCode);
}
