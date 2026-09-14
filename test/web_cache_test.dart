@TestOn('browser')
library;

import 'package:app_wide_search/app_wide_search.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  test('search cache and history persist across browser box reopen', () async {
    Hive.registerAdapter(SearchHistoryItemAdapter());
    final cache = SearchCacheRepository(boxName: 'web_search_cache');
    final history = SearchHistoryRepository(boxName: 'web_search_history');
    addTearDown(() async {
      await cache.dispose();
      await history.dispose();
      await Hive.deleteBoxFromDisk('web_search_cache');
      await Hive.deleteBoxFromDisk('web_search_history');
    });
    await cache.initialize();
    await history.initialize();
    await cache.cacheResult(
      SearchResult(
        query: 'Test',
        items: [
          SearchItem(
            id: '1',
            title: 'ทดสอบ',
            subtitle: 'Browser',
            groupId: 'products',
          ),
        ],
      ),
    );
    await history.addToHistory('Test');
    await cache.dispose();
    await history.dispose();
    await cache.initialize();
    await history.initialize();
    expect(cache.getCachedResult('TEST')?.items.single.title, 'ทดสอบ');
    expect(history.getRecentSearches(), ['Test']);
  });
}
