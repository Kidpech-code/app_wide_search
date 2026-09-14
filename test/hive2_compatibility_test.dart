@TestOn('vm')
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:app_wide_search/app_wide_search.dart';

void main() {
  test(
    'reads adapter records written by Hive 2.2.3 without migration',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'hive2_compatibility_',
      );
      addTearDown(() async {
        await Hive.close();
        await directory.delete(recursive: true);
      });
      await File(
        'test/fixtures/hive2/legacy.hive',
      ).copy('${directory.path}/legacy.hive');
      Hive.init(directory.path);
      Hive.registerAdapter(SearchItemAdapter());
      Hive.registerAdapter(SearchGroupAdapter());
      final box = await Hive.openBox<dynamic>('legacy');
      final item = box.get('item') as SearchItem;
      expect(item.id, 'old-item');
      expect(item.title, 'ทดสอบ');
      expect(item.groupId, 'products');
      final group = box.get('group') as SearchGroup;
      expect(group.icon, 123);
      expect(group.color, 0xFF123456);
      await box.put('ce-write', 'ok');
      await box.close();
      final reopened = await Hive.openBox<dynamic>('legacy');
      expect(reopened.get('ce-write'), 'ok');
    },
  );
}
