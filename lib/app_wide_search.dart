/// A high-performance Flutter package for app-wide search with grouped results.
///
/// This library provides a complete search solution with:
/// - Customizable SearchDelegate and full-screen search interfaces
/// - Grouped results with ExpansionTile widgets
/// - Offline caching and search history with Hive
/// - State management with Riverpod
/// - Deep-link support with go_router
/// - Internationalization with intl
///
/// ## Usage
///
/// First, initialize Hive and register adapters:
///
/// ```dart
/// import 'package:hive_flutter/hive_flutter.dart';
/// import 'package:app_wide_search/app_wide_search.dart';
///
/// void main() async {
///   await Hive.initFlutter();
///   Hive.registerAdapter(SearchItemAdapter());
///   Hive.registerAdapter(SearchGroupAdapter());
///   Hive.registerAdapter(SearchHistoryItemAdapter());
///   runApp(const MyApp());
/// }
/// ```
///
/// Then, provide your search implementation:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     searchProviderProvider.overrideWithValue(
///       InMemorySearchProvider(mySearchableItems),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// Show the search interface:
///
/// ```dart
/// // Using SearchDelegate
/// final result = await showSearch(
///   context: context,
///   delegate: AppWideSearchDelegate(ref: ref),
/// );
///
/// // Or navigate to full-screen search
/// context.goToSearch();
/// ```
library;

// Models
export 'src/models/search_item.dart';
export 'src/models/search_group.dart';
export 'src/models/search_result.dart';
export 'src/models/search_provider.dart';
export 'src/models/search_history_item.dart';
export 'src/models/cancellation_token.dart';

// Repositories
export 'src/repositories/search_history_repository.dart';
export 'src/repositories/search_cache_repository.dart';

// Providers
export 'src/providers/search_providers.dart';

// UI
export 'src/ui/app_wide_search_delegate.dart';
export 'src/ui/search_screen.dart';

// Widgets
export 'src/widgets/search_result_list.dart';
export 'src/widgets/grouped_search_results.dart';

// Routing
export 'src/routing/search_route_config.dart';

// Localization
export 'src/l10n/search_localizations.dart';
