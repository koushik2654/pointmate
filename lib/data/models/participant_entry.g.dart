// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParticipantEntryAdapter extends TypeAdapter<ParticipantEntry> {
  @override
  final int typeId = 3;

  @override
  ParticipantEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParticipantEntry(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarColorValue: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ParticipantEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
