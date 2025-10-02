# Examples Matrix — app_wide_search v0.1.0

**Purpose**: Map user personas and use cases to specific examples  
**Audit Date**: 2025-10-02

---

## User Personas

### 👨‍💻 Persona 1: Flutter Beginner

**Experience**: 0-6 months Flutter  
**Goals**: Quick integration, minimal code, copy-paste ready  
**Pain Points**: Overwhelmed by configuration options

### 👩‍💻 Persona 2: Mobile App Developer

**Experience**: 1-2 years Flutter, shipping apps  
**Goals**: Production-ready patterns, best practices, performance  
**Pain Points**: Needs examples that scale to real apps

### 🧑‍💼 Persona 3: Enterprise Developer

**Experience**: 3+ years, large teams  
**Goals**: Customization, testing, accessibility, compliance  
**Pain Points**: Generic examples don't fit complex requirements

### 🔬 Persona 4: Performance Engineer

**Experience**: Expert level, optimizing for scale  
**Goals**: Benchmarks, profiling, optimization techniques  
**Pain Points**: Needs quantitative metrics and profiling data

---

## Use Cases

### UC-1: Simple In-Memory Search

**Description**: Static list of items, no backend, no persistence  
**Complexity**: ⭐ (Beginner)  
**Common For**: Learning, prototypes, small apps (<1000 items)

### UC-2: Full-Featured App Integration

**Description**: Grouped results, routing, caching, history  
**Complexity**: ⭐⭐ (Intermediate)  
**Common For**: Standard mobile apps with search feature

### UC-3: Remote API Integration

**Description**: HTTP requests, cancellation, error handling, retry logic  
**Complexity**: ⭐⭐⭐ (Advanced)  
**Common For**: Apps with server-side search, dynamic data

### UC-4: Offline-First Architecture

**Description**: Local cache priority, sync, conflict resolution  
**Complexity**: ⭐⭐⭐ (Advanced)  
**Common For**: Apps requiring offline functionality

### UC-5: Accessibility Compliance

**Description**: Screen readers, keyboard nav, WCAG 2.1 AA  
**Complexity**: ⭐⭐ (Intermediate)  
**Common For**: Government, education, healthcare apps

### UC-6: Custom Branding

**Description**: Custom themes, colors, animations, layouts  
**Complexity**: ⭐⭐ (Intermediate)  
**Common For**: White-label apps, brand-specific requirements

### UC-7: Performance Optimization

**Description**: Large datasets, profiling, benchmarking  
**Complexity**: ⭐⭐⭐⭐ (Expert)  
**Common For**: Apps with >10k items, performance-critical scenarios

---

## Coverage Matrix

| Persona / Use Case    | UC-1 Simple           | UC-2 Full-Featured | UC-3 Remote API | UC-4 Offline | UC-5 Accessibility | UC-6 Branding        | UC-7 Performance         |
| --------------------- | --------------------- | ------------------ | --------------- | ------------ | ------------------ | -------------------- | ------------------------ |
| **P1: Beginner**      | ✅ quickstart_minimal | ✅ example/main    | ❌ Missing      | ❌ Missing   | ❌ Missing         | ⚠️ Partial (example) | ❌ Missing               |
| **P2: Mobile Dev**    | ✅ quickstart_minimal | ✅ example/main    | ❌ Missing      | ❌ Missing   | ❌ Missing         | ⚠️ Partial (example) | ⚠️ Partial (benchmarks/) |
| **P3: Enterprise**    | ⚠️ Too simple         | ✅ example/main    | ❌ Missing      | ❌ Missing   | ❌ Missing         | ❌ Missing           | ❌ Missing               |
| **P4: Perf Engineer** | N/A                   | N/A                | N/A             | N/A          | N/A                | N/A                  | ⚠️ Partial (benchmarks/) |

**Legend**:

- ✅ Fully Covered
- ⚠️ Partially Covered
- ❌ Not Covered
- N/A Not Applicable

---

## Existing Examples Analysis

### ✅ Example 1: quickstart_minimal

**Location**: `examples/quickstart_minimal/`  
**Target Persona**: P1 (Beginner)  
**Use Case**: UC-1 (Simple In-Memory)  
**Status**: ✅ Complete

**What it Demonstrates**:

- Minimal setup (~100 LOC)
- InMemorySearchProvider
- Basic SearchDelegate usage
- No routing, no caching

**Strengths**:

- ✅ Copy-paste ready
- ✅ Runs in <90 seconds from install
- ✅ Clear, well-commented code
- ✅ Has README with run instructions

**Gaps**:

- No error handling shown
- No customization examples
- Doesn't show SearchScreen (only Delegate)

**Grade**: A+ (Excellent for intended audience)

---

### ✅ Example 2: example/main

**Location**: `example/`  
**Target Persona**: P2 (Mobile Dev), P3 (Enterprise)  
**Use Cases**: UC-2 (Full-Featured), UC-6 (Branding - partial)  
**Status**: ✅ Complete

**What it Demonstrates**:

- Grouped results with ExpansionTile
- go_router integration
- SearchDelegate + SearchScreen
- Cache demo comparison
- Theme switching (6 themes)
- Performance tracking UI
- Sample data generation

**Strengths**:

- ✅ Comprehensive feature showcase
- ✅ Real-world architecture patterns
- ✅ Well-organized sections
- ✅ Interactive UI for learning
- ✅ Performance demo included

**Gaps**:

- Doesn't show remote API pattern
- No error recovery examples
- No offline sync example
- Accessibility features not highlighted

**Grade**: A- (Excellent but could cover more scenarios)

---

### ⚠️ Example 3: benchmarks/

**Location**: `example/benchmarks/`  
**Target Persona**: P4 (Performance Engineer)  
**Use Case**: UC-7 (Performance)  
**Status**: ⚠️ Partial

**What it Demonstrates**:

- Basic performance test harness
- Latency measurement
- Dataset size variations

**Strengths**:

- ✅ Provides quantitative data
- ✅ Automated testing

**Gaps**:

- No profiling instructions
- No flame graph generation
- No memory leak tests
- Not integrated with CI

**Grade**: C+ (Functional but needs enhancement)

---

## Missing Examples (High Priority)

### ❌ Example 4: remote_api

**Target Persona**: P2, P3  
**Use Case**: UC-3 (Remote API)  
**Priority**: HIGH  
**ETA**: 4 hours

**Should Demonstrate**:

```dart
class RemoteSearchProvider extends SearchProvider {
  // HTTP requests with dio/http
  // Cancellation token usage
  // Timeout handling
  // Retry with exponential backoff
  // Error states (network, server, timeout)
  // Loading indicators
  // Pagination
}
```

**Key Files**:

- `lib/main.dart` - API integration
- `lib/providers/api_search_provider.dart` - Provider impl
- `lib/models/api_error.dart` - Error handling
- `README.md` - Setup, mock API instructions
- `test/api_search_test.dart` - Unit tests

**README Should Include**:

- How to run with mock server
- Performance notes (latency, cancellation rate)
- Gotchas (CORS, rate limiting)

---

### ❌ Example 5: offline_first

**Target Persona**: P2, P3  
**Use Case**: UC-4 (Offline)  
**Priority**: HIGH  
**ETA**: 6 hours

**Should Demonstrate**:

```dart
class OfflineSearchProvider extends SearchProvider {
  // Cache-first strategy
  // Background sync
  // Conflict resolution
  // Offline indicator
  // Sync status
}
```

**Key Patterns**:

- Try cache first, fallback to API
- Queue writes for sync
- Show "cached" badge on results
- Handle stale data

---

### ❌ Example 6: accessibility

**Target Persona**: P3 (Enterprise)  
**Use Case**: UC-5 (Accessibility)  
**Priority**: MEDIUM  
**ETA**: 5 hours

**Should Demonstrate**:

```dart
// Semantic labels
Semantics(
  label: 'Search for products',
  hint: 'Type to filter results',
  child: SearchField(),
)

// Keyboard navigation
Focus(
  onKeyEvent: (node, event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      // Handle enter
    }
  },
)

// Screen reader announcements
SemanticsService.announce(
  'Found ${results.length} results',
  TextDirection.ltr,
);
```

**Testing**:

- Screen reader test script
- Keyboard-only navigation test
- Color contrast validation

---

### ❌ Example 7: custom_theme

**Target Persona**: P2, P3  
**Use Case**: UC-6 (Branding)  
**Priority**: MEDIUM  
**ETA**: 3 hours

**Should Demonstrate**:

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      SearchThemeData(
        resultItemPadding: EdgeInsets.all(20),
        groupHeaderColor: Colors.purple,
        emptyStateIcon: Icons.rocket,
      ),
    ],
  ),
)

// Custom result builder
GroupedSearchResults(
  itemBuilder: (context, item) {
    return CustomBrandedResultCard(item: item);
  },
  groupHeaderBuilder: (context, group, count, expanded) {
    return BrandedGroupHeader(group: group);
  },
)
```

**Before/After Screenshots**:

- Default theme
- Custom branded theme
- Dark mode variant

---

## Enhanced Examples Roadmap

### Phase 1: Critical Gaps (P0) - Week 1

1. ✅ Format existing examples
2. ✅ Fix analyzer warnings
3. ✅ Restructure to pub.dev convention

### Phase 2: Essential Examples (P1) - Week 2

4. ❌ Create remote_api example
5. ❌ Create offline_first example
6. ✅ Enhance benchmarks with profiling

### Phase 3: Enterprise Examples (P1-P2) - Week 3

7. ❌ Create accessibility example
8. ❌ Create custom_theme example
9. ❌ Add advanced patterns guide

### Phase 4: Polish (P2-P3) - Week 4

10. Add video tutorials
11. Add interactive playground (web)
12. Add migration guides

---

## Example Quality Checklist

Each example MUST have:

- [ ] **README.md** with:

  - What it demonstrates
  - How to run (step-by-step)
  - Prerequisites
  - Expected output
  - Performance notes
  - Gotchas/limitations

- [ ] **Well-commented code**:

  - Explain WHY not just WHAT
  - Link to relevant docs
  - Note non-obvious patterns

- [ ] **Runnable out-of-box**:

  - `flutter pub get && flutter run` works
  - No manual configuration
  - Mock data included

- [ ] **Tests** (where applicable):

  - Unit tests for providers
  - Widget tests for UI
  - Integration test if complex

- [ ] **Performance notes**:

  - Expected metrics
  - Bottlenecks
  - Optimization tips

- [ ] **Screenshots** (for UI examples):
  - Light + dark mode
  - Different states (empty, error, loading)
  - Platform variations if relevant

---

## Recommendations

### Immediate (Before v0.1.0)

1. Add READMEs to existing examples with:

   - "What this demonstrates"
   - "How to run"
   - "Key learnings"

2. Add troubleshooting section to example READMEs

3. Add performance notes to benchmarks

### Pre-v1.0

4. Create 4 missing examples (remote_api, offline_first, accessibility, custom_theme)

5. Add video walkthroughs for each example

6. Create interactive web demo at https://kidpech-code.github.io/app_wide_search/

### Post-v1.0

7. Add examples for:

   - Multi-language search
   - Fuzzy matching
   - Voice search integration
   - Search analytics

8. Create "cookbook" with snippets for common tasks

---

## Coverage Score

| Dimension              | Coverage  | Target | Gap                               |
| ---------------------- | --------- | ------ | --------------------------------- |
| **Personas**           | 2/4 (50%) | 4/4    | -2 personas                       |
| **Use Cases**          | 2/7 (29%) | 6/7    | -4 use cases                      |
| **Quality** (existing) | 9/10      | 10/10  | -1 point (needs tests)            |
| **Documentation**      | 7/10      | 10/10  | -3 points (needs troubleshooting) |

**Overall Score**: 47% coverage  
**Target**: 80% coverage for v1.0  
**Gap**: Need 4 more examples + enhanced docs

---

**Recommendation**: Create **remote_api** and **offline_first** examples as minimum for production launch. Add **accessibility** and **custom_theme** for v1.0 milestone.
