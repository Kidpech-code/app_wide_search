// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

/// Hive `TypeAdapter` for [SearchItem]. Stores searchable entries for in-app
/// providers and offline caches.
class SearchItemAdapter extends TypeAdapter<SearchItem> {
  /// Creates a new [SearchItemAdapter] to link the adapter with Hive.
  SearchItemAdapter();

  @override
  final int typeId = 0;

  @override
  SearchItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchItem(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      groupId: fields[3] as String,
      description: fields[4] as String?,
      imageUrl: fields[5] as String?,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
      route: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SearchItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.groupId)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.metadata)
      ..writeByte(7)
      ..write(obj.route);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
