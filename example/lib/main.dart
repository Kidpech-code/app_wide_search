import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:app_wide_search/app_wide_search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Note: In production, you would run build_runner to generate adapters
  // For this example, we're using the models without persistence to Hive boxes

  runApp(
    ProviderScope(
      overrides: [
        // Provide a custom search provider with sample data
        searchProviderProvider.overrideWithValue(InMemorySearchProvider(_getSampleData())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App-Wide Search Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      routerConfig: _createRouter(),
      localizationsDelegates: const [SearchLocalizationsDelegate()],
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        // Add search route with deep-link support
        SearchRouteConfig.createSearchRoute(),
        GoRoute(
          path: '/details/:id',
          builder: (context, state) => DetailsScreen(id: state.pathParameters['id']!),
        ),
      ],
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App-Wide Search Demo'),
        actions: [
          // Search button in app bar
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              // Show search delegate
              showSearch(
                context: context,
                delegate: AppWideSearchDelegate(ref: ref),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 32),
              Text('Welcome to App-Wide Search', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('Try searching for products, documents, or contacts', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 48),

              // Example 1: SearchDelegate
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showSearch(
                    context: context,
                    delegate: AppWideSearchDelegate(ref: ref),
                  );
                  if (result != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: ${result.title}')));
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Open Search (Modal)'),
              ),

              const SizedBox(height: 16),

              // Example 2: Full-screen search with go_router
              ElevatedButton.icon(
                onPressed: () {
                  context.goToSearch();
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Search (Full Screen)'),
              ),

              const SizedBox(height: 16),

              // Example 3: Search with pre-filled query
              OutlinedButton.icon(
                onPressed: () {
                  context.goToSearch(query: 'laptop');
                },
                icon: const Icon(Icons.link),
                label: const Text('Search "laptop" (Deep Link)'),
              ),

              const SizedBox(height: 32),

              // Sample data info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, size: 32),
                      const SizedBox(height: 8),
                      Text('Sample Data Included', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      const Text(
                        'This demo includes products, documents, and contacts. '
                        'Try searching for: iPhone, Flutter, laptop, or John.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: Center(child: Text('Details for item: $id')),
    );
  }
}

// Sample data generator
List<SearchItem> _getSampleData() {
  return [
    // Products
    SearchItem(
      id: '1',
      title: 'iPhone 15 Pro',
      subtitle: 'Latest Apple smartphone',
      groupId: 'products',
      description: 'A17 Pro chip, titanium design, and advanced camera system',
      route: '/details/1',
    ),
    SearchItem(
      id: '2',
      title: 'MacBook Pro M3',
      subtitle: 'Professional laptop',
      groupId: 'products',
      description: 'Powerful performance for developers and creatives',
      route: '/details/2',
    ),
    SearchItem(
      id: '3',
      title: 'iPad Air',
      subtitle: 'Versatile tablet',
      groupId: 'products',
      description: 'Perfect for creativity and productivity',
      route: '/details/3',
    ),
    SearchItem(
      id: '4',
      title: 'Dell XPS 15',
      subtitle: 'Windows laptop',
      groupId: 'products',
      description: 'High-performance laptop for professionals',
      route: '/details/4',
    ),

    // Documents
    SearchItem(
      id: '5',
      title: 'Flutter Best Practices',
      subtitle: 'Development guide',
      groupId: 'documents',
      description: 'Guidelines for building high-quality Flutter apps',
      route: '/details/5',
    ),
    SearchItem(
      id: '6',
      title: 'Riverpod Tutorial',
      subtitle: 'State management',
      groupId: 'documents',
      description: 'Complete guide to Riverpod 3.0 features',
      route: '/details/6',
    ),
    SearchItem(
      id: '7',
      title: 'Go Router Documentation',
      subtitle: 'Routing guide',
      groupId: 'documents',
      description: 'Deep-linking and navigation patterns',
      route: '/details/7',
    ),
    SearchItem(
      id: '8',
      title: 'Hive Database Guide',
      subtitle: 'Storage solution',
      groupId: 'documents',
      description: 'Fast and lightweight local database',
      route: '/details/8',
    ),

    // Contacts
    SearchItem(
      id: '9',
      title: 'John Doe',
      subtitle: 'john.doe@example.com',
      groupId: 'contacts',
      description: 'Software Engineer at Tech Corp',
      route: '/details/9',
    ),
    SearchItem(
      id: '10',
      title: 'Jane Smith',
      subtitle: 'jane.smith@example.com',
      groupId: 'contacts',
      description: 'Product Manager at Innovation Labs',
      route: '/details/10',
    ),
    SearchItem(
      id: '11',
      title: 'Bob Johnson',
      subtitle: 'bob.j@example.com',
      groupId: 'contacts',
      description: 'UX Designer at Creative Studio',
      route: '/details/11',
    ),

    // Settings
    SearchItem(
      id: '12',
      title: 'Privacy Settings',
      subtitle: 'Manage your privacy',
      groupId: 'settings',
      description: 'Control who can see your information',
      route: '/details/12',
    ),
    SearchItem(
      id: '13',
      title: 'Notification Preferences',
      subtitle: 'Customize notifications',
      groupId: 'settings',
      description: 'Choose what notifications you receive',
      route: '/details/13',
    ),
    SearchItem(
      id: '14',
      title: 'Account Settings',
      subtitle: 'Update your account',
      groupId: 'settings',
      description: 'Change email, password, and profile info',
      route: '/details/14',
    ),
  ];
}
