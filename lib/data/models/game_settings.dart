import 'package:hive/hive.dart';

import 'participant_entry.dart';
import 'round_multiplier.dart';
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
    required this.roundMultiplier,
    required this.participants,
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

  @HiveField(5)
  RoundMultiplier roundMultiplier;

  @HiveField(6)
  List<ParticipantEntry> participants;

  factory GameSettings.defaults(String gameId) {
    return GameSettings(
      gameId: gameId,
      winningCondition: WinningCondition.highestScoreWins,
      allowNegativeScores: true,
      enableTimer: false,
      targetScore: 500,
      roundMultiplier: RoundMultiplier.x1,
      participants: [
        ParticipantEntry(id: 'alex', name: 'Alex', avatarColorValue: 0xFFBEE3F8),
        ParticipantEntry(id: 'jordan', name: 'Jordan', avatarColorValue: 0xFFFBD5D5),
        ParticipantEntry(id: 'sam', name: 'Sam', avatarColorValue: 0xFFC6F0D3),
      ],
    );
  }
}
