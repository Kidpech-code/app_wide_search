# App-Wide Search - Video Tutorial Script

**Target Duration**: 10 minutes  
**Target Audience**: Flutter developers (beginner to intermediate)  
**Format**: Screen recording with voiceover + code editing  
**Goal**: Get viewers from "zero to first search" in under 10 minutes

---

## 📝 Pre-Production Checklist

### Software Setup

- [ ] Flutter SDK 3.5.0+ installed
- [ ] VS Code with Flutter extension
- [ ] Screen recording software (QuickTime, OBS, or similar)
- [ ] Audio recording setup (clear mic, quiet room)
- [ ] Clean demo project ready

### Visual Preparation

- [ ] VS Code theme: Dark+ or Material Theme (high contrast for recording)
- [ ] Font size: 16-18pt (readable on mobile screens)
- [ ] Hide menubar/taskbar for clean recording
- [ ] Close unnecessary apps/notifications
- [ ] Prepare terminal with large font

### Demo Materials

- [ ] Fresh Flutter project created
- [ ] app_wide_search package available
- [ ] Example code snippets ready to paste
- [ ] Test data prepared
- [ ] Final app working perfectly

---

## 🎬 Video Script with Timestamps

### [00:00 - 00:30] Opening Hook

**Screen**: Animated title card → Demo app running on simulator

**Voiceover**:

> "Want to add powerful, production-ready search to your Flutter app in just 5 minutes? In this tutorial, I'll show you how to use app_wide_search to create a beautiful search experience with Riverpod integration, caching, and deep-linking support. By the end of this video, you'll have a fully working search feature. Let's dive in!"

**Visual Actions**:

- Show polished app running with search working
- Quick demo: type query → instant results → select item
- Fade to VS Code

---

### [00:30 - 01:30] Part 1: Project Setup

**Screen**: Terminal + VS Code

**Voiceover**:

> "First, let's create a new Flutter project and add the app_wide_search package."

**Visual Actions**:

1. Show terminal with command:

   ```bash
   flutter create search_demo
   cd search_demo
   ```

2. Open `pubspec.yaml` in VS Code

3. Add dependencies (highlight as you type):

   ```yaml
   dependencies:
     flutter_riverpod: ^2.6.0
     app_wide_search: ^0.2.0
   ```

4. Save file

5. Run in terminal:
   ```bash
   flutter pub get
   ```

**Voiceover continues**:

> "We need two packages: flutter_riverpod for state management, and app_wide_search for our search functionality. Run pub get to install them."

**On-Screen Text**:

```
✓ flutter_riverpod: State management
✓ app_wide_search: Search functionality
```

---

### [01:30 - 03:00] Part 2: Basic Setup

**Screen**: `lib/main.dart` in VS Code

**Voiceover**:

> "Now let's set up the most basic search implementation. I'll show you the essential code first, then we'll break it down."

**Visual Actions**:

1. Delete boilerplate code (show deleting from line 10 onwards)

2. Add imports at top:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:app_wide_search/app_wide_search.dart';
   ```

3. Replace `main()` function:
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

**Voiceover explains**:

> "Three key pieces here: First, we wrap our app in ProviderScope for Riverpod. Second, we override the search provider with InMemorySearchProvider - that's our data source. Third, we'll create some sample data to search through."

**Pause on screen to highlight**:

- Circle `ProviderScope`
- Circle `searchProviderProvider`
- Circle `_createSampleData()`

---

### [03:00 - 04:30] Part 3: Sample Data

**Screen**: Still in `main.dart`, scroll to bottom

**Voiceover**:

> "Let's create sample data for our search. I'll add products, contacts, and documents."

**Visual Actions**:

1. Scroll to bottom of file

2. Add function:
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
       SearchItem(
         id: '2',
         title: 'MacBook Pro M3',
         subtitle: 'Professional laptop',
         groupId: 'products',
       ),
       SearchItem(
         id: '3',
         title: 'John Doe',
         subtitle: 'john@example.com',
         groupId: 'contacts',
       ),
       // More items...
     ];
   }
   ```

**Voiceover explains**:

> "SearchItem is the data model. Each item needs an ID, title, and subtitle. The groupId lets you organize results by category. You can add optional fields like description, route, and metadata."

**On-Screen Annotations**:

- Point to required fields: `id`, `title`, `subtitle`
- Point to optional: `description`, `groupId`

---

### [04:30 - 06:30] Part 4: Adding Search UI

**Screen**: Back to top of `main.dart`

**Voiceover**:

> "Now for the exciting part - adding the search UI. It's just two simple steps."

**Visual Actions**:

1. Create basic home screen:
   ```dart
   class HomeScreen extends ConsumerWidget {
     const HomeScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Search Demo'),
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
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.search, size: 100),
               SizedBox(height: 24),
               Text('Tap the search icon to begin'),
             ],
           ),
         ),
       );
     }
   }
   ```

**Voiceover explains**:

> "We extend ConsumerWidget to access Riverpod. In the app bar, we add a search icon button. When tapped, it calls showSearch with AppWideSearchDelegate - that's it! The package handles everything else."

**Highlight in order**:

- `ConsumerWidget`
- `IconButton` in actions
- `showSearch()` call
- `AppWideSearchDelegate(ref: ref)`

---

### [06:30 - 08:00] Part 5: Live Demo & Features

**Screen**: Split screen (code left, simulator right)

**Voiceover**:

> "Let's see it in action! I'll run the app and show you what we just built."

**Visual Actions**:

1. Press F5 or run command:

   ```bash
   flutter run -d chrome
   ```

2. Show app loading

3. **Demo Interaction 1**: Basic Search

   - Click search icon
   - Type "iPhone"
   - Show instant results appearing
   - Highlight the result card

4. **Demo Interaction 2**: Clear & New Search

   - Clear search with X button
   - Type "John"
   - Show contact results

5. **Demo Interaction 3**: Empty State
   - Clear search
   - Show empty state message
   - Type "xyz123" (no results)
   - Show "no results" state

**Voiceover explains**:

> "Notice how search is instant - no loading delays. The UI automatically handles empty states, no results, and clearing. You get suggestions, recent searches, and smooth animations all out of the box."

**On-Screen Callouts** (text overlays):

- "⚡ Instant results"
- "🎨 Material Design"
- "♿ Accessibility built-in"
- "📱 Works on all platforms"

---

### [08:00 - 09:00] Part 6: Handling Search Results

**Screen**: Back to VS Code, add result handling

**Voiceover**:

> "Want to do something when a user selects a result? Just await the showSearch call."

**Visual Actions**:

1. Modify the `onPressed` handler:

   ```dart
   onPressed: () async {
     final result = await showSearch(
       context: context,
       delegate: AppWideSearchDelegate(ref: ref),
     );

     if (result != null && context.mounted) {
       // Navigate or show details
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Selected: ${result.title}'),
         ),
       );
     }
   },
   ```

2. Hot reload (press 'r' in terminal)

3. Show in simulator:
   - Open search
   - Select an item
   - Show SnackBar appearing

**Voiceover**:

> "showSearch returns the selected SearchItem, or null if cancelled. You can navigate to a details page, update state, or anything else. Here, I'm just showing a snackbar with the selected item."

---

### [09:00 - 09:45] Part 7: Next Steps & Advanced Features

**Screen**: Show the full example app from the package

**Voiceover**:

> "What we just built is the foundation. The package includes much more:"

**Visual Actions**:

1. Quick montage showing:

   - Grouped search results (by category)
   - Full-screen search with routing
   - Cache configuration screen
   - Custom theming

2. Show documentation on screen

**Voiceover lists features**:

> "Grouped results by category, full-screen search with go_router, persistent caching with Hive, custom themes, deep-linking support, and comprehensive examples for every skill level."

**On-Screen Text**:

```
📦 Advanced Features:
✓ Grouped results
✓ Full-screen mode
✓ Persistent caching
✓ Deep-linking
✓ Custom themes
✓ Pagination support
```

---

### [09:45 - 10:00] Closing

**Screen**: Code recap → Example app running → End card

**Voiceover**:

> "And that's it! In under 10 minutes, we went from zero to a fully working search feature. Check the description for links to the package, complete examples, and documentation. If you found this helpful, give it a like and subscribe for more Flutter tutorials. Happy coding!"

**Visual Actions**:

- Show final app one more time
- Fade to end card with:
  - Subscribe button
  - GitHub repo link
  - pub.dev package link
  - "Next Video" thumbnail

**On-Screen Text**:

```
🔗 Links:
📦 pub.dev/packages/app_wide_search
💻 github.com/Kidpech-code/app_wide_search
📚 Full Documentation
🎯 More Examples

👍 Like | 🔔 Subscribe | 💬 Comment
```

---

## 🎥 Shot List & Recording Notes

### Required Shots

1. **Title Card** (0:00-0:05)

   - Animated logo
   - Title: "Flutter Search in 5 Minutes"
   - Subtitle: "app_wide_search tutorial"

2. **Demo Showcase** (0:05-0:30)

   - Polished app running
   - Multiple search interactions
   - Smooth animations

3. **Code Editing** (0:30-9:00)

   - Clean VS Code setup
   - Large, readable font (16-18pt)
   - Dark theme with good contrast
   - Type code in real-time (or appear to)
   - Use syntax highlighting

4. **Live App Demo** (6:30-8:00)

   - Split screen (code + simulator)
   - Clear UI interactions
   - Pointer/cursor visible

5. **Feature Montage** (9:00-9:45)

   - Quick cuts (2-3 seconds each)
   - Show advanced examples
   - Professional transitions

6. **End Card** (9:45-10:00)
   - Clean design
   - Clear CTAs
   - Links overlay

### Camera/Recording Setup

**VS Code Recording**:

- Resolution: 1920x1080 minimum
- Frame rate: 60fps for smooth motion
- Font: Fira Code or JetBrains Mono, 16-18pt
- Theme: Dark+ or Material Theme Ocean
- Hide: minimap, breadcrumbs, status bar items

**Simulator Recording**:

- iOS Simulator or Chrome DevTools mobile view
- Frame: iPhone 15 Pro or similar
- Show device frame for context
- 60fps recording

**Audio**:

- Sample rate: 48kHz
- Bit rate: 192kbps minimum
- Use pop filter and treat room acoustics
- Record in quiet environment
- Speak clearly at moderate pace (~150 words/min)

### Editing Notes

**Pacing**:

- Code typing: Speed up 1.5-2x (still readable)
- Pauses: Cut most dead air, keep 0.5-1s for breath
- Transitions: Quick (0.2-0.3s), smooth

**Text Overlays**:

- Font: Sans-serif, bold, white with shadow
- Position: Bottom third (avoid covering code/UI)
- Duration: Long enough to read 2x comfortably
- Animation: Fade in/out (0.2s)

**Annotations**:

- Circles/arrows: Bright color (yellow/green)
- Line thickness: 3-5px
- Duration: 1-3 seconds
- Purpose: Draw attention to key concepts

**Background Music** (optional):

- Volume: -30dB to -25dB (subtle)
- Style: Lo-fi beats, ambient coding music
- Fade out during important explanations

### Quality Checklist

Before publishing:

- [ ] Audio levels consistent (-3dB to -6dB peak)
- [ ] No background noise
- [ ] Code is legible at 720p (test on phone)
- [ ] All text overlays are readable
- [ ] Transitions are smooth
- [ ] No typos in code or text
- [ ] Final app works perfectly
- [ ] End card links are correct
- [ ] Thumbnail is eye-catching (test on mobile)

---

## 📋 B-Roll Footage Ideas

If you want to expand the video or add variety:

1. **Package Stats** (animated):

   - Download count
   - GitHub stars
   - Version number
   - Supported platforms

2. **Feature Comparison Table**:

   - app_wide_search vs custom implementation
   - Time saved
   - Lines of code comparison

3. **Performance Graphs**:

   - Search speed benchmarks
   - Memory usage
   - Render time

4. **Community Showcase**:
   - Apps using the package
   - GitHub contributors
   - Community feedback

---

## 🎤 Alternative Voiceover Scripts

### Version 2: More Technical

For experienced developers who want less explanation:

**[00:00]**:

> "Building search in Flutter? Let's skip the boilerplate. Here's app_wide_search in action - full-featured search with Riverpod, caching, and routing in under 50 lines of code."

**[00:30]**:

> "Install: flutter_riverpod and app_wide_search. Wrap your app in ProviderScope, override the search provider with InMemorySearchProvider, pass your data. Done."

(Continue with compressed, faster-paced explanations)

### Version 3: Beginner-Friendly

For absolute beginners:

**[00:00]**:

> "Hi! If you're new to Flutter and want to add search to your app, you're in the right place. I'll walk you through everything step by step, no prior knowledge needed."

**[01:00]**:

> "Don't worry if you're not familiar with Riverpod - I'll explain exactly what each line does and why we need it. Let's start with creating a new Flutter project..."

(Continue with detailed, slower-paced explanations)

---

## 📊 Success Metrics

Track these after publishing:

**Engagement**:

- View duration (target: >60% retention)
- Likes/dislikes ratio (target: >95% positive)
- Comments with questions/success stories
- Shares (especially to developer communities)

**Action**:

- Click-through rate to package page
- GitHub stars gained post-video
- Package downloads spike
- Follow-up questions about advanced features

**Quality Indicators**:

- Watch time on first 30 seconds (critical hook)
- Drop-off points (indicates confusing sections)
- Repeat views (people coming back for reference)

---

## 🔄 Video Variants

Consider creating additional videos:

1. **30-second Short**: Quick teaser for TikTok/Instagram/YouTube Shorts
2. **Extended Cut**: 20-minute deep dive with advanced features
3. **Tutorial Series**: Multi-part series (Setup → Intermediate → Advanced)
4. **Live Coding**: Unedited, real-time implementation with chat
5. **Troubleshooting**: Common issues and solutions

---

**Production Timeline**:

- Script finalization: 2 hours
- Setup & rehearsal: 1 hour
- Recording: 2-3 hours (multiple takes)
- Editing: 4-6 hours
- Review & revisions: 2 hours
- **Total**: ~12-14 hours for professional quality

**Release Checklist**:

- [ ] Video rendered (1080p60, H.264)
- [ ] Thumbnail designed (1280x720)
- [ ] Title optimized for SEO
- [ ] Description with timestamps and links
- [ ] Tags added (Flutter, Dart, Tutorial, Search, Riverpod)
- [ ] Cards added (GitHub, pub.dev, related videos)
- [ ] End screen configured
- [ ] Captions/subtitles generated
- [ ] Posted to social media (Twitter, Reddit, Discord)
- [ ] Package README updated with video link

---

**Built for app_wide_search v0.2.0**  
_Last updated: October 2, 2025_
