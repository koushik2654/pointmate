// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_match.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameMatchAdapter extends TypeAdapter<GameMatch> {
  @override
  final int typeId = 5;

  @override
  GameMatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameMatch(
      gameId: fields[0] as String,
      name: fields[1] as String,
      players: (fields[2] as List).cast<MatchPlayer>(),
    );
  }

  @override
  void write(BinaryWriter writer, GameMatch obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.gameId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.players);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
