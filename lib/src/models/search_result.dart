import 'search_item.dart';

/// Represents the complete result set from a search operation.
///
/// A [SearchResult] contains all matching items organized by their groups,
/// along with metadata about the search operation itself.
class SearchResult {
  /// Creates a search result.
  const SearchResult({
    required this.query,
    required this.items,
    this.totalCount,
    this.executionTimeMs,
    this.hasMore = false,
    this.nextPage,
  });

  /// The search query that produced these results.
  final String query;

  /// All items matching the search query.
  final List<SearchItem> items;

  /// Total number of results available (may be more than items.length).
  final int? totalCount;

  /// Time taken to execute the search in milliseconds.
  final int? executionTimeMs;

  /// Whether more results are available beyond this page.
  final bool hasMore;

  /// Token or page number for fetching the next page of results.
  final String? nextPage;

  /// Returns items grouped by their groupId.
  Map<String, List<SearchItem>> get groupedItems {
    final grouped = <String, List<SearchItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.groupId, () => []).add(item);
    }
    return grouped;
  }

  /// Returns true if this result set is empty.
  bool get isEmpty => items.isEmpty;

  /// Returns true if this result set has items.
  bool get isNotEmpty => items.isNotEmpty;

  /// Creates an empty search result.
  factory SearchResult.empty(String query) {
    return SearchResult(
      query: query,
      items: const [],
      totalCount: 0,
      hasMore: false,
    );
  }

  /// Creates a copy of this result with updated fields.
  SearchResult copyWith({
    String? query,
    List<SearchItem>? items,
    int? totalCount,
    int? executionTimeMs,
    bool? hasMore,
    String? nextPage,
  }) {
    return SearchResult(
      query: query ?? this.query,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      executionTimeMs: executionTimeMs ?? this.executionTimeMs,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
    );
  }

  @override
  String toString() =>
      'SearchResult(query: $query, items: ${items.length}, totalCount: $totalCount)';
}
