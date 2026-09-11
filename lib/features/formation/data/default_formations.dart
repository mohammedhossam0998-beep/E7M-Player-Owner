import '../domain/entities/formation_position.dart';
import '../domain/entities/match_type.dart';

class DefaultFormations {
  static List<FormationPosition> getFormation(MatchType type) {
    switch (type) {
      case MatchType.five:
        return _fivePlayers();

      case MatchType.six:
        return _sixPlayers();

      case MatchType.seven:
        return _sevenPlayers();
    }
  }

  static List<FormationPosition> _fivePlayers() {
    return [
      const FormationPosition(id: "GK", title: "GK", x: .50, y: .90),

      const FormationPosition(id: "DEF", title: "DEF", x: .50, y: .68),

      const FormationPosition(id: "LM", title: "LM", x: .28, y: .42),
      const FormationPosition(id: "RM", title: "RM", x: .72, y: .42),

      const FormationPosition(id: "ST", title: "ST", x: .50, y: .15),
    ];
  }

  static List<FormationPosition> _sixPlayers() {
    return [
      const FormationPosition(id: "GK", title: "GK", x: .50, y: .90),

      const FormationPosition(id: "LB", title: "LB", x: .30, y: .68),
      const FormationPosition(id: "RB", title: "RB", x: .70, y: .68),

      const FormationPosition(id: "CM", title: "CM", x: .50, y: .48),

      const FormationPosition(id: "LW", title: "LW", x: .30, y: .18),
      const FormationPosition(id: "RW", title: "RW", x: .70, y: .18),
    ];
  }

  static List<FormationPosition> _sevenPlayers() {
    return [
      const FormationPosition(id: "GK", title: "GK", x: .50, y: .90),

      const FormationPosition(id: "LB", title: "LB", x: .28, y: .70),
      const FormationPosition(id: "RB", title: "RB", x: .72, y: .70),

      const FormationPosition(id: "CM1", title: "CM", x: .38, y: .45),
      const FormationPosition(id: "CM2", title: "CM", x: .62, y: .45),

      const FormationPosition(id: "LW", title: "LW", x: .30, y: .15),
      const FormationPosition(id: "RW", title: "RW", x: .70, y: .15),
    ];
  }
}