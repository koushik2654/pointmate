import 'package:hive/hive.dart';

part 'winning_condition.g.dart';

@HiveType(typeId: 1)
enum WinningCondition {
  @HiveField(0)
  highestScoreWins,
  @HiveField(1)
  lowestScoreWins;

  String get label {
    switch (this) {
      case WinningCondition.highestScoreWins:
        return 'Highest Score Wins';
      case WinningCondition.lowestScoreWins:
        return 'Lowest Score Wins';
    }
  }
}
