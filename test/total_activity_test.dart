import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/main.dart';
import 'package:pointmate/widgets/total_activity_card.dart';

import 'support/pump_until.dart';

/// Scopes to the Total Activity card's own count text, since a created
/// game's "You" score of 0 can otherwise collide with the same digit.
Finder _totalActivityCount(String value) =>
    find.descendant(of: find.byType(TotalActivityCard), matching: find.text(value));

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

    expect(
      _totalActivityCount('0'),
      findsOneWidget,
      reason: 'no rounds recorded yet on a fresh install',
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Fresh Game');
    await tester.pumpAndSettle();

    await tapAndWaitUntil(
      tester,
      find.text('Create Game'),
      () => find.text('New Game').evaluate().isEmpty,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      _totalActivityCount('0'),
      findsOneWidget,
      reason: 'creating a game with no rounds yet should not count as played',
    );

    await tester.tap(find.text('Fresh Game'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add New Round'));
    await tester.pumpAndSettle();

    await tapAndWaitUntil(
      tester,
      find.text('Save'),
      () => find.text('Add New Round').evaluate().length == 1,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(
      _totalActivityCount('1'),
      findsOneWidget,
      reason: 'recording a round on the new game should now count it as played',
    );
  });
}
