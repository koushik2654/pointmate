import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/game_match.dart';
import '../data/models/match_player.dart';

/// Loads/persists the live score state for a single game (rounds + running
/// totals per player), independent of that game's rule configuration.
class GameMatchProvider extends ChangeNotifier {
  GameMatchProvider({
    required Box<GameMatch> box,
    required String gameId,
    required String gameName,
  }) : _box = box,
       _gameId = gameId,
       _match = box.get(gameId) ?? GameMatch.defaults(gameId, gameName) {
    if (!_box.containsKey(_gameId)) {
      _box.put(_gameId, _match);
    }
  }

  final Box<GameMatch> _box;
  final String _gameId;
  final GameMatch _match;

  GameMatch get match => _match;

  int get currentRound => _match.currentRound;

  bool get isFinished => _match.isFinished;

  /// Marks the game as finished: it drops off the Home screen's active
  /// list and surfaces on the History tab instead.
  Future<void> finishGame() async {
    _match.isFinished = true;
    await _box.put(_gameId, _match);
    notifyListeners();
  }

  /// Adds a new player to the live match. Their score for every round
  /// already played is backfilled to zero so the scoreboard stays aligned.
  Future<void> addPlayer({
    required String id,
    required String name,
    required int avatarColorValue,
  }) async {
    _match.players = [
      ..._match.players,
      MatchPlayer(
        id: id,
        name: name,
        avatarColorValue: avatarColorValue,
        roundScores: List.filled(currentRound, 0),
      ),
    ];
    await _box.put(_gameId, _match);
    notifyListeners();
  }

  Future<void> removePlayer(String id) async {
    _match.players = _match.players.where((p) => p.id != id).toList();
    await _box.put(_gameId, _match);
    notifyListeners();
  }

  List<MatchPlayerView> get leaderboard {
    final sorted = _match.leaderboard;
    return [for (final p in sorted) MatchPlayerView(id: p.id, name: p.name, total: p.total)];
  }

  Future<void> addRound(Map<String, int> roundPoints) async {
    for (final player in _match.players) {
      final delta = roundPoints[player.id] ?? 0;
      final previousTotal = player.roundScores.isEmpty ? 0 : player.roundScores.last;
      player.roundScores = [...player.roundScores, previousTotal + delta];
    }
    await _box.put(_gameId, _match);
    notifyListeners();
  }

  /// Per-round breakdown for every round played so far: each player's point
  /// delta that round and their running total after it.
  List<RoundSummary> get rounds {
    return [
      for (int i = 0; i < currentRound; i++)
        RoundSummary(
          roundNumber: i + 1,
          deltas: {for (final player in _match.players) player.id: _deltaAt(player, i)},
          totals: {for (final player in _match.players) player.id: player.roundScores[i]},
        ),
    ];
  }

  /// Replaces round [roundIndex]'s per-player points, recomputing every
  /// player's cumulative totals for that round and every round after it.
  Future<void> updateRound(int roundIndex, Map<String, int> roundPoints) async {
    for (final player in _match.players) {
      final deltas = _deltasFor(player);
      deltas[roundIndex] = roundPoints[player.id] ?? deltas[roundIndex];
      player.roundScores = _cumulativeFrom(deltas);
    }
    await _box.put(_gameId, _match);
    notifyListeners();
  }

  /// Removes round [roundIndex] entirely, recomputing every player's
  /// cumulative totals for the rounds that come after it.
  Future<void> deleteRound(int roundIndex) async {
    for (final player in _match.players) {
      final deltas = _deltasFor(player)..removeAt(roundIndex);
      player.roundScores = _cumulativeFrom(deltas);
    }
    await _box.put(_gameId, _match);
    notifyListeners();
  }

  int _deltaAt(MatchPlayer player, int roundIndex) {
    final scores = player.roundScores;
    final previousTotal = roundIndex == 0 ? 0 : scores[roundIndex - 1];
    return scores[roundIndex] - previousTotal;
  }

  List<int> _deltasFor(MatchPlayer player) {
    return [for (int i = 0; i < player.roundScores.length; i++) _deltaAt(player, i)];
  }

  List<int> _cumulativeFrom(List<int> deltas) {
    final totals = <int>[];
    var runningTotal = 0;
    for (final delta in deltas) {
      runningTotal += delta;
      totals.add(runningTotal);
    }
    return totals;
  }
}

@immutable
class MatchPlayerView {
  const MatchPlayerView({required this.id, required this.name, required this.total});

  final String id;
  final String name;
  final int total;
}

/// One round's per-player points and running totals, keyed by player id.
@immutable
class RoundSummary {
  const RoundSummary({required this.roundNumber, required this.deltas, required this.totals});

  final int roundNumber;
  final Map<String, int> deltas;
  final Map<String, int> totals;
}
