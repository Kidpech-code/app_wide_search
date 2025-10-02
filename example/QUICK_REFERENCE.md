# Quick Reference: Examples for app_wide_search

**🎯 Goal:** Help you find the right example fast

---

## 🆘 I Need To...

### Get Started (< 5 minutes)

→ **Use current [example/](../example/)** - Comprehensive working app

```bash
cd example && flutter run
```

**Shows:** SearchDelegate, full-screen search, routing, history, cache

---

### Add Basic Search

```dart
// Minimal code - copy/paste ready
import 'package:app_wide_search/app_wide_search.dart';

// 1. Create items
final items = [
  SearchItem(id: '1', title: 'Apple', subtitle: 'Fruit', groupId: 'food'),
  SearchItem(id: '2', title: 'Banana', subtitle: 'Fruit', groupId: 'food'),
];

// 2. Create provider
final provider = InMemorySearchProvider(items);

// 3. Show search
showSearch(
  context: context,
  delegate: AppWideSearchDelegate(searchProvider: provider),
);
```

---

### Search My API

```dart
class MyApiProvider extends SearchProvider {
  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
    CancellationToken? cancellationToken,
  }) async {
    // Check cancellation before expensive work
    cancellationToken?.throwIfCancelled();

    final response = await http.get(
      Uri.parse('https://api.example.com/search?q=$query&limit=$limit'),
    );

    // Check again after network call
    cancellationToken?.throwIfCancelled();

    final json = jsonDecode(response.body);
    return SearchResult(
      query: query,
      items: (json['items'] as List)
          .map((item) => SearchItem.fromJson(item))
          .toList(),
      totalCount: json['total'],
      hasMore: json['has_more'],
    );
  }
}
```

---

### Add URL Deep-Linking

```dart
// go_router setup
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchScreen(initialQuery: query);
      },
    ),
  ],
);

// Navigate with query
context.go('/search?q=flutter');

// URL: https://myapp.com/search?q=flutter
```

---

### Cache Results (Offline Support)

```dart
// Initialize cache
final cache = SearchCacheRepository(
  boxName: 'search_cache',
  cacheDuration: Duration(hours: 24),
  maxEntries: 50,
);
await cache.initialize();

// Cache results
await cache.cacheResult(searchResult);

// Retrieve cached
final cached = cache.getCachedResult(query);
if (cached != null) {
  // Use cached data
  return cached;
}

// Fall back to API
final fresh = await apiProvider.search(query);
await cache.cacheResult(fresh);
return fresh;
```

---

### Customize UI

```dart
SearchScreen(
  customResultBuilder: (context, ref) {
    final results = ref.watch(searchResultsProvider);
    return results.when(
      data: (result) => ListView.builder(
        itemCount: result.items.length,
        itemBuilder: (context, index) {
          final item = result.items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(item.title[0])),
              title: Text(item.title, style: TextStyle(fontSize: 18)),
              subtitle: Text(item.subtitle),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => print('Selected: ${item.title}'),
            ),
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  },
)
```

---

### Add Groups/Categories

```dart
// Define groups
final groups = [
  SearchGroup(id: 'products', name: 'Products', priority: 1),
  SearchGroup(id: 'docs', name: 'Documentation', priority: 2),
];

// Create items with groupId
final items = [
  SearchItem(id: '1', title: 'iPhone', groupId: 'products', ...),
  SearchItem(id: '2', title: 'Guide', groupId: 'docs', ...),
];

// Use GroupedSearchResults widget
GroupedSearchResults(
  result: searchResult,
  groups: groups,
  onItemTap: (item) => print('Tapped: ${item.title}'),
)
```

---

### Handle Loading/Empty/Error States

```dart
ref.watch(searchResultsProvider).when(
  // Loading state
  loading: () => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Searching...'),
      ],
    ),
  ),

  // Error state with retry
  error: (error, stack) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text('Error: $error'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Retry search
            ref.invalidate(searchResultsProvider);
          },
          child: Text('Retry'),
        ),
      ],
    ),
  ),

  // Data state
  data: (result) {
    if (result.isEmpty) {
      // Empty state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48),
            SizedBox(height: 16),
            Text('No results found'),
            Text('Try different keywords'),
          ],
        ),
      );
    }

    // Show results
    return SearchResultList(result: result);
  },
)
```

---

### Add Search History

```dart
// Riverpod provider for history
final historyProvider = FutureProvider<List<String>>((ref) async {
  final repo = SearchHistoryRepository(boxName: 'search_history');
  await repo.initialize();
  return repo.getRecentSearches(limit: 10);
});

// Add to history
await historyRepo.addSearch(query);

// Clear history
await historyRepo.clearHistory();

// Show in UI
final history = ref.watch(historyProvider);
history.when(
  data: (queries) => ListView.builder(
    itemCount: queries.length,
    itemBuilder: (context, index) {
      return ListTile(
        leading: Icon(Icons.history),
        title: Text(queries[index]),
        onTap: () {
          // Search again
          ref.read(searchQueryProvider.notifier).state = queries[index];
        },
      );
    },
  ),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => SizedBox.shrink(),
)
```

---

### Optimize Performance

```dart
// 1. Use debouncing (built-in with SearchScreen)
SearchScreen(
  debounceDuration: Duration(milliseconds: 300), // Default
)

// 2. Cancel stale requests
final token = CancellationToken();

try {
  final result = await provider.search(
    query,
    cancellationToken: token,
  );
} catch (e) {
  if (e is CancelledException) {
    // Request was cancelled - this is expected
    return;
  }
  rethrow;
}

// Cancel on new input
token.cancel();

// 3. Use const constructors
const SearchResultList(result: result)

// 4. Limit rebuilds with .select()
final query = ref.watch(
  searchQueryProvider.select((q) => q.trim().toLowerCase()),
);

// 5. Cache provider with autoDispose
@riverpod
FutureOr<SearchResult> searchResults(SearchResultsRef ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return SearchResult.empty(query);

  // Auto-dispose when not needed
  return provider.search(query);
}
```

---

### Run on Multiple Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

---

## 📦 Dependencies

```yaml
dependencies:
  app_wide_search: ^0.2.0
  flutter_riverpod: ^3.0.0 # State management
  go_router: ^16.0.0 # Routing (optional)
  hive_flutter: ^1.1.0 # Caching (optional)
```

---

## 🆘 Troubleshooting

### "No results showing"

- Check that `SearchProvider.search()` returns items
- Verify items have searchable text in title/subtitle/description
- Use `print(result.items.length)` to debug

### "App rebuilds too much"

- Use `.select()` in `ref.watch()`
- Add `const` to widgets
- Use `debounceDuration` for SearchScreen

### "Search is slow"

- Use `CancellationToken` to cancel stale requests
- Add debouncing (default 300ms)
- Cache results with `SearchCacheRepository`
- Profile with Flutter DevTools

### "History not persisting"

- Call `await repo.initialize()` before using
- Check Hive box is opened
- Verify `path_provider` permissions

---

## 📚 More Resources

- **Full Example:** [/example](../example/)
- **API Docs:** [pub.dev/documentation/app_wide_search](https://pub.dev/documentation/app_wide_search/latest/)
- **Source Code:** [GitHub](https://github.com/kidpech-code/app_wide_search)
- **Issues:** [GitHub Issues](https://github.com/kidpech-code/app_wide_search/issues)

---

**Last Updated:** October 2, 2025  
**Package Version:** 0.2.0
