class TeamMemberModel {
  final int id;
  final String fullName;
  final String? profileImage;
  final String role;
  final DateTime? joinedAt;

  const TeamMemberModel({
    required this.id,
    required this.fullName,
    this.profileImage,
    required this.role,
    this.joinedAt,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory TeamMemberModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TeamMemberModel(
      id: _toInt(json['id']) ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      profileImage:
      json['profile_image']?.toString(),
      role: json['role']?.toString() ?? 'player',
      joinedAt: _toDateTime(
        json['joined_at'],
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profile_image': profileImage,
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get isCaptain =>
      role.toLowerCase() == 'captain';

  bool get isPlayer =>
      role.toLowerCase() == 'player';

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