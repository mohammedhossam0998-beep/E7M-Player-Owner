class CompetitionBracketModel {
  final CompetitionBracketCompetition competition;
  final CompetitionBracketParticipation participation;
  final bool generated;
  final List<CompetitionBracketRound> rounds;
  final int matchesCount;

  const CompetitionBracketModel({
    required this.competition,
    required this.participation,
    required this.generated,
    required this.rounds,
    required this.matchesCount,
  });

  factory CompetitionBracketModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketModel(
      competition: CompetitionBracketCompetition.fromJson(
        Map<String, dynamic>.from(
          json['competition'] as Map,
        ),
      ),
      participation: CompetitionBracketParticipation.fromJson(
        Map<String, dynamic>.from(
          json['participation'] as Map,
        ),
      ),
      generated: json['generated'] == true,
      rounds: (json['rounds'] as List? ?? [])
          .whereType<Map>()
          .map(
            (item) => CompetitionBracketRound.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      matchesCount: _parseInt(json['matches_count']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competition': competition.toJson(),
      'participation': participation.toJson(),
      'generated': generated,
      'rounds': rounds.map((item) => item.toJson()).toList(),
      'matches_count': matchesCount,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class CompetitionBracketCompetition {
  final int id;
  final String name;
  final String? competitionType;
  final String? format;
  final String? seedingMethod;
  final bool seedingConfirmed;
  final bool tournamentLocked;
  final String? status;

  const CompetitionBracketCompetition({
    required this.id,
    required this.name,
    this.competitionType,
    this.format,
    this.seedingMethod,
    required this.seedingConfirmed,
    required this.tournamentLocked,
    this.status,
  });

  factory CompetitionBracketCompetition.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketCompetition(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      competitionType: json['competition_type']?.toString(),
      format: json['format']?.toString(),
      seedingMethod: json['seeding_method']?.toString(),
      seedingConfirmed: _parseBool(
        json['seeding_confirmed'],
      ),
      tournamentLocked: _parseBool(
        json['tournament_locked'],
      ),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'competition_type': competitionType,
      'format': format,
      'seeding_method': seedingMethod,
      'seeding_confirmed': seedingConfirmed,
      'tournament_locked': tournamentLocked,
      'status': status,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }
}

class CompetitionBracketParticipation {
  final int registrationId;
  final String? status;

  const CompetitionBracketParticipation({
    required this.registrationId,
    this.status,
  });

  factory CompetitionBracketParticipation.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketParticipation(
      registrationId:
      _parseInt(json['registration_id']) ?? 0,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'status': status,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class CompetitionBracketRound {
  final String round;
  final List<CompetitionBracketMatch> matches;

  const CompetitionBracketRound({
    required this.round,
    required this.matches,
  });

  factory CompetitionBracketRound.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketRound(
      round: json['round']?.toString() ?? 'unknown',
      matches: (json['matches'] as List? ?? [])
          .whereType<Map>()
          .map(
            (item) => CompetitionBracketMatch.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'matches': matches.map((item) => item.toJson()).toList(),
    };
  }
}

class CompetitionBracketMatch {
  final int id;
  final int? matchNumber;
  final DateTime? date;
  final String? startTime;
  final String? status;
  final int? homeScore;
  final int? awayScore;
  final CompetitionBracketParticipant? homeParticipant;
  final CompetitionBracketParticipant? awayParticipant;
  final int? homeSourceMatchId;
  final int? awaySourceMatchId;

  const CompetitionBracketMatch({
    required this.id,
    this.matchNumber,
    this.date,
    this.startTime,
    this.status,
    this.homeScore,
    this.awayScore,
    this.homeParticipant,
    this.awayParticipant,
    this.homeSourceMatchId,
    this.awaySourceMatchId,
  });

  factory CompetitionBracketMatch.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketMatch(
      id: _parseInt(json['id']) ?? 0,
      matchNumber: _parseInt(json['match_number']),
      date: _parseDateTime(json['date']),
      startTime: json['start_time']?.toString(),
      status: json['status']?.toString(),
      homeScore: _parseInt(json['home_score']),
      awayScore: _parseInt(json['away_score']),
      homeParticipant:
      _parseParticipant(json['home_participant']),
      awayParticipant:
      _parseParticipant(json['away_participant']),
      homeSourceMatchId:
      _parseInt(json['home_source_match_id']),
      awaySourceMatchId:
      _parseInt(json['away_source_match_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_number': matchNumber,
      'date': date?.toIso8601String(),
      'start_time': startTime,
      'status': status,
      'home_score': homeScore,
      'away_score': awayScore,
      'home_participant': homeParticipant?.toJson(),
      'away_participant': awayParticipant?.toJson(),
      'home_source_match_id': homeSourceMatchId,
      'away_source_match_id': awaySourceMatchId,
    };
  }

  static CompetitionBracketParticipant? _parseParticipant(
      dynamic value,
      ) {
    if (value is! Map) return null;

    return CompetitionBracketParticipant.fromJson(
      Map<String, dynamic>.from(value),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }
}

class CompetitionBracketParticipant {
  final int registrationId;
  final String type;
  final int? id;
  final String? name;

  const CompetitionBracketParticipant({
    required this.registrationId,
    required this.type,
    this.id,
    this.name,
  });

  factory CompetitionBracketParticipant.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionBracketParticipant(
      registrationId:
      _parseInt(json['registration_id']) ?? 0,
      type: json['type']?.toString() ?? 'player',
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registration_id': registrationId,
      'type': type,
      'id': id,
      'name': name,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}