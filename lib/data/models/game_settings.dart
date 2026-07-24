import 'package:hive/hive.dart';

import 'participant_entry.dart';
import 'winning_condition.dart';

part 'game_settings.g.dart';

/// Persisted rule configuration for a single game, keyed by [gameId].
@HiveType(typeId: 0)
class GameSettings extends HiveObject {
  GameSettings({
    required this.gameId,
    required this.winningCondition,
    required this.allowNegativeScores,
    required this.enableTimer,
    required this.targetScore,
    required this.participants,
    this.category,
    this.invertScoreColors = false,
  });

  @HiveField(0)
  String gameId;

  @HiveField(1)
  WinningCondition winningCondition;

  @HiveField(2)
  bool allowNegativeScores;

  @HiveField(3)
  bool enableTimer;

  @HiveField(4)
  int targetScore;

  @HiveField(6)
  List<ParticipantEntry> participants;

  /// The category chip picked when creating this game (e.g. "Rummy"), used
  /// to pick its icon on Home. Null for games created before this field
  /// existed.
  @HiveField(7)
  String? category;

  /// Flips which extreme (highest/lowest total) is highlighted green vs red
  /// on the scoreboard's Total row. Default follows [winningCondition]: the
  /// winning extreme is green. Some players prefer it the other way round.
  @HiveField(8)
  bool invertScoreColors;

  factory GameSettings.defaults(String gameId) {
    return GameSettings(
      gameId: gameId,
      winningCondition: WinningCondition.highestScoreWins,
      allowNegativeScores: true,
      enableTimer: false,
      targetScore: 500,
      participants: [],
    );
  }
}
