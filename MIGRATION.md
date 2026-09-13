# Migrating to 0.2.0

## Hive CE

Replace application dependencies/imports of `hive` and `hive_flutter` with
`hive_ce: ^2.20.0` and `hive_ce_flutter: ^2.3.4` wherever they initialize this
package's storage or register its adapters:

```dart
import 'package:hive_ce_flutter/hive_flutter.dart';

await Hive.initFlutter();
Hive.registerAdapter(SearchItemAdapter());
Hive.registerAdapter(SearchGroupAdapter());
Hive.registerAdapter(SearchHistoryItemAdapter());
```

Hive and Hive CE use separate Dart registries. Do not register these adapters
with the old Hive instance or open the same box concurrently through both engines.
Keep existing storage paths, box names, type IDs and field IDs. Back up persisted
application data before upgrading. Tests read synthetic Hive 2.2.3 model records
with Hive CE; this does not validate every application's custom adapters or data.

Minimum declared versions: Dart 3.8, Flutter 3.32. Validation uses Flutter 3.44.2 /
Dart 3.12.2. GoRouter constraints now allow 16.x through 18.x; the local SDK
was tested with both 17.5.0 and 18.0.1. GoRouter 18 resolves intl 0.20.2
through Flutter localizations; that SDK pin can cause a broad dependency upgrade
to prefer GoRouter 17 with a newer intl version.

## Group icons

`SearchGroup.icon` remains an integer with the same Hive field ID. Rendering an
arbitrary integer as `IconData` prevented release builds with icon tree shaking.
Supply constant icons through the new callback:

```dart
GroupedSearchResults(
  result: result,
  groups: groups,
  groupIconBuilder: (context, group) => switch (group.id) {
    'products' => const Icon(Icons.shopping_bag),
    'documents' => const Icon(Icons.description),
    _ => null,
  },
  onItemTap: onItemTap,
)
```

If the callback is absent or returns null, a folder icon using the group color
is displayed. Existing apps relying on automatic `SearchGroup.icon` rendering
must add this callback. Do not construct dynamic `IconData` inside the callback.
Default release builds no longer need `--no-tree-shake-icons`.

## Verification

```sh
flutter pub get
(cd example/_shared && flutter pub get)
(cd example/quickstart_minimal && flutter pub get)
flutter analyze --fatal-infos
flutter test
flutter test --platform chrome test/web_cache_test.dart
flutter test --platform chrome --wasm test/web_cache_test.dart
(cd example && flutter build web --release)
(cd example && flutter build web --wasm --release)
flutter pub publish --dry-run
```
