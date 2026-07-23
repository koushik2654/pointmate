import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/data/models/game_match.dart';
import 'package:pointmate/data/models/game_settings.dart';
import 'package:pointmate/data/models/match_player.dart';
import 'package:pointmate/providers/games_provider.dart';
import 'package:pointmate/screens/leaderboard_screen.dart';
import 'package:provider/provider.dart';

MatchPlayer _player(String id, String name, List<int> roundScores) {
  return MatchPlayer(id: id, name: name, avatarColorValue: 0xFFAAAAAA, roundScores: roundScores);
}

Widget _wrapped(Box<GameMatch> matchBox, Box<GameSettings> settingsBox) {
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (context) => GamesProvider(matchBox: matchBox, settingsBox: settingsBox),
      child: const LeaderboardScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_leaderboard_screen_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('shows an empty state when no games have been played', (tester) async {
    final matchBox = Hive.box<GameMatch>(HiveBoxes.gameMatches);
    final settingsBox = Hive.box<GameSettings>(HiveBoxes.gameSettings);

    // Real (disk-backed) Hive writes hang if awaited directly inside a
    // testWidgets body under flutter_test's fake-clock zone; runAsync opts
    // this block into the real zone so the write actually completes.
    await tester.runAsync(() async {
      await matchBox.clear();
    });

    await tester.pumpWidget(_wrapped(matchBox, settingsBox));

    expect(find.text('No games played yet'), findsOneWidget);
  });

  testWidgets('ranks players by wins with the leader highlighted first', (tester) async {
    final matchBox = Hive.box<GameMatch>(HiveBoxes.gameMatches);
    final settingsBox = Hive.box<GameSettings>(HiveBoxes.gameSettings);

    await tester.runAsync(() async {
      await matchBox.clear();
      await matchBox.put(
        'lbscreen-g1',
        GameMatch(
          gameId: 'lbscreen-g1',
          name: 'Game 1',
          players: [_player('alice', 'Alice', [100]), _player('bob', 'Bob', [50])],
        ),
      );
      await matchBox.put(
        'lbscreen-g2',
        GameMatch(
          gameId: 'lbscreen-g2',
          name: 'Game 2',
          players: [_player('alice', 'Alice', [30]), _player('carol', 'Carol', [80])],
        ),
      );
    });

    await tester.pumpWidget(_wrapped(matchBox, settingsBox));

    // Alice: 2 games played, 1 win. Carol: 1 game played, 1 win. Bob: 0 wins.
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('2 games played'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('1 game played'), findsNWidgets(2)); // Carol and Bob

    final aliceTop = tester.getTopLeft(find.text('Alice'));
    final bobTop = tester.getTopLeft(find.text('Bob'));
    expect(aliceTop.dy, lessThan(bobTop.dy), reason: 'the top winner should be listed first');
  });
}
