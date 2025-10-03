// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

/// Hive `TypeAdapter` for [SearchHistoryItem]. Persists recent queries so they
/// can be surfaced instantly on subsequent launches.
class SearchHistoryItemAdapter extends TypeAdapter<SearchHistoryItem> {
  /// Creates a new [SearchHistoryItemAdapter] for registering with Hive.
  SearchHistoryItemAdapter();

  @override
  final int typeId = 2;

  @override
  SearchHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryItem(
      query: fields[0] as String,
      timestamp: fields[1] as DateTime,
      count: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.query)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
