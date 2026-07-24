// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameSettingsAdapter extends TypeAdapter<GameSettings> {
  @override
  final int typeId = 0;

  @override
  GameSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameSettings(
      gameId: fields[0] as String,
      winningCondition: fields[1] as WinningCondition,
      allowNegativeScores: fields[2] as bool,
      enableTimer: fields[3] as bool,
      targetScore: fields[4] as int,
      participants: (fields[6] as List).cast<ParticipantEntry>(),
      category: fields[7] as String?,
      invertScoreColors: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, GameSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.gameId)
      ..writeByte(1)
      ..write(obj.winningCondition)
      ..writeByte(2)
      ..write(obj.allowNegativeScores)
      ..writeByte(3)
      ..write(obj.enableTimer)
      ..writeByte(4)
      ..write(obj.targetScore)
      ..writeByte(6)
      ..write(obj.participants)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.invertScoreColors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
