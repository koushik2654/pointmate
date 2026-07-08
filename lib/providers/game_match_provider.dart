import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/game_match.dart';

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
}

@immutable
class MatchPlayerView {
  const MatchPlayerView({required this.id, required this.name, required this.total});

  final String id;
  final String name;
  final int total;
}
