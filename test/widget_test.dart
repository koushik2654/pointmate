import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/main.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  testWidgets('Home screen renders title and active games', (WidgetTester tester) async {
    await tester.pumpWidget(const PointMateApp());

    expect(find.text('PointMate'), findsOneWidget);
    expect(find.text('Active Games'), findsOneWidget);
    expect(find.text('Poker Night'), findsOneWidget);
  });

  testWidgets('Tapping a game card opens its dashboard with a sorted leaderboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PointMateApp());

    await tester.tap(find.text('Poker Night'));
    await tester.pumpAndSettle();

    expect(find.text('ROUND 5'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('4,250'), findsOneWidget);
  });
}
