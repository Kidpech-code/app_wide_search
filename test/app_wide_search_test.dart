import 'package:flutter_test/flutter_test.dart';
import 'package:app_wide_search/app_wide_search.dart';

void main() {
  group('SearchItem', () {
    test('creates a search item with required fields', () {
      final item = SearchItem(
        id: '1',
        title: 'Test Item',
        subtitle: 'Test Subtitle',
        groupId: 'test',
      );

      expect(item.id, '1');
      expect(item.title, 'Test Item');
      expect(item.subtitle, 'Test Subtitle');
      expect(item.groupId, 'test');
    });

    test('supports optional fields', () {
      final item = SearchItem(
        id: '1',
        title: 'Test',
        subtitle: 'Subtitle',
        groupId: 'test',
        description: 'Description',
        imageUrl: 'https://example.com/image.png',
        route: '/details/1',
        metadata: {'key': 'value'},
      );

      expect(item.description, 'Description');
      expect(item.imageUrl, 'https://example.com/image.png');
      expect(item.route, '/details/1');
      expect(item.metadata, {'key': 'value'});
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = SearchItem(
        id: '1',
        title: 'Original',
        subtitle: 'Subtitle',
        groupId: 'test',
      );

      final copy = original.copyWith(title: 'Updated');

      expect(copy.id, original.id);
      expect(copy.title, 'Updated');
      expect(copy.subtitle, original.subtitle);
    });

    test('equality is based on id', () {
      final item1 = SearchItem(
        id: '1',
        title: 'Item 1',
        subtitle: 'Subtitle',
        groupId: 'test',
      );

      final item2 = SearchItem(
        id: '1',
        title: 'Different Title',
        subtitle: 'Subtitle',
        groupId: 'test',
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });
  });

  group('SearchGroup', () {
    test('creates a search group with required fields', () {
      final group = SearchGroup(id: 'test', name: 'Test Group');

      expect(group.id, 'test');
      expect(group.name, 'Test Group');
      expect(group.priority, 0);
    });

    test('supports custom priority', () {
      final group = SearchGroup(id: 'test', name: 'Test Group', priority: 100);

      expect(group.priority, 100);
    });
  });

  group('SearchResult', () {
    test('creates a search result', () {
      final items = [
        SearchItem(
          id: '1',
          title: 'Item 1',
          subtitle: 'Subtitle',
          groupId: 'group1',
        ),
        SearchItem(
          id: '2',
          title: 'Item 2',
          subtitle: 'Subtitle',
          groupId: 'group2',
        ),
      ];

      final result = SearchResult(query: 'test', items: items, totalCount: 2);

      expect(result.query, 'test');
      expect(result.items.length, 2);
      expect(result.totalCount, 2);
      expect(result.isNotEmpty, true);
    });

    test('groups items by groupId', () {
      final items = [
        SearchItem(
          id: '1',
          title: 'Item 1',
          subtitle: 'Subtitle',
          groupId: 'group1',
        ),
        SearchItem(
          id: '2',
          title: 'Item 2',
          subtitle: 'Subtitle',
          groupId: 'group1',
        ),
        SearchItem(
          id: '3',
          title: 'Item 3',
          subtitle: 'Subtitle',
          groupId: 'group2',
        ),
      ];

      final result = SearchResult(query: 'test', items: items);

      final grouped = result.groupedItems;

      expect(grouped.keys.length, 2);
      expect(grouped['group1']?.length, 2);
      expect(grouped['group2']?.length, 1);
    });

    test('creates empty result', () {
      final result = SearchResult.empty('test');

      expect(result.query, 'test');
      expect(result.items, isEmpty);
      expect(result.totalCount, 0);
      expect(result.isEmpty, true);
    });
  });

  group('InMemorySearchProvider', () {
    late List<SearchItem> testItems;
    late InMemorySearchProvider provider;

    setUp(() {
      testItems = [
        SearchItem(
          id: '1',
          title: 'Flutter Tutorial',
          subtitle: 'Learn Flutter',
          groupId: 'tutorials',
          description: 'A comprehensive guide to Flutter development',
        ),
        SearchItem(
          id: '2',
          title: 'Dart Basics',
          subtitle: 'Learn Dart',
          groupId: 'tutorials',
          description: 'Introduction to Dart programming',
        ),
        SearchItem(
          id: '3',
          title: 'iPhone 15',
          subtitle: 'Apple smartphone',
          groupId: 'products',
        ),
      ];

      provider = InMemorySearchProvider(testItems);
    });

    test('returns empty result for empty query', () async {
      final result = await provider.search('');

      expect(result.isEmpty, true);
      expect(result.query, '');
    });

    test('performs case-insensitive substring search', () async {
      final result = await provider.search('flutter');

      expect(result.items.length, 1);
      expect(result.items.first.title, 'Flutter Tutorial');
    });

    test('searches in title, subtitle, and description', () async {
      final result = await provider.search('learn');

      expect(result.items.length, 2);
    });

    test('returns search metadata', () async {
      final result = await provider.search('tutorial');

      expect(result.query, 'tutorial');
      expect(result.totalCount, isNotNull);
      expect(result.executionTimeMs, isNotNull);
    });

    test('supports pagination', () async {
      final result = await provider.search('tutorial', limit: 1, offset: 0);

      expect(result.items.length, 1);
      expect(result.hasMore, false);
    });

    test('provides suggestions for partial queries', () async {
      final suggestions = await provider.getSuggestions('fl');

      expect(suggestions.isNotEmpty, true);
      expect(suggestions.any((item) => item.title.startsWith('Fl')), true);
    });

    test('limits suggestions to 5 items', () async {
      final manyItems = List.generate(
        10,
        (i) => SearchItem(
          id: '$i',
          title: 'Flutter $i',
          subtitle: 'Item',
          groupId: 'test',
        ),
      );

      final largeProvider = InMemorySearchProvider(manyItems);
      final suggestions = await largeProvider.getSuggestions('flutter');

      expect(suggestions.length, lessThanOrEqualTo(5));
    });
  });

  group('SearchHistoryRepository', () {
    test('initializes with correct configuration', () {
      final repository = SearchHistoryRepository(
        boxName: 'test_history',
        maxHistoryItems: 10,
      );

      expect(repository.boxName, 'test_history');
      expect(repository.maxHistoryItems, 10);
    });
  });

  group('SearchCacheRepository', () {
    test('initializes with correct configuration', () {
      final repository = SearchCacheRepository(
        boxName: 'test_cache',
        cacheDuration: const Duration(hours: 12),
      );

      expect(repository.boxName, 'test_cache');
      expect(repository.cacheDuration, const Duration(hours: 12));
    });
  });
}
