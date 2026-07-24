import 'package:hive_flutter/hive_flutter.dart';

import 'models/friend.dart';
import 'models/game_match.dart';
import 'models/game_settings.dart';
import 'models/match_player.dart';
import 'models/participant_entry.dart';
import 'models/round_multiplier.dart';
import 'models/winning_condition.dart';

/// Box names used across the app's local (offline) storage.
class HiveBoxes {
  HiveBoxes._();

  static const String gameSettings = 'game_settings';
  static const String gameMatches = 'game_matches';
  static const String friends = 'friends';
}

void registerHiveAdapters() {
  Hive.registerAdapter(GameSettingsAdapter());
  Hive.registerAdapter(WinningConditionAdapter());
  // GameSettings no longer has a roundMultiplier field, but this stays
  // registered so existing saved games (which still have that field written
  // to disk) can still be decoded — removing it would break loading them.
  Hive.registerAdapter(RoundMultiplierAdapter());
  Hive.registerAdapter(ParticipantEntryAdapter());
  Hive.registerAdapter(MatchPlayerAdapter());
  Hive.registerAdapter(GameMatchAdapter());
  Hive.registerAdapter(FriendAdapter());
}

Future<void> openHiveBoxes() async {
  await Hive.openBox<GameSettings>(HiveBoxes.gameSettings);
  await Hive.openBox<GameMatch>(HiveBoxes.gameMatches);
  await Hive.openBox<Friend>(HiveBoxes.friends);
}

/// Registers all Hive adapters and opens the boxes the app needs.
/// Must be awaited before [runApp].
Future<void> initHive() async {
  await Hive.initFlutter();
  registerHiveAdapters();
  await openHiveBoxes();
}
