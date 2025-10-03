import 'package:app_wide_search/app_wide_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Entry point for the app_wide_search quickstart example.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SearchItemAdapter());
  Hive.registerAdapter(SearchGroupAdapter());
  Hive.registerAdapter(SearchHistoryItemAdapter());

  runApp(
    ProviderScope(
      overrides: [
        searchProviderProvider.overrideWithValue(
          InMemorySearchProvider(_demoItems),
        ),
      ],
      child: const SearchExampleApp(),
    ),
  );
}

/// Root widget that configures the demo MaterialApp.
class SearchExampleApp extends StatelessWidget {
  /// Creates the example application shell.
  const SearchExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app_wide_search — quickstart',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const _HomePage(),
    );
  }
}

/// Demonstrates launching the search flow from a button.
class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('App-wide search quickstart')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('Open search'),
          onPressed: () => _showSearch(context, ref),
        ),
      ),
    );
  }

  Future<void> _showSearch(BuildContext context, WidgetRef ref) async {
    late final AppWideSearchDelegate delegate;

    Widget buildSuggestions(BuildContext context, List<String> suggestions) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(suggestion),
            onTap: () {
              delegate.query = suggestion;
              delegate.showResults(context);
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      );
    }

    Widget buildResults(BuildContext context, SearchResult result) {
      final items = result.items;
      if (items.isEmpty) {
        return const Center(child: Text('Try another keyword'));
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final groupLabel = _groupLabels[item.groupId] ?? 'All';
          final initials = item.title.isNotEmpty
              ? item.title.substring(0, 1).toUpperCase()
              : '?';

          return ListTile(
            leading: CircleAvatar(child: Text(initials)),
            title: Text(item.title),
            subtitle: Text('${item.subtitle} · $groupLabel'),
            onTap: () {
              delegate.close(context, item);
              ref.read(searchProviderProvider).onItemSelected(item);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Selected ${item.title}')));
            },
          );
        },
      );
    }

    delegate = AppWideSearchDelegate(
      ref: ref,
      hintText: 'Search demo content…',
      suggestionBuilder: buildSuggestions,
      resultBuilder: buildResults,
    );

    await showSearch<SearchItem?>(context: context, delegate: delegate);
  }
}

final Map<String, String> _groupLabels = {
  'productivity': 'Productivity',
  'communication': 'Communication',
  'shortcuts': 'Shortcuts',
};

final List<SearchItem> _demoItems = [
  SearchItem(
    id: 'calendar',
    title: 'Calendar',
    subtitle: 'Jump to upcoming events',
    groupId: 'productivity',
    description: 'Open the shared calendar and review scheduling conflicts.',
  ),
  SearchItem(
    id: 'tasks',
    title: 'My Tasks',
    subtitle: 'Review open action items',
    groupId: 'productivity',
    description: 'Sort and filter outstanding tasks by priority.',
  ),
  SearchItem(
    id: 'inbox',
    title: 'Inbox',
    subtitle: 'Check unread messages',
    groupId: 'communication',
    description: 'Open the message center with unread filters applied.',
  ),
  SearchItem(
    id: 'compose',
    title: 'Compose message',
    subtitle: 'Send a new direct message',
    groupId: 'communication',
  ),
  SearchItem(
    id: 'new-document',
    title: 'Create document',
    subtitle: 'Start with a collaborative doc template',
    groupId: 'shortcuts',
  ),
];
