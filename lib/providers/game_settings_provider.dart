import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/game_settings.dart';
import '../data/models/participant_entry.dart';
import '../data/models/round_multiplier.dart';
import '../data/models/winning_condition.dart';

/// Loads/persists a single game's [GameSettings] to/from its Hive box.
///
/// Every mutation writes through to disk immediately so the app stays
/// consistent with no explicit "save" step required by the rest of the UI.
class GameSettingsProvider extends ChangeNotifier {
  GameSettingsProvider({required Box<GameSettings> box, required String gameId})
      : _box = box,
        _gameId = gameId,
        _settings = box.get(gameId) ?? GameSettings.defaults(gameId) {
    if (!_box.containsKey(_gameId)) {
      _box.put(_gameId, _settings);
    }
  }

  final Box<GameSettings> _box;
  final String _gameId;
  final GameSettings _settings;

  GameSettings get settings => _settings;

  Future<void> _persist() async {
    await _box.put(_gameId, _settings);
    notifyListeners();
  }

  Future<void> setWinningCondition(WinningCondition value) async {
    _settings.winningCondition = value;
    await _persist();
  }

  Future<void> setAllowNegativeScores(bool value) async {
    _settings.allowNegativeScores = value;
    await _persist();
  }

  Future<void> setEnableTimer(bool value) async {
    _settings.enableTimer = value;
    await _persist();
  }

  Future<void> setTargetScore(int value) async {
    _settings.targetScore = value;
    await _persist();
  }

  Future<void> setRoundMultiplier(RoundMultiplier value) async {
    _settings.roundMultiplier = value;
    await _persist();
  }

  Future<void> addParticipant(String name) async {
    if (name.trim().isEmpty) return;
    _settings.participants = [
      ..._settings.participants,
      ParticipantEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        avatarColorValue: 0xFFD9D3E3,
      ),
    ];
    await _persist();
  }

  Future<void> removeParticipant(String id) async {
    _settings.participants = _settings.participants.where((p) => p.id != id).toList();
    await _persist();
  }
}
