import 'package:hive/hive.dart';

import 'match_player.dart';

part 'game_match.g.dart';

/// The live, in-progress state of a single game: its players and their
/// running totals round by round. Persisted independently from [GameSettings]
/// so playing a game doesn't require its rules to be finalized first.
@HiveType(typeId: 5)
class GameMatch extends HiveObject {
  GameMatch({required this.gameId, required this.name, required this.players});

  @HiveField(0)
  String gameId;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<MatchPlayer> players;

  int get currentRound => players.isEmpty ? 0 : players.first.roundScores.length;

  List<MatchPlayer> get leaderboard =>
      [...players]..sort((a, b) => b.total.compareTo(a.total));

  factory GameMatch.defaults(String gameId, String name) {
    return GameMatch(
      gameId: gameId,
      name: name,
      players: [
        MatchPlayer(
          id: 'alex',
          name: 'Alex',
          avatarColorValue: 0xFFBEE3F8,
          roundScores: const [500, 1400, 2100, 3200, 4250],
        ),
        MatchPlayer(
          id: 'sarah',
          name: 'Sarah',
          avatarColorValue: 0xFFFBD5D5,
          roundScores: const [300, 900, 1500, 2200, 3100],
        ),
        MatchPlayer(
          id: 'mike',
          name: 'Mike',
          avatarColorValue: 0xFFC6F0D3,
          roundScores: const [200, 800, 1400, 2000, 2850],
        ),
      ],
    );
  }
}
