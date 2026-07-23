import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/main.dart';
import 'package:pointmate/screens/new_game_screen.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_test_new_game').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets(
    'Roster starts empty; adding a custom player selects them without duplicating them below, '
    'and removing them clears the roster again',
    (WidgetTester tester) async {
      await tester.pumpWidget(const PointMateApp());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(NewGameScreen), findsOneWidget);
      expect(find.text('0 Selected'), findsOneWidget, reason: 'no preset roster by default');

      await tester.tap(find.text('Add custom player...').first);
      await tester.pumpAndSettle();

      expect(find.text('Add Player'), findsOneWidget, reason: 'dialog should open');
      expect(find.text('Avatar Color'), findsOneWidget, reason: 'color picker should be present');

      final addButtonBefore = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Add'));
      expect(addButtonBefore.onPressed, isNull, reason: 'Add should be disabled with no name');

      await tester.enterText(find.byType(TextField).last, 'Zoe Test');
      await tester.pumpAndSettle();

      final addButtonAfter = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Add'));
      expect(addButtonAfter.onPressed, isNotNull, reason: 'Add should enable once a name is typed');

      await tester.tap(find.byKey(const ValueKey(Color(0xFF7FCDBB))));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();

      expect(find.text('1 Selected'), findsOneWidget, reason: 'roster count should increase');
      expect(find.text('Zoe'), findsOneWidget, reason: 'first name label under the new avatar');
      expect(
        find.text('Zoe Test'),
        findsNothing,
        reason: 'a selected player is not duplicated in the list below',
      );

      // The avatar's own remove (x) button, not the AppBar's dismiss button.
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();

      expect(find.text('0 Selected'), findsOneWidget, reason: 'roster count should decrease');
      expect(find.text('Zoe'), findsNothing, reason: 'removed custom player should be gone');
    },
  );
}
