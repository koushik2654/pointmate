
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/data/models/game_match.dart';
import 'package:pointmate/data/models/game_settings.dart';
import 'package:pointmate/data/models/match_player.dart';
import 'package:pointmate/providers/games_provider.dart';
import 'package:pointmate/screens/history_screen.dart';
import 'package:provider/provider.dart';

MatchPlayer _player(String id, String name, List<int> roundScores) {
  return MatchPlayer(id: id, name: name, avatarColorValue: 0xFFAAAAAA, roundScores: roundScores);
}

Widget _wrapped(Box<GameMatch> matchBox, Box<GameSettings> settingsBox) {
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (context) => GamesProvider(matchBox: matchBox, settingsBox: settingsBox),
      child: const HistoryScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_history_screen_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('shows an empty state when no games have been finished', (tester) async {
    final matchBox = Hive.box<GameMatch>(HiveBoxes.gameMatches);
    final settingsBox = Hive.box<GameSettings>(HiveBoxes.gameSettings);

    // Real (disk-backed) Hive writes hang if awaited directly inside a
    // testWidgets body under flutter_test's fake-clock zone; runAsync opts
    // this block into the real zone so the write actually completes.
    await tester.runAsync(() async {
      await matchBox.clear();
    });

    await tester.pumpWidget(_wrapped(matchBox, settingsBox));

    expect(find.text('No finished games yet'), findsOneWidget);
  });

  testWidgets('shows a finished game with its winner and standings', (tester) async {
    final matchBox = Hive.box<GameMatch>(HiveBoxes.gameMatches);
    final settingsBox = Hive.box<GameSettings>(HiveBoxes.gameSettings);

    await tester.runAsync(() async {
      await matchBox.clear();
      await matchBox.put(
        'hist-g1',
        GameMatch(
          gameId: 'hist-g1',
          name: 'Finished Poker',
          players: [_player('alice', 'Alice', [100]), _player('bob', 'Bob', [50])],
          isFinished: true,
        ),
      );
      // An unfinished game shouldn't show up here at all.
      await matchBox.put(
        'hist-g2',
        GameMatch(
          gameId: 'hist-g2',
          name: 'Still Playing',
          players: [_player('carol', 'Carol', [10])],
        ),
      );
    });

    await tester.pumpWidget(_wrapped(matchBox, settingsBox));

    expect(find.text('Finished Poker'), findsOneWidget);
    expect(find.text('Alice won'), findsOneWidget);
    expect(find.text('100 pts'), findsOneWidget);
    expect(find.text('1 round · 2 players'), findsOneWidget);
    expect(find.text('Still Playing'), findsNothing);
  });
}
