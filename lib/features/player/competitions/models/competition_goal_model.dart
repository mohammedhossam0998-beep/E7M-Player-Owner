class CompetitionGoalModel {
  final int id;
  final int matchId;
  final int playerId;
  final String? playerName;
  final String? playerImage;
  final int? minute;
  final bool isOwnGoal;
  final DateTime? createdAt;

  const CompetitionGoalModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    this.playerName,
    this.playerImage,
    this.minute,
    required this.isOwnGoal,
    this.createdAt,
  });

  factory CompetitionGoalModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionGoalModel(
      id: _parseInt(json['id']) ?? 0,
      matchId: _parseInt(json['match_id']) ?? 0,
      playerId: _parseInt(json['player_id']) ?? 0,
      playerName: json['player_name']?.toString(),
      playerImage: json['player_image']?.toString(),
      minute: _parseInt(json['minute']),
      isOwnGoal: _parseBool(json['is_own_goal']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'player_id': playerId,
      'player_name': playerName,
      'player_image': playerImage,
      'minute': minute,
      'is_own_goal': isOwnGoal,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }
}