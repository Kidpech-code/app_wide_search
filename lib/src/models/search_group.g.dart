// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchGroupAdapter extends TypeAdapter<SearchGroup> {
  @override
  final int typeId = 1;

  @override
  SearchGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      icon: fields[3] as int?,
      color: fields[4] as int?,
      priority: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SearchGroup obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
