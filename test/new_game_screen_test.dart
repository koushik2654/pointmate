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

  // The New Game screen's friends list now grows tall enough (one row per
  // roster member) that the default 800x600 test surface evicts scrolled-off
  // content from the sliver cache. Use a tall virtual viewport so the whole
  // screen fits without scrolling, matching a real phone.
  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(480, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Adding a custom player shows it in the roster', (WidgetTester tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(const PointMateApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(NewGameScreen), findsOneWidget);
    expect(find.text('3 Selected'), findsOneWidget, reason: 'starting roster count');

    await tester.ensureVisible(find.text('Add custom player...').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add custom player...').first);
    await tester.pumpAndSettle();

    expect(find.text('Add Player'), findsOneWidget, reason: 'dialog should open');
    expect(find.text('Avatar Color'), findsOneWidget, reason: 'color picker should be present');

    final addButtonBefore = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Add'),
    );
    expect(addButtonBefore.onPressed, isNull, reason: 'Add should be disabled with no name');

    await tester.enterText(find.byType(TextField).last, 'Zoe Test');
    await tester.pumpAndSettle();

    final addButtonAfter = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Add'),
    );
    expect(addButtonAfter.onPressed, isNotNull, reason: 'Add should enable once a name is typed');

    await tester.tap(find.byKey(const ValueKey(Color(0xFF7FCDBB))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('4 Selected'), findsOneWidget, reason: 'roster count should increase');
    expect(find.text('Zoe'), findsOneWidget, reason: 'first name label under the new avatar');

    await _swipeDeleteRosterRow(tester, 'Zoe Test');

    expect(find.text('3 Selected'), findsOneWidget, reason: 'roster count should decrease');
    expect(find.text('Zoe Test'), findsNothing, reason: 'deleted custom player should be gone');
  });

  testWidgets('Swiping a preset roster member deletes them too', (WidgetTester tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(const PointMateApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('3 Selected'), findsOneWidget, reason: 'starting roster count');
    expect(find.text('Sarah King'), findsOneWidget, reason: 'preset roster member row');

    await _swipeDeleteRosterRow(tester, 'Sarah King');

    expect(find.text('2 Selected'), findsOneWidget, reason: 'roster count should decrease');
    expect(
      find.text('Sarah King'),
      findsOneWidget,
      reason: 'preset friend returns to the suggestions list rather than disappearing',
    );
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Sarah King'), matching: find.byType(Row)).first,
        matching: find.byIcon(Icons.add_rounded),
      ),
      findsOneWidget,
      reason: 'Sarah King should now show an add button, not a delete row',
    );
  });
}

/// Locates the swipeable roster row containing [name], drags it left to
/// reveal the delete button, and taps it.
Future<void> _swipeDeleteRosterRow(WidgetTester tester, String name) async {
  final rowFinder = find.ancestor(
    of: find.text(name),
    matching: find.byWidgetPredicate((w) => w.runtimeType.toString() == '_RosterListRow'),
  );
  expect(rowFinder, findsOneWidget, reason: '$name should have a swipeable roster row');

  await tester.ensureVisible(rowFinder);
  await tester.pumpAndSettle();
  await tester.drag(rowFinder, const Offset(-80, 0));
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(of: rowFinder, matching: find.byIcon(Icons.remove_circle_rounded)));
  await tester.pumpAndSettle();
}
