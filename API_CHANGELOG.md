# API Changelog

**Package:** `app_wide_search`  
**Version:** 0.1.0 → 0.2.0  
**Type:** Minor Release (Backward Compatible)

---

## Summary

Version 0.2.0 adds **production-critical cancellation support** to prevent memory leaks and race conditions, while upgrading dependencies to latest stable versions. **Zero breaking changes** to existing API - all additions are backward compatible.

---

## Public API Changes

### ✅ New Exports

```dart
// lib/app_wide_search.dart
export 'src/models/cancellation_token.dart';  // NEW
```

**Added Classes:**

- `CancellationToken` - Token for cancelling async operations
- `CancelledException` - Exception thrown when operation cancelled

---

## Interface Changes

### `SearchProvider` (Abstract Class)

**Method Signature Update:**

```dart
// BEFORE (v0.1.0)
abstract class SearchProvider {
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
  });
}

// AFTER (v0.2.0)
abstract class SearchProvider {
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
    CancellationToken? cancellationToken,  // NEW: optional parameter
  });
}
```

**Impact:** ✅ **BACKWARD COMPATIBLE**

- New parameter is **optional** with default `null`
- Existing implementations work without changes
- Recommended to implement cancellation for production apps

**Migration:** None required, but recommended:

```dart
// Option 1: Ignore cancellation (works as-is)
class MyProvider extends SearchProvider {
  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
    CancellationToken? cancellationToken,  // Just add parameter
  }) async {
    // Your existing code works unchanged
    return performSearch(query);
  }
}

// Option 2: Implement cancellation (recommended)
class MyProvider extends SearchProvider {
  CancellationToken? _activeToken;

  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
    CancellationToken? cancellationToken,
  }) async {
    // Cancel previous search
    _activeToken?.cancel();
    _activeToken = cancellationToken ?? CancellationToken();

    try {
      // Check before expensive operations
      _activeToken!.throwIfCancelled();

      final result = await expensiveSearch(query);

      // Check before returning
      _activeToken!.throwIfCancelled();

      return result;
    } on CancelledException {
      return SearchResult.empty(query);
    }
  }
}
```

---

## Dependency Changes

### Major Version Upgrades

| Dependency       | Before  | After   | Breaking?                  |
| ---------------- | ------- | ------- | -------------------------- |
| **go_router**    | ^14.0.2 | ^16.0.0 | ⚠️ **BREAKING** (for apps) |
| flutter_lints    | ^5.0.0  | ^6.0.0  | ⚠️ Stricter rules          |
| intl             | ^0.19.0 | ^0.20.0 | ✅ Compatible              |
| flutter_riverpod | ^2.5.1  | ^2.6.0  | ✅ Compatible              |

**Critical:** `go_router` upgraded from 14.x → 16.x

- **Package API:** No breaking changes
- **Your App:** May need to upgrade `go_router` if using our package

**Migration for Apps:**

```yaml
# pubspec.yaml
dependencies:
  app_wide_search: ^0.2.0
  go_router: ^16.0.0 # Upgrade from ^14.0.0
```

**go_router 14.x → 16.x Breaking Changes:**

1. `GoRouter.of(context)` → use `GoRouterState.of(context)` in some cases
2. Route configuration builder changes (minor)
3. See [go_router changelog](https://pub.dev/packages/go_router/changelog)

---

## New Features

### CancellationToken API

**Purpose:** Prevent memory leaks and race conditions in async search operations.

**Use Cases:**

1. ✅ Cancel network requests when user types new query
2. ✅ Abort expensive computations when navigating away
3. ✅ Prevent stale results from overwriting newer ones

**Example:**

```dart
class SearchViewModel {
  final SearchProvider _provider;
  CancellationToken? _searchToken;

  Future<void> search(String query) async {
    // Cancel previous search
    _searchToken?.cancel();
    _searchToken = CancellationToken();

    try {
      final result = await _provider.search(
        query,
        cancellationToken: _searchToken,
      );

      // Update UI with result
      _updateResults(result);
    } on CancelledException {
      // Search was cancelled, ignore
    }
  }
}
```

**API Documentation:**

```dart
/// A token that can be used to cancel asynchronous operations.
///
/// Pass to search operations to allow cancelling long-running searches.
class CancellationToken {
  /// Whether this token has been cancelled.
  bool get isCancelled;

  /// Cancels this token and notifies all listeners.
  void cancel();

  /// Registers a callback to be called when cancelled.
  void Function() onCancelled(void Function() callback);

  /// Throws [CancelledException] if this token has been cancelled.
  void throwIfCancelled();
}

/// Exception thrown when an operation is cancelled.
class CancelledException implements Exception {
  const CancelledException();
}
```

---

## Deprecations

**None.** All existing APIs remain supported.

---

## Breaking Changes

### For Package Users: ✅ None

All changes are backward compatible. Existing code works without modification.

### For App Dependencies: ⚠️ go_router 16.x

If your app uses `go_router` directly, you'll need to upgrade:

```bash
flutter pub upgrade go_router
```

**Impact:** Low - Most apps will upgrade smoothly. Check [go_router migration guide](https://pub.dev/packages/go_router) if you hit issues.

---

## Semver Justification

### Why Minor (0.2.0) Not Major (1.0.0)?

✅ **Backward Compatible:**

- No existing method signatures changed
- New parameters are optional
- Existing implementations work unchanged
- No deprecated APIs removed

✅ **Added Features:**

- `CancellationToken` API (opt-in)
- `CancelledException` exception type

⚠️ **Dependency Upgrade:**

- `go_router` 16.x is a dependency change, not API change
- Apps control their own go_router version
- No breaking changes in `app_wide_search` public API

**Conclusion:** Minor version bump is correct per [Semantic Versioning](https://semver.org):

> MINOR version when you add functionality in a backwards compatible manner

---

## Migration Guide

### From v0.1.x to v0.2.0

**Step 1:** Update dependency

```yaml
# pubspec.yaml
dependencies:
  app_wide_search: ^0.2.0
```

**Step 2:** Upgrade go_router (if needed)

```yaml
# pubspec.yaml
dependencies:
  go_router: ^16.0.0 # Was: ^14.0.0
```

**Step 3:** Run pub upgrade

```bash
flutter pub upgrade
```

**Step 4:** (Optional) Implement cancellation

```dart
class MySearchProvider extends SearchProvider {
  @override
  Future<SearchResult> search(
    String query, {
    int limit = 20,
    int offset = 0,
    CancellationToken? cancellationToken,  // Add this parameter
  }) async {
    // Add cancellation checks for long operations
    cancellationToken?.throwIfCancelled();

    final result = await yourSearchLogic(query);

    cancellationToken?.throwIfCancelled();

    return result;
  }
}
```

**Step 5:** Test

```bash
flutter test
```

**Expected:** All existing tests pass without changes.

---

## Testing Recommendations

After upgrading, test these scenarios:

1. ✅ Basic search still works
2. ✅ Navigation with go_router works
3. ✅ Search history and cache work
4. ✅ (Optional) Rapid typing cancels previous searches

**Sample Test:**

```dart
test('search with cancellation', () async {
  final provider = MySearchProvider();
  final token = CancellationToken();

  // Start search
  final future = provider.search('query', cancellationToken: token);

  // Cancel immediately
  token.cancel();

  // Should either complete or throw CancelledException
  expect(
    future,
    anyOf([
      completes,
      throwsA(isA<CancelledException>()),
    ]),
  );
});
```

---

## Rollback Plan

If issues arise, you can rollback:

```yaml
# pubspec.yaml
dependencies:
  app_wide_search: ^0.1.0 # Previous version
  go_router: ^14.0.0
```

```bash
flutter pub downgrade
```

---

## Future Deprecations

**None planned.** All APIs in v0.2.0 will remain supported through v0.x and v1.x.

---

## Questions & Support

- 📖 **Documentation:** [README.md](README.md)
- 🐛 **Issues:** [GitHub Issues](https://github.com/kidpech-code/app_wide_search/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/kidpech-code/app_wide_search/discussions)

---

**Last Updated:** 2025-10-02  
**Next Review:** v0.3.0 release
