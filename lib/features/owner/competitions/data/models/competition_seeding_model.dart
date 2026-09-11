class CompetitionSeedingModel {
  final int id;
  final int competitionId;
  final int registrationId;
  final int seed;
  final int? playerId;
  final int? teamId;
  final String status;

  const CompetitionSeedingModel({
    required this.id,
    required this.competitionId,
    required this.registrationId,
    required this.seed,
    this.playerId,
    this.teamId,
    required this.status,
  });

  factory CompetitionSeedingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionSeedingModel(
      id: int.parse(json['id'].toString()),
      competitionId: int.parse(
        json['competition_id'].toString(),
      ),
      registrationId: int.parse(
        json['registration_id'].toString(),
      ),
      seed: int.parse(
        json['seed'].toString(),
      ),
      playerId: json['player_id'] == null
          ? null
          : int.parse(
        json['player_id'].toString(),
      ),
      teamId: json['team_id'] == null
          ? null
          : int.parse(
        json['team_id'].toString(),
      ),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competition_id': competitionId,
      'registration_id': registrationId,
      'seed': seed,
      'player_id': playerId,
      'team_id': teamId,
      'status': status,
    };
  }

  CompetitionSeedingModel copyWith({
    int? id,
    int? competitionId,
    int? registrationId,
    int? seed,
    int? playerId,
    int? teamId,
    String? status,
  }) {
    return CompetitionSeedingModel(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      registrationId: registrationId ?? this.registrationId,
      seed: seed ?? this.seed,
      playerId: playerId ?? this.playerId,
      teamId: teamId ?? this.teamId,
      status: status ?? this.status,
    );
  }
}