import 'package:app_wide_search/app_wide_search.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'dart:io';

// Mock PathProvider for testing
class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchCacheRepository', () {
    late SearchCacheRepository repository;
    const testBoxName = 'test_search_cache';

    setUp(() async {
      // Set up mock path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();

      // Initialize Hive
      final tempDir = await getTemporaryDirectory();
      Hive.init(tempDir.path);

      repository = SearchCacheRepository(
        boxName: testBoxName,
        cacheDuration: const Duration(seconds: 2),
        maxEntries: 3, // Small limit for testing
      );
      await repository.initialize();
    });

    tearDown(() async {
      await repository.dispose();
      await Hive.deleteBoxFromDisk(testBoxName);
    });

    test('caches and retrieves search results', () async {
      final result = SearchResult(
        query: 'test query',
        items: [
          SearchItem(
            id: '1',
            title: 'Test Item',
            subtitle: 'Subtitle',
            groupId: 'group1',
          ),
        ],
        totalCount: 1,
        executionTimeMs: 100,
        hasMore: false,
      );

      await repository.cacheResult(result);

      final cached = repository.getCachedResult('test query');
      expect(cached, isNotNull);
      expect(cached!.query, 'test query');
      expect(cached.items.length, 1);
      expect(cached.items.first.title, 'Test Item');
      expect(cached.totalCount, 1);
      expect(cached.executionTimeMs, 100);
    });

    test('returns null for cache miss', () {
      final cached = repository.getCachedResult('non-existent');
      expect(cached, isNull);
    });

    test('respects max cache size limit and evicts oldest', () async {
      // Add 3 items (max limit)
      for (var i = 0; i < 3; i++) {
        final result = SearchResult(
          query: 'query$i',
          items: [
            SearchItem(
              id: '$i',
              title: 'Item $i',
              subtitle: 'Subtitle',
              groupId: 'group1',
            ),
          ],
          totalCount: 1,
        );
        await repository.cacheResult(result);
        // Small delay to ensure different timestamps
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      // Verify all 3 are cached
      expect(repository.getCachedResult('query0'), isNotNull);
      expect(repository.getCachedResult('query1'), isNotNull);
      expect(repository.getCachedResult('query2'), isNotNull);

      // Add one more (should trigger eviction of oldest 20%)
      final result = SearchResult(
        query: 'query3',
        items: [
          SearchItem(
            id: '3',
            title: 'Item 3',
            subtitle: 'Subtitle',
            groupId: 'group1',
          ),
        ],
        totalCount: 1,
      );
      await repository.cacheResult(result);

      // Query0 should be evicted (oldest)
      expect(repository.getCachedResult('query0'), isNull);
      expect(repository.getCachedResult('query1'), isNotNull);
      expect(repository.getCachedResult('query2'), isNotNull);
      expect(repository.getCachedResult('query3'), isNotNull);
    });

    test('invalidates cache after TTL', () async {
      final result = SearchResult(
        query: 'expiring query',
        items: [
          SearchItem(
            id: '1',
            title: 'Test Item',
            subtitle: 'Subtitle',
            groupId: 'group1',
          ),
        ],
        totalCount: 1,
      );

      await repository.cacheResult(result);

      // Should be cached immediately
      expect(repository.getCachedResult('expiring query'), isNotNull);

      // Wait for cache to expire (duration is 2 seconds in setUp)
      await Future<void>.delayed(const Duration(seconds: 3));

      // Should be expired now
      expect(repository.getCachedResult('expiring query'), isNull);
    });

    test('clears cache on demand', () async {
      // Add multiple items
      for (var i = 0; i < 3; i++) {
        final result = SearchResult(
          query: 'query$i',
          items: [
            SearchItem(
              id: '$i',
              title: 'Item $i',
              subtitle: 'Subtitle',
              groupId: 'group1',
            ),
          ],
          totalCount: 1,
        );
        await repository.cacheResult(result);
      }

      // Verify all are cached
      expect(repository.getCachedResult('query0'), isNotNull);
      expect(repository.getCachedResult('query1'), isNotNull);
      expect(repository.getCachedResult('query2'), isNotNull);

      // Clear cache
      await repository.clearCache();

      // All should be gone
      expect(repository.getCachedResult('query0'), isNull);
      expect(repository.getCachedResult('query1'), isNull);
      expect(repository.getCachedResult('query2'), isNull);
    });

    test('handles cache miss gracefully', () {
      // Should not throw
      expect(() => repository.getCachedResult('non-existent'), returnsNormally);
      expect(repository.getCachedResult('non-existent'), isNull);
    });

    test('removes expired entries only', () async {
      // Add items with different expiration
      final result1 = SearchResult(
        query: 'will-expire',
        items: [
          SearchItem(
            id: '1',
            title: 'Item 1',
            subtitle: 'Subtitle',
            groupId: 'group1',
          ),
        ],
        totalCount: 1,
      );
      await repository.cacheResult(result1);

      // Wait for first item to expire
      await Future<void>.delayed(const Duration(seconds: 3));

      final result2 = SearchResult(
        query: 'will-not-expire',
        items: [
          SearchItem(
            id: '2',
            title: 'Item 2',
            subtitle: 'Subtitle',
            groupId: 'group1',
          ),
        ],
        totalCount: 1,
      );
      await repository.cacheResult(result2);

      // Clean up expired
      await repository.removeExpiredEntries();

      // First should be gone, second should remain
      expect(repository.getCachedResult('will-expire'), isNull);
      expect(repository.getCachedResult('will-not-expire'), isNotNull);
    });

    test('query is case-insensitive', () async {
      final result = SearchResult(
        query: 'Test Query',
        items: [
          SearchItem(
            id: '1',
            title: 'Test Item',
            subtitle: 'Subtitle',
            groupId: 'group1',
          ),
        ],
        totalCount: 1,
      );

      await repository.cacheResult(result);

      // Should find with different case
      expect(repository.getCachedResult('test query'), isNotNull);
      expect(repository.getCachedResult('TEST QUERY'), isNotNull);
      expect(repository.getCachedResult('Test Query'), isNotNull);
    });

    test('throws StateError when not initialized', () {
      final uninitializedRepo = SearchCacheRepository(boxName: 'uninitialized');

      expect(
        () => uninitializedRepo.getCachedResult('query'),
        throwsStateError,
      );
    });

    test('preserves all SearchItem fields', () async {
      final result = SearchResult(
        query: 'full item',
        items: [
          SearchItem(
            id: '1',
            title: 'Test Title',
            subtitle: 'Test Subtitle',
            groupId: 'test-group',
            description: 'Test Description',
            imageUrl: 'https://example.com/image.png',
            metadata: {'key': 'value', 'count': 42},
            route: '/test-route',
          ),
        ],
        totalCount: 1,
        executionTimeMs: 150,
        hasMore: true,
        nextPage: 'page2',
      );

      await repository.cacheResult(result);

      final cached = repository.getCachedResult('full item');
      expect(cached, isNotNull);

      final item = cached!.items.first;
      expect(item.id, '1');
      expect(item.title, 'Test Title');
      expect(item.subtitle, 'Test Subtitle');
      expect(item.groupId, 'test-group');
      expect(item.description, 'Test Description');
      expect(item.imageUrl, 'https://example.com/image.png');
      expect(item.metadata, {'key': 'value', 'count': 42});
      expect(item.route, '/test-route');

      expect(cached.totalCount, 1);
      expect(cached.executionTimeMs, 150);
      expect(cached.hasMore, true);
      expect(cached.nextPage, 'page2');
    });
  });
}
