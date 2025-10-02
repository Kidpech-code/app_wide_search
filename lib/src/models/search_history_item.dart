import 'package:hive/hive.dart';

part 'search_history_item.g.dart';

/// Represents a historical search query.
///
/// This class stores information about past searches including the query text,
/// timestamp, and usage count for ranking recent searches.
@HiveType(typeId: 2)
class SearchHistoryItem extends HiveObject {
  /// Creates a search history item.
  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    this.count = 1,
  });

  /// The search query text.
  @HiveField(0)
  String query;

  /// When this search was last performed.
  @HiveField(1)
  DateTime timestamp;

  /// Number of times this query has been searched.
  @HiveField(2)
  int count;

  /// Increments the usage count and updates timestamp.
  void recordUsage() {
    count++;
    timestamp = DateTime.now();
  }

  @override
  String toString() =>
      'SearchHistoryItem(query: $query, count: $count, timestamp: $timestamp)';
}
