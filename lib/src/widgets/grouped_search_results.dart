import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../models/search_item.dart';
import '../models/search_group.dart';

/// Displays search results grouped by category using ExpansionTiles.
///
/// This widget provides an organized view of search results by grouping them
/// into expandable sections. Each group can be customized with icons, colors,
/// and other visual properties.
class GroupedSearchResults extends StatefulWidget {
  /// Creates a grouped search results widget.
  const GroupedSearchResults({
    required this.result,
    required this.onItemTap,
    this.groups,
    this.itemBuilder,
    this.initiallyExpanded = true,
    super.key,
  });

  /// The search result to display.
  final SearchResult result;

  /// Callback when an item is tapped.
  final void Function(SearchItem) onItemTap;

  /// Optional group metadata for customization.
  final Map<String, SearchGroup>? groups;

  /// Custom builder for individual items.
  final Widget Function(BuildContext, SearchItem)? itemBuilder;

  /// Whether groups should be initially expanded.
  final bool initiallyExpanded;

  @override
  State<GroupedSearchResults> createState() => _GroupedSearchResultsState();
}

class _GroupedSearchResultsState extends State<GroupedSearchResults> {
  late Map<String, bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = {};
    for (final groupId in widget.result.groupedItems.keys) {
      _expandedStates[groupId] = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = widget.result.groupedItems;
    final sortedGroupIds = groupedItems.keys.toList()
      ..sort((a, b) {
        final groupA = widget.groups?[a];
        final groupB = widget.groups?[b];
        if (groupA == null || groupB == null) return 0;
        return groupB.priority.compareTo(groupA.priority);
      });

    return ListView.builder(
      itemCount: sortedGroupIds.length,
      itemBuilder: (context, index) {
        final groupId = sortedGroupIds[index];
        final items = groupedItems[groupId]!;
        final group = widget.groups?[groupId];

        return _buildGroupSection(context, groupId, items, group);
      },
    );
  }

  Widget _buildGroupSection(
    BuildContext context,
    String groupId,
    List<SearchItem> items,
    SearchGroup? group,
  ) {
    final theme = Theme.of(context);
    final groupColor = group?.color != null
        ? Color(group!.color!)
        : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        key: PageStorageKey<String>(groupId),
        initiallyExpanded: _expandedStates[groupId] ?? true,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedStates[groupId] = expanded;
          });
        },
        leading: group?.icon != null
            ? Icon(IconData(group!.icon!, fontFamily: 'MaterialIcons'))
            : Icon(Icons.folder, color: groupColor),
        title: Text(
          group?.name ?? groupId,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${items.length} ${items.length == 1 ? 'item' : 'items'}',
          style: theme.textTheme.bodySmall,
        ),
        children: items.map((item) {
          return widget.itemBuilder?.call(context, item) ??
              _buildDefaultItem(context, item);
        }).toList(),
      ),
    );
  }

  Widget _buildDefaultItem(BuildContext context, SearchItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: item.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!))
          : const CircleAvatar(child: Icon(Icons.description)),
      title: Text(item.title),
      subtitle: Text(
        item.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => widget.onItemTap(item),
    );
  }
}
