class CompetitionRegistrationModel {
  final int id;
  final int competitionId;

  final int? playerId;
  final int? teamId;

  final String status;

  final DateTime? registeredAt;
  final DateTime? reviewedAt;
  final DateTime? cancelledAt;

  final int? waitlistPosition;

  final String? playerName;
  final String? playerEmail;
  final String? playerProfileImage;

  final String? teamName;
  final int? teamCaptainId;

  const CompetitionRegistrationModel({
    required this.id,
    required this.competitionId,
    this.playerId,
    this.teamId,
    required this.status,
    this.registeredAt,
    this.reviewedAt,
    this.cancelledAt,
    this.waitlistPosition,
    this.playerName,
    this.playerEmail,
    this.playerProfileImage,
    this.teamName,
    this.teamCaptainId,
  });

  factory CompetitionRegistrationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionRegistrationModel(
      id: _parseInt(json['id']),
      competitionId: _parseInt(json['competition_id']),
      playerId: _parseNullableInt(json['player_id']),
      teamId: _parseNullableInt(json['team_id']),
      status: (json['status'] ?? 'pending').toString(),
      registeredAt: _parseDateTime(json['registered_at']),
      reviewedAt: _parseDateTime(json['reviewed_at']),
      cancelledAt: _parseDateTime(json['cancelled_at']),
      waitlistPosition:
      _parseNullableInt(json['waitlist_position']),
      playerName: json['player_name']?.toString(),
      playerEmail: json['player_email']?.toString(),
      playerProfileImage:
      json['player_profile_image']?.toString(),
      teamName: json['team_name']?.toString(),
      teamCaptainId:
      _parseNullableInt(json['team_captain_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competition_id': competitionId,
      'player_id': playerId,
      'team_id': teamId,
      'status': status,
      'registered_at': registeredAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'waitlist_position': waitlistPosition,
      'player_name': playerName,
      'player_email': playerEmail,
      'player_profile_image': playerProfileImage,
      'team_name': teamName,
      'team_captain_id': teamCaptainId,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
