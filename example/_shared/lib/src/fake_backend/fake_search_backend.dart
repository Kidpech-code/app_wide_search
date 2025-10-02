import 'dart:async';
import 'dart:math';
import 'package:app_wide_search/app_wide_search.dart';
import '../fixtures/fixture_data.dart';

/// Mock search backend with configurable behavior for testing and examples.
///
/// Features:
/// - Configurable latency simulation
/// - Random error injection
/// - Pagination support
/// - Cancellation support
/// - Realistic search scoring
class FakeSearchBackend {
  /// Creates a fake search backend with configurable parameters.
  FakeSearchBackend({
    this.latency = const Duration(milliseconds: 100),
    this.errorRate = 0.0,
    this.itemCount = 1000,
    this.pageSize = 20,
    this.useRealisticData = true,
  }) : _random = Random() {
    _initializeData();
  }

  /// Simulated network latency for search operations.
  final Duration latency;

  /// Probability of random errors (0.0 to 1.0).
  final double errorRate;

  /// Total number of items in the fake dataset.
  final int itemCount;

  /// Number of items per page for pagination.
  final int pageSize;

  /// Whether to generate realistic test data.
  final bool useRealisticData;

  final Random _random;

  late List<SearchItem> _allItems;
  int _searchCount = 0;

  void _initializeData() {
    if (useRealisticData) {
      _allItems = FixtureData.generateRealisticItems(itemCount);
    } else {
      _allItems = List.generate(
        itemCount,
        (index) => SearchItem(
          id: 'item_$index',
          title: 'Item $index',
          subtitle: 'Subtitle for item $index',
          groupId: 'group_${index % 10}',
          description: 'Description for item $index with some searchable text',
        ),
      );
    }
  }

  /// Searches items with realistic behavior.
  ///
  /// Returns a [SearchResult] after simulating network latency.
  /// May throw errors based on [errorRate].
  /// Supports cancellation via [cancellationToken].
  Future<SearchResult> search(String query, {int page = 1, int? limit, CancellationToken? cancellationToken}) async {
    _searchCount++;
    final searchId = _searchCount;

    // Simulate network latency
    await Future<void>.delayed(latency);

    // Check cancellation after delay
    cancellationToken?.throwIfCancelled();

    // Simulate random errors
    if (_random.nextDouble() < errorRate) {
      throw Exception('Simulated network error (search #$searchId)');
    }

    if (query.trim().isEmpty) {
      return SearchResult.empty(query);
    }

    final normalizedQuery = query.toLowerCase().trim();
    final startTime = DateTime.now();

    // Search with scoring
    final scoredMatches =
        _allItems
            .map((item) {
              final score = _calculateScore(item, normalizedQuery);
              return score > 0 ? (item: item, score: score) : null;
            })
            .whereType<({SearchItem item, double score})>()
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final matches = scoredMatches.map((e) => e.item).toList();

    // Paginate results
    final effectiveLimit = limit ?? pageSize;
    final startIndex = (page - 1) * effectiveLimit;
    final endIndex = min(startIndex + effectiveLimit, matches.length);

    final paginatedItems = startIndex < matches.length ? matches.sublist(startIndex, endIndex) : <SearchItem>[];

    final executionTime = DateTime.now().difference(startTime).inMilliseconds;

    return SearchResult(
      query: query,
      items: paginatedItems,
      totalCount: matches.length,
      executionTimeMs: executionTime,
      hasMore: endIndex < matches.length,
      nextPage: endIndex < matches.length ? 'page=${page + 1}' : null,
    );
  }

  /// Calculates relevance score for an item.
  ///
  /// Scoring logic:
  /// - Title exact match: 100
  /// - Title starts with query: 80
  /// - Title contains query: 60
  /// - Subtitle contains query: 40
  /// - Description contains query: 20
  double _calculateScore(SearchItem item, String query) {
    final titleLower = item.title.toLowerCase();
    final subtitleLower = item.subtitle.toLowerCase();
    final descLower = item.description?.toLowerCase() ?? '';

    if (titleLower == query) return 100.0;
    if (titleLower.startsWith(query)) return 80.0;
    if (titleLower.contains(query)) return 60.0;
    if (subtitleLower.contains(query)) return 40.0;
    if (descLower.contains(query)) return 20.0;

    return 0.0;
  }

  /// Streams search results progressively.
  ///
  /// Useful for demonstrating streaming search patterns.
  /// Emits partial results as they become available.
  Stream<SearchResult> searchStream(String query, {int batchSize = 10, CancellationToken? cancellationToken}) async* {
    if (query.trim().isEmpty) {
      yield SearchResult.empty(query);
      return;
    }

    // Simulate initial delay
    await Future<void>.delayed(latency ~/ 2);
    cancellationToken?.throwIfCancelled();

    final normalizedQuery = query.toLowerCase().trim();
    final matches = <SearchItem>[];

    for (var i = 0; i < _allItems.length; i += batchSize) {
      cancellationToken?.throwIfCancelled();

      final batch = _allItems.skip(i).take(batchSize);
      for (final item in batch) {
        if (_calculateScore(item, normalizedQuery) > 0) {
          matches.add(item);
        }
      }

      // Emit partial results
      yield SearchResult(query: query, items: List.from(matches), totalCount: matches.length, hasMore: i + batchSize < _allItems.length);

      // Simulate processing delay
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Resets search count and regenerates data.
  void reset() {
    _searchCount = 0;
    _initializeData();
  }

  /// Returns search statistics.
  Map<String, dynamic> get stats => {
    'totalSearches': _searchCount,
    'totalItems': _allItems.length,
    'averageLatency': latency.inMilliseconds,
    'errorRate': errorRate,
  };
}
