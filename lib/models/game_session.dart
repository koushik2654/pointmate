import 'package:flutter/material.dart';

/// Lifecycle state of a game session, drives the small status chip on a card.
enum GameStatus { inProgress, paused, yourTurn }

extension GameStatusDisplay on GameStatus {
  String get label {
    switch (this) {
      case GameStatus.inProgress:
        return 'In Progress';
      case GameStatus.paused:
        return 'Paused';
      case GameStatus.yourTurn:
        return 'Your Turn';
    }
  }

  IconData get icon {
    switch (this) {
      case GameStatus.inProgress:
        return Icons.access_time_rounded;
      case GameStatus.paused:
        return Icons.pause_rounded;
      case GameStatus.yourTurn:
        return Icons.campaign_rounded;
    }
  }
}

/// A single player's standing within a [GameSession].
@immutable
class PlayerScore {
  const PlayerScore({
    required this.id,
    required this.name,
    required this.score,
    this.isCurrentUser = false,
    this.avatarColor = const Color(0xFFD9D3E3),
  });

  /// Matches [MatchPlayer.id] so live totals can be looked up in the
  /// persisted [GameMatch] for this game, if one exists.
  final String id;
  final String name;
  final int score;
  final bool isCurrentUser;
  final Color avatarColor;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

/// An in-progress, paused, or awaiting-turn game and its current standings.
@immutable
class GameSession {
  const GameSession({
    required this.id,
    required this.name,
    required this.icon,
    required this.status,
    required this.players,
  });

  final String id;
  final String name;
  final IconData icon;
  final GameStatus status;
  final List<PlayerScore> players;
}
