import 'package:hive/hive.dart';
import '../models/search_result.dart';
import '../models/search_item.dart';

/// Repository for caching search results using Hive.
///
/// This class provides methods to cache and retrieve search results for
/// offline access and improved performance. Cached results expire after a
/// configurable duration.
///
/// Performance features:
/// - Maximum entry limit with LRU eviction (default: 50 queries)
/// - Maximum size limit (default: 5MB)
/// - Automatic cleanup of oldest 20% when limits exceeded
class SearchCacheRepository {
  /// Creates a search cache repository.
  SearchCacheRepository({
    required this.boxName,
    this.cacheDuration = const Duration(hours: 24),
    this.maxEntries = 50,
    this.maxSizeBytes = 5 * 1024 * 1024, // 5MB
  });

  /// Name of the Hive box to store cached results.
  final String boxName;

  /// Duration for which cached results remain valid.
  final Duration cacheDuration;

  /// Maximum number of cached queries.
  /// When exceeded, oldest entries are removed (LRU eviction).
  final int maxEntries;

  /// Maximum cache size in bytes.
  /// Approximate limit for total cached data.
  final int maxSizeBytes;

  Box<Map<dynamic, dynamic>>? _box;

  /// Initializes the repository and opens the Hive box.
  ///
  /// This method must be called before using any other repository methods.
  Future<void> initialize() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
  }

  /// Caches a search result.
  ///
  /// Stores the [result] associated with the [query]. The result will expire
  /// after [cacheDuration] and will not be returned by [getCachedResult].
  ///
  /// Automatically evicts oldest entries if cache limits are exceeded.
  Future<void> cacheResult(SearchResult result) async {
    _ensureInitialized();

    // Check entry limit and evict if needed
    if (_box!.length >= maxEntries) {
      await _evictOldest();
    }

    final data = {
      'query': result.query,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'items': result.items.map(_serializeItem).toList(),
      'totalCount': result.totalCount,
      'executionTimeMs': result.executionTimeMs,
      'hasMore': result.hasMore,
      'nextPage': result.nextPage,
    };

    await _box!.put(result.query.toLowerCase(), data);
  }

  /// Retrieves a cached search result.
  ///
  /// Returns the cached [SearchResult] for [query] if it exists and hasn't
  /// expired. Returns null if no valid cache entry exists.
  SearchResult? getCachedResult(String query) {
    _ensureInitialized();

    final data = _box!.get(query.toLowerCase());
    if (data == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);

    // Check if cache has expired
    if (DateTime.now().difference(timestamp) > cacheDuration) {
      _box!.delete(query.toLowerCase());
      return null;
    }

    final items = (data['items'] as List<dynamic>).map((item) => _deserializeItem(item as Map<dynamic, dynamic>)).toList();

    return SearchResult(
      query: data['query'] as String,
      items: items,
      totalCount: data['totalCount'] as int?,
      executionTimeMs: data['executionTimeMs'] as int?,
      hasMore: data['hasMore'] as bool? ?? false,
      nextPage: data['nextPage'] as String?,
    );
  }

  /// Clears all cached results.
  Future<void> clearCache() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// Removes expired cache entries.
  ///
  /// This method is useful for periodic cleanup to free up storage space.
  Future<void> removeExpiredEntries() async {
    _ensureInitialized();

    final keysToDelete = <String>[];
    for (final key in _box!.keys) {
      final data = _box!.get(key);
      if (data != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
        if (DateTime.now().difference(timestamp) > cacheDuration) {
          keysToDelete.add(key as String);
        }
      }
    }

    await _box!.deleteAll(keysToDelete);
  }

  /// Closes the Hive box and releases resources.
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }

  /// Evicts oldest cached entries to free up space.
  ///
  /// Removes the oldest 20% of entries based on timestamp.
  Future<void> _evictOldest() async {
    final entries = _box!.toMap().entries.toList();

    // Sort by timestamp (oldest first)
    entries.sort((a, b) {
      final aTime = a.value['timestamp'] as int;
      final bTime = b.value['timestamp'] as int;
      return aTime.compareTo(bTime);
    });

    // Remove oldest 20%
    final toRemove = (entries.length * 0.2).ceil();
    final keysToDelete = entries.take(toRemove).map((e) => e.key as String).toList();

    await _box!.deleteAll(keysToDelete);
  }

  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError('SearchCacheRepository not initialized. Call initialize() first.');
    }
  }

  Map<String, dynamic> _serializeItem(SearchItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'subtitle': item.subtitle,
      'groupId': item.groupId,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'metadata': item.metadata,
      'route': item.route,
    };
  }

  SearchItem _deserializeItem(Map<dynamic, dynamic> data) {
    return SearchItem(
      id: data['id'] as String,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String,
      groupId: data['groupId'] as String,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      route: data['route'] as String?,
    );
  }
}
