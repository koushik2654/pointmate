// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchPlayerAdapter extends TypeAdapter<MatchPlayer> {
  @override
  final int typeId = 4;

  @override
  MatchPlayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchPlayer(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarColorValue: fields[2] as int,
      roundScores: (fields[3] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, MatchPlayer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarColorValue)
      ..writeByte(3)
      ..write(obj.roundScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchPlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
