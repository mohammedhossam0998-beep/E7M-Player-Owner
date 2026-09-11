class TeamJoinRequestModel {
  final int id;
  final int teamId;
  final int playerId;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? fullName;
  final String? profileImage;

  final String? position;
  final String? skillLevel;
  final String? city;
  final String? experience;

  const TeamJoinRequestModel({
    required this.id,
    required this.teamId,
    required this.playerId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.profileImage,
    this.position,
    this.skillLevel,
    this.city,
    this.experience,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory TeamJoinRequestModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TeamJoinRequestModel(
      id: _toInt(json['id']) ?? 0,
      teamId: _toInt(json['team_id']) ?? 0,
      playerId: _toInt(json['player_id']) ?? 0,

      status:
      json['status']?.toString() ?? 'pending',

      createdAt:
      _toDateTime(json['created_at']),

      updatedAt:
      _toDateTime(json['updated_at']),

      fullName:
      json['full_name']?.toString(),

      profileImage:
      json['profile_image']?.toString(),

      position:
      json['position']?.toString(),

      skillLevel:
      json['skill_level']?.toString(),

      city:
      json['city']?.toString(),

      experience:
      json['experience']?.toString(),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'player_id': playerId,
      'status': status,
      'created_at':
      createdAt?.toIso8601String(),
      'updated_at':
      updatedAt?.toIso8601String(),
      'full_name': fullName,
      'profile_image': profileImage,
      'position': position,
      'skill_level': skillLevel,
      'city': city,
      'experience': experience,
    };
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isPending =>
      status.toLowerCase() == 'pending';

  bool get isApproved =>
      status.toLowerCase() == 'approved';

  bool get isRejected =>
      status.toLowerCase() == 'rejected';

  // ============================================================
  // HELPERS
  // ============================================================

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static DateTime? _toDateTime(
      dynamic value,
      ) {
    if (value == null) return null;

    return DateTime.tryParse(
      value.toString(),
    );
  }
}