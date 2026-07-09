import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/main.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_test_total_activity').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('Total Activity reflects games with at least one round played', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(480, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PointMateApp());

    expect(find.text('0'), findsOneWidget, reason: 'no rounds recorded yet on a fresh install');

    await tester.tap(find.text('Poker Night'));
    await tester.pumpAndSettle();

    expect(find.text('ROUND 5'), findsOneWidget, reason: 'sample game seeds 5 rounds on first open');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      find.text('1'),
      findsOneWidget,
      reason: 'opening a sample game seeds a played match, counting it as played',
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Fresh Game');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Game'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      find.text('1'),
      findsOneWidget,
      reason: 'creating a game with no rounds yet should not count as played',
    );

    await tester.tap(find.text('Fresh Game'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add New Round'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      find.text('2'),
      findsOneWidget,
      reason: 'recording a round on the new game should now count it as played',
    );
  });
}
