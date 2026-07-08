// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'winning_condition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WinningConditionAdapter extends TypeAdapter<WinningCondition> {
  @override
  final int typeId = 1;

  @override
  WinningCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WinningCondition.highestScoreWins;
      case 1:
        return WinningCondition.lowestScoreWins;
      default:
        return WinningCondition.highestScoreWins;
    }
  }

  @override
  void write(BinaryWriter writer, WinningCondition obj) {
    switch (obj) {
      case WinningCondition.highestScoreWins:
        writer.writeByte(0);
        break;
      case WinningCondition.lowestScoreWins:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WinningConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
