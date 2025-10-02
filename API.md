# API Documentation

## Models

### SearchItem

Represents a single searchable item in the app.

```dart
SearchItem({
  required String id,              // Unique identifier
  required String title,           // Primary display text
  required String subtitle,        // Secondary display text
  required String groupId,         // Group/category identifier
  String? description,             // Optional detailed description
  String? imageUrl,                // Optional image URL
  Map<String, dynamic>? metadata,  // Optional custom metadata
  String? route,                   // Optional navigation route
  void Function()? onTap,          // Optional tap handler
})
```

**Methods:**

- `copyWith()` - Creates a copy with updated fields

### SearchGroup

Represents a group or category of search items.

```dart
SearchGroup({
  required String id,        // Unique identifier
  required String name,      // Display name
  String? description,       // Optional description
  int? icon,                 // Optional icon code point
  int? color,                // Optional color value
  int priority = 0,          // Sort priority (higher = first)
})
```

### SearchResult

Contains complete search results with metadata.

```dart
SearchResult({
  required String query,           // Search query
  required List<SearchItem> items, // Matching items
  int? totalCount,                 // Total results available
  int? executionTimeMs,            // Search execution time
  bool hasMore = false,            // More results available
  String? nextPage,                // Next page token
})
```

**Properties:**

- `groupedItems` - Returns items grouped by groupId
- `isEmpty` / `isNotEmpty` - Check if results are empty

**Factory:**

- `SearchResult.empty(String query)` - Creates empty result

### SearchHistoryItem

Represents a historical search query.

```dart
SearchHistoryItem({
  required String query,        // Search query text
  required DateTime timestamp,  // Last search time
  int count = 1,               // Usage count
})
```

## Abstract Classes

### SearchProvider

Contract for implementing custom search backends.

```dart
abstract class SearchProvider {
  // Performs a search operation
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
  });

  // Provides search suggestions
  Future<List<SearchItem>> getSuggestions(String query);

  // Clears cached data
  Future<void> clearCache();

  // Called when an item is selected
  Future<void> onItemSelected(SearchItem item);
}
```

**Built-in Implementations:**

- `InMemorySearchProvider` - Simple in-memory search for testing

## Repositories

### SearchHistoryRepository

Manages search history with Hive.

```dart
SearchHistoryRepository({
  required String boxName,
  int maxHistoryItems = 50,
})
```

**Methods:**

- `initialize()` - Opens Hive box
- `addToHistory(String query)` - Saves query to history
- `getRecentSearches({int limit = 10})` - Gets recent searches
- `removeFromHistory(String query)` - Removes specific query
- `clearHistory()` - Clears all history
- `dispose()` - Closes box

### SearchCacheRepository

Manages result caching with Hive.

```dart
SearchCacheRepository({
  required String boxName,
  Duration cacheDuration = const Duration(hours: 24),
})
```

**Methods:**

- `initialize()` - Opens Hive box
- `cacheResult(SearchResult result)` - Caches search result
- `getCachedResult(String query)` - Retrieves cached result
- `clearCache()` - Clears all cache
- `removeExpiredEntries()` - Removes expired entries
- `dispose()` - Closes box

## Providers (Riverpod)

### searchProviderProvider

Provider for your SearchProvider implementation. Must be overridden:

```dart
ProviderScope(
  overrides: [
    searchProviderProvider.overrideWithValue(
      MySearchProvider(),
    ),
  ],
  child: MyApp(),
)
```

### searchQueryProvider

StateProvider for the current search query:

```dart
final query = ref.watch(searchQueryProvider);
ref.read(searchQueryProvider.notifier).state = 'new query';
```

### searchResultsProvider

FutureProvider for search results. Automatically caches results:

```dart
final resultsAsync = ref.watch(searchResultsProvider);
resultsAsync.when(
  data: (result) => /* show results */,
  loading: () => /* show loading */,
  error: (error, stack) => /* show error */,
);
```

### searchSuggestionsProvider

FamilyProvider for search suggestions:

```dart
final suggestionsAsync = ref.watch(
  searchSuggestionsProvider('partial query'),
);
```

### recentSearchesProvider

FutureProvider for recent search history:

```dart
final recentAsync = ref.watch(recentSearchesProvider);
```

### clearSearchHistoryProvider

Provider for clearing search history:

```dart
final clearHistory = ref.read(clearSearchHistoryProvider);
clearHistory();
```

### clearSearchCacheProvider

Provider for clearing search cache:

```dart
final clearCache = ref.read(clearSearchCacheProvider);
clearCache();
```

## UI Widgets

### AppWideSearchDelegate

Customizable SearchDelegate for modal search.

```dart
AppWideSearchDelegate({
  required WidgetRef ref,
  String? hintText,
  Widget Function(BuildContext, SearchResult)? resultBuilder,
  Widget Function(BuildContext, List<String>)? suggestionBuilder,
  Widget Function(BuildContext, String)? emptyBuilder,
})
```

**Usage:**

```dart
showSearch(
  context: context,
  delegate: AppWideSearchDelegate(ref: ref),
);
```

### SearchScreen

Full-screen search interface.

```dart
SearchScreen({
  String? initialQuery,
  Widget Function(BuildContext, WidgetRef)? customResultBuilder,
})
```

### SearchResultList

Displays search results in a list.

```dart
SearchResultList({
  required SearchResult result,
  required void Function(SearchItem) onItemTap,
  bool showGrouped = true,
  Widget Function(BuildContext, SearchItem)? itemBuilder,
})
```

### GroupedSearchResults

Displays results grouped by category with ExpansionTile.

```dart
GroupedSearchResults({
  required SearchResult result,
  required void Function(SearchItem) onItemTap,
  Map<String, SearchGroup>? groups,
  Widget Function(BuildContext, SearchItem)? itemBuilder,
  bool initiallyExpanded = true,
})
```

## Routing

### SearchRouteConfig

Configuration for go_router integration.

**Constants:**

- `searchPath` - Default search route path ('/search')
- `queryParam` - Query parameter name ('q')

**Static Methods:**

```dart
// Create search route
GoRoute route = SearchRouteConfig.createSearchRoute({
  String? path,
  Widget Function(BuildContext, GoRouterState)? builder,
});

// Create shell route
ShellRoute shell = SearchRouteConfig.createSearchShellRoute({
  required Widget Function(BuildContext, GoRouterState, Widget) builder,
  List<RouteBase>? routes,
});

// Navigate to search
SearchRouteConfig.navigateToSearch(context, query: 'flutter');

// Show search modal
SearchRouteConfig.showSearchModal(context, delegate);
```

**Extension:**

```dart
// On BuildContext
context.goToSearch(query: 'flutter');
```

## Localization

### SearchLocalizations

Provides localized strings.

**Methods:**

- `SearchLocalizations.of(context)` - Get instance
- `searchHint` - Search field hint
- `clearSearch` - Clear button tooltip
- `back` - Back button tooltip
- `noResults` - No results message
- `tryDifferentKeywords` - Suggestion message
- `startTyping` - Start typing prompt
- `fillSearchField` - Fill field tooltip
- `errorMessage(String)` - Error message format
- `resultsCount(int)` - Results count format
- `recentSearches` - Recent searches label
- `clearHistory` - Clear history label

### SearchLocalizationsDelegate

Delegate for loading localizations.

```dart
MaterialApp(
  localizationsDelegates: const [
    SearchLocalizationsDelegate(),
    // ...
  ],
)
```

## Best Practices

### Performance

1. Use const constructors:

```dart
const SearchResultList(...)
```

2. Implement pagination:

```dart
@override
Future<SearchResult> search(String query, {int limit = 20, int offset = 0}) {
  // Implement pagination
}
```

3. Cache strategically:

```dart
SearchCacheRepository(
  cacheDuration: const Duration(hours: 48), // Adjust based on data volatility
)
```

### Error Handling

```dart
@override
Future<SearchResult> search(String query, {...}) async {
  try {
    // Search logic
  } catch (e) {
    throw SearchException('Failed to search: $e');
  }
}
```

### Custom Providers

```dart
class ApiSearchProvider extends SearchProvider {
  ApiSearchProvider(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<SearchResult> search(String query, {...}) async {
    final response = await apiClient.search(query);
    // Transform to SearchResult
  }
}
```

### Testing

```dart
test('search returns results', () async {
  final provider = InMemorySearchProvider(testItems);
  final result = await provider.search('test');
  expect(result.items, isNotEmpty);
});
```
