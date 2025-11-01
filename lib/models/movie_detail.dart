// Model for detailed movie information from Backend API
class MovieDetail {
  final String mongoId;
  final int tmdbId;
  final String title;
  final String overview;
  final String poster;
  final String videoUrl;
  final double rating;
  final int year;
  final List<String> genre;
  final bool isPro;
  final int views;
  final int favoritesCount;

  // Detailed information
  final int runtime; // in minutes
  final int budget;
  final int revenue;
  final String tagline;
  final String homepage;
  final String status;
  final String originalLanguage;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final List<Video> videos;
  final List<ProductionCompany> productionCompanies;

  MovieDetail({
    required this.mongoId,
    required this.tmdbId,
    required this.title,
    required this.overview,
    required this.poster,
    required this.videoUrl,
    required this.rating,
    required this.year,
    required this.genre,
    required this.isPro,
    required this.views,
    required this.favoritesCount,
    required this.runtime,
    required this.budget,
    required this.revenue,
    required this.tagline,
    required this.homepage,
    required this.status,
    required this.originalLanguage,
    required this.cast,
    required this.crew,
    required this.videos,
    required this.productionCompanies,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      mongoId: json['_id'] as String? ?? '',
      tmdbId: json['tmdbId'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown',
      overview: json['overview'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      year: json['year'] as int? ?? 0,
      genre: (json['genre'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isPro: json['isPro'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      favoritesCount: json['favoritesCount'] as int? ?? 0,
      runtime: json['runtime'] as int? ?? 0,
      budget: json['budget'] as int? ?? 0,
      revenue: json['revenue'] as int? ?? 0,
      tagline: json['tagline'] as String? ?? '',
      homepage: json['homepage'] as String? ?? '',
      status: json['status'] as String? ?? 'Released',
      originalLanguage: json['originalLanguage'] as String? ?? 'en',
      cast: (json['cast'] as List<dynamic>?)
              ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) => CrewMember.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      productionCompanies: (json['productionCompanies'] as List<dynamic>?)
              ?.map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  // Get director(s) from crew
  List<CrewMember> get directors =>
      crew.where((member) => member.job == 'Director').toList();

  // Get writers from crew
  List<CrewMember> get writers =>
      crew.where((member) => member.job == 'Writer' || member.job == 'Screenplay').toList();

  // Get official trailers
  List<Video> get trailers =>
      videos.where((video) => video.type == 'Trailer' && video.site == 'YouTube').toList();
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String profilePath;
  final int order;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profilePath'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class CrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String profilePath;

  CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    required this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      job: json['job'] as String? ?? '',
      department: json['department'] as String? ?? '',
      profilePath: json['profilePath'] as String? ?? '',
    );
  }
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
      official: json['official'] as bool? ?? false,
    );
  }

  // Get YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}

class ProductionCompany {
  final int id;
  final String name;
  final String logoPath;

  ProductionCompany({
    required this.id,
    required this.name,
    required this.logoPath,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      logoPath: json['logoPath'] as String? ?? '',
    );
  }
}
