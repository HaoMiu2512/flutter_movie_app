class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final String mediaType; // 'movie' or 'tv'

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    this.mediaType = 'movie',
  });

  // Convert Movie object to Map (for storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'mediaType': mediaType,
    };
  }

  // Create Movie object from Map (from storage)
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String,
      overview: json['overview'] as String,
      voteAverage: (json['voteAverage'] as num).toDouble(),
      releaseDate: json['releaseDate'] as String,
      mediaType: json['mediaType'] as String? ?? 'movie',
    );
  }

  // Create Movie from API response
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
      other is Movie && runtimeType == other.runtimeType && id == other.id && mediaType == other.mediaType;

  @override
  int get hashCode => id.hashCode ^ mediaType.hashCode;
}
