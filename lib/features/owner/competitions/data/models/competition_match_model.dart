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
  });

  factory CompetitionMatchModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionMatchModel(
      id: int.parse(json['id'].toString()),
      competitionId: int.parse(
        json['competition_id'].toString(),
      ),
      matchDate: json['match_date'] == null
          ? null
          : DateTime.tryParse(
        json['match_date'].toString(),
      ),
      startTime: json['start_time']?.toString(),
      homeScore: json['home_score'] == null
          ? null
          : int.tryParse(
        json['home_score'].toString(),
      ),
      awayScore: json['away_score'] == null
          ? null
          : int.tryParse(
        json['away_score'].toString(),
      ),
      status: json['status']?.toString() ?? '',
      homeParticipantId:
      json['home_participant_id'] == null
          ? null
          : int.tryParse(
        json['home_participant_id'].toString(),
      ),
      awayParticipantId:
      json['away_participant_id'] == null
          ? null
          : int.tryParse(
        json['away_participant_id'].toString(),
      ),
      round: json['round']?.toString(),
      matchNumber: json['match_number'] == null
          ? null
          : int.tryParse(
        json['match_number'].toString(),
      ),
      homeSourceMatchId:
      json['home_source_match_id'] == null
          ? null
          : int.tryParse(
        json['home_source_match_id'].toString(),
      ),
      awaySourceMatchId:
      json['away_source_match_id'] == null
          ? null
          : int.tryParse(
        json['away_source_match_id'].toString(),
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
    };
  }

  CompetitionMatchModel copyWith({
    int? id,
    int? competitionId,
    DateTime? matchDate,
    String? startTime,
    int? homeScore,
    int? awayScore,
    String? status,
    int? homeParticipantId,
    int? awayParticipantId,
    String? round,
    int? matchNumber,
    int? homeSourceMatchId,
    int? awaySourceMatchId,
  }) {
    return CompetitionMatchModel(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      matchDate: matchDate ?? this.matchDate,
      startTime: startTime ?? this.startTime,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      homeParticipantId:
      homeParticipantId ?? this.homeParticipantId,
      awayParticipantId:
      awayParticipantId ?? this.awayParticipantId,
      round: round ?? this.round,
      matchNumber: matchNumber ?? this.matchNumber,
      homeSourceMatchId:
      homeSourceMatchId ?? this.homeSourceMatchId,
      awaySourceMatchId:
      awaySourceMatchId ?? this.awaySourceMatchId,
    );
  }
}