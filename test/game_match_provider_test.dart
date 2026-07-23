import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pointmate/data/hive_boxes.dart';
import 'package:pointmate/data/models/game_match.dart';
import 'package:pointmate/providers/game_match_provider.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('pointmate_provider_test').path);
    registerHiveAdapters();
    await openHiveBoxes();
  });

  test('updateRound recomputes totals for that round onward', () async {
    final provider = GameMatchProvider(
      box: Hive.box<GameMatch>(HiveBoxes.gameMatches),
      gameId: 'history-update-logic-test',
      gameName: 'Update Logic Test',
    );

    // Seeded rounds are cumulative [500, 1400, 2100, 3200, 4250] for Alex,
    // i.e. deltas of +500, +900, +700, +1100, +1050.
    await provider.updateRound(4, {'alex': 2000, 'sarah': 900, 'mike': 850});

    final rounds = provider.rounds;
    expect(rounds, hasLength(5));
    // Round 4's total for Alex was 3200, so round 5 should now total 5200.
    expect(rounds.last.deltas['alex'], 2000);
    expect(rounds.last.totals['alex'], 5200);
    // Sarah/Mike's points that round were re-submitted unchanged.
    expect(rounds.last.totals['sarah'], 3100);
    expect(rounds.last.totals['mike'], 2850);
  });

  test('deleteRound removes a round and recomputes the rest', () async {
    final provider = GameMatchProvider(
      box: Hive.box<GameMatch>(HiveBoxes.gameMatches),
      gameId: 'history-delete-logic-test',
      gameName: 'Delete Logic Test',
    );

    expect(provider.rounds, hasLength(5));

    await provider.deleteRound(0);

    final rounds = provider.rounds;
    expect(rounds, hasLength(4));
    // Former round 2 (delta +900) is now round 1.
    expect(rounds.first.roundNumber, 1);
    expect(rounds.first.deltas['alex'], 900);
    expect(rounds.first.totals['alex'], 900);
    // Former round 5 (delta +1050) is now round 4, with round 1's +500
    // removed from the running total: 900 + 700 + 1100 + 1050 = 3750.
    expect(rounds.last.roundNumber, 4);
    expect(rounds.last.totals['alex'], 3750);
  });
}
