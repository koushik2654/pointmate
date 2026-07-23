import 'package:flutter_test/flutter_test.dart';

/// Taps [tapTarget] and waits, with real delays, until [settled] is true or
/// [timeout] elapses.
///
/// A tap that triggers a real (disk-backed) Hive write can't complete on a
/// fixed short delay: under concurrent test-file execution, actual I/O time
/// varies with system load. Awaiting the write directly inside a testWidgets
/// body also doesn't work — flutter_test's fake-clock zone never lets it
/// resolve — so both the tap and the wait run inside a single [WidgetTester.
/// runAsync] call, which opts into the real zone for the whole interaction.
Future<void> tapAndWaitUntil(
  WidgetTester tester,
  Finder tapTarget,
  bool Function() settled, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.runAsync(() async {
    await tester.tap(tapTarget);
    final deadline = DateTime.now().add(timeout);
    while (!settled() && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  });
}
