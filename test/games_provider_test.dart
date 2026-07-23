import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/data/models/game_match.dart';
import 'package:pointmate/data/models/game_settings.dart';
import 'package:pointmate/data/models/match_player.dart';
import 'package:pointmate/data/models/round_multiplier.dart';
import 'package:pointmate/data/models/winning_condition.dart';
import 'package:pointmate/providers/games_provider.dart';

MatchPlayer _player(String id, String name, List<int> roundScores) {
  return MatchPlayer(id: id, name: name, avatarColorValue: 0xFFAAAAAA, roundScores: roundScores);
}

GameSettings _lowestScoreWinsSettings(String gameId) {
  return GameSettings(
    gameId: gameId,
    winningCondition: WinningCondition.lowestScoreWins,
    allowNegativeScores: true,
    enableTimer: false,
    targetScore: 500,
    roundMultiplier: RoundMultiplier.x1,
    participants: const [],
  );
}

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_games_provider_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  test('leaderboard aggregates wins by name, respecting each game\'s winning '
      'condition and excluding games with no rounds recorded', () async {
    final matchBox = Hive.box<GameMatch>(HiveBoxes.gameMatches);
    final settingsBox = Hive.box<GameSettings>(HiveBoxes.gameSettings);

    // g1: highest score wins (default, no settings recorded) -> Alice beats Bob.
    await matchBox.put(
      'lb-g1',
      GameMatch(
        gameId: 'lb-g1',
        name: 'Game 1',
        players: [_player('alice', 'Alice', [100]), _player('bob', 'Bob', [50])],
      ),
    );

    // g2: highest score wins -> Carol beats Alice.
    await matchBox.put(
      'lb-g2',
      GameMatch(
        gameId: 'lb-g2',
        name: 'Game 2',
        players: [_player('alice', 'Alice', [30]), _player('carol', 'Carol', [80])],
      ),
    );

    // g3: explicit lowest score wins -> Dave (lower total) beats Eve.
    await settingsBox.put('lb-g3', _lowestScoreWinsSettings('lb-g3'));
    await matchBox.put(
      'lb-g3',
      GameMatch(
        gameId: 'lb-g3',
        name: 'Game 3',
        players: [_player('dave', 'Dave', [10]), _player('eve', 'Eve', [40])],
      ),
    );

    // g4: tie for first -> both Frank and Grace win.
    await matchBox.put(
      'lb-g4',
      GameMatch(
        gameId: 'lb-g4',
        name: 'Game 4',
        players: [_player('frank', 'Frank', [20]), _player('grace', 'Grace', [20])],
      ),
    );

    // g5: no rounds recorded yet -> excluded entirely, Henry shouldn't appear.
    await matchBox.put(
      'lb-g5',
      GameMatch(gameId: 'lb-g5', name: 'Game 5', players: [_player('henry', 'Henry', [])]),
    );

    final provider = GamesProvider(matchBox: matchBox, settingsBox: settingsBox);
    final leaderboard = provider.leaderboard;

    LeaderboardEntry byName(String name) => leaderboard.firstWhere((e) => e.name == name);

    expect(leaderboard.map((e) => e.name), isNot(contains('Henry')));

    expect(byName('Alice').wins, 1);
    expect(byName('Alice').gamesPlayed, 2);
    expect(byName('Bob').wins, 0);
    expect(byName('Carol').wins, 1);
    expect(byName('Dave').wins, 1, reason: 'lowest total should win under lowestScoreWins');
    expect(byName('Eve').wins, 0);
    expect(byName('Frank').wins, 1, reason: 'a tie credits both players with the win');
    expect(byName('Grace').wins, 1);

    // Alice has the same win count as the other 1-win players but more
    // games played, so she should rank strictly first.
    expect(leaderboard.first.name, 'Alice');
    // 0-win players rank behind every 1-win player.
    final firstZeroWinIndex = leaderboard.indexOf(byName('Bob'));
    final lastOneWinIndex = leaderboard.indexOf(byName('Grace'));
    expect(firstZeroWinIndex, greaterThan(lastOneWinIndex));
  });

  test('activeGames and finishedGames are both sourced directly from '
      'persistence, not an in-memory list', () async {
    final matchBox = Hive.box<GameMatch>(HiveBoxes.gameMatches);
    final settingsBox = Hive.box<GameSettings>(HiveBoxes.gameSettings);

    final provider = GamesProvider(matchBox: matchBox, settingsBox: settingsBox);

    // An unfinished match should show up in activeGames as soon as it's
    // persisted -- no separate "register this game" call needed, which is
    // what makes a game reachable from Home even after an app restart.
    await matchBox.put(
      'active-g1',
      GameMatch(
        gameId: 'active-g1',
        name: 'Active Game',
        players: [_player('you', 'You', [50])],
      ),
    );
    expect(provider.activeGames.any((session) => session.id == 'active-g1'), isTrue);
    expect(
      provider.activeGames.firstWhere((session) => session.id == 'active-g1').players.first.score,
      50,
    );

    // Marking a match finished should drop it out of activeGames and into
    // finishedGames without needing a new GamesProvider instance.
    await matchBox.put(
      'active-finished-test',
      GameMatch(
        gameId: 'active-finished-test',
        name: 'Finished Session',
        players: [_player('you', 'You', [200])],
        isFinished: true,
      ),
    );

    expect(provider.activeGames.any((session) => session.id == 'active-finished-test'), isFalse);
    expect(
      provider.finishedGames.map((match) => match.gameId),
      contains('active-finished-test'),
    );
    expect(
      provider.finishedGames.map((match) => match.gameId),
      isNot(contains('active-g1')),
    );
  });
}
