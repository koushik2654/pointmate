import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/game_match.dart';
import '../data/models/game_settings.dart';
import '../models/game_session.dart';

/// Holds the games/activity state shown on the Home screen.
///
/// Seeded with sample data for now; a later change will replace [_activeGames]
/// and [_totalGamesPlayed] with values loaded from persistence. Player scores
/// are always resolved live against [_matchBox] so rounds recorded on a
/// game's dashboard show up here immediately.
class GamesProvider extends ChangeNotifier {
  GamesProvider({required Box<GameMatch> matchBox, required Box<GameSettings> settingsBox})
    : _matchBox = matchBox,
      _settingsBox = settingsBox,
      _matchListenable = matchBox.listenable(),
      _activeGames = List<GameSession>.from(_sampleGames),
      _totalGamesPlayed = 24 {
    _matchListenable.addListener(_onMatchesChanged);
  }

  final Box<GameMatch> _matchBox;
  final Box<GameSettings> _settingsBox;
  final ValueListenable<Box<GameMatch>> _matchListenable;
  final int _totalGamesPlayed;
  final List<GameSession> _activeGames;

  int get totalGamesPlayed => _totalGamesPlayed;

  List<GameSession> get activeGames =>
      List.unmodifiable(_activeGames.map(_withLiveScores));

  /// Adds a newly created game to the top of the active games list.
  void createGame({
    required String id,
    required String name,
    required IconData icon,
    required List<PlayerScore> players,
  }) {
    _activeGames.insert(
      0,
      GameSession(id: id, name: name, icon: icon, status: GameStatus.inProgress, players: players),
    );
    notifyListeners();
  }

  /// Removes [id] from the active games list and deletes its persisted
  /// settings/match records, if any.
  Future<void> deleteGame(String id) async {
    _activeGames.removeWhere((session) => session.id == id);
    await _matchBox.delete(id);
    await _settingsBox.delete(id);
    notifyListeners();
  }

  void _onMatchesChanged() => notifyListeners();

  /// Returns [session] with each player's score replaced by their current
  /// total from the persisted [GameMatch], falling back to the stored value
  /// if the game has no match recorded yet (e.g. the hardcoded samples).
  GameSession _withLiveScores(GameSession session) {
    final match = _matchBox.get(session.id);
    if (match == null) return session;

    final totalsById = {for (final player in match.players) player.id: player.total};
    return GameSession(
      id: session.id,
      name: session.name,
      icon: session.icon,
      status: session.status,
      players: [
        for (final player in session.players)
          PlayerScore(
            id: player.id,
            name: player.name,
            score: totalsById[player.id] ?? player.score,
            isCurrentUser: player.isCurrentUser,
            avatarColor: player.avatarColor,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _matchListenable.removeListener(_onMatchesChanged);
    super.dispose();
  }

  static const List<GameSession> _sampleGames = [
    GameSession(
      id: 'poker-night',
      name: 'Poker Night',
      icon: Icons.style_rounded,
      status: GameStatus.inProgress,
      players: [
        PlayerScore(
          id: 'you',
          name: 'You',
          score: 200,
          isCurrentUser: true,
          avatarColor: Color(0xFF6D4AA6),
        ),
        PlayerScore(id: 'alice', name: 'Alice', score: 120),
        PlayerScore(id: 'bob', name: 'Bob', score: -50),
      ],
    ),
    GameSession(
      id: 'family-rummy',
      name: 'Family Rummy',
      icon: Icons.style_rounded,
      status: GameStatus.paused,
      players: [
        PlayerScore(
          id: 'you',
          name: 'You',
          score: 80,
          isCurrentUser: true,
          avatarColor: Color(0xFF6D4AA6),
        ),
        PlayerScore(id: 'mom', name: 'Mom', score: 45),
        PlayerScore(id: 'dad', name: 'Dad', score: 30),
      ],
    ),
    GameSession(
      id: 'catan-session',
      name: 'Catan Session',
      icon: Icons.hexagon_outlined,
      status: GameStatus.yourTurn,
      players: [
        PlayerScore(id: 'sarah', name: 'Sarah', score: 9),
        PlayerScore(id: 'john', name: 'John', score: 8),
        PlayerScore(id: 'you', name: 'You', score: 6, isCurrentUser: true),
      ],
    ),
  ];
}
