import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Provides localized strings for the search package.
///
/// This class uses the intl package to provide internationalization support.
/// Currently supports English, with examples of how to add more languages.
class SearchLocalizations {
  /// Creates search localizations for the given locale.
  SearchLocalizations(this.locale);

  /// The current locale.
  final Locale locale;

  /// Retrieves the localization instance from the widget tree.
  static SearchLocalizations of(BuildContext context) {
    return Localizations.of<SearchLocalizations>(
          context,
          SearchLocalizations,
        ) ??
        SearchLocalizations(const Locale('en'));
  }

  /// Hint text for the search field.
  String get searchHint => Intl.message(
    'Search...',
    name: 'searchHint',
    desc: 'Hint text displayed in the search input field',
    locale: locale.toString(),
  );

  /// Tooltip for the clear search button.
  String get clearSearch => Intl.message(
    'Clear search',
    name: 'clearSearch',
    desc: 'Tooltip for button that clears search text',
    locale: locale.toString(),
  );

  /// Tooltip for the back button.
  String get back => Intl.message(
    'Back',
    name: 'back',
    desc: 'Tooltip for navigation back button',
    locale: locale.toString(),
  );

  /// Message shown when no results are found.
  String get noResults => Intl.message(
    'No results found',
    name: 'noResults',
    desc: 'Message displayed when search returns no results',
    locale: locale.toString(),
  );

  /// Suggestion to try different keywords.
  String get tryDifferentKeywords => Intl.message(
    'Try different keywords',
    name: 'tryDifferentKeywords',
    desc: 'Suggestion shown when no results are found',
    locale: locale.toString(),
  );

  /// Prompt to start typing.
  String get startTyping => Intl.message(
    'Start typing to search',
    name: 'startTyping',
    desc: 'Message shown before user starts typing',
    locale: locale.toString(),
  );

  /// Tooltip for fill search field button.
  String get fillSearchField => Intl.message(
    'Fill search field',
    name: 'fillSearchField',
    desc: 'Tooltip for button that fills search field with suggestion',
    locale: locale.toString(),
  );

  /// Error message format.
  String errorMessage(String error) => Intl.message(
    'Error: $error',
    name: 'errorMessage',
    args: [error],
    desc: 'Error message format',
    locale: locale.toString(),
  );

  /// Results count format.
  String resultsCount(int count) => Intl.message(
    '$count results',
    name: 'resultsCount',
    args: [count],
    desc: 'Number of search results',
    locale: locale.toString(),
  );

  /// Label for search history section.
  String get recentSearches => Intl.message(
    'Recent Searches',
    name: 'recentSearches',
    desc: 'Header for recent search history',
    locale: locale.toString(),
  );

  /// Label for clearing search history.
  String get clearHistory => Intl.message(
    'Clear history',
    name: 'clearHistory',
    desc: 'Button to clear search history',
    locale: locale.toString(),
  );
}

/// Delegate for loading search localizations.
class SearchLocalizationsDelegate
    extends LocalizationsDelegate<SearchLocalizations> {
  /// Creates a search localizations delegate.
  const SearchLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'th'].contains(locale.languageCode);

  @override
  Future<SearchLocalizations> load(Locale locale) async {
    return SearchLocalizations(locale);
  }

  @override
  bool shouldReload(SearchLocalizationsDelegate old) => false;
}
