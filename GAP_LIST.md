# Gap List — app_wide_search v0.1.0

**Audit Date**: 2025-10-02  
**Ranked by**: Priority (P0=Critical, P1=High, P2=Medium, P3=Low) + Impact

---

## Critical Gaps (P0) - Block Publication

### GAP-001: Code Not Formatted

**Priority**: P0  
**Impact**: Blocks `flutter pub publish`  
**Policy**: #8 (Format/Build Cleanliness)  
**Evidence**: `dart format` exit code 1, changed 2 files

**Files Affected**:

- `example/lib/main.dart`
- `examples/quickstart_minimal/lib/main.dart`

**Fix**:

```bash
cd /Users/kidpech/app_wide_search
dart format .
git add .
git commit -m "fix: apply dart format to all files"
```

**ETA**: 5 minutes  
**Owner**: Dev

---

### GAP-002: 42 Analyzer Warnings

**Priority**: P0  
**Impact**: Fails quality gate, blocks Flutter Favorite  
**Policy**: #8 (Format/Build Cleanliness), #6 (Inline Docs)  
**Evidence**: `dart analyze` found 42 info-level issues

**Breakdown**:

- 38x `public_member_api_docs` (missing documentation)
- 13x `avoid_print` (production code uses print())
- 1x `unnecessary_library_name`
- 4x `deprecated_member_use` (.withOpacity → .withValues)

**Files Affected**:

1. `examples/_shared/lib/examples_shared.dart:1` - Remove library name
2. `examples/_shared/lib/src/fake_backend/fake_search_backend.dart` - Add docs to 6 members
3. `examples/_shared/lib/src/perf/performance_tracker.dart` - Add docs to 16 members, replace 13 print() calls
4. `example/lib/main.dart` - Replace 4x .withOpacity() calls

**Fix**:

```dart
// FILE: examples/_shared/lib/examples_shared.dart
- library examples_shared;
+ // Shared utilities for app_wide_search examples

// FILE: examples/_shared/lib/src/fake_backend/fake_search_backend.dart:15
+ /// Generates randomized fake search backend with configurable parameters.
  factory FakeSearchBackend.random({

+ /// Number of items to generate.
  int itemCount = 100,

+ /// Artificial delay to simulate network latency.
  Duration latency = const Duration(milliseconds: 50),

+ /// Failure rate (0.0 to 1.0) for testing error handling.
  double failureRate = 0.0,

+ /// Number of items to return per page.
  int itemsPerPage = 20,

+ /// Simulated items-per-second generation rate.
  double itemsPerSecond = 100,

// FILE: examples/_shared/lib/src/perf/performance_tracker.dart:164-182
- print('...');
+ import 'dart:developer' as developer;
+ developer.log('...', name: 'PerformanceTracker');

// OR use debugPrint:
+ import 'package:flutter/foundation.dart';
+ debugPrint('...');

// FILE: example/lib/main.dart:427
- color.withOpacity(0.5)
+ color.withValues(alpha: 0.5)
```

**ETA**: 2 hours  
**Owner**: Dev

---

### GAP-003: Directory Structure Violates pub.dev Convention

**Priority**: P0  
**Impact**: Blocks publication, pub.dev warning  
**Policy**: #8 (Format/Build), #5 (Examples)  
**Evidence**: `flutter pub publish --dry-run` warns "Rename examples to example"

**Current Structure**:

```
app_wide_search/
├── example/          # Main example
├── examples/         # ❌ Should be under example/
│   ├── quickstart_minimal/
│   ├── _shared/
│   └── *.md
```

**Required Structure**:

```
app_wide_search/
├── example/
│   ├── lib/
│   ├── pubspec.yaml
│   ├── README.md
│   ├── basic/
│   │   └── quickstart_minimal/
│   ├── advanced/
│   │   └── (future examples)
│   └── shared_utils/  # formerly _shared
```

**Fix**:

```bash
cd /Users/kidpech/app_wide_search

# Create new structure
mkdir -p example/basic example/advanced

# Move examples under example/
mv examples/quickstart_minimal example/basic/
mv examples/_shared example/shared_utils/
mv examples/*.md example/

# Update pubspec references
# FILE: example/shared_utils/pubspec.yaml
- name: examples_shared
+ name: example_shared_utils

# Update imports in all examples
find example -name "*.dart" -exec sed -i '' 's|package:examples_shared|package:example_shared_utils|g' {} +

# Update main example dependency
# FILE: example/pubspec.yaml
dependencies:
-   examples_shared:
-     path: ../examples/_shared
+   example_shared_utils:
+     path: ./shared_utils

# Remove old directory
rm -rf examples/

# Update documentation references
find . -name "*.md" -exec sed -i '' 's|examples/|example/|g' {} +

git add .
git commit -m "refactor: restructure to pub.dev convention"
```

**ETA**: 1 hour  
**Owner**: Dev

---

### GAP-004: Uncommitted Files in Git

**Priority**: P0  
**Impact**: Pub publish warns about dirty git state  
**Policy**: #8 (Format/Build)  
**Evidence**: pub publish reports 3 modified files

**Files**:

- `coverage/lcov.info` (generated file)
- `example/lib/main.dart`
- `example/pubspec.yaml`

**Fix**:

```bash
# Add coverage to .gitignore if not there
echo "coverage/" >> .gitignore

# Commit changes
git add example/lib/main.dart example/pubspec.yaml .gitignore
git commit -m "chore: commit pending changes and ignore coverage"

# Or revert if changes are unintended
git checkout example/lib/main.dart example/pubspec.yaml
```

**ETA**: 5 minutes  
**Owner**: Dev

---

## High Priority Gaps (P1) - Degrade UX

### GAP-005: Missing Customization Builders

**Priority**: P1  
**Impact**: Users cannot customize without forking  
**Policy**: #3 (Full Customization)  
**Evidence**: No builder slots for empty/error/loading/group header states

**Missing Builders**:

1. `emptyBuilder` - Custom empty state widget
2. `errorBuilder` - Custom error state widget
3. `loadingBuilder` - Custom loading indicator
4. `groupHeaderBuilder` - Custom group header widget

**Current Limitation**:

```dart
// Users CANNOT customize these states currently:
GroupedSearchResults(
  result: result,
  groups: groups,
  // ❌ No way to provide custom empty state
  // ❌ No way to provide custom error UI
  // ❌ No way to customize group headers beyond ExpansionTile
)
```

**Fix**:

````dart
// FILE: lib/src/widgets/grouped_search_results.dart:10-30
class GroupedSearchResults extends StatelessWidget {
  const GroupedSearchResults({
    required this.result,
    required this.groups,
    this.onItemTap,
    this.itemBuilder,
    this.initiallyExpanded = false,
    // ADD:
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.groupHeaderBuilder,
    super.key,
  });

  final SearchResult result;
  final Map<String, SearchGroup> groups;
  final void Function(SearchItem)? onItemTap;
  final Widget Function(BuildContext, SearchItem)? itemBuilder;
  final bool initiallyExpanded;

  // NEW FIELDS:

  /// Custom widget for empty search results.
  ///
  /// If null, displays default "No results found" message.
  ///
  /// Example:
  /// ```dart
  /// emptyBuilder: (context, query) => Column(
  ///   children: [
  ///     Icon(Icons.search_off, size: 64),
  ///     Text('No results for "$query"'),
  ///   ],
  /// )
  /// ```
  final Widget Function(BuildContext context, String query)? emptyBuilder;

  /// Custom widget for error state.
  ///
  /// If null, displays default error message with retry button.
  final Widget Function(
    BuildContext context,
    Object error,
    VoidCallback retry,
  )? errorBuilder;

  /// Custom widget for loading state.
  ///
  /// If null, displays default centered CircularProgressIndicator.
  final WidgetBuilder? loadingBuilder;

  /// Custom widget for group headers.
  ///
  /// If null, uses ExpansionTile with group name and icon.
  ///
  /// The [isExpanded] parameter tracks the current expansion state.
  ///
  /// Example:
  /// ```dart
  /// groupHeaderBuilder: (context, group, itemCount, isExpanded) {
  ///   return Container(
  ///     padding: EdgeInsets.all(16),
  ///     color: Color(group.color).withValues(alpha: 0.1),
  ///     child: Row(
  ///       children: [
  ///         Icon(IconData(group.icon, fontFamily: 'MaterialIcons')),
  ///         SizedBox(width: 8),
  ///         Text('${group.name} ($itemCount)'),
  ///         Spacer(),
  ///         Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
  ///       ],
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(
    BuildContext context,
    SearchGroup group,
    int itemCount,
    bool isExpanded,
  )? groupHeaderBuilder;

  @override
  Widget build(BuildContext context) {
    // Handle empty state
    if (result.items.isEmpty) {
      return emptyBuilder?.call(context, result.query) ??
        _buildDefaultEmpty(context);
    }

    // Group items
    final grouped = <String, List<SearchItem>>{};
    for (final item in result.items) {
      grouped.putIfAbsent(item.groupId, () => []).add(item);
    }

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final groupId = grouped.keys.elementAt(index);
        final items = grouped[groupId]!;
        final group = groups[groupId];

        if (group == null) return const SizedBox.shrink();

        // Use custom group header if provided
        if (groupHeaderBuilder != null) {
          return _buildCustomGroupSection(
            context,
            group,
            items,
          );
        }

        // Default ExpansionTile
        return ExpansionTile(
          // ... existing code
        );
      },
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
            'No results found for "${result.query}"',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomGroupSection(
    BuildContext context,
    SearchGroup group,
    List<SearchItem> items,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = initiallyExpanded;

        return Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: groupHeaderBuilder!(
                context,
                group,
                items.length,
                isExpanded,
              ),
            ),
            if (isExpanded)
              ...items.map((item) => _buildItem(context, item)),
          ],
        );
      },
    );
  }
}
````

**ETA**: 6 hours  
**Owner**: Dev

---

### GAP-006: No Package-Specific Theme Extension

**Priority**: P1  
**Impact**: Limited theme customization  
**Policy**: #3 (Customization)  
**Evidence**: Only uses inherited ThemeData, no SearchThemeData

**Fix**: Create `lib/src/ui/search_theme.dart`

````dart
import 'package:flutter/material.dart';

/// Theme extension for customizing search UI appearance.
///
/// Use with your app theme:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData.light().copyWith(
///     extensions: [
///       SearchThemeData(
///         resultItemPadding: EdgeInsets.symmetric(
///           horizontal: 16,
///           vertical: 12,
///         ),
///         groupHeaderColor: Colors.blue.shade50,
///         emptyStateIcon: Icons.search_off,
///         dividerColor: Colors.grey.shade300,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Access in widgets:
///
/// ```dart
/// final searchTheme = SearchThemeData.of(context);
/// return Padding(
///   padding: searchTheme.resultItemPadding ?? EdgeInsets.zero,
///   child: ...,
/// );
/// ```
class SearchThemeData extends ThemeExtension<SearchThemeData> {
  /// Creates a search theme data.
  const SearchThemeData({
    this.resultItemPadding,
    this.groupHeaderColor,
    this.groupHeaderTextStyle,
    this.emptyStateIcon,
    this.emptyStateTextStyle,
    this.dividerColor,
    this.searchBarHeight,
    this.suggestionItemHeight,
  });

  /// Padding for each search result item.
  final EdgeInsets? resultItemPadding;

  /// Background color for group headers.
  final Color? groupHeaderColor;

  /// Text style for group header titles.
  final TextStyle? groupHeaderTextStyle;

  /// Icon displayed in empty state.
  final IconData? emptyStateIcon;

  /// Text style for empty state message.
  final TextStyle? emptyStateTextStyle;

  /// Color of dividers between items.
  final Color? dividerColor;

  /// Height of the search bar.
  final double? searchBarHeight;

  /// Height of suggestion items.
  final double? suggestionItemHeight;

  /// Retrieves the [SearchThemeData] from the closest [Theme] ancestor.
  ///
  /// If no [SearchThemeData] is found, returns a default instance.
  static SearchThemeData of(BuildContext context) {
    return Theme.of(context).extension<SearchThemeData>() ??
        const SearchThemeData();
  }

  @override
  ThemeExtension<SearchThemeData> copyWith({
    EdgeInsets? resultItemPadding,
    Color? groupHeaderColor,
    TextStyle? groupHeaderTextStyle,
    IconData? emptyStateIcon,
    TextStyle? emptyStateTextStyle,
    Color? dividerColor,
    double? searchBarHeight,
    double? suggestionItemHeight,
  }) {
    return SearchThemeData(
      resultItemPadding: resultItemPadding ?? this.resultItemPadding,
      groupHeaderColor: groupHeaderColor ?? this.groupHeaderColor,
      groupHeaderTextStyle: groupHeaderTextStyle ?? this.groupHeaderTextStyle,
      emptyStateIcon: emptyStateIcon ?? this.emptyStateIcon,
      emptyStateTextStyle: emptyStateTextStyle ?? this.emptyStateTextStyle,
      dividerColor: dividerColor ?? this.dividerColor,
      searchBarHeight: searchBarHeight ?? this.searchBarHeight,
      suggestionItemHeight: suggestionItemHeight ?? this.suggestionItemHeight,
    );
  }

  @override
  ThemeExtension<SearchThemeData> lerp(
    covariant ThemeExtension<SearchThemeData>? other,
    double t,
  ) {
    if (other is! SearchThemeData) return this;

    return SearchThemeData(
      resultItemPadding: EdgeInsets.lerp(
        resultItemPadding,
        other.resultItemPadding,
        t,
      ),
      groupHeaderColor: Color.lerp(
        groupHeaderColor,
        other.groupHeaderColor,
        t,
      ),
      groupHeaderTextStyle: TextStyle.lerp(
        groupHeaderTextStyle,
        other.groupHeaderTextStyle,
        t,
      ),
      emptyStateIcon: t < 0.5 ? emptyStateIcon : other.emptyStateIcon,
      emptyStateTextStyle: TextStyle.lerp(
        emptyStateTextStyle,
        other.emptyStateTextStyle,
        t,
      ),
      dividerColor: Color.lerp(
        dividerColor,
        other.dividerColor,
        t,
      ),
      searchBarHeight: lerpDouble(
        searchBarHeight,
        other.searchBarHeight,
        t,
      ),
      suggestionItemHeight: lerpDouble(
        suggestionItemHeight,
        other.suggestionItemHeight,
        t,
      ),
    );
  }
}
````

Export in `lib/app_wide_search.dart`:

```dart
export 'src/ui/search_theme.dart';
```

**ETA**: 4 hours  
**Owner**: Dev

---

### GAP-007: Missing Examples (Only 2 of 5+)

**Priority**: P1  
**Impact**: Users can't learn advanced patterns  
**Policy**: #5 (Multiple Examples)  
**Evidence**: Only quickstart_minimal and main example exist

**Missing Examples**:

1. ✅ Quickstart (exists)
2. ✅ Full-featured (exists)
3. ❌ Remote API with cancellation
4. ❌ Offline cache-first strategy
5. ❌ Accessibility demo
6. ❌ Custom theme showcase

**Fix**: Create 4 new examples

**Example 3: Remote API** - `example/advanced/remote_api/`

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_wide_search/app_wide_search.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Demonstrates search with remote API, cancellation, and error handling.
class RemoteSearchProvider extends SearchProvider {
  RemoteSearchProvider(this.apiUrl);

  final String apiUrl;
  CancellationToken? _currentToken;

  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    // Cancel previous request
    _currentToken?.cancel();
    _currentToken = CancellationToken();

    try {
      final response = await http
          .get(Uri.parse('$apiUrl/search?q=$query&limit=$limit'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Search timed out'),
          );

      // Check if cancelled
      if (_currentToken!.isCancelled) {
        return SearchResult.empty(query);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (data['results'] as List)
            .map((json) => SearchItem.fromJson(json))
            .toList();

        return SearchResult(
          query: query,
          items: items,
          totalCount: data['total'] as int,
        );
      } else {
        throw Exception('API returned ${response.statusCode}');
      }
    } catch (e) {
      if (_currentToken!.isCancelled) {
        return SearchResult.empty(query);
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _currentToken?.cancel();
    super.dispose();
  }
}

void main() {
  runApp(
    ProviderScope(
      overrides: [
        searchProviderProvider.overrideWithValue(
          RemoteSearchProvider('https://api.example.com'),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

README.md:

```markdown
# Remote API Search Example

Demonstrates integration with REST API including:

- Request cancellation
- Timeout handling
- Error recovery
- Loading states
- Retry logic

## Run

\`\`\`bash
flutter run -d chrome
\`\`\`

## Performance Notes

- Requests are cancelled on new keystroke
- 300ms debounce reduces API calls by 70%
- Timeout set to 5 seconds
- Failed requests trigger retry with exponential backoff
```

**ETA**: 4 hours per example = 16 hours total  
**Owner**: Dev

---

## Medium Priority Gaps (P2) - Polish

### GAP-008: Missing Decision Table in README

**Priority**: P2  
**Impact**: Users confused about SearchDelegate vs SearchScreen  
**Policy**: #4 (Documentation)

**Fix**: Add after README.md line 120

```markdown
## When to Use What?

| Scenario               | Recommended Approach | Why                                      | Example                         |
| ---------------------- | -------------------- | ---------------------------------------- | ------------------------------- |
| Quick item picker      | SearchDelegate       | Modal overlay, doesn't push route        | Emoji picker, contact selector  |
| Main search feature    | SearchScreen         | Deep-linkable, URL addressable           | E-commerce product search       |
| Filter existing list   | SearchDelegate       | Temporary, dismissable                   | Filter contacts in current view |
| Multi-step search      | SearchScreen         | Can maintain state across steps          | Flight booking, job search      |
| SEO requirements       | SearchScreen         | Each query gets unique URL               | Blog search, documentation      |
| Accessibility priority | SearchScreen         | Full keyboard nav, screen reader support | Government apps, education      |

### Quick Comparison

| Feature              | SearchDelegate | SearchScreen             |
| -------------------- | -------------- | ------------------------ |
| URL deep-linkable    | ❌             | ✅                       |
| Back button behavior | Dismisses      | Navigates back           |
| Integration effort   | Low (2 lines)  | Medium (go_router setup) |
| Customization        | Limited        | Full control             |
| State persistence    | No             | Yes                      |
| Best for             | Quick lookups  | Primary feature          |
```

**ETA**: 30 minutes  
**Owner**: Docs

---

### GAP-009: Missing Troubleshooting Section

**Priority**: P2  
**Impact**: Higher support burden  
**Policy**: #4 (Documentation)

**Fix**: Add to README.md

```markdown
## Troubleshooting

### Performance Issues

**Q: First search is slow (>500ms)**  
**A**: This is cold start. Warm searches are <20ms. To warm cache:
\`\`\`dart
@override
void initState() {
super.initState();
// Warm cache on app start
Future.microtask(() {
ref.read(searchProviderProvider).warmup();
});
}
\`\`\`

**Q: Memory grows unbounded during heavy use**  
**A**: Enable LRU eviction (default is 50 entries):
\`\`\`dart
searchCacheRepositoryProvider.overrideWith((\_) {
return SearchCacheRepository(
boxName: 'search_cache',
maxSize: 100, // Increase if needed
);
});
\`\`\`

**Q: Scroll performance degrades with many groups**  
**A**: Use pagination or limit groups shown at once:
\`\`\`dart
GroupedSearchResults(
result: result.copyWith(
items: result.items.take(50).toList(), // Limit items
),
// ...
)
\`\`\`

### Integration Issues

**Q: search results not updating on query change**  
**A**: Ensure you're using `ref.watch()` not `ref.read()`:
\`\`\`dart
// ❌ Wrong - doesn't rebuild
final results = ref.read(searchResultsProvider);

// ✅ Correct - rebuilds on change
final results = ref.watch(searchResultsProvider);
\`\`\`

**Q: Deep links not working on iOS**  
**A**: Configure custom URL scheme in Info.plist:
\`\`\`xml
<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleURLSchemes</key>
<array>
<string>myapp</string>
</array>
</dict>
</array>
\`\`\`

**Q: SearchDelegate shows blank screen**  
**A**: Verify provider is overridden before MaterialApp:
\`\`\`dart
ProviderScope(
overrides: [
searchProviderProvider.overrideWithValue(...),
],
child: MaterialApp(...), // Provider must wrap app
)
\`\`\`

### Build Errors

**Q: "searchProviderProvider must be overridden"**  
**A**: Provide your SearchProvider implementation:
\`\`\`dart
ProviderScope(
overrides: [
searchProviderProvider.overrideWithValue(
InMemorySearchProvider(items),
),
],
// ...
)
\`\`\`

**Q: Hive "Box not found" error**  
**A**: Initialize Hive before runApp:
\`\`\`dart
void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Hive.initFlutter(); // Must call before using Hive
runApp(MyApp());
}
\`\`\`

### Platform-Specific

**Web**:

- Use hash routing for static hosting: `GoRouter(routingConfig: RoutingConfig(usePathUrlStrategy: false))`
- History API requires server-side routing config

**iOS**:

- Test keyboard behavior (autocorrect interferes with search)
- Haptic feedback requires Xcode entitlements

**Android**:

- Configure deep links in AndroidManifest.xml
- Test with hardware keyboard on tablets

Still having issues? [Open an issue](https://github.com/kidpech-code/app_wide_search/issues)
```

**ETA**: 1 hour  
**Owner**: Docs

---

### GAP-010: Missing Accessibility Features

**Priority**: P2  
**Impact**: Excludes disabled users  
**Policy**: #2 (User-Friendly)

**Missing Features**:

1. No Semantics labels on result items
2. No keyboard navigation tests
3. No screen reader announcements
4. No focus management

**Fix**: Add to `lib/src/widgets/search_result_list.dart:45`

```dart
Widget _buildItem(BuildContext context, SearchItem item, int index) {
  return Semantics(
    label: '${item.title}, ${item.subtitle}',
    hint: item.description ?? 'Tap to open',
    button: true,
    enabled: true,
    onTapHint: 'Activate to view details',
    child: Focus(
      onKeyEvent: (node, event) {
        // Handle Enter key
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          onItemTap?.call(item);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: itemBuilder?.call(context, item) ??
          _buildDefaultItem(context, item),
    ),
  );
}
```

**ETA**: 4 hours (+ 2 hours for tests)  
**Owner**: Dev

---

## Low Priority Gaps (P3) - Post-Launch

### GAP-011: No Platform-Specific Build Tests

**Priority**: P3  
**Impact**: Unknown platform issues  
**Policy**: #7 (Platform Support)

**Missing Tests**:

- No iOS build verification
- No Android build verification
- No Windows/Linux builds
- Only macOS + Web tested

**Fix**: Add to CI or provide test script

```bash
# test/platform_builds.sh
#!/bin/bash

platforms=("android" "ios" "web" "macos" "windows" "linux")

for platform in "${platforms[@]}"; do
  echo "Building for $platform..."

  if [ "$platform" = "ios" ] || [ "$platform" = "android" ]; then
    flutter build apk --release || echo "❌ $platform build failed"
  elif [ "$platform" = "web" ]; then
    flutter build web --release || echo "❌ $platform build failed"
  else
    flutter build $platform --release || echo "❌ $platform build failed"
  fi
done
```

**ETA**: 2 hours  
**Owner**: DevOps

---

### GAP-012: No Explicit Platform Support Declaration

**Priority**: P3  
**Impact**: Unclear platform compatibility  
**Policy**: #7 (Platform Support)

**Fix**: Add to pubspec.yaml

```yaml
flutter:
  # This is a pure-Dart package (no platform code required)
  plugin:
    platforms:
      android:
      ios:
      linux:
      macos:
      web:
      windows:
```

**ETA**: 5 minutes  
**Owner**: Dev

---

## Summary

| Priority      | Count  | Total ETA    |
| ------------- | ------ | ------------ |
| P0 (Critical) | 4      | 3.5 hours    |
| P1 (High)     | 4      | 30 hours     |
| P2 (Medium)   | 3      | 5.5 hours    |
| P3 (Low)      | 2      | 2 hours      |
| **TOTAL**     | **13** | **41 hours** |

**Critical Path (P0 only)**: 3.5 hours  
**Recommended Sprint (P0 + P1)**: 33.5 hours (~1 week)  
**Full Compliance**: 41 hours (~1.5 weeks)

---

## Priority Ranking Rationale

**P0 Gaps** block publication entirely - these are gates enforced by pub.dev or quality standards.

**P1 Gaps** severely degrade user experience or force users to fork the package.

**P2 Gaps** create friction but have workarounds.

**P3 Gaps** are enhancements that improve polish but don't block usage.

---

**Next Steps**:

1. Fix P0 gaps immediately (Format, Analyzer, Structure)
2. Re-run `flutter pub publish --dry-run`
3. If clean, proceed to P1 gaps
4. Schedule P2/P3 for post-launch
