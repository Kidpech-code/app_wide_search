import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_providers.dart';
import '../widgets/search_result_list.dart';
import '../l10n/search_localizations.dart';

/// A full-screen search interface.
///
/// This widget provides a complete search experience on a dedicated screen,
/// as an alternative to using SearchDelegate. It's useful when you want more
/// control over the search UI or want to integrate search with go_router.
///
/// Performance features:
/// - Debounced search (300ms) to reduce unnecessary queries
/// - Minimal rebuilds using ValueNotifier for clear button visibility
/// - Automatic search-as-you-type (configurable via [searchOnChange])
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates a search screen.
  const SearchScreen({
    this.initialQuery,
    this.customResultBuilder,
    this.searchOnChange = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    super.key,
  });

  /// Initial query to pre-fill in the search field.
  final String? initialQuery;

  /// Custom builder for search results.
  final Widget Function(BuildContext, WidgetRef)? customResultBuilder;

  /// Whether to search automatically as the user types.
  /// If false, search only occurs when user presses enter or search button.
  /// Defaults to true.
  final bool searchOnChange;

  /// The debounce duration for search-as-you-type.
  /// Only applies when [searchOnChange] is true.
  /// Defaults to 300ms.
  final Duration debounceDuration;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late ValueNotifier<bool> _showClearButton;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _showClearButton = ValueNotifier<bool>(
      widget.initialQuery?.isNotEmpty ?? false,
    );
    if (widget.initialQuery != null) {
      // Trigger search with initial query
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery!;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _showClearButton.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _showClearButton.value = value.isNotEmpty;

    if (!widget.searchOnChange) return;

    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (value.trim().isNotEmpty) {
        ref.read(searchQueryProvider.notifier).state = value;
      } else {
        ref.read(searchQueryProvider.notifier).state = '';
      }
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _searchController.clear();
    _showClearButton.value = false;
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: widget.initialQuery == null,
          decoration: InputDecoration(
            hintText: SearchLocalizations.of(context).searchHint,
            border: InputBorder.none,
            suffixIcon: ValueListenableBuilder<bool>(
              valueListenable: _showClearButton,
              builder: (context, showClear, _) {
                return showClear
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmitted,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _onSearchSubmitted(_searchController.text);
            },
          ),
        ],
      ),
      body:
          widget.customResultBuilder?.call(context, ref) ??
          resultsAsync.when(
            data: (result) {
              if (result.isEmpty && _searchController.text.isEmpty) {
                return _buildRecentSearches(context);
              }

              if (result.isEmpty) {
                return _buildEmptyState(context);
              }

              return SearchResultList(
                result: result,
                onItemTap: (item) {
                  if (item.route != null) {
                    // Use go_router's navigation
                    context.go(item.route!);
                  } else if (item.onTap != null) {
                    item.onTap!();
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              final theme = Theme.of(context);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.0,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      SearchLocalizations.of(
                        context,
                      ).errorMessage(error.toString()),
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return recentSearchesAsync.when(
      data: (searches) {
        if (searches.isEmpty) {
          return _buildEmptyHistory(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    SearchLocalizations.of(context).recentSearches,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      final clearHistory = ref.read(clearSearchHistoryProvider);
                      clearHistory();
                    },
                    child: Text(SearchLocalizations.of(context).clearHistory),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searches.length,
                itemBuilder: (context, index) {
                  final query = searches[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(query),
                    trailing: const Icon(Icons.north_west),
                    onTap: () {
                      _searchController.text = query;
                      ref.read(searchQueryProvider.notifier).state = query;
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildEmptyHistory(context),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = theme.disabledColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64.0, color: disabledColor),
          const SizedBox(height: 16.0),
          Text(
            SearchLocalizations.of(context).startTyping,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = theme.disabledColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.0, color: disabledColor),
          const SizedBox(height: 16.0),
          Text(
            SearchLocalizations.of(context).noResults,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          Text(
            SearchLocalizations.of(context).tryDifferentKeywords,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
