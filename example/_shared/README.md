# Examples Shared Package

**Shared utilities and fixtures for app_wide_search examples.**

This package provides common code used across multiple example apps to avoid duplication and ensure consistency.

## 📦 What's Included

### 1. **Fake Backend** (`src/fake_backend/`)

Mock search backend with realistic behavior for testing and demos.

**Features**:

- ✅ Configurable latency simulation (default: 100ms)
- ✅ Random error injection (0-100% rate)
- ✅ Pagination support
- ✅ Cancellation support
- ✅ Realistic search scoring algorithm
- ✅ Streaming API support

**Usage**:

```dart
import 'package:examples_shared/examples_shared.dart';

final backend = FakeSearchBackend(
  latency: Duration(milliseconds: 100),
  errorRate: 0.1, // 10% error rate
  itemCount: 1000,
);

final result = await backend.search('query', page: 1);
```

### 2. **Fixture Data** (`src/fixtures/`)

Realistic test data generator using faker library.

**Generates**:

- 🛍️ Products (with prices, descriptions, images)
- 👤 Contacts (with emails, phone, company)
- 📄 Documentation pages (with sections, timestamps)
- 📁 Media files (with sizes, types)
- ⚙️ Settings (with descriptions, routes)

**Usage**:

```dart
import 'package:examples_shared/examples_shared.dart';

// Generate 1000 realistic items
final items = FixtureData.generateRealisticItems(1000);

// Get pre-defined search groups
final groups = FixtureData.groups;
```

### 3. **App Themes** (`src/theme/`)

Pre-defined Material 3 themes for consistent UI.

**Available Themes**:

- 🌟 Light Theme (default)
- 🌙 Dark Theme
- 🔵 Blue Theme
- 🟢 Green Theme
- 🟠 Orange Theme
- ⬛ High Contrast Theme (accessibility)

**Usage**:

```dart
import 'package:examples_shared/examples_shared.dart';

MaterialApp(
  theme: AppThemes.lightTheme,
  darkTheme: AppThemes.darkTheme,
  // ...
)

// Or get all themes as a map
final themes = AppThemes.allThemes;
```

### 4. **Performance Tracker** (`src/perf/`)

Simple performance monitoring for search operations.

**Tracks**:

- ⏱️ Query execution time
- 📊 Results count
- 💾 Cache hit/miss rates
- 📈 P95 execution time
- 📉 Average times (cached vs uncached)

**Usage**:

```dart
import 'package:examples_shared/examples_shared.dart';

final tracker = PerformanceTracker();

// Track a search operation
await tracker.trackSearch(
  query: 'iPhone',
  operation: () => searchProvider.search('iPhone'),
  getResultCount: (result) => result.items.length,
  fromCache: false,
);

// Get statistics
final stats = tracker.stats;
print('Average time: ${stats.averageExecutionTime.inMilliseconds}ms');
print('Cache hit rate: ${stats.cacheHitRate}%');

// Print formatted report
tracker.printReport();
```

## 🚀 Installation

This is a local package used by examples. To use it in your example:

```yaml
# pubspec.yaml
dependencies:
  examples_shared:
    path: ../_shared
  flutter_riverpod: ^2.6.0
  faker: ^2.1.0
```

## 📖 API Reference

### FakeSearchBackend

```dart
FakeSearchBackend({
  Duration latency = const Duration(milliseconds: 100),
  double errorRate = 0.0, // 0.0 to 1.0
  int itemCount = 1000,
  int pageSize = 20,
  bool useRealisticData = true,
})

// Methods
Future<SearchResult> search(String query, {int page, int? limit, CancellationToken? token})
Stream<SearchResult> searchStream(String query, {int batchSize, CancellationToken? token})
void reset()
Map<String, dynamic> get stats
```

### FixtureData

```dart
// Static methods
static List<SearchItem> generateRealisticItems(int count)
static List<SearchGroup> get groups
```

### AppThemes

```dart
// Static getters
static ThemeData get lightTheme
static ThemeData get darkTheme
static ThemeData get blueTheme
static ThemeData get greenTheme
static ThemeData get orangeTheme
static ThemeData get highContrastTheme
static Map<String, ThemeData> get allThemes
```

### PerformanceTracker

```dart
PerformanceTracker({bool enabled = true})

// Methods
void recordSearch({required String query, required int resultCount, required Duration executionTime, bool fromCache})
Future<T> trackSearch<T>({required String query, required Future<T> Function() operation, required int Function(T) getResultCount, bool fromCache})
void reset()
void printReport()

// Getters
Duration get averageExecutionTime
Duration get averageCachedExecutionTime
Duration get averageUncachedExecutionTime
Duration get p95ExecutionTime
double get cacheHitRate
int get totalSearches
List<PerformanceMetric> get metrics
PerformanceStats get stats
```

## 🎯 Use Cases

### Example 1: Remote API with Fake Backend

```dart
import 'package:examples_shared/examples_shared.dart';

final backend = FakeSearchBackend(
  latency: Duration(milliseconds: 200), // Simulate network
  errorRate: 0.05, // 5% errors
  itemCount: 10000,
);

// Use in provider
final searchProvider = Provider((ref) => backend);
```

### Example 2: Performance Benchmarking

```dart
import 'package:examples_shared/examples_shared.dart';

final tracker = PerformanceTracker();

// Track searches
for (var query in testQueries) {
  await tracker.trackSearch(
    query: query,
    operation: () => search(query),
    getResultCount: (r) => r.items.length,
  );
}

// Compare results
print('Average: ${tracker.averageExecutionTime.inMilliseconds}ms');
print('P95: ${tracker.p95ExecutionTime.inMilliseconds}ms');
```

### Example 3: Theme Switcher

```dart
import 'package:examples_shared/examples_shared.dart';

class MyApp extends StatefulWidget {
  // ...
}

class _MyAppState extends State<MyApp> {
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppThemes.allThemes[_selectedTheme],
      // ...
    );
  }
}
```

## 🔧 Development

### Running Tests

```bash
cd examples/_shared
flutter test
```

### Analyzing Code

```bash
flutter analyze
```

### Formatting

```bash
dart format .
```

## 📝 Notes

- This package is **not published** to pub.dev - it's local only
- Uses `path` dependency in examples
- Faker generates different data on each run
- Performance tracker keeps last 100 metrics
- All themes use Material 3

## 🔗 Related

- [Main Package](../../) - app_wide_search
- [Quickstart Example](../quickstart_minimal/) - Simple beginner example
- [Full Example](../../example/) - Complete feature showcase

---

**Part of app_wide_search v0.2.0**  
_Last updated: October 2, 2025_
