import 'package:hive/hive.dart';

part 'friend.g.dart';

/// A player the user has added to a game before, remembered across games so
/// they can be picked again from the New Game screen's friends list.
@HiveType(typeId: 6)
class Friend extends HiveObject {
  Friend({required this.id, required this.name, required this.avatarColorValue});

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int avatarColorValue;
}
