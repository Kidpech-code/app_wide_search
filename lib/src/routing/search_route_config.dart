import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/search_item.dart';
import '../ui/app_wide_search_delegate.dart';
import '../ui/search_screen.dart';

/// Configuration for search routes with go_router.
///
/// This class provides pre-configured routes that can be integrated into your
/// app's router. It supports both modal search (using SearchDelegate) and
/// full-screen search with deep-link support.
class SearchRouteConfig {
  /// Path for the search screen.
  static const String searchPath = '/search';

  /// Query parameter name for search query.
  static const String queryParam = 'q';

  /// Creates a GoRoute for the search screen.
  ///
  /// This route supports deep-linking with query parameters. For example:
  /// `/search?q=flutter` will open the search screen with "flutter" pre-filled.
  static GoRoute createSearchRoute({String? path, Widget Function(BuildContext, GoRouterState)? builder}) {
    return GoRoute(path: path ?? searchPath, builder: builder ?? _defaultSearchBuilder);
  }

  /// Creates a ShellRoute for search with a persistent navigation bar.
  ///
  /// This is useful for apps with bottom navigation where search should be
  /// one of the main tabs.
  static ShellRoute createSearchShellRoute({required Widget Function(BuildContext, GoRouterState, Widget) builder, List<RouteBase>? routes}) {
    return ShellRoute(builder: builder, routes: routes ?? [createSearchRoute()]);
  }

  static Widget _defaultSearchBuilder(BuildContext context, GoRouterState state) {
    final query = state.uri.queryParameters[queryParam];
    return SearchScreen(initialQuery: query);
  }

  /// Navigates to the search screen using go_router.
  ///
  /// If [query] is provided, it will be pre-filled in the search field.
  static void navigateToSearch(BuildContext context, {String? query}) {
    if (query != null && query.isNotEmpty) {
      context.go('$searchPath?$queryParam=${Uri.encodeComponent(query)}');
    } else {
      context.go(searchPath);
    }
  }

  /// Shows the search delegate as a modal.
  ///
  /// This is an alternative to navigating to a full search screen. It shows
  /// the search interface as an overlay.
  static Future<SearchItem?> showSearchModal(BuildContext context, AppWideSearchDelegate delegate) {
    return showSearch<SearchItem?>(context: context, delegate: delegate);
  }
}

/// Extension on BuildContext for convenient search navigation.
extension SearchNavigation on BuildContext {
  /// Navigates to the search screen.
  void goToSearch({String? query}) {
    SearchRouteConfig.navigateToSearch(this, query: query);
  }
}
