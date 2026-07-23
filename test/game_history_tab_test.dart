import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/data/models/game_match.dart';
import 'package:pointmate/providers/game_match_provider.dart';
import 'package:pointmate/screens/game/game_history_tab_screen.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_history_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('renders rounds newest-first with per-round deltas and totals', (tester) async {
    final provider = GameMatchProvider(
      box: Hive.box<GameMatch>(HiveBoxes.gameMatches),
      gameId: 'history-render-test',
      gameName: 'Render Test',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(value: provider, child: const GameHistoryTabScreen()),
      ),
    );

    // Alex's seeded rounds are cumulative [500, 1400, 2100, 3200, 4250],
    // i.e. deltas of +500, +900, +700, +1100, +1050.
    expect(find.text('Round 5'), findsOneWidget);
    expect(find.text('+1050'), findsOneWidget);
    expect(find.text('4250'), findsOneWidget);
    final round5Top = tester.getTopLeft(find.text('Round 5'));

    // Round 1 is further down the (lazily built) list; scroll to it.
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(find.text('Round 1'), findsOneWidget);
    final round1Top = tester.getTopLeft(find.text('Round 1'));
    expect(round5Top.dy, lessThan(round1Top.dy));
  });
}
