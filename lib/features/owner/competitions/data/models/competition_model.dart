class CompetitionModel {
  final int id;
  final String name;
  final String? description;
  final String? location;

  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? registrationStartDate;
  final DateTime? registrationDeadline;

  final double entryFee;

  final String status;
  final int createdBy;

  final String competitionType;

  // Tournament format returned by the backend.
  // Examples: league, knockout.
  final String? format;

  final int? maxParticipants;
  final int? minPlayersPerTeam;
  final int? maxPlayersPerTeam;

  final String approvalMode;
  final bool waitingListEnabled;

  final String visibility;
  final bool allowWithdrawal;

  final String refundPolicy;

  final DateTime? createdAt;

  const CompetitionModel({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.startDate,
    this.endDate,
    this.registrationStartDate,
    this.registrationDeadline,
    required this.entryFee,
    required this.status,
    required this.createdBy,
    required this.competitionType,
    this.format,
    this.maxParticipants,
    this.minPlayersPerTeam,
    this.maxPlayersPerTeam,
    required this.approvalMode,
    required this.waitingListEnabled,
    required this.visibility,
    required this.allowWithdrawal,
    required this.refundPolicy,
    this.createdAt,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      id: _parseInt(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      registrationStartDate:
      _parseDateTime(json['registration_start_date']),
      registrationDeadline:
      _parseDateTime(json['registration_deadline']),
      entryFee: _parseDouble(json['entry_fee']),
      status: json['status'] as String,
      createdBy: _parseInt(json['created_by']),
      competitionType: json['competition_type'] as String,

      format: json['format']?.toString(),

      maxParticipants: _parseNullableInt(json['max_participants']),
      minPlayersPerTeam:
      _parseNullableInt(json['min_players_per_team']),
      maxPlayersPerTeam:
      _parseNullableInt(json['max_players_per_team']),
      approvalMode: json['approval_mode'] as String,
      waitingListEnabled:
      json['waiting_list_enabled'] as bool,
      visibility: json['visibility'] as String,
      allowWithdrawal: json['allow_withdrawal'] as bool,
      refundPolicy: json['refund_policy'] as String,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'registration_start_date':
      registrationStartDate?.toIso8601String(),
      'registration_deadline':
      registrationDeadline?.toIso8601String(),
      'entry_fee': entryFee,
      'status': status,
      'created_by': createdBy,
      'competition_type': competitionType,
      'format': format,
      'max_participants': maxParticipants,
      'min_players_per_team': minPlayersPerTeam,
      'max_players_per_team': maxPlayersPerTeam,
      'approval_mode': approvalMode,
      'waiting_list_enabled': waitingListEnabled,
      'visibility': visibility,
      'allow_withdrawal': allowWithdrawal,
      'refund_policy': refundPolicy,
      'created_at': createdAt?.toIso8601String(),
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

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}