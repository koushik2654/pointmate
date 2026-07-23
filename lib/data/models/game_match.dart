import 'package:hive/hive.dart';

import 'match_player.dart';

part 'game_match.g.dart';

/// The live, in-progress state of a single game: its players and their
/// running totals round by round. Persisted independently from [GameSettings]
/// so playing a game doesn't require its rules to be finalized first.
@HiveType(typeId: 5)
class GameMatch extends HiveObject {
  GameMatch({
    required this.gameId,
    required this.name,
    required this.players,
    this.isFinished = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @HiveField(0)
  String gameId;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<MatchPlayer> players;

  /// Whether the player has explicitly finished this game. Finished games
  /// drop off the Home screen's active list and surface on the History tab
  /// instead.
  @HiveField(3)
  bool isFinished;

  /// When this game was created. Defaults to the construction time if not
  /// supplied, so every newly created game is stamped automatically.
  @HiveField(4)
  DateTime createdAt;

  int get currentRound => players.isEmpty ? 0 : players.first.roundScores.length;

  List<MatchPlayer> get leaderboard =>
      [...players]..sort((a, b) => b.total.compareTo(a.total));

  factory GameMatch.defaults(String gameId, String name) {
    return GameMatch(gameId: gameId, name: name, players: []);
  }
}
