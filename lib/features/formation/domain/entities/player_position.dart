enum PlayerPositionType {
  goalkeeper,

  leftBack,
  leftCenterBack,
  centerBack,
  rightCenterBack,
  rightBack,

  defensiveMidfielder,
  leftMidfielder,
  centralMidfielder,
  rightMidfielder,
  attackingMidfielder,

  leftWinger,
  rightWinger,

  leftForward,
  centerForward,
  rightForward,

  striker,
}
class PlayerPosition {
  final String id;

  final PlayerPositionType type;

  final String name;

  final String shortName;

  final double x;

  final double y;

  final bool editable;

  final bool required;

  const PlayerPosition({
    required this.id,
    required this.type,
    required this.name,
    required this.shortName,
    required this.x,
    required this.y,
    this.editable = true,
    this.required = true,
  });

  PlayerPosition copyWith({
    String? id,
    PlayerPositionType? type,
    String? name,
    String? shortName,
    double? x,
    double? y,
    bool? editable,
    bool? required,
  }) {
    return PlayerPosition(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      x: x ?? this.x,
      y: y ?? this.y,
      editable: editable ?? this.editable,
      required: required ?? this.required,
    );
  }
}