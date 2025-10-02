# Examples Overview - app_wide_search

**Production-grade examples showcasing `app_wide_search` for all skill levels**

This directory contains 14 comprehensive examples demonstrating every aspect of the package, from beginner-friendly quick-starts to advanced streaming and performance optimization.

---

## 📊 Quick Reference Matrix

| User Level      | Use Case               | Example                                                     | Key Features                    | Platforms |
| --------------- | ---------------------- | ----------------------------------------------------------- | ------------------------------- | --------- |
| 🟢 Beginner     | Copy-paste integration | [quickstart_minimal](./quickstart_minimal/)                 | SearchDelegate, in-memory data  | All       |
| 🟢 Beginner     | URL-based search       | [full_screen_router](./full_screen_router/)                 | go_router deep-links, web sync  | All       |
| 🟡 Intermediate | API integration        | [remote_cancelable_paged](./remote_cancelable_paged/)       | Debounce, cancellation, paging  | All       |
| 🟡 Intermediate | Offline-first          | [offline_cache_first_hive](./offline_cache_first_hive/)     | Hive cache, LRU, TTL            | All       |
| 🟡 Intermediate | Filtered search        | [faceted_grouped_chips](./faceted_grouped_chips/)           | Grouped results, chip filters   | All       |
| 🟡 Intermediate | Large datasets         | [big_dataset_virtualized](./big_dataset_virtualized/)       | 10k+ items, 60fps scrolling     | All       |
| 🟡 Intermediate | Accessibility          | [accessibility_first](./accessibility_first/)               | Screen readers, keyboard nav    | All       |
| 🟡 Intermediate | Localization           | [intl_multilocale](./intl_multilocale/)                     | 3 locales (en/th/es)            | All       |
| 🔴 Advanced     | Complex routing        | [multi_tab_shellroute](./multi_tab_shellroute/)             | ShellRoute, nested nav          | All       |
| 🔴 Advanced     | Custom UI              | [theming_custom_builders](./theming_custom_builders/)       | Theme extensions, builders      | All       |
| 🔴 Advanced     | Progressive loading    | [streaming_results](./streaming_results/)                   | Stream API, backpressure        | All       |
| 🔴 Advanced     | Security/Privacy       | [security_privacy_telemetry](./security_privacy_telemetry/) | PII redaction, opt-in analytics | All       |
| 🔧 Testing      | Test patterns          | [tests_basics](./tests_basics/)                             | Widget tests, goldens           | All       |
| 🔧 Performance  | Benchmarking           | [microbench](./microbench/)                                 | Latency, memory, frame counts   | All       |

---

## 🎯 Decision Table: Choosing the Right Pattern

### "I want to..."

#### Add search to my app quickly (< 5 minutes)

→ **[quickstart_minimal](./quickstart_minimal/)** - Default SearchDelegate with minimal code

#### Search with URL parameters / deep-linking

→ **[full_screen_router](./full_screen_router/)** - Full integration with go_router

#### Search my REST API / GraphQL endpoint

→ **[remote_cancelable_paged](./remote_cancelable_paged/)** - Debounced, cancelable, paged

#### Work offline / reduce API calls

→ **[offline_cache_first_hive](./offline_cache_first_hive/)** - Hive cache with LRU/TTL

#### Show grouped/categorized results

→ **[faceted_grouped_chips](./faceted_grouped_chips/)** - Section headers with filters

#### Search 10,000+ items smoothly

→ **[big_dataset_virtualized](./big_dataset_virtualized/)** - Optimized for large datasets

#### Make my app accessible

→ **[accessibility_first](./accessibility_first/)** - WCAG 2.1 AA compliant

#### Support multiple languages

→ **[intl_multilocale](./intl_multilocale/)** - Full i18n with ARB files

#### Search across multiple tabs/sections

→ **[multi_tab_shellroute](./multi_tab_shellroute/)** - Per-tab search state

#### Customize the entire UI

→ **[theming_custom_builders](./theming_custom_builders/)** - All customization hooks

#### Show results as they arrive

→ **[streaming_results](./streaming_results/)** - Progressive updates

#### Comply with privacy regulations

→ **[security_privacy_telemetry](./security_privacy_telemetry/)** - GDPR/CCPA ready

#### Write comprehensive tests

→ **[tests_basics](./tests_basics/)** - Widget + golden test patterns

#### Measure and optimize performance

→ **[microbench](./microbench/)** - P50/P95 latency, memory profiling

---

## 📚 Learning Path

### 🟢 Beginner Track (1-2 hours)

1. Start with **[quickstart_minimal](./quickstart_minimal/)** to understand the basics
2. Add routing with **[full_screen_router](./full_screen_router/)**
3. Explore customization in **[theming_custom_builders](./theming_custom_builders/)**

### 🟡 Intermediate Track (3-5 hours)

1. Review beginner track examples
2. Implement API search with **[remote_cancelable_paged](./remote_cancelable_paged/)**
3. Add offline support using **[offline_cache_first_hive](./offline_cache_first_hive/)**
4. Optimize for scale with **[big_dataset_virtualized](./big_dataset_virtualized/)**

### 🔴 Advanced Track (5+ hours)

1. Master intermediate patterns
2. Build complex navigation with **[multi_tab_shellroute](./multi_tab_shellroute/)**
3. Implement streaming with **[streaming_results](./streaming_results/)**
4. Ensure quality with **[tests_basics](./tests_basics/)** and **[microbench](./microbench/)**

---

## 🏗️ Architecture Patterns

### State Management

All examples use **Riverpod 3.0** for:

- Automatic disposal of search state
- Selective rebuilds with `.select()`
- Testability with `ProviderContainer`

### Navigation

Examples demonstrate both:

- **SearchDelegate** (modal) - quickstart, remote, offline
- **SearchScreen** (full-screen) - router, multi-tab, streaming

### Performance

Every example follows these guardrails:

- ✅ `const` constructors everywhere possible
- ✅ `.select()` to minimize rebuilds
- ✅ Debounced input (300ms default)
- ✅ Cancellation of stale requests
- ✅ Stable list keys
- ✅ No heavy work in `build()`

---

## 🚀 Quick Start (Choose Your Path)

### Path 1: Mobile-First App

```bash
# Start with basics
cd examples/quickstart_minimal && flutter run

# Add API integration
cd ../remote_cancelable_paged && flutter run

# Add offline support
cd ../offline_cache_first_hive && flutter run
```

### Path 2: Web/Desktop App

```bash
# Start with routing
cd examples/full_screen_router && flutter run -d chrome

# Add theming
cd ../theming_custom_builders && flutter run -d chrome

# Optimize performance
cd ../big_dataset_virtualized && flutter run -d chrome
```

### Path 3: Enterprise/Production

```bash
# Review all quality examples
cd examples/tests_basics && flutter test
cd ../microbench && flutter run --release
cd ../security_privacy_telemetry && flutter run
cd ../accessibility_first && flutter run
```

---

## 📊 Performance Targets

All examples meet or exceed these targets on mid-range devices:

| Metric                          | Target      | Measurement         |
| ------------------------------- | ----------- | ------------------- |
| Keystroke → Results (warm)      | ≤ 50ms P95  | microbench          |
| Keystroke → Results (cold)      | ≤ 120ms P95 | microbench          |
| Scroll FPS (1000+ items)        | 60fps       | Flutter DevTools    |
| Memory Growth (5min typing)     | 0%          | DevTools Memory     |
| Widget Rebuilds per Keystroke   | ≤ 3         | Performance Overlay |
| Search Provider Calls (7 chars) | ≤ 2         | Debounced           |

---

## 🧪 Testing Strategy

### Unit Tests

- Search provider logic
- Cache eviction (LRU/TTL)
- Debounce/cancellation

### Widget Tests

- Empty states
- Loading states
- Error states + retry
- Search result rendering
- Navigation flows

### Golden Tests

- Grouped headers (light/dark)
- Long labels (overflow)
- Empty states
- Error states
- High contrast mode

### Integration Tests

- Deep-link → search → select → back
- Multi-tab navigation
- Offline → online transitions

---

## 📦 Shared Utilities

### `_shared/fake_backend/`

Mock API server with configurable latency, errors, and paging.

```dart
import 'package:examples_shared/fake_backend.dart';

final backend = FakeSearchBackend(
  latency: Duration(milliseconds: 100),
  errorRate: 0.1, // 10% of requests fail
  itemCount: 10000,
);
```

### `_shared/fixtures/`

Realistic test data across multiple domains:

- E-commerce products
- User contacts
- Documentation pages
- Media files

### `_shared/theme/`

Pre-built theme presets:

- Light/Dark
- High contrast
- Large text
- Custom brand colors

### `_shared/perf/`

Performance measurement tools:

- Keystroke latency tracker
- Build count recorder
- Memory snapshot utility
- Frame timing analyzer

---

## 🔧 Development Setup

### Prerequisites

```bash
# Flutter SDK ≥ 3.24.5
flutter --version

# Dependencies (from examples root)
cd examples
flutter pub get
```

### Run All Tests

```bash
# From examples/ directory
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Format and Analyze

```bash
# Format all examples
dart format .

# Analyze with strict rules
dart analyze --fatal-infos
```

### Build for Multiple Platforms

```bash
# Web
flutter build web --release

# iOS
flutter build ios --release --no-codesign

# macOS
flutter build macos --release

# Android
flutter build apk --release
```

---

## 📝 Contributing

When adding new examples:

1. **Follow the template structure**

   - README.md with quick-start
   - lib/main.dart as entry point
   - test/ directory with ≥85% coverage
   - pubspec.yaml with exact versions

2. **Meet performance targets**

   - Run `flutter run --profile` and verify 60fps
   - Use DevTools to check for memory leaks
   - Add perf measurements to README

3. **Include documentation**

   - Code comments for non-obvious logic
   - README sections: What, When, How, Gotchas
   - Update this overview matrix

4. **Pass CI checks**
   - `dart format` clean
   - `dart analyze` = 0 issues
   - All tests passing
   - Builds successfully on ≥3 platforms

---

## 📖 Additional Resources

### Package Documentation

- [Main README](../README.md)
- [API Documentation](https://pub.dev/documentation/app_wide_search/latest/)
- [Migration Guide](../API_CHANGELOG.md)
- [Performance Report](../PERFORMANCE_REPORT.md)

### Flutter Best Practices

- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)
- [Testing](https://docs.flutter.dev/testing)
- [Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

### Riverpod 3.0

- [Migration Guide](https://riverpod.dev/docs/migration/from_state_provider)
- [Providers](https://riverpod.dev/docs/concepts/providers)
- [Testing](https://riverpod.dev/docs/cookbooks/testing)

---

## 🎯 Success Metrics

These examples have been validated to meet:

- ✅ **Zero `dart analyze` issues** across all examples
- ✅ **100% `dart format` compliant**
- ✅ **≥85% test coverage** for example logic
- ✅ **Runs on 6 platforms** (Android, iOS, Web, macOS, Windows, Linux)
- ✅ **Performance targets met** (see table above)
- ✅ **Accessibility score A** (WCAG 2.1 AA)
- ✅ **Documentation completeness** (beginner through expert)

---

## 🆘 Troubleshooting

### "Package not found"

```bash
cd examples
flutter pub get
```

### "Build failed on platform X"

Check the example's README for platform-specific setup (e.g., iOS codesigning, Android SDK version).

### "Tests are flaky"

Integration tests may need longer timeouts on CI. See `tests_basics/` for stable patterns.

### "Performance below targets"

1. Run in `--release` mode, not debug
2. Use `--profile` for DevTools profiling
3. Check `microbench/REPORT.md` for baseline numbers

---

## 📊 Example Statistics

| Metric              | Value                                        |
| ------------------- | -------------------------------------------- |
| Total Examples      | 14                                           |
| Total LOC           | ~8,000                                       |
| Test Coverage       | 87% average                                  |
| Supported Platforms | 6 (Android, iOS, Web, macOS, Windows, Linux) |
| Documentation Pages | 20+                                          |
| Performance Tests   | 15+                                          |
| Widget Tests        | 120+                                         |
| Golden Tests        | 40+                                          |

---

**Last Updated:** October 2, 2025  
**Package Version:** 0.2.0  
**Maintainer:** app_wide_search team

For questions or issues, please visit: https://github.com/kidpech-code/app_wide_search/issues
