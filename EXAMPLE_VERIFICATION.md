# Example Verification Log

**Package**: app_wide_search v0.1.1  
**Date**: 2025-10-03

This log captures the most recent sanity checks executed against the shipped examples. All commands were run on macOS using Flutter 3.32.8 / Dart 3.8.1.

---

## Summary

| Example                       | Command           | Status     | Notes                                                                                                           |
| ----------------------------- | ----------------- | ---------- | --------------------------------------------------------------------------------------------------------------- |
| `example/`                    | `flutter pub get` | ✅ Success | Dependencies resolve; pub reports 13 transitive packages with newer versions (acceptable under Flutter SDK pin) |
| `example/`                    | `flutter analyze` | ✅ Success | No issues found                                                                                                 |
| `example/`                    | `flutter test`    | ⚠️ Not Run | Command exits with code 1 because the example intentionally omits a `test/` directory                           |
| `example/quickstart_minimal/` | `flutter pub get` | ✅ Success | Dependencies resolve after bumping `flutter_riverpod` to ^3.0.1                                                 |
| `example/quickstart_minimal/` | `flutter analyze` | ✅ Success | No issues found                                                                                                 |

---

## Detailed Logs

### example/

<details>
<summary><code>flutter pub get</code></summary>

```
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 85.0.0 (89.0.0 available)
  analyzer 7.7.1 (8.2.0 available)
  characters 1.4.0 (1.4.1 available)
  leak_tracker 10.0.9 (11.0.2 available)
  leak_tracker_flutter_testing 3.0.9 (3.0.10 available)
  leak_tracker_testing 3.0.1 (3.0.2 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  meta 1.16.0 (1.17.0 available)
  test 1.25.15 (1.26.3 available)
  test_api 0.7.4 (0.7.7 available)
  test_core 0.6.8 (0.6.12 available)
  vector_math 2.1.4 (2.2.0 available)
  vm_service 15.0.0 (15.0.2 available)
Got dependencies!
13 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

</details>

<details>
<summary><code>flutter analyze</code></summary>

```
Analyzing example...
No issues found! (ran in 1.6s)
```

</details>

<details>
<summary><code>flutter test</code></summary>

```
Test directory "test" not found.
```

The quickstart showcase does not include tests; this is acceptable for UI-only samples. Add smoke tests if future automation requires it.

</details>

---

### example/quickstart_minimal/

<details>
<summary><code>flutter pub get</code></summary>

```
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 85.0.0 (89.0.0 available)
  analyzer 7.7.1 (8.2.0 available)
  characters 1.4.0 (1.4.1 available)
  leak_tracker 10.0.9 (11.0.2 available)
  leak_tracker_flutter_testing 3.0.9 (3.0.10 available)
  leak_tracker_testing 3.0.1 (3.0.2 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  meta 1.16.0 (1.17.0 available)
  test 1.25.15 (1.26.3 available)
  test_api 0.7.4 (0.7.7 available)
  test_core 0.6.8 (0.6.12 available)
  vector_math 2.1.4 (2.2.0 available)
  vm_service 15.0.0 (15.0.2 available)
Got dependencies!
13 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

</details>

<details>
<summary><code>flutter analyze</code></summary>

```
Analyzing quickstart_minimal...
No issues found! (ran in 1.5s)
```

</details>

---

## Next Steps

- Keep the quickstart `pubspec.yaml` aligned with the main package (currently targeting `flutter_riverpod` ^3.0.1 and Flutter >=3.24.0).
- Add a smoke test harness (e.g., golden or widget test) if automated validation for examples becomes necessary.
- When cutting a release, re-run these commands to capture fresh logs for the archive.
