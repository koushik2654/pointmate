import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/game_match.dart';
import '../data/models/game_settings.dart';
import '../data/models/winning_condition.dart';
import '../models/game_session.dart';

/// Holds the games/activity state shown on the Home screen.
///
/// [activeGames] and [finishedGames] are both derived live from [_matchBox]
/// (Hive-persisted) rather than an in-memory list, so a game a player
/// created stays reachable from Home after backing out of its dashboard, or
/// even after the app restarts — not just for the lifetime of this
/// provider instance.
class GamesProvider extends ChangeNotifier {
  GamesProvider({required Box<GameMatch> matchBox, required Box<GameSettings> settingsBox})
    : _matchBox = matchBox,
      _settingsBox = settingsBox,
      _matchListenable = matchBox.listenable() {
    _matchListenable.addListener(_onMatchesChanged);
  }

  final Box<GameMatch> _matchBox;
  final Box<GameSettings> _settingsBox;
  final ValueListenable<Box<GameMatch>> _matchListenable;

  /// Number of games that have had at least one round recorded.
  int get totalGamesPlayed => _matchBox.values.where((match) => match.currentRound > 0).length;

  /// Players ranked by how many games they're currently leading or have
  /// won, aggregated by name across every played game. Each game's winner
  /// (or co-winners, on a tie) is whoever leads under its own
  /// [WinningCondition], live as rounds are recorded.
  List<LeaderboardEntry> get leaderboard {
    final wins = <String, int>{};
    final gamesPlayed = <String, int>{};
    final avatarColors = <String, Color>{};

    for (final match in _matchBox.values) {
      if (match.currentRound == 0 || match.players.isEmpty) continue;

      for (final player in match.players) {
        gamesPlayed[player.name] = (gamesPlayed[player.name] ?? 0) + 1;
        avatarColors.putIfAbsent(player.name, () => Color(player.avatarColorValue));
      }

      final winningCondition =
          _settingsBox.get(match.gameId)?.winningCondition ??
          WinningCondition.highestScoreWins;
      final totals = [for (final player in match.players) player.total];
      final winningTotal = winningCondition == WinningCondition.lowestScoreWins
          ? totals.reduce((a, b) => a < b ? a : b)
          : totals.reduce((a, b) => a > b ? a : b);

      for (final player in match.players) {
        if (player.total == winningTotal) {
          wins[player.name] = (wins[player.name] ?? 0) + 1;
        }
      }
    }

    final entries = [
      for (final name in gamesPlayed.keys)
        LeaderboardEntry(
          name: name,
          wins: wins[name] ?? 0,
          gamesPlayed: gamesPlayed[name]!,
          avatarColor: avatarColors[name]!,
        ),
    ];

    entries.sort((a, b) {
      final byWins = b.wins.compareTo(a.wins);
      return byWins != 0 ? byWins : b.gamesPlayed.compareTo(a.gamesPlayed);
    });

    return entries;
  }

  /// Every unfinished game, sourced directly from persistence so it's
  /// reachable from Home no matter how the player got here.
  List<GameSession> get activeGames => [
    for (final match in _matchBox.values)
      if (!match.isFinished) _toSession(match),
  ];

  /// Every game marked finished via [GameMatchProvider.finishGame].
  List<GameMatch> get finishedGames =>
      _matchBox.values.where((match) => match.isFinished).toList();

  /// Deletes a game's persisted settings/match records, if any.
  Future<void> deleteGame(String id) async {
    await _matchBox.delete(id);
    await _settingsBox.delete(id);
    notifyListeners();
  }

  void _onMatchesChanged() => notifyListeners();

  /// A live "in progress" status isn't tracked per game yet, so every
  /// restored game shows the same status chip.
  GameSession _toSession(GameMatch match) {
    return GameSession(
      id: match.gameId,
      name: match.name,
      icon: _iconForCategory(_settingsBox.get(match.gameId)?.category),
      status: GameStatus.inProgress,
      players: [
        for (final player in match.players)
          PlayerScore(
            id: player.id,
            name: player.name,
            score: player.total,
            avatarColor: Color(player.avatarColorValue),
          ),
      ],
    );
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case 'Board Game':
        return Icons.hexagon_outlined;
      case 'Rummy':
      case 'Spades':
        return Icons.style_rounded;
      case 'Lowest Count':
        return Icons.trending_down_rounded;
      case 'Shuttle':
        return Icons.sports_tennis_rounded;
      default:
        return Icons.style_rounded;
    }
  }

  @override
  void dispose() {
    _matchListenable.removeListener(_onMatchesChanged);
    super.dispose();
  }
}

/// One player's standing on the app-level leaderboard, aggregated by name
/// across every game they've played.
@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.wins,
    required this.gamesPlayed,
    required this.avatarColor,
  });

  final String name;
  final int wins;
  final int gamesPlayed;
  final Color avatarColor;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
