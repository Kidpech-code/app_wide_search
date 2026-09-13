import 'package:app_wide_search/app_wide_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final item = SearchItem(
    id: '1',
    title: 'Product',
    subtitle: 'Details',
    groupId: 'products',
  );
  final result = SearchResult(query: 'Product', items: [item]);
  final groups = {
    'products': SearchGroup(
      id: 'products',
      name: 'Products',
      icon: 123,
      color: 0xFF123456,
    ),
  };

  testWidgets(
    'group icon builder renders custom icons and preserves item taps',
    (tester) async {
      SearchItem? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupedSearchResults(
              result: result,
              groups: groups,
              groupIconBuilder: (context, group) => group.id == 'products'
                  ? const Icon(Icons.shopping_bag)
                  : null,
              onItemTap: (value) => selected = value,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsNothing);
      await tester.tap(find.text('Product'));
      expect(selected, same(item));
    },
  );

  testWidgets('unresolved legacy icons use the group-colored folder fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GroupedSearchResults(
            result: result,
            groups: groups,
            groupIconBuilder: (context, group) => null,
            onItemTap: (_) {},
          ),
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.folder));
    expect(icon.color, const Color(0xFF123456));
  });
}
