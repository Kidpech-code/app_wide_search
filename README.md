# App-Wide Search

A high-performance Flutter package for implementing app-wide search with grouped results, offline caching, and deep-link support.

[![pub package](https://img.shields.io/pub/v/app_wide_search.svg)](https://pub.dev/packages/app_wide_search)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

✨ **Flexible Search Interfaces**

- Customizable `SearchDelegate` for modal search
- Full-screen search with `SearchScreen`
- Support for both approaches in the same app

🎯 **Grouped Results**

- Organize results by category using `ExpansionTile`
- Customizable group icons, colors, and priorities
- Smooth expand/collapse animations

💾 **Offline Support**

- Automatic result caching with Hive
- Search history management
- Configurable cache duration

🚀 **High Performance**

- Efficient state management with Riverpod
- AutoDispose providers for automatic cleanup
- Const constructors to minimize rebuilds
- Optimized build methods following Flutter best practices

🌐 **Deep-Link Support**

- Full integration with go_router
- Support for query parameters in URLs
- Navigate to search with pre-filled queries

🌍 **Internationalization**

- Built-in support for multiple languages using intl
- Easy to add custom translations
- Localized UI strings

🎨 **Highly Customizable**

- Override default UI components
- Provide custom search providers
- Custom item builders and layouts

📱 **Cross-Platform**

- Supports Android, iOS, Web, macOS, Windows, and Linux
- Consistent behavior across all platforms

## Getting Started

### Installation

Add `app_wide_search` to your `pubspec.yaml`:

```yaml
dependencies:
  app_wide_search: ^0.1.0
  flutter_riverpod: ^2.5.1
  hive_flutter: ^1.1.0
  go_router: ^14.0.2
```

Then run:

```bash
flutter pub get
```

### Basic Setup

1. **Initialize Hive and register adapters:**

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_wide_search/app_wide_search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Note: Run build_runner to generate Hive adapters
  // flutter pub run build_runner build

  runApp(const MyApp());
}
```

2. **Provide your search implementation:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // ... Hive initialization ...

  runApp(
    ProviderScope(
      overrides: [
        searchProviderProvider.overrideWithValue(
          InMemorySearchProvider(mySearchableItems),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

3. **Add search to your app:**

```dart
// Option 1: Using SearchDelegate
IconButton(
  icon: const Icon(Icons.search),
  onPressed: () async {
    final result = await showSearch(
      context: context,
      delegate: AppWideSearchDelegate(ref: ref),
    );
    // Handle result...
  },
)

// Option 2: Using go_router for full-screen search
TextButton(
  onPressed: () => context.goToSearch(),
  child: const Text('Search'),
)
```

## Usage Examples

### Creating Search Items

```dart
final searchItems = [
  SearchItem(
    id: '1',
    title: 'Flutter Tutorial',
    subtitle: 'Learn Flutter basics',
    groupId: 'tutorials',
    description: 'A comprehensive guide to Flutter development',
    route: '/tutorials/1',
    imageUrl: 'https://example.com/flutter.png',
  ),
  SearchItem(
    id: '2',
    title: 'Riverpod Guide',
    subtitle: 'State management',
    groupId: 'tutorials',
    description: 'Master Riverpod 3.0',
    route: '/tutorials/2',
  ),
];
```

### Custom Search Provider

Implement `SearchProvider` to integrate with your data source:

```dart
class MySearchProvider extends SearchProvider {
  MySearchProvider(this.database);

  final Database database;

  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final results = await database.query(
      'items',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: limit,
      offset: offset,
    );

    final items = results.map((row) => SearchItem(
      id: row['id'] as String,
      title: row['title'] as String,
      subtitle: row['subtitle'] as String,
      groupId: row['category'] as String,
    )).toList();

    return SearchResult(
      query: query,
      items: items,
      totalCount: items.length,
    );
  }

  @override
  Future<List<SearchItem>> getSuggestions(String query) async {
    // Return autocomplete suggestions
    final results = await database.query(
      'items',
      where: 'title LIKE ?',
      whereArgs: ['$query%'],
      limit: 5,
    );

    return results.map((row) => SearchItem(
      id: row['id'] as String,
      title: row['title'] as String,
      subtitle: '',
      groupId: 'suggestions',
    )).toList();
  }
}
```

### Customizing Grouped Results

```dart
// Define custom groups with icons and colors
final groups = {
  'products': SearchGroup(
    id: 'products',
    name: 'Products',
    icon: Icons.shopping_bag.codePoint,
    color: Colors.blue.value,
    priority: 100,
  ),
  'documents': SearchGroup(
    id: 'documents',
    name: 'Documents',
    icon: Icons.description.codePoint,
    color: Colors.green.value,
    priority: 90,
  ),
};

// Use in SearchDelegate
AppWideSearchDelegate(
  ref: ref,
  resultBuilder: (context, result) {
    return GroupedSearchResults(
      result: result,
      groups: groups,
      initiallyExpanded: true,
      onItemTap: (item) {
        // Handle tap
      },
    );
  },
)
```

### Deep-Link Integration

```dart
import 'package:go_router/go_router.dart';
import 'package:app_wide_search/app_wide_search.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Add search route with deep-link support
    SearchRouteConfig.createSearchRoute(),
  ],
);

// Navigate with pre-filled query
context.goToSearch(query: 'flutter');

// Or use URL: myapp://search?q=flutter
```

### Custom Item Builder

```dart
SearchResultList(
  result: searchResult,
  onItemTap: (item) {
    print('Tapped: ${item.title}');
  },
  itemBuilder: (context, item) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(item.title[0]),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subtitle),
            if (item.description != null)
              Text(
                item.description!,
                style: TextStyle(fontSize: 12),
                maxLines: 2,
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  },
)
```

## Advanced Features

### Search History

The package automatically maintains search history:

```dart
// Access recent searches
final recentSearches = ref.watch(recentSearchesProvider);

// Clear history
final clearHistory = ref.read(clearSearchHistoryProvider);
clearHistory();
```

### Cache Management

Control search result caching:

```dart
// Clear cache
final clearCache = ref.read(clearSearchCacheProvider);
clearCache();

// Configure cache duration
SearchCacheRepository(
  boxName: 'search_cache',
  cacheDuration: const Duration(hours: 48),
)
```

### Localization

Add custom translations:

```dart
MaterialApp(
  localizationsDelegates: const [
    SearchLocalizationsDelegate(),
    // Your other delegates...
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('th'),
  ],
  // ...
)
```

## Performance Tips

1. **Use const constructors** wherever possible
2. **Implement proper pagination** in your search provider
3. **Set appropriate cache duration** based on data volatility
4. **Use AutoDispose providers** to free resources
5. **Keep build methods lean** - avoid expensive operations

## Architecture

This package follows Flutter best practices:

- **Separation of concerns**: Models, repositories, providers, and UI are clearly separated
- **Dependency injection**: Uses Riverpod for clean dependency management
- **Offline-first**: Caching with Hive for offline support
- **Testability**: All components are easily testable
- **Performance**: Optimized for minimal rebuilds and efficient memory usage

## API Reference

### Core Classes

- **`SearchItem`**: Represents a searchable item
- **`SearchGroup`**: Defines a group/category of items
- **`SearchResult`**: Contains search results and metadata
- **`SearchProvider`**: Abstract class for custom search implementations

### UI Widgets

- **`AppWideSearchDelegate`**: Customizable SearchDelegate
- **`SearchScreen`**: Full-screen search interface
- **`SearchResultList`**: Displays search results
- **`GroupedSearchResults`**: Displays grouped results with ExpansionTile

### Providers

- **`searchProviderProvider`**: Your SearchProvider implementation
- **`searchQueryProvider`**: Current search query
- **`searchResultsProvider`**: Search results
- **`searchSuggestionsProvider`**: Search suggestions
- **`recentSearchesProvider`**: Recent search history

### Repositories

- **`SearchHistoryRepository`**: Manages search history with Hive
- **`SearchCacheRepository`**: Caches search results with Hive

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, feature requests, or questions, please file an issue on [GitHub](https://github.com/kidpech/app_wide_search/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
