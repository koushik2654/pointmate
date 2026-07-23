import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/main.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_debug5').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('debug', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(480, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PointMateApp());

    await tester.tap(find.text('Poker Night'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Fresh Game');
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text('Create Game'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    print('Is still on NewGameScreen: ${find.text('New Game').evaluate().isNotEmpty}');
    print('Has arrow_back: ${find.byIcon(Icons.arrow_back).evaluate().isNotEmpty}');
  });
}
