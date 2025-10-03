import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../models/search_provider.dart';
import '../models/search_result.dart';
import '../repositories/search_history_repository.dart';
import '../repositories/search_cache_repository.dart';

/// Provider for the search provider implementation.
///
/// This provider must be overridden with your custom [SearchProvider]
/// implementation. If not overridden, it will throw an error.
final searchProviderProvider = Provider<SearchProvider>((ref) {
  throw UnimplementedError(
    'searchProviderProvider must be overridden with your SearchProvider implementation',
  );
});

/// Provider for the search history repository.
///
/// This provider initializes and manages the [SearchHistoryRepository].
/// It automatically disposes the repository when no longer needed.
final searchHistoryRepositoryProvider =
    Provider.autoDispose<SearchHistoryRepository>((ref) {
      final repository = SearchHistoryRepository(
        boxName: 'search_history',
        maxHistoryItems: 50,
      );

      ref.onDispose(() {
        repository.dispose();
      });

      return repository;
    });

/// Provider for the search cache repository.
///
/// This provider initializes and manages the [SearchCacheRepository].
/// It automatically disposes the repository when no longer needed.
final searchCacheRepositoryProvider =
    Provider.autoDispose<SearchCacheRepository>((ref) {
      final repository = SearchCacheRepository(
        boxName: 'search_cache',
        cacheDuration: const Duration(hours: 24),
      );

      ref.onDispose(() {
        repository.dispose();
      });

      return repository;
    });

/// Provider for the current search query.
///
/// Use this provider to access and update the current search query text.
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for search results.
///
/// This provider performs a search whenever the query changes. It checks the
/// cache first and falls back to the search provider if no cached result
/// exists. Results are automatically cached for future use.
final searchResultsProvider = FutureProvider.autoDispose<SearchResult>((
  ref,
) async {
  final (String rawQuery, String normalizedQuery) = ref.watch(
    searchQueryProvider.select((String value) => (value, value.trim())),
  );

  if (normalizedQuery.isEmpty) {
    return SearchResult.empty(rawQuery);
  }

  // Initialize repositories
  final cacheRepo = ref.watch(searchCacheRepositoryProvider);
  await cacheRepo.initialize();

  final historyRepo = ref.watch(searchHistoryRepositoryProvider);
  await historyRepo.initialize();

  // Check cache first
  final cachedResult = cacheRepo.getCachedResult(normalizedQuery);
  if (cachedResult != null) {
    return cachedResult;
  }

  // Perform search
  final searchProvider = ref.watch(searchProviderProvider);
  final result = await searchProvider.search(normalizedQuery);

  // Cache the result
  await cacheRepo.cacheResult(result);

  // Add to history
  await historyRepo.addToHistory(normalizedQuery);

  return result;
});

/// Provider for search suggestions.
///
/// This provider fetches suggestions based on the current query. It's useful
/// for autocomplete and search-as-you-type features.
final searchSuggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      if (query.trim().isEmpty) {
        // Return recent searches when query is empty
        final historyRepo = ref.watch(searchHistoryRepositoryProvider);
        await historyRepo.initialize();
        return historyRepo.getRecentSearches(limit: 5);
      }

      final searchProvider = ref.watch(searchProviderProvider);
      final suggestions = await searchProvider.getSuggestions(query);
      return suggestions.map((item) => item.title).toList();
    });

/// Provider for recent search history.
///
/// This provider exposes the user's recent search queries.
final recentSearchesProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final historyRepo = ref.watch(searchHistoryRepositoryProvider);
  await historyRepo.initialize();
  return historyRepo.getRecentSearches(limit: 10);
});

/// Provider for clearing search history.
///
/// This is a mutation provider that clears all search history.
final clearSearchHistoryProvider = Provider.autoDispose<void Function()>((ref) {
  return () async {
    final historyRepo = ref.read(searchHistoryRepositoryProvider);
    await historyRepo.initialize();
    await historyRepo.clearHistory();
    ref.invalidate(recentSearchesProvider);
  };
});

/// Provider for clearing search cache.
///
/// This is a mutation provider that clears all cached search results.
final clearSearchCacheProvider = Provider.autoDispose<void Function()>((ref) {
  return () async {
    final cacheRepo = ref.read(searchCacheRepositoryProvider);
    await cacheRepo.initialize();
    await cacheRepo.clearCache();
    ref.invalidate(searchResultsProvider);
  };
});
