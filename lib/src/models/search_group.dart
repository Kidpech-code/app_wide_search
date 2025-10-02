import 'package:hive/hive.dart';

part 'search_group.g.dart';

/// Represents a group or category of search items.
///
/// Groups allow organizing search results into logical categories for better
/// user experience. Each group can be expanded or collapsed in the UI.
@HiveType(typeId: 1)
class SearchGroup extends HiveObject {
  /// Creates a search group.
  SearchGroup({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.priority = 0,
  });

  /// Unique identifier for this group.
  @HiveField(0)
  final String id;

  /// Display name of the group.
  @HiveField(1)
  final String name;

  /// Optional description of what items belong to this group.
  @HiveField(2)
  final String? description;

  /// Optional icon data for the group.
  @HiveField(3)
  final int? icon;

  /// Optional color value for the group.
  @HiveField(4)
  final int? color;

  /// Priority for sorting groups (higher priority appears first).
  @HiveField(5)
  final int priority;

  /// Creates a copy of this group with updated fields.
  SearchGroup copyWith({
    String? id,
    String? name,
    String? description,
    int? icon,
    int? color,
    int? priority,
  }) {
    return SearchGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SearchGroup(id: $id, name: $name)';
}
