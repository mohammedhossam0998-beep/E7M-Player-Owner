enum MatchType {
  five,
  six,
  seven,
}

extension MatchTypeExtension on MatchType {
  String get title {
    switch (this) {
      case MatchType.five:
        return "5 vs 5";
      case MatchType.six:
        return "6 vs 6";
      case MatchType.seven:
        return "7 vs 7";
    }
  }

  String get localizationKey {
    switch (this) {
      case MatchType.five:
        return "match_type_five";
      case MatchType.six:
        return "match_type_six";
      case MatchType.seven:
        return "match_type_seven";
    }
  }

  int get playersCount {
    switch (this) {
      case MatchType.five:
        return 5;
      case MatchType.six:
        return 6;
      case MatchType.seven:
        return 7;
    }
  }

  int get minimumPlayers => playersCount;

  int get maximumPlayers {
    switch (this) {
      case MatchType.five:
        return 8;
      case MatchType.six:
        return 10;
      case MatchType.seven:
        return 12;
    }
  }

  int get substitutes => maximumPlayers - minimumPlayers;

  List<String> get formations {
    switch (this) {
      case MatchType.five:
        return ["2-2", "1-2-1", "2-1-1"];

      case MatchType.six:
        return ["2-2-1", "3-1-1", "2-1-2"];

      case MatchType.seven:
        return ["3-2-1", "2-3-1", "2-2-2"];
    }
  }
}
