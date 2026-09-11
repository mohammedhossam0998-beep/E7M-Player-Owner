class PlayerProfileModel {
  final int? id;
  final int? userId;

  // Account information
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profileImage;

  // Football profile
  final String? position;
  final String? skillLevel;
  final String? dateOfBirth;
  final String? preferredFoot;
  final String? bio;
  final int? height;
  final int? weight;
  final String? city;
  final int? experience;
  final String? playingStyle;

  final DateTime? createdAt;

  const PlayerProfileModel({
    this.id,
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.profileImage,
    this.position,
    this.skillLevel,
    this.dateOfBirth,
    this.preferredFoot,
    this.bio,
    this.height,
    this.weight,
    this.city,
    this.experience,
    this.playingStyle,
    this.createdAt,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory PlayerProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PlayerProfileModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),

      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profileImage: json['profile_image']?.toString(),

      position: json['position']?.toString(),
      skillLevel: json['skill_level']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      preferredFoot: json['preferred_foot']?.toString(),
      bio: json['bio']?.toString(),

      height: _toInt(json['height']),
      weight: _toInt(json['weight']),

      city: json['city']?.toString(),
      experience: _toInt(json['experience']),
      playingStyle: json['playing_style']?.toString(),

      createdAt: _toDateTime(json['created_at']),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,

      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,

      'position': position,
      'skill_level': skillLevel,
      'date_of_birth': dateOfBirth,
      'preferred_foot': preferredFoot,
      'bio': bio,

      'height': height,
      'weight': weight,
      'city': city,
      'experience': experience,
      'playing_style': playingStyle,

      'created_at': createdAt?.toIso8601String(),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PlayerProfileModel copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? position,
    String? skillLevel,
    String? dateOfBirth,
    String? preferredFoot,
    String? bio,
    int? height,
    int? weight,
    String? city,
    int? experience,
    String? playingStyle,
    DateTime? createdAt,
  }) {
    return PlayerProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,

      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,

      position: position ?? this.position,
      skillLevel: skillLevel ?? this.skillLevel,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      bio: bio ?? this.bio,

      height: height ?? this.height,
      weight: weight ?? this.weight,
      city: city ?? this.city,
      experience: experience ?? this.experience,
      playingStyle: playingStyle ?? this.playingStyle,

      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }
}