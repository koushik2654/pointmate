// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_multiplier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoundMultiplierAdapter extends TypeAdapter<RoundMultiplier> {
  @override
  final int typeId = 2;

  @override
  RoundMultiplier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RoundMultiplier.x1;
      case 1:
        return RoundMultiplier.x2;
      case 2:
        return RoundMultiplier.x3;
      default:
        return RoundMultiplier.x1;
    }
  }

  @override
  void write(BinaryWriter writer, RoundMultiplier obj) {
    switch (obj) {
      case RoundMultiplier.x1:
        writer.writeByte(0);
        break;
      case RoundMultiplier.x2:
        writer.writeByte(1);
        break;
      case RoundMultiplier.x3:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundMultiplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
