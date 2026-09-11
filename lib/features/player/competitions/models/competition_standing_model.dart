class CompetitionStandingModel {
  final int rank;
  final int? playerId;
  final int? teamId;
  final String? playerName;
  final String? playerImage;
  final String? teamName;
  final String? teamLogo;

  final int played;
  final int wins;
  final int draws;
  final int losses;

  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  final int points;

  const CompetitionStandingModel({
    required this.rank,
    this.playerId,
    this.teamId,
    this.playerName,
    this.playerImage,
    this.teamName,
    this.teamLogo,
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
    return CompetitionStandingModel(
      rank: _toInt(json['rank']) ?? 0,

      playerId: _toInt(json['player_id']),
      teamId: _toInt(json['team_id']),

      playerName: json['player_name']?.toString(),
      playerImage: json['player_image']?.toString(),

      teamName: json['team_name']?.toString(),
      teamLogo: json['team_logo']?.toString(),

      played: _toInt(json['played']) ?? 0,
      wins: _toInt(json['wins']) ?? 0,
      draws: _toInt(json['draws']) ?? 0,
      losses: _toInt(json['losses']) ?? 0,

      goalsFor: _toInt(json['goals_for']) ?? 0,
      goalsAgainst: _toInt(json['goals_against']) ?? 0,
      goalDifference:
      _toInt(json['goal_difference']) ?? 0,

      points: _toInt(json['points']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'player_id': playerId,
      'team_id': teamId,
      'player_name': playerName,
      'player_image': playerImage,
      'team_name': teamName,
      'team_logo': teamLogo,
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

  static int? _toInt(dynamic value) {
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
}