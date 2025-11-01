/// User Profile Model
class UserProfile {
  final String id;
  final String firebaseUid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? bio;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? country;
  final List<String>? favoriteGenres;
  final DateTime joinDate;
  final DateTime lastActive;
  final bool emailNotifications;
  final bool pushNotifications;
  final int totalFavorites;
  final int totalReviews;
  final int totalComments;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.bio,
    this.phoneNumber,
    this.dateOfBirth,
    this.country,
    this.favoriteGenres,
    required this.joinDate,
    required this.lastActive,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.totalFavorites = 0,
    this.totalReviews = 0,
    this.totalComments = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      bio: json['bio'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      country: json['country'],
      favoriteGenres: json['favoriteGenres'] != null 
          ? List<String>.from(json['favoriteGenres']) 
          : null,
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      totalFavorites: json['totalFavorites'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'country': country,
      'favoriteGenres': favoriteGenres,
      'joinDate': joinDate.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'totalFavorites': totalFavorites,
      'totalReviews': totalReviews,
      'totalComments': totalComments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? country,
    List<String>? favoriteGenres,
    DateTime? joinDate,
    DateTime? lastActive,
    bool? emailNotifications,
    bool? pushNotifications,
    int? totalFavorites,
    int? totalReviews,
    int? totalComments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      joinDate: joinDate ?? this.joinDate,
      lastActive: lastActive ?? this.lastActive,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalReviews: totalReviews ?? this.totalReviews,
      totalComments: totalComments ?? this.totalComments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
