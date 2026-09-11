class CompetitionBracketModel {
  final int competitionId;
  final String competitionName;
  final String competitionType;
  final String format;
  final bool seedingConfirmed;
  final bool tournamentLocked;
  final String status;
  final List<CompetitionBracketRoundModel> rounds;

  const CompetitionBracketModel({
    required this.competitionId,
    required this.competitionName,
    required this.competitionType,
    required this.format,
    required this.seedingConfirmed,
    required this.tournamentLocked,
    required this.status,
    required this.rounds,
  });

  factory CompetitionBracketModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final competition =
    json['competition'] is Map<String, dynamic>
        ? json['competition'] as Map<String, dynamic>
        : <String, dynamic>{};

    final roundsData = json['rounds'];

    return CompetitionBracketModel(
      competitionId: int.parse(
        competition['id'].toString(),
      ),
      competitionName:
      competition['name']?.toString() ?? '',
      competitionType:
      competition['competition_type']?.toString() ?? '',
      format:
      competition['format']?.toString() ?? '',
      seedingConfirmed:
      competition['seeding_confirmed'] == true,
      tournamentLocked:
      competition['tournament_locked'] == true,
      status:
      competition['status']?.toString() ?? '',
      rounds: roundsData is List
          ? roundsData
          .map(
            (item) =>
            CompetitionBracketRoundModel.fromJson(
              item as Map<String, dynamic>,
            ),
      )
          .toList()
          : [],
    );
  }
}

// ============================================================
// BRACKET ROUND
// ============================================================

class CompetitionBracketRoundModel {
  final String round;
  final List<CompetitionBracketMatchModel> matches;

  const CompetitionBracketRoundModel({
    required this.round,
    required this.matches,
  });

  factory CompetitionBracketRoundModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final matchesData = json['matches'];

    return CompetitionBracketRoundModel(
      round:
      json['round']?.toString() ?? '',
      matches: matchesData is List
          ? matchesData
          .map(
            (item) =>
            CompetitionBracketMatchModel.fromJson(
              item as Map<String, dynamic>,
            ),
      )
          .toList()
          : [],
    );
  }
}

// ============================================================
// BRACKET MATCH
// ============================================================

class CompetitionBracketMatchModel {
  final int id;
  final int matchNumber;
  final DateTime? date;
  final String? startTime;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final CompetitionBracketParticipantModel?
  homeParticipant;
  final CompetitionBracketParticipantModel?
  awayParticipant;
  final int? homeSourceMatchId;
  final int? awaySourceMatchId;

  const CompetitionBracketMatchModel({
    required this.id,
    required this.matchNumber,
    this.date,
    this.startTime,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.homeParticipant,
    this.awayParticipant,
    this.homeSourceMatchId,
    this.awaySourceMatchId,
  });

  factory CompetitionBracketMatchModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketMatchModel(
      id: int.parse(
        json['id'].toString(),
      ),
      matchNumber: int.parse(
        json['match_number'].toString(),
      ),
      date: json['date'] == null
          ? null
          : DateTime.tryParse(
        json['date'].toString(),
      ),
      startTime:
      json['start_time']?.toString(),
      status:
      json['status']?.toString() ?? '',
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
      homeParticipant:
      json['home_participant']
      is Map<String, dynamic>
          ? CompetitionBracketParticipantModel
          .fromJson(
        json['home_participant']
        as Map<String, dynamic>,
      )
          : null,
      awayParticipant:
      json['away_participant']
      is Map<String, dynamic>
          ? CompetitionBracketParticipantModel
          .fromJson(
        json['away_participant']
        as Map<String, dynamic>,
      )
          : null,
      homeSourceMatchId:
      json['home_source_match_id'] == null
          ? null
          : int.tryParse(
        json['home_source_match_id']
            .toString(),
      ),
      awaySourceMatchId:
      json['away_source_match_id'] == null
          ? null
          : int.tryParse(
        json['away_source_match_id']
            .toString(),
      ),
    );
  }
}

// ============================================================
// BRACKET PARTICIPANT
// ============================================================

class CompetitionBracketParticipantModel {
  final int registrationId;
  final String type;
  final int participantId;
  final String name;

  const CompetitionBracketParticipantModel({
    required this.registrationId,
    required this.type,
    required this.participantId,
    required this.name,
  });

  factory CompetitionBracketParticipantModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketParticipantModel(
      registrationId: int.parse(
        json['registration_id'].toString(),
      ),
      type:
      json['type']?.toString() ?? '',
      participantId: int.parse(
        json['id'].toString(),
      ),
      name:
      json['name']?.toString() ?? '',
    );
  }
}