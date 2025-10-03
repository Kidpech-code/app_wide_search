# Quickstart Minimal Example

**The simplest possible app_wide_search implementation in ~100 lines of code.**

Perfect for absolute beginners who want to add search to their Flutter app in under 5 minutes.

## What You'll Learn

- ✅ How to add search to any Flutter app with just 3 steps
- ✅ Using `InMemorySearchProvider` for simple data
- ✅ Opening search with `showSearch()` and `AppWideSearchDelegate`
- ✅ Creating `SearchItem` objects

## What's NOT Included

This example deliberately excludes advanced features to keep it simple:

- ❌ No routing/navigation (see `full_screen_router` example)
- ❌ No persistence/caching (see current `/example` app)
- ❌ No API integration (see `remote_cancelable_paged` example)
- ❌ No grouped results (see current `/example` app)
- ❌ No customization (see `theming_custom_ui` example)

## Quick Start

### 1. Run the Example

```bash
cd example/quickstart_minimal
flutter pub get
flutter run
```

### 2. Try It Out

1. Tap the search icon (🔍) in the app bar
2. Type "iPhone" or "John" or "Flutter"
3. See instant search results!

That's it! 🎉

## Code Walkthrough

### Step 1: Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^3.0.1
  app_wide_search:
    path: ../../ # Or use pub.dev version
```

### Step 2: Set Up Provider

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        searchProviderProvider.overrideWithValue(
          InMemorySearchProvider(_createSampleData()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Step 3: Add Search Button

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AppWideSearchDelegate(ref: ref),
              );
            },
          ),
        ],
      ),
      // ... rest of your UI
    );
  }
}
```

### Step 4: Create Sample Data

```dart
List<SearchItem> _createSampleData() {
  return [
    SearchItem(
      id: '1',
      title: 'iPhone 15 Pro',
      subtitle: 'Latest Apple smartphone',
      groupId: 'products',
      description: 'A17 Pro chip with titanium design',
    ),
    // ... more items
  ];
}
```

## How It Works

1. **ProviderScope**: Wraps your app to enable Riverpod state management
2. **searchProviderProvider**: The core provider that supplies search data
3. **InMemorySearchProvider**: A simple provider that searches through a list in memory
4. **AppWideSearchDelegate**: The search UI that Flutter's `showSearch()` displays
5. **SearchItem**: The data model for each searchable item

## Customization Options

Even in this minimal example, you can easily customize:

### Change Theme Colors

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
  ),
)
```

### Add Your Own Data

Replace `_createSampleData()` with your own items:

```dart
List<SearchItem> _createSampleData() {
  return [
    SearchItem(
      id: 'user_1',
      title: 'Alice Johnson',
      subtitle: 'alice@mycompany.com',
      groupId: 'team',
    ),
    // Add as many items as you want!
  ];
}
```

### Handle Selection

```dart
final result = await showSearch(
  context: context,
  delegate: AppWideSearchDelegate(ref: ref),
);

if (result != null) {
  // Navigate to details page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailsPage(item: result),
    ),
  );
}
```

## Performance Notes

This example uses `InMemorySearchProvider` which:

- ✅ **Fast**: Searches ~10,000 items in <50ms
- ✅ **Simple**: No database or API setup needed
- ❌ **Limited**: All data must fit in memory
- ❌ **No persistence**: Data resets on app restart

For larger datasets or persistence, see the `/example` app which uses Hive for caching.

## Next Steps

Ready for more? Check out these examples:

### 📱 [Full Screen Router](../full_screen_router/)

Learn how to integrate search with `go_router` for full-screen search and deep-linking.

### 🌐 [Remote API Search](../remote_cancelable_paged/)

Connect to a real API with pagination, cancellation, and error handling.

### 🎨 [Current Example App](../../example/)

See ALL features: caching, grouped results, history, persistence, and more.

### 📚 [API Documentation](../../API.md)

Complete API reference with all classes and methods.

## Common Questions

### Q: Do I need Riverpod?

**A:** Yes, app_wide_search uses Riverpod for state management. But you only need basic knowledge - the examples show you everything.

### Q: Can I use this with GetX/Bloc/Provider?

**A:** The package uses Riverpod internally, but you can still use your preferred state management for the rest of your app.

### Q: How do I add more items?

**A:** Just add more `SearchItem` objects to the list in `_createSampleData()`. You can add thousands!

### Q: Can I search my own models?

**A:** Yes! Convert your models to `SearchItem` objects. See the [API docs](../../API.md#searchitem) for details.

### Q: Is this production-ready?

**A:** Absolutely! This pattern is used in production apps. For advanced features (caching, API integration), see the other examples.

## Troubleshooting

### "Package not found" Error

```bash
flutter pub get
```

### "Cannot find AppWideSearchDelegate"

Make sure you imported the package:

```dart
import 'package:app_wide_search/app_wide_search.dart';
```

### No Search Results

Check that your `SearchItem` objects have non-empty `title` fields - that's what the search looks for.

## File Structure

```
quickstart_minimal/
├── lib/
│   └── main.dart           # Complete example (~160 lines)
├── pubspec.yaml            # Dependencies
├── analysis_options.yaml   # Lint rules
└── README.md              # This file
```

## Contributing

Found a bug or have a suggestion? [Open an issue](https://github.com/Kidpech-code/app_wide_search/issues) or submit a PR!

## License

MIT License - See [LICENSE](../../LICENSE) for details.

---

**Built with ❤️ using [app_wide_search](https://pub.dev/packages/app_wide_search)**
