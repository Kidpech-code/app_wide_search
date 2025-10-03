/// Quickstart Minimal Example for app_wide_search
///
/// This is the simplest possible implementation showing:
/// - Basic search setup with InMemorySearchProvider
/// - Opening search with a button
/// - Displaying search results
///
/// No routing, no persistence, no advanced features - just pure search.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_wide_search/app_wide_search.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        // Provide sample data for search
        searchProviderProvider.overrideWithValue(
          InMemorySearchProvider(_createSampleData()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quickstart Minimal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quickstart Minimal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Search button - that's all you need!
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AppWideSearchDelegate(ref: ref),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Tap the search icon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for: iPhone, John, or Flutter',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: AppWideSearchDelegate(ref: ref),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Open Search'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Creates sample data for the search provider
List<SearchItem> _createSampleData() {
  return [
    // Products
    SearchItem(
      id: '1',
      title: 'iPhone 15 Pro',
      subtitle: 'Latest Apple smartphone',
      groupId: 'products',
      description: 'A17 Pro chip with titanium design',
    ),
    SearchItem(
      id: '2',
      title: 'MacBook Pro M3',
      subtitle: 'Professional laptop',
      groupId: 'products',
      description: 'Powerful performance for developers',
    ),
    SearchItem(
      id: '3',
      title: 'iPad Air',
      subtitle: 'Versatile tablet',
      groupId: 'products',
      description: 'Perfect for creativity',
    ),

    // Contacts
    SearchItem(
      id: '4',
      title: 'John Doe',
      subtitle: 'john@example.com',
      groupId: 'contacts',
      description: 'Software Engineer',
    ),
    SearchItem(
      id: '5',
      title: 'Jane Smith',
      subtitle: 'jane@example.com',
      groupId: 'contacts',
      description: 'Product Manager',
    ),

    // Docs
    SearchItem(
      id: '6',
      title: 'Flutter Best Practices',
      subtitle: 'Development guide',
      groupId: 'docs',
      description: 'Guidelines for building quality apps',
    ),
    SearchItem(
      id: '7',
      title: 'Riverpod Tutorial',
      subtitle: 'State management',
      groupId: 'docs',
      description: 'Complete guide to Riverpod',
    ),
  ];
}
