## Advanced Example: Custom UI with Grouped Results

This example demonstrates how to create a custom search interface with grouped results.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_wide_search/app_wide_search.dart';

class CustomSearchScreen extends ConsumerWidget {
  const CustomSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      'contacts': SearchGroup(
        id: 'contacts',
        name: 'Contacts',
        icon: Icons.people.codePoint,
        color: Colors.orange.value,
        priority: 80,
      ),
    };

    return SearchScreen(
      customResultBuilder: (context, ref) {
        final resultsAsync = ref.watch(searchResultsProvider);

        return resultsAsync.when(
          data: (result) {
            if (result.isEmpty) {
              return const Center(
                child: Text('No results found'),
              );
            }

            return GroupedSearchResults(
              result: result,
              groups: groups,
              initiallyExpanded: true,
              onItemTap: (item) {
                // Custom tap handler
                print('Tapped: ${item.title}');
              },
              itemBuilder: (context, item) {
                // Custom item builder
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(item.title[0]),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item.subtitle),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        );
      },
    );
  }
}
```

## Custom Search Provider Example

Create your own search provider to integrate with any data source:

```dart
import 'package:app_wide_search/app_wide_search.dart';

class ApiSearchProvider extends SearchProvider {
  ApiSearchProvider(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await apiClient.search(
        query: query,
        limit: limit,
        offset: offset,
      );

      final items = response.results.map((item) {
        return SearchItem(
          id: item.id,
          title: item.title,
          subtitle: item.description,
          groupId: item.category,
          route: '/details/${item.id}',
        );
      }).toList();

      stopwatch.stop();

      return SearchResult(
        query: query,
        items: items,
        totalCount: response.totalCount,
        executionTimeMs: stopwatch.elapsedMilliseconds,
        hasMore: response.hasMore,
        nextPage: response.nextPageToken,
      );
    } catch (e) {
      throw SearchException('Failed to search: $e');
    }
  }

  @override
  Future<List<SearchItem>> getSuggestions(String query) async {
    final response = await apiClient.getSuggestions(query);
    return response.suggestions.map((s) => SearchItem(
      id: s.id,
      title: s.text,
      subtitle: '',
      groupId: 'suggestions',
    )).toList();
  }

  @override
  Future<void> onItemSelected(SearchItem item) async {
    // Track analytics
    await apiClient.trackSearchClick(item.id);
  }
}

// Use it in your app
ProviderScope(
  overrides: [
    searchProviderProvider.overrideWithValue(
      ApiSearchProvider(myApiClient),
    ),
  ],
  child: MyApp(),
)
```

## Deep-Link Integration Example

```dart
import 'package:go_router/go_router.dart';
import 'package:app_wide_search/app_wide_search.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        // Add search to navigation bar
        SearchRouteConfig.createSearchRoute(
          path: '/search',
          builder: (context, state) {
            final query = state.uri.queryParameters['q'];
            return SearchScreen(
              initialQuery: query,
              customResultBuilder: (context, ref) {
                // Custom UI
                return CustomResultsView();
              },
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

// Now you can deep-link to search:
// myapp://search?q=flutter
// https://myapp.com/search?q=flutter
```
