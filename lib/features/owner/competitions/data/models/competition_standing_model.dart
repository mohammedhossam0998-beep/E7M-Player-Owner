class CompetitionStandingModel {
  final int position;
  final int registrationId;
  final String participantType;
  final int participantId;
  final String participantName;
  final String? participantImage;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;

  const CompetitionStandingModel({
    required this.position,
    required this.registrationId,
    required this.participantType,
    required this.participantId,
    required this.participantName,
    this.participantImage,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });

  factory CompetitionStandingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final participant =
    json['participant'] is Map<String, dynamic>
        ? json['participant'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CompetitionStandingModel(
      position: int.parse(
        json['position'].toString(),
      ),
      registrationId: int.parse(
        json['registration_id'].toString(),
      ),
      participantType:
      participant['type']?.toString() ?? '',
      participantId: int.parse(
        participant['id'].toString(),
      ),
      participantName:
      participant['name']?.toString() ?? '',
      participantImage:
      participant['image']?.toString(),
      played: int.parse(
        json['played'].toString(),
      ),
      wins: int.parse(
        json['wins'].toString(),
      ),
      draws: int.parse(
        json['draws'].toString(),
      ),
      losses: int.parse(
        json['losses'].toString(),
      ),
      goalsFor: int.parse(
        json['goals_for'].toString(),
      ),
      goalsAgainst: int.parse(
        json['goals_against'].toString(),
      ),
      goalDifference: int.parse(
        json['goal_difference'].toString(),
      ),
      points: int.parse(
        json['points'].toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'registration_id': registrationId,
      'participant': {
        'type': participantType,
        'id': participantId,
        'name': participantName,
        'image': participantImage,
      },
      'played': played,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goals_for': goalsFor,
      'goals_against': goalsAgainst,
      'goal_difference': goalDifference,
      'points': points,
    };
  }

  CompetitionStandingModel copyWith({
    int? position,
    int? registrationId,
    String? participantType,
    int? participantId,
    String? participantName,
    String? participantImage,
    int? played,
    int? wins,
    int? draws,
    int? losses,
    int? goalsFor,
    int? goalsAgainst,
    int? goalDifference,
    int? points,
  }) {
    return CompetitionStandingModel(
      position: position ?? this.position,
      registrationId:
      registrationId ?? this.registrationId,
      participantType:
      participantType ?? this.participantType,
      participantId:
      participantId ?? this.participantId,
      participantName:
      participantName ?? this.participantName,
      participantImage:
      participantImage ?? this.participantImage,
      played: played ?? this.played,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst:
      goalsAgainst ?? this.goalsAgainst,
      goalDifference:
      goalDifference ?? this.goalDifference,
      points: points ?? this.points,
    );
  }
}