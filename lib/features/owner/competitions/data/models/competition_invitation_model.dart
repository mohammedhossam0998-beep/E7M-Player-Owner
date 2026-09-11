class CompetitionInvitationModel {
  final int id;
  final int competitionId;

  final int? playerId;
  final int? teamId;

  final String status;

  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  final String? playerName;
  final String? playerEmail;
  final String? playerProfileImage;

  final String? teamName;
  final int? teamCaptainId;

  const CompetitionInvitationModel({
    required this.id,
    required this.competitionId,
    this.playerId,
    this.teamId,
    required this.status,
    this.expiresAt,
    this.respondedAt,
    this.createdAt,
    this.playerName,
    this.playerEmail,
    this.playerProfileImage,
    this.teamName,
    this.teamCaptainId,
  });

  factory CompetitionInvitationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionInvitationModel(
      id: _parseInt(json['id']),
      competitionId: _parseInt(json['competition_id']),
      playerId: _parseNullableInt(json['player_id']),
      teamId: _parseNullableInt(json['team_id']),
      status: json['status'] as String,
      expiresAt: _parseDateTime(json['expires_at']),
      respondedAt: _parseDateTime(json['responded_at']),
      createdAt: _parseDateTime(json['created_at']),
      playerName: json['player_name'] as String?,
      playerEmail: json['player_email'] as String?,
      playerProfileImage:
      json['player_profile_image'] as String?,
      teamName: json['team_name'] as String?,
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
      'expires_at': expiresAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
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
    return int.parse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}