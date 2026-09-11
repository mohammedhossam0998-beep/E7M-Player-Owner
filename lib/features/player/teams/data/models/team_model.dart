class TeamModel {
  final int id;
  final String name;
  final int captainId;

  final String? description;
  final String? logo;
  final String? gameType;
  final String? skillLevel;
  final String? city;
  final int? maxPlayers;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  final int membersCount;
  final int availableSlots;
  final double? distanceKm;

  final bool isMember;
  final bool isCaptain;
  final bool hasPendingRequest;

  final DateTime? createdAt;

  const TeamModel({
    required this.id,
    required this.name,
    required this.captainId,
    this.description,
    this.logo,
    this.gameType,
    this.skillLevel,
    this.city,
    this.maxPlayers,
    this.locationName,
    this.latitude,
    this.longitude,
    this.membersCount = 0,
    this.availableSlots = 0,
    this.distanceKm,
    this.isMember = false,
    this.isCaptain = false,
    this.hasPendingRequest = false,
    this.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      captainId: _toInt(json['captain_id']) ?? 0,

      description: json['description']?.toString(),
      logo: json['logo']?.toString(),
      gameType: json['game_type']?.toString(),
      skillLevel: json['skill_level']?.toString(),
      city: json['city']?.toString(),
      maxPlayers: _toInt(json['max_players']),
      locationName: json['location_name']?.toString(),

      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),

      membersCount: _toInt(json['members_count']) ?? 0,
      availableSlots: _toInt(json['available_slots']) ?? 0,

      distanceKm: _toDouble(json['distance_km']),

      isMember: _toBool(json['is_member']),
      isCaptain: _toBool(json['is_captain']),
      hasPendingRequest: _toBool(json['has_pending_request']),

      createdAt: _toDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'captain_id': captainId,
      'description': description,
      'logo': logo,
      'game_type': gameType,
      'skill_level': skillLevel,
      'city': city,
      'max_players': maxPlayers,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'members_count': membersCount,
      'available_slots': availableSlots,
      'distance_km': distanceKm,
      'is_member': isMember,
      'is_captain': isCaptain,
      'has_pending_request': hasPendingRequest,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  TeamModel copyWith({
    int? id,
    String? name,
    int? captainId,
    String? description,
    String? logo,
    String? gameType,
    String? skillLevel,
    String? city,
    int? maxPlayers,
    String? locationName,
    double? latitude,
    double? longitude,
    int? membersCount,
    int? availableSlots,
    double? distanceKm,
    bool? isMember,
    bool? isCaptain,
    bool? hasPendingRequest,
    DateTime? createdAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      captainId: captainId ?? this.captainId,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      gameType: gameType ?? this.gameType,
      skillLevel: skillLevel ?? this.skillLevel,
      city: city ?? this.city,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      membersCount: membersCount ?? this.membersCount,
      availableSlots: availableSlots ?? this.availableSlots,
      distanceKm: distanceKm ?? this.distanceKm,
      isMember: isMember ?? this.isMember,
      isCaptain: isCaptain ?? this.isCaptain,
      hasPendingRequest: hasPendingRequest ?? this.hasPendingRequest,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final stringValue = value?.toString().toLowerCase();

    return stringValue == 'true' || stringValue == '1';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}