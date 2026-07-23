import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/main.dart';

import 'support/pump_until.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('Home screen renders title and the active games section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PointMateApp());

    expect(find.text('PointMate'), findsOneWidget);
    expect(find.text('Active Games'), findsOneWidget);
  });

  testWidgets('Creating a game shows it on Home and opens its dashboard with a leaderboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PointMateApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Board Game Night');
    await tester.pumpAndSettle();

    await tapAndWaitUntil(
      tester,
      find.text('Create Game'),
      () => find.text('New Game').evaluate().isEmpty,
    );
    await tester.pumpAndSettle();

    expect(find.text('Board Game Night'), findsOneWidget);
    expect(find.text('ROUND 0'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });
}
