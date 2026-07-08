import 'package:hive/hive.dart';

part 'participant_entry.g.dart';

@HiveType(typeId: 3)
class ParticipantEntry extends HiveObject {
  ParticipantEntry({required this.id, required this.name, required this.avatarColorValue});

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int avatarColorValue;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
