import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_item.dart';
import '../models/search_result.dart';
import '../providers/search_providers.dart';
import '../widgets/search_result_list.dart';
import '../l10n/search_localizations.dart';

/// A customizable search delegate that integrates with Riverpod.
///
/// This delegate provides a complete search experience with suggestions,
/// results, and history management. It can be customized by overriding
/// various builder methods.
class AppWideSearchDelegate extends SearchDelegate<SearchItem?> {
  /// Creates an app-wide search delegate.
  AppWideSearchDelegate({
    required this.ref,
    this.hintText,
    this.resultBuilder,
    this.suggestionBuilder,
    this.emptyBuilder,
  });

  /// Reference to the Riverpod ProviderContainer.
  final WidgetRef ref;

  /// Custom hint text for the search field.
  final String? hintText;

  /// Custom builder for search results.
  final Widget Function(BuildContext, SearchResult)? resultBuilder;

  /// Custom builder for suggestions.
  final Widget Function(BuildContext, List<String>)? suggestionBuilder;

  /// Custom builder for empty state.
  final Widget Function(BuildContext, String)? emptyBuilder;

  @override
  String? get searchFieldLabel =>
      hintText ?? SearchLocalizations.of(ref.context).searchHint;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: SearchLocalizations.of(context).clearSearch,
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: SearchLocalizations.of(context).back,
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Update the query in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = query;
    });

    return Consumer(
      builder: (context, ref, _) {
        final resultsAsync = ref.watch(searchResultsProvider);

        return resultsAsync.when(
          data: (result) {
            if (result.isEmpty) {
              return emptyBuilder?.call(context, query) ??
                  _buildDefaultEmpty(context);
            }

            return resultBuilder?.call(context, result) ??
                SearchResultList(
                  result: result,
                  onItemTap: (item) {
                    close(context, item);
                    _handleItemSelection(item);
                  },
                );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              SearchLocalizations.of(context).errorMessage(error.toString()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final suggestionsAsync = ref.watch(searchSuggestionsProvider(query));

        return suggestionsAsync.when(
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return _buildNoSuggestions(context);
            }

            return suggestionBuilder?.call(context, suggestions) ??
                _buildDefaultSuggestions(context, suggestions);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              SearchLocalizations.of(context).errorMessage(error.toString()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultSuggestions(
    BuildContext context,
    List<String> suggestions,
  ) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestion),
          trailing: IconButton(
            icon: const Icon(Icons.north_west),
            tooltip: SearchLocalizations.of(context).fillSearchField,
            onPressed: () {
              query = suggestion;
            },
          ),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildNoSuggestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            SearchLocalizations.of(context).startTyping,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            SearchLocalizations.of(context).noResults,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            SearchLocalizations.of(context).tryDifferentKeywords,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _handleItemSelection(SearchItem item) {
    final searchProvider = ref.read(searchProviderProvider);
    searchProvider.onItemSelected(item);
  }
}
