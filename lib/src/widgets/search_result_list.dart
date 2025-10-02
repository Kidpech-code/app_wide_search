import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../models/search_item.dart';
import 'grouped_search_results.dart';

/// Displays search results in a list format.
///
/// This widget renders search results using either a flat list or grouped
/// format depending on configuration. It provides callbacks for item
/// interactions and can be customized with custom item builders.
class SearchResultList extends StatelessWidget {
  /// Creates a search result list.
  const SearchResultList({
    required this.result,
    required this.onItemTap,
    this.showGrouped = true,
    this.itemBuilder,
    super.key,
  });

  /// The search result to display.
  final SearchResult result;

  /// Callback when an item is tapped.
  final void Function(SearchItem) onItemTap;

  /// Whether to display results grouped by category.
  final bool showGrouped;

  /// Custom builder for individual items.
  final Widget Function(BuildContext, SearchItem)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (showGrouped) {
      return GroupedSearchResults(
        result: result,
        onItemTap: onItemTap,
        itemBuilder: itemBuilder,
      );
    }

    return ListView.builder(
      itemCount: result.items.length,
      itemBuilder: (context, index) {
        final item = result.items[index];
        return itemBuilder?.call(context, item) ??
            _buildDefaultItem(context, item);
      },
    );
  }

  Widget _buildDefaultItem(BuildContext context, SearchItem item) {
    return ListTile(
      leading: item.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
          : const CircleAvatar(child: Icon(Icons.search)),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      onTap: () => onItemTap(item),
    );
  }
}
