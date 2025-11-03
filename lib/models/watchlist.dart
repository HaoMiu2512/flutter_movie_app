class WatchlistItem {
  final String itemId;
  final String itemType; // 'movie', 'tv', 'trending', 'upcoming'
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final DateTime addedAt;
  final String? id; // MongoDB _id

  WatchlistItem({
    required this.itemId,
    required this.itemType,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    required this.addedAt,
    this.id,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing WatchlistItem: $json'); // Debug log
    return WatchlistItem(
      itemId: json['itemId']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? 'movie',
      title: json['title']?.toString() ?? 'Unknown Title',
      posterPath: json['posterPath']?.toString(),
      backdropPath: json['backdropPath']?.toString(),
      overview: json['overview']?.toString(),
      releaseDate: json['releaseDate']?.toString(),
      voteAverage: json['voteAverage'] != null 
          ? (json['voteAverage'] as num).toDouble() 
          : null,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemType': itemType,
      'title': title,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'overview': overview,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'addedAt': addedAt.toIso8601String(),
      if (id != null) '_id': id,
    };
  }
}

class Watchlist {
  final String id;
  final String name;
  final String description;
  final bool isPublic;
  final List<WatchlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Watchlist({
    required this.id,
    required this.name,
    this.description = '',
    this.isPublic = false,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    List<WatchlistItem> itemsList = [];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => WatchlistItem.fromJson(item))
          .toList();
    }

    return Watchlist(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isPublic: json['isPublic'] ?? false,
      items: itemsList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Watchlist copyWith({
    String? id,
    String? name,
    String? description,
    bool? isPublic,
    List<WatchlistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get itemCount => items.length;

  bool containsItem(String itemId, String itemType) {
    return items.any(
      (item) => item.itemId == itemId && item.itemType == itemType,
    );
  }
}

class WatchlistCheckResult {
  final bool isInAnyList;
  final List<WatchlistInfo> inWatchlists;

  WatchlistCheckResult({
    required this.isInAnyList,
    required this.inWatchlists,
  });

  factory WatchlistCheckResult.fromJson(Map<String, dynamic> json) {
    List<WatchlistInfo> lists = [];
    if (json['inWatchlists'] != null) {
      lists = (json['inWatchlists'] as List)
          .map((item) => WatchlistInfo.fromJson(item))
          .toList();
    }

    return WatchlistCheckResult(
      isInAnyList: json['isInAnyList'] ?? false,
      inWatchlists: lists,
    );
  }
}

class WatchlistInfo {
  final String id;
  final String name;

  WatchlistInfo({
    required this.id,
    required this.name,
  });

  factory WatchlistInfo.fromJson(Map<String, dynamic> json) {
    return WatchlistInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
