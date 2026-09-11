class CompetitionMatchModel {
  final int id;
  final int competitionId;

  final DateTime? matchDate;
  final String? startTime;

  final int? homeScore;
  final int? awayScore;

  final String status;

  final int? homeParticipantId;
  final int? awayParticipantId;

  final String? round;
  final int? matchNumber;

  final int? homeSourceMatchId;
  final int? awaySourceMatchId;

  final int? homePlayerId;
  final int? homeTeamId;

  final int? awayPlayerId;
  final int? awayTeamId;

  const CompetitionMatchModel({
    required this.id,
    required this.competitionId,
    this.matchDate,
    this.startTime,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.homeParticipantId,
    this.awayParticipantId,
    this.round,
    this.matchNumber,
    this.homeSourceMatchId,
    this.awaySourceMatchId,
    this.homePlayerId,
    this.homeTeamId,
    this.awayPlayerId,
    this.awayTeamId,
  });

  factory CompetitionMatchModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionMatchModel(
      id: _parseInt(json['id']) ?? 0,

      competitionId: _parseInt(
        json['competition_id'] ??
            json['competitionId'],
      ) ??
          0,

      matchDate: _parseDateTime(
        json['match_date'] ??
            json['matchDate'],
      ),

      startTime:
      json['start_time']?.toString() ??
          json['startTime']?.toString(),

      homeScore: _parseNullableInt(
        json['home_score'] ??
            json['homeScore'],
      ),

      awayScore: _parseNullableInt(
        json['away_score'] ??
            json['awayScore'],
      ),

      status:
      (json['status'] ?? '').toString(),

      homeParticipantId: _parseNullableInt(
        json['home_participant_id'] ??
            json['homeParticipantId'],
      ),

      awayParticipantId: _parseNullableInt(
        json['away_participant_id'] ??
            json['awayParticipantId'],
      ),

      round:
      json['round']?.toString(),

      matchNumber: _parseNullableInt(
        json['match_number'] ??
            json['matchNumber'],
      ),

      homeSourceMatchId: _parseNullableInt(
        json['home_source_match_id'] ??
            json['homeSourceMatchId'],
      ),

      awaySourceMatchId: _parseNullableInt(
        json['away_source_match_id'] ??
            json['awaySourceMatchId'],
      ),

      homePlayerId: _parseNullableInt(
        json['home_player_id'] ??
            json['homePlayerId'],
      ),

      homeTeamId: _parseNullableInt(
        json['home_team_id'] ??
            json['homeTeamId'],
      ),

      awayPlayerId: _parseNullableInt(
        json['away_player_id'] ??
            json['awayPlayerId'],
      ),

      awayTeamId: _parseNullableInt(
        json['away_team_id'] ??
            json['awayTeamId'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competition_id': competitionId,
      'match_date': matchDate?.toIso8601String(),
      'start_time': startTime,
      'home_score': homeScore,
      'away_score': awayScore,
      'status': status,
      'home_participant_id': homeParticipantId,
      'away_participant_id': awayParticipantId,
      'round': round,
      'match_number': matchNumber,
      'home_source_match_id': homeSourceMatchId,
      'away_source_match_id': awaySourceMatchId,
      'home_player_id': homePlayerId,
      'home_team_id': homeTeamId,
      'away_player_id': awayPlayerId,
      'away_team_id': awayTeamId,
    };
  }

  bool get isCompleted =>
      status == 'completed';

  bool get isScheduled =>
      status == 'scheduled';

  bool get isCancelled =>
      status == 'cancelled';

  bool get hasResult =>
      homeScore != null &&
          awayScore != null;

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    return _parseInt(value);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}