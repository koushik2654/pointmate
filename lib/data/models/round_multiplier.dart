import 'package:hive/hive.dart';

part 'round_multiplier.g.dart';

@HiveType(typeId: 2)
enum RoundMultiplier {
  @HiveField(0)
  x1,
  @HiveField(1)
  x2,
  @HiveField(2)
  x3;

  String get label {
    switch (this) {
      case RoundMultiplier.x1:
        return '1x (Standard)';
      case RoundMultiplier.x2:
        return '2x (Double)';
      case RoundMultiplier.x3:
        return '3x (Triple)';
    }
  }
}
