import 'package:hive/hive.dart';
import '../models/search_history_item.dart';

/// Repository for managing search history using Hive.
///
/// This class provides methods to save, retrieve, and manage the user's search
/// history. It uses Hive for efficient local storage with automatic
/// serialization.
class SearchHistoryRepository {
  /// Creates a search history repository.
  SearchHistoryRepository({required this.boxName, this.maxHistoryItems = 50});

  /// Name of the Hive box to store search history.
  final String boxName;

  /// Maximum number of history items to retain.
  final int maxHistoryItems;

  Box<SearchHistoryItem>? _box;

  /// Initializes the repository and opens the Hive box.
  ///
  /// This method must be called before using any other repository methods.
  Future<void> initialize() async {
    _box = await Hive.openBox<SearchHistoryItem>(boxName);
  }

  /// Saves a search query to history.
  ///
  /// If the query already exists, increments its usage count and updates the
  /// timestamp. If the history exceeds [maxHistoryItems], removes the oldest
  /// entries.
  Future<void> addToHistory(String query) async {
    _ensureInitialized();

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return;

    // Check if query already exists
    final existingKey = _box!.keys.firstWhere(
      (key) => _box!.get(key)?.query.toLowerCase() == normalizedQuery,
      orElse: () => null,
    );

    if (existingKey != null) {
      // Update existing item
      final item = _box!.get(existingKey)!;
      item.recordUsage();
      await item.save();
    } else {
      // Add new item
      final item = SearchHistoryItem(
        query: query.trim(),
        timestamp: DateTime.now(),
      );
      await _box!.add(item);

      // Cleanup old items if necessary
      if (_box!.length > maxHistoryItems) {
        await _cleanupOldItems();
      }
    }
  }

  /// Retrieves recent search history.
  ///
  /// Returns a list of search queries ordered by recency and usage count. The
  /// [limit] parameter controls how many items to return.
  List<String> getRecentSearches({int limit = 10}) {
    _ensureInitialized();

    final items = _box!.values.toList();
    items.sort((a, b) {
      // Sort by timestamp descending, then by count descending
      final timeCompare = b.timestamp.compareTo(a.timestamp);
      if (timeCompare != 0) return timeCompare;
      return b.count.compareTo(a.count);
    });

    return items.take(limit).map((item) => item.query).toList();
  }

  /// Removes a specific query from history.
  Future<void> removeFromHistory(String query) async {
    _ensureInitialized();

    final normalizedQuery = query.trim().toLowerCase();
    final keysToDelete = <dynamic>[];

    for (final key in _box!.keys) {
      final item = _box!.get(key);
      if (item?.query.toLowerCase() == normalizedQuery) {
        keysToDelete.add(key);
      }
    }

    await _box!.deleteAll(keysToDelete);
  }

  /// Clears all search history.
  Future<void> clearHistory() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// Closes the Hive box and releases resources.
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }

  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'SearchHistoryRepository not initialized. Call initialize() first.',
      );
    }
  }

  Future<void> _cleanupOldItems() async {
    final items = _box!.values.toList();
    items.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final itemsToDelete = items.take(items.length - maxHistoryItems);
    final keysToDelete = <dynamic>[];

    for (final item in itemsToDelete) {
      final key = _box!.keys.firstWhere(
        (k) => _box!.get(k) == item,
        orElse: () => null,
      );
      if (key != null) {
        keysToDelete.add(key);
      }
    }

    await _box!.deleteAll(keysToDelete);
  }
}
