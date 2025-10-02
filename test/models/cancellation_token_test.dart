import 'package:app_wide_search/app_wide_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CancellationToken', () {
    test('creates uncancelled token by default', () {
      final token = CancellationToken();
      expect(token.isCancelled, isFalse);
    });

    test('marks token as cancelled after cancel()', () {
      final token = CancellationToken();
      expect(token.isCancelled, isFalse);

      token.cancel();
      expect(token.isCancelled, isTrue);

      // Calling cancel again should be safe
      token.cancel();
      expect(token.isCancelled, isTrue);
    });

    test('throws CancelledException when cancelled', () {
      final token = CancellationToken();

      // Should not throw when not cancelled
      expect(() => token.throwIfCancelled(), returnsNormally);

      token.cancel();

      // Should throw when cancelled
      expect(
        () => token.throwIfCancelled(),
        throwsA(isA<CancelledException>()),
      );
    });

    test('notifies listeners on cancellation', () {
      final token = CancellationToken();
      var callbackCount = 0;

      token.onCancelled(() {
        callbackCount++;
      });

      expect(callbackCount, 0);

      token.cancel();
      expect(callbackCount, 1);

      // Calling cancel again should not trigger callback again
      token.cancel();
      expect(callbackCount, 1);
    });

    test('handles multiple listeners correctly', () {
      final token = CancellationToken();
      var callback1Count = 0;
      var callback2Count = 0;
      var callback3Count = 0;

      token.onCancelled(() {
        callback1Count++;
      });
      token.onCancelled(() {
        callback2Count++;
      });
      token.onCancelled(() {
        callback3Count++;
      });

      expect(callback1Count, 0);
      expect(callback2Count, 0);
      expect(callback3Count, 0);

      token.cancel();

      expect(callback1Count, 1);
      expect(callback2Count, 1);
      expect(callback3Count, 1);
    });

    test('calls listener immediately if already cancelled', () {
      final token = CancellationToken();
      var callbackCount = 0;

      token.cancel();
      expect(token.isCancelled, isTrue);

      // Adding listener after cancellation should call it immediately
      token.onCancelled(() {
        callbackCount++;
      });

      expect(callbackCount, 1);
    });
  });

  group('CancelledException', () {
    test('creates exception with message', () {
      const exception = CancelledException();
      expect(exception.toString(), 'Operation was cancelled');
    });

    test('is const and can be used in const contexts', () {
      const exception1 = CancelledException();
      const exception2 = CancelledException();

      // Same const instances should be identical
      expect(identical(exception1, exception2), isTrue);
    });
  });
}
