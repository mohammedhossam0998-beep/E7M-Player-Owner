class CompetitionInvitationModel {
  final int id;
  final int competitionId;
  final int playerId;
  final int? teamId;

  final String status;

  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Competition data
  final String? competitionName;
  final String? competitionStatus;
  final String? competitionType;
  final double? entryFee;
  final DateTime? competitionStartDate;
  final String? approvalMode;

  // Team data
  final String? teamName;

  const CompetitionInvitationModel({
    required this.id,
    required this.competitionId,
    required this.playerId,
    this.teamId,
    required this.status,
    this.expiresAt,
    this.respondedAt,
    this.createdAt,
    this.updatedAt,
    this.competitionName,
    this.competitionStatus,
    this.competitionType,
    this.entryFee,
    this.competitionStartDate,
    this.approvalMode,
    this.teamName,
  });

  factory CompetitionInvitationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionInvitationModel(
      id: _parseInt(
        json['id'] ?? json['invitation_id'],
      ),

      competitionId: _parseInt(
        json['competition_id'],
      ),

      playerId: _parseInt(
        json['player_id'],
      ),

      teamId: _parseNullableInt(
        json['team_id'],
      ),

      status: (
          json['status'] ??
              json['invitation_status'] ??
              ''
      ).toString(),

      expiresAt: _parseDateTime(
        json['expires_at'],
      ),

      respondedAt: _parseDateTime(
        json['responded_at'],
      ),

      createdAt: _parseDateTime(
        json['created_at'],
      ),

      updatedAt: _parseDateTime(
        json['updated_at'],
      ),

      competitionName: _parseNullableString(
        json['competition_name'] ??
            json['name'],
      ),

      competitionStatus: _parseNullableString(
        json['competition_status'],
      ),

      competitionType: _parseNullableString(
        json['competition_type'],
      ),

      entryFee: _parseNullableDouble(
        json['entry_fee'],
      ),

      competitionStartDate: _parseDateTime(
        json['start_date'] ??
            json['competition_start_date'],
      ),

      approvalMode: _parseNullableString(
        json['approval_mode'],
      ),

      teamName: _parseNullableString(
        json['team_name'],
      ),
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
      'updated_at': updatedAt?.toIso8601String(),
      'competition_name': competitionName,
      'competition_status': competitionStatus,
      'competition_type': competitionType,
      'entry_fee': entryFee,
      'start_date': competitionStartDate?.toIso8601String(),
      'approval_mode': approvalMode,
      'team_name': teamName,
    };
  }

  CompetitionInvitationModel copyWith({
    int? id,
    int? competitionId,
    int? playerId,
    int? teamId,
    String? status,
    DateTime? expiresAt,
    DateTime? respondedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? competitionName,
    String? competitionStatus,
    String? competitionType,
    double? entryFee,
    DateTime? competitionStartDate,
    String? approvalMode,
    String? teamName,
  }) {
    return CompetitionInvitationModel(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      playerId: playerId ?? this.playerId,
      teamId: teamId ?? this.teamId,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      competitionName:
      competitionName ?? this.competitionName,
      competitionStatus:
      competitionStatus ?? this.competitionStatus,
      competitionType:
      competitionType ?? this.competitionType,
      entryFee: entryFee ?? this.entryFee,
      competitionStartDate:
      competitionStartDate ?? this.competitionStartDate,
      approvalMode:
      approvalMode ?? this.approvalMode,
      teamName: teamName ?? this.teamName,
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isAccepted => status.toLowerCase() == 'accepted';

  bool get isRejected => status.toLowerCase() == 'rejected';

  bool get isExpired =>
      status.toLowerCase() == 'expired' ||
          hasExpired;

  bool get isForPlayer => playerId > 0;

  bool get isForTeam => teamId != null;

  bool get hasExpired {
    if (expiresAt == null) return false;

    return DateTime.now().isAfter(expiresAt!);
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    final parsed = int.tryParse(
      value.toString(),
    );

    return parsed;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    if (result.isEmpty) return null;

    return result;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(
      value.toString(),
    );
  }
}