/// A token that can be used to cancel asynchronous operations.
///
/// Pass a [CancellationToken] to search operations to allow cancelling
/// long-running searches when the user types a new query or navigates away.
///
/// Example:
/// ```dart
/// class MySearchProvider extends SearchProvider {
///   CancellationToken? _activeToken;
///
///   @override
///   Future<SearchResult> search(
///     String query, {
///     int page = 1,
///     int pageSize = 10,
///     CancellationToken? cancellationToken,
///   }) async {
///     // Cancel previous search
///     _activeToken?.cancel();
///     _activeToken = cancellationToken ?? CancellationToken();
///
///     try {
///       final response = await http.get(buildUrl(query));
///
///       // Check if cancelled before processing
///       if (_activeToken!.isCancelled) {
///         throw CancelledException();
///       }
///
///       return parseResponse(response);
///     } catch (e) {
///       if (_activeToken?.isCancelled ?? false) {
///         return SearchResult.empty(query);
///       }
///       rethrow;
///     }
///   }
/// }
/// ```
class CancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  /// Creates a new cancellation token.
  CancellationToken();

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Cancels this token and notifies all listeners.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        // Ignore listener errors
      }
    }
    _listeners.clear();
  }

  /// Registers a callback to be called when this token is cancelled.
  ///
  /// Returns a function that can be called to unregister the listener.
  void Function() onCancelled(void Function() callback) {
    if (_isCancelled) {
      callback();
      return () {};
    }

    _listeners.add(callback);
    return () => _listeners.remove(callback);
  }

  /// Throws [CancelledException] if this token has been cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw const CancelledException();
    }
  }
}

/// Exception thrown when an operation is cancelled via a [CancellationToken].
class CancelledException implements Exception {
  /// Creates a cancellation exception.
  const CancelledException();

  @override
  String toString() => 'Operation was cancelled';
}
