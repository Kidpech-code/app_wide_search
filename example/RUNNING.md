# Running the Example App

This guide shows how to run the example application to see all features in action.

## Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.8.1 or higher
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

## Quick Start

### 1. Get Dependencies

From the package root:

```bash
cd /Users/kidpech/app_wide_search
flutter pub get
```

From the example directory:

```bash
cd example
flutter pub get
```

### 2. Run the Example

#### On macOS Desktop

```bash
cd example
flutter run -d macos
```

#### On Chrome (Web)

```bash
cd example
flutter run -d chrome
```

#### On iOS Simulator

```bash
cd example
flutter run -d ios
```

#### On Android Emulator

```bash
cd example
flutter run -d android
```

## What to Try

### 1. Modal Search (SearchDelegate)

- Click the search icon in the app bar
- Type "flutter" or "laptop" to see results
- Notice the suggestions as you type
- Try clearing the search
- Select an item to see the result

### 2. Full-Screen Search

- Click "Open Search (Full Screen)"
- See the dedicated search screen
- Notice the recent searches when the field is empty
- Type to search and see grouped results

### 3. Deep-Link Search

- Click "Search 'laptop' (Deep Link)"
- Notice the query parameter in the URL (web)
- The search is pre-filled with "laptop"

### 4. Grouped Results

- Perform any search
- See results grouped by:
  - Products
  - Documents
  - Contacts
  - Settings
- Tap groups to expand/collapse
- Each group shows item count

### 5. Search History

- Perform several searches
- Clear the search field
- See your recent searches listed
- Tap a recent search to run it again
- Click "Clear history" to remove all

## Sample Search Queries

Try these queries to see different results:

- **"iPhone"** - Shows products
- **"flutter"** - Shows documents and products
- **"john"** - Shows contacts
- **"privacy"** - Shows settings
- **"laptop"** - Shows multiple products

## Features Demonstrated

### Performance

- ✅ Fast search with instant results
- ✅ Smooth animations and transitions
- ✅ No lag or stuttering
- ✅ Efficient memory usage

### UI/UX

- ✅ Clean, Material Design 3 interface
- ✅ Intuitive navigation
- ✅ Clear visual hierarchy
- ✅ Helpful empty states

### Functionality

- ✅ Real-time search
- ✅ Autocomplete suggestions
- ✅ Search history tracking
- ✅ Result grouping
- ✅ Deep-link support

## Code Examples

### Adding Your Own Data

Edit `example/lib/main.dart` and modify the `_getSampleData()` function:

```dart
List<SearchItem> _getSampleData() {
  return [
    SearchItem(
      id: 'your-id',
      title: 'Your Item',
      subtitle: 'Your subtitle',
      groupId: 'your-group',
      description: 'Your description',
      route: '/your-route',
    ),
    // Add more items...
  ];
}
```

### Customizing Groups

Add this before the `SearchResultList` widget:

```dart
final customGroups = {
  'your-group': SearchGroup(
    id: 'your-group',
    name: 'Your Group Name',
    icon: Icons.star.codePoint,
    color: Colors.purple.value,
    priority: 100,
  ),
};

// Then use:
GroupedSearchResults(
  result: result,
  groups: customGroups,
  // ...
)
```

### Custom Search Provider

Replace `InMemorySearchProvider` with your own:

```dart
class MyCustomProvider extends SearchProvider {
  @override
  Future<SearchResult> search(String query, {...}) async {
    // Your API call or database query
    final items = await yourSearchLogic(query);

    return SearchResult(
      query: query,
      items: items,
      totalCount: items.length,
    );
  }
}

// Use it:
ProviderScope(
  overrides: [
    searchProviderProvider.overrideWithValue(
      MyCustomProvider(),
    ),
  ],
  child: MyApp(),
)
```

## Troubleshooting

### Issue: Dependencies not found

**Solution:**

```bash
cd /Users/kidpech/app_wide_search
flutter pub get
cd example
flutter pub get
```

### Issue: Hive errors

**Solution:** Run build_runner to generate adapters:

```bash
cd /Users/kidpech/app_wide_search
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: go_router errors

**Solution:** Make sure you're using go_router 14.0.2 or higher:

```bash
flutter pub upgrade go_router
```

### Issue: Platform not supported

**Solution:** Check supported platforms in pubspec.yaml. Currently supports:

- Android
- iOS
- Web
- macOS
- Windows
- Linux

## Development Tips

### Hot Reload

The example app supports hot reload. Make changes and save to see them instantly.

### Debugging

Add breakpoints in:

- `search_providers.dart` - To debug search logic
- `app_wide_search_delegate.dart` - To debug SearchDelegate
- `search_screen.dart` - To debug full-screen search

### Performance Profiling

```bash
flutter run --profile
```

Then use Flutter DevTools to analyze performance.

## Next Steps

1. **Explore the Code**: Look at `example/lib/main.dart` to understand the setup
2. **Read the Docs**: Check out `README.md` and `API.md` for detailed information
3. **Customize**: Modify the example to match your app's needs
4. **Integrate**: Copy the patterns into your own app

## Additional Resources

- [Package README](../README.md)
- [API Documentation](../API.md)
- [Advanced Examples](./README.md)
- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [go_router Documentation](https://pub.dev/packages/go_router)

## Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Review the documentation
3. File an issue on GitHub
4. Check existing issues for solutions

---

Enjoy exploring the app-wide search package! 🎉
