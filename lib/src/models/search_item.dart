import 'package:hive/hive.dart';

part 'search_item.g.dart';

/// Represents a single searchable item in the app.
///
/// A [SearchItem] encapsulates all the information needed to display and
/// interact with a search result. Each item belongs to a specific group and
/// can be customized with metadata for advanced use cases.
@HiveType(typeId: 0)
class SearchItem extends HiveObject {
  /// Creates a search item.
  SearchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.groupId,
    this.description,
    this.imageUrl,
    this.metadata,
    this.route,
    this.onTap,
  });

  /// Unique identifier for this search item.
  @HiveField(0)
  final String id;

  /// Primary display title of the search item.
  @HiveField(1)
  final String title;

  /// Secondary display text shown below the title.
  @HiveField(2)
  final String subtitle;

  /// Identifier of the group this item belongs to.
  @HiveField(3)
  final String groupId;

  /// Optional detailed description of the item.
  @HiveField(4)
  final String? description;

  /// Optional URL for an image to display with the item.
  @HiveField(5)
  final String? imageUrl;

  /// Optional metadata for custom use cases.
  @HiveField(6)
  final Map<String, dynamic>? metadata;

  /// Optional route to navigate to when item is tapped.
  @HiveField(7)
  final String? route;

  /// Optional custom tap handler.
  ///
  /// If both [route] and [onTap] are provided, [onTap] takes precedence.
  final void Function()? onTap;

  /// Creates a copy of this search item with updated fields.
  SearchItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? groupId,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    String? route,
    void Function()? onTap,
  }) {
    return SearchItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      route: route ?? this.route,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SearchItem(id: $id, title: $title, groupId: $groupId)';
}
