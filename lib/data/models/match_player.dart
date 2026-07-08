import 'package:hive/hive.dart';

part 'match_player.g.dart';

/// A participant's running total across the rounds played so far in a
/// [GameMatch]. `roundScores[i]` is the cumulative total after round i+1.
@HiveType(typeId: 4)
class MatchPlayer extends HiveObject {
  MatchPlayer({
    required this.id,
    required this.name,
    required this.avatarColorValue,
    required this.roundScores,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int avatarColorValue;

  @HiveField(3)
  List<int> roundScores;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  int get total => roundScores.isEmpty ? 0 : roundScores.last;
}
