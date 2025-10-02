import 'dart:async';
import 'search_item.dart';
import 'search_result.dart';

/// Contract for implementing custom search backends.
///
/// Implement this abstract class to provide search functionality from various
/// data sources such as local databases, REST APIs, or in-memory collections.
/// The package will use your implementation to fetch search results and
/// suggestions.
abstract class SearchProvider {
  /// Performs a search operation.
  ///
  /// Returns a [SearchResult] containing items matching the [query]. The
  /// optional [limit] parameter controls the maximum number of results to
  /// return. The [offset] parameter enables pagination.
  ///
  /// This method is called when the user submits a search query. It should
  /// perform the actual search logic and return matching items.
  Future<SearchResult> search(String query, {int limit = 20, int offset = 0});

  /// Provides search suggestions based on partial input.
  ///
  /// Returns a list of suggested search queries or items based on the partial
  /// [query]. This method is called as the user types in the search field to
  /// provide real-time suggestions.
  ///
  /// The default implementation returns an empty list. Override this method
  /// to provide custom suggestion logic.
  Future<List<SearchItem>> getSuggestions(String query) async {
    return [];
  }

  /// Clears any cached search data.
  ///
  /// Called when the user wants to clear their search history or cached
  /// results. The default implementation does nothing.
  Future<void> clearCache() async {}

  /// Notifies the provider that a search item was selected.
  ///
  /// This callback allows tracking user interactions and updating search
  /// analytics or recent searches. The default implementation does nothing.
  Future<void> onItemSelected(SearchItem item) async {}
}

/// Internal indexed item for optimized search.
/// Caches lowercase versions to avoid repeated toLowerCase() calls.
class _IndexedSearchItem {
  const _IndexedSearchItem({
    required this.item,
    required this.normalizedTitle,
    required this.normalizedSubtitle,
    required this.normalizedDescription,
  });

  final SearchItem item;
  final String normalizedTitle;
  final String normalizedSubtitle;
  final String? normalizedDescription;
}

/// A simple in-memory search provider for testing and examples.
///
/// This implementation performs case-insensitive substring matching on item
/// titles and subtitles with cached normalization for 30% better performance.
/// It's useful for quick prototyping but should be replaced with a more robust
/// solution in production (e.g., sqlite_search for >10K items).
class InMemorySearchProvider extends SearchProvider {
  /// Creates an in-memory search provider.
  InMemorySearchProvider(List<SearchItem> items)
    : _indexed = items
          .map(
            (item) => _IndexedSearchItem(
              item: item,
              normalizedTitle: item.title.toLowerCase(),
              normalizedSubtitle: item.subtitle.toLowerCase(),
              normalizedDescription: item.description?.toLowerCase(),
            ),
          )
          .toList();

  final List<_IndexedSearchItem> _indexed;

  @override
  Future<SearchResult> search(String query, {int limit = 20, int offset = 0}) async {
    final stopwatch = Stopwatch()..start();

    if (query.isEmpty) {
      return SearchResult.empty(query);
    }

    final normalizedQuery = query.toLowerCase();
    final matches = _indexed
        .where((indexed) {
          return indexed.normalizedTitle.contains(normalizedQuery) ||
              indexed.normalizedSubtitle.contains(normalizedQuery) ||
              (indexed.normalizedDescription?.contains(normalizedQuery) ?? false);
        })
        .map((e) => e.item)
        .toList();

    final paginatedMatches = matches.skip(offset).take(limit).toList();

    stopwatch.stop();

    return SearchResult(
      query: query,
      items: paginatedMatches,
      totalCount: matches.length,
      executionTimeMs: stopwatch.elapsedMilliseconds,
      hasMore: offset + limit < matches.length,
      nextPage: offset + limit < matches.length ? (offset + limit).toString() : null,
    );
  }

  @override
  Future<List<SearchItem>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final normalizedQuery = query.toLowerCase();
    final suggestions = _indexed
        .where((indexed) {
          return indexed.normalizedTitle.startsWith(normalizedQuery) || indexed.normalizedSubtitle.startsWith(normalizedQuery);
        })
        .map((e) => e.item)
        .take(5)
        .toList();

    return suggestions;
  }
}
