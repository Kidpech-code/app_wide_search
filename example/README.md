# app_wide_search example

A minimal example that wires the **app_wide_search** package into a Flutter
application using the provided `AppWideSearchDelegate`. The example overrides
`searchProviderProvider` with the built-in `InMemorySearchProvider`, registers
Hive adapters, and customizes both the suggestion and results builders.

## What it shows

- ProviderScope override with an in-memory search provider
- Hive initialization and adapter registration
- Custom suggestion and result builders that highlight group metadata
- Launching the search UI via `showSearch`

## Running the example

```bash
flutter pub get
flutter run -d chrome
```

The example has been tested with Flutter 3.24.0 and Dart 3.8.0. Use a Chrome
desktop runtime or any other supported Flutter device.
