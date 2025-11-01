class TvSeriesDetail {
  final String id;
  final int tmdbId;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? firstAirDate;
  final List<Genre> genres;
  final List<Season> seasons;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final List<Video> videos;
  final List<ProductionCompany> productionCompanies;
  final List<int> episodeRunTime;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final String status;
  final String type;
  final String originalLanguage;
  final String? tagline;
  final String? homepage;
  final int views;

  TvSeriesDetail({
    required this.id,
    required this.tmdbId,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.firstAirDate,
    required this.genres,
    required this.seasons,
    required this.cast,
    required this.crew,
    required this.videos,
    required this.productionCompanies,
    required this.episodeRunTime,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.status,
    required this.type,
    required this.originalLanguage,
    this.tagline,
    this.homepage,
    required this.views,
  });

  factory TvSeriesDetail.fromJson(Map<String, dynamic> json) {
    return TvSeriesDetail(
      id: json['_id'] ?? '',
      tmdbId: json['tmdbId'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['posterPath'],
      backdropPath: json['backdropPath'],
      voteAverage: (json['voteAverage'] ?? 0).toDouble(),
      voteCount: json['voteCount'] ?? 0,
      firstAirDate: json['firstAirDate'],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => Genre.fromJson(g))
              .toList() ??
          [],
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((s) => Season.fromJson(s))
              .toList() ??
          [],
      cast: (json['cast'] as List<dynamic>?)
              ?.map((c) => CastMember.fromJson(c))
              .toList() ??
          [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((c) => CrewMember.fromJson(c))
              .toList() ??
          [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((v) => Video.fromJson(v))
              .toList() ??
          [],
      productionCompanies: (json['productionCompanies'] as List<dynamic>?)
              ?.map((p) => ProductionCompany.fromJson(p))
              .toList() ??
          [],
      episodeRunTime: (json['episodeRunTime'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      numberOfSeasons: json['numberOfSeasons'] ?? 0,
      numberOfEpisodes: json['numberOfEpisodes'] ?? 0,
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      originalLanguage: json['originalLanguage'] ?? '',
      tagline: json['tagline'],
      homepage: json['homepage'],
      views: json['views'] ?? 0,
    );
  }

  // Get all trailers and teasers
  List<Video> get trailers =>
      videos.where((v) => v.type == 'Trailer' || v.type == 'Teaser').toList();

  // Get creators (similar to directors in movies)
  List<CrewMember> get creators =>
      crew.where((c) => c.job == 'Creator' || c.job == 'Executive Producer').toList();
}

class Season {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final int seasonNumber;
  final int episodeCount;
  final String? airDate;

  Season({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
    required this.episodeCount,
    this.airDate,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['posterPath'],
      seasonNumber: json['seasonNumber'] ?? 0,
      episodeCount: json['episodeCount'] ?? 0,
      airDate: json['airDate'],
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profilePath'],
      order: json['order'] ?? 0,
    );
  }
}

class CrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profilePath'],
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
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
      official: json['official'] ?? false,
    );
  }

  // Helper to get YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}

class ProductionCompany {
  final int id;
  final String name;
  final String? logoPath;
  final String originCountry;

  ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logoPath: json['logoPath'],
      originCountry: json['originCountry'] ?? '',
    );
  }
}
