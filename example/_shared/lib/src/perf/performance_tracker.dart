import 'dart:async';
import 'package:flutter/foundation.dart';

/// Simple performance tracking utility for examples.
///
/// Tracks search performance metrics including:
/// - Query execution time
/// - Results count
/// - Cache hit/miss
/// - Memory usage estimates
class PerformanceTracker {
  /// Creates a performance tracker.
  PerformanceTracker({this.enabled = true});

  /// Whether tracking is enabled.
  final bool enabled;
  final List<PerformanceMetric> _metrics = [];
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Records a search operation.
  void recordSearch({required String query, required int resultCount, required Duration executionTime, bool fromCache = false}) {
    if (!enabled) return;

    if (fromCache) {
      _cacheHits++;
    } else {
      _cacheMisses++;
    }

    _metrics.add(
      PerformanceMetric(query: query, resultCount: resultCount, executionTime: executionTime, fromCache: fromCache, timestamp: DateTime.now()),
    );

    // Keep only last 100 metrics
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }
  }

  /// Times a search operation and records it.
  Future<T> trackSearch<T>({
    required String query,
    required Future<T> Function() operation,
    required int Function(T) getResultCount,
    bool fromCache = false,
  }) async {
    if (!enabled) {
      return await operation();
    }

    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    recordSearch(query: query, resultCount: getResultCount(result), executionTime: stopwatch.elapsed, fromCache: fromCache);

    return result;
  }

  /// Gets average execution time across all searches.
  Duration get averageExecutionTime {
    if (_metrics.isEmpty) return Duration.zero;

    final total = _metrics.fold<int>(0, (sum, metric) => sum + metric.executionTime.inMicroseconds);

    return Duration(microseconds: total ~/ _metrics.length);
  }

  /// Gets average execution time for cached searches.
  Duration get averageCachedExecutionTime {
    final cachedMetrics = _metrics.where((m) => m.fromCache).toList();
    if (cachedMetrics.isEmpty) return Duration.zero;

    final total = cachedMetrics.fold<int>(0, (sum, metric) => sum + metric.executionTime.inMicroseconds);

    return Duration(microseconds: total ~/ cachedMetrics.length);
  }

  /// Gets average execution time for non-cached searches.
  Duration get averageUncachedExecutionTime {
    final uncachedMetrics = _metrics.where((m) => !m.fromCache).toList();
    if (uncachedMetrics.isEmpty) return Duration.zero;

    final total = uncachedMetrics.fold<int>(0, (sum, metric) => sum + metric.executionTime.inMicroseconds);

    return Duration(microseconds: total ~/ uncachedMetrics.length);
  }

  /// Gets P95 (95th percentile) execution time.
  Duration get p95ExecutionTime {
    if (_metrics.isEmpty) return Duration.zero;

    final sorted = _metrics.map((m) => m.executionTime).toList()..sort((a, b) => a.inMicroseconds.compareTo(b.inMicroseconds));

    final index = (sorted.length * 0.95).floor();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  /// Gets cache hit rate as a percentage (0-100).
  double get cacheHitRate {
    final total = _cacheHits + _cacheMisses;
    if (total == 0) return 0.0;
    return (_cacheHits / total) * 100;
  }

  /// Gets total number of searches tracked.
  int get totalSearches => _metrics.length;

  /// Gets all recorded metrics.
  List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);

  /// Gets recent metrics (last N searches).
  List<PerformanceMetric> getRecentMetrics({int limit = 10}) {
    final start = (_metrics.length - limit).clamp(0, _metrics.length);
    return _metrics.sublist(start);
  }

  /// Gets statistics summary.
  PerformanceStats get stats => PerformanceStats(
    totalSearches: totalSearches,
    cacheHits: _cacheHits,
    cacheMisses: _cacheMisses,
    cacheHitRate: cacheHitRate,
    averageExecutionTime: averageExecutionTime,
    averageCachedTime: averageCachedExecutionTime,
    averageUncachedTime: averageUncachedExecutionTime,
    p95ExecutionTime: p95ExecutionTime,
  );

  /// Resets all metrics.
  void reset() {
    _metrics.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Prints a formatted performance report.
  void printReport() {
    if (_metrics.isEmpty) {
      debugPrint('No performance data recorded.');
      return;
    }

    debugPrint('\n═══════════════════════════════════════════');
    debugPrint('         PERFORMANCE REPORT');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('Total Searches:    $totalSearches');
    debugPrint('Cache Hits:        $_cacheHits');
    debugPrint('Cache Misses:      $_cacheMisses');
    debugPrint('Cache Hit Rate:    ${cacheHitRate.toStringAsFixed(1)}%');
    debugPrint('───────────────────────────────────────────');
    debugPrint('Average Time:      ${averageExecutionTime.inMilliseconds}ms');
    debugPrint('Cached Avg:        ${averageCachedExecutionTime.inMilliseconds}ms');
    debugPrint('Uncached Avg:      ${averageUncachedExecutionTime.inMilliseconds}ms');
    debugPrint('P95 Time:          ${p95ExecutionTime.inMilliseconds}ms');
    debugPrint('═══════════════════════════════════════════\n');
  }
}

/// A single performance metric record.
class PerformanceMetric {
  /// Creates a performance metric.
  const PerformanceMetric({
    required this.query,
    required this.resultCount,
    required this.executionTime,
    required this.fromCache,
    required this.timestamp,
  });

  /// The search query.
  final String query;

  /// Number of results returned.
  final int resultCount;

  /// Time taken to execute the search.
  final Duration executionTime;

  /// Whether the result came from cache.
  final bool fromCache;

  /// When the search was performed.
  final DateTime timestamp;

  @override
  String toString() =>
      'PerformanceMetric(query: "$query", results: $resultCount, '
      'time: ${executionTime.inMilliseconds}ms, cached: $fromCache)';
}

/// Performance statistics summary.
class PerformanceStats {
  /// Creates performance statistics.
  const PerformanceStats({
    required this.totalSearches,
    required this.cacheHits,
    required this.cacheMisses,
    required this.cacheHitRate,
    required this.averageExecutionTime,
    required this.averageCachedTime,
    required this.averageUncachedTime,
    required this.p95ExecutionTime,
  });

  /// Total number of searches performed.
  final int totalSearches;

  /// Number of cache hits.
  final int cacheHits;

  /// Number of cache misses.
  final int cacheMisses;

  /// Cache hit rate as a percentage.
  final double cacheHitRate;

  /// Average execution time across all searches.
  final Duration averageExecutionTime;

  /// Average execution time for cached searches.
  final Duration averageCachedTime;

  /// Average execution time for uncached searches.
  final Duration averageUncachedTime;

  /// 95th percentile execution time.
  final Duration p95ExecutionTime;

  /// Converts to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
    'totalSearches': totalSearches,
    'cacheHits': cacheHits,
    'cacheMisses': cacheMisses,
    'cacheHitRate': cacheHitRate,
    'averageExecutionTimeMs': averageExecutionTime.inMilliseconds,
    'averageCachedTimeMs': averageCachedTime.inMilliseconds,
    'averageUncachedTimeMs': averageUncachedTime.inMilliseconds,
    'p95ExecutionTimeMs': p95ExecutionTime.inMilliseconds,
  };

  @override
  String toString() =>
      'PerformanceStats(searches: $totalSearches, '
      'hitRate: ${cacheHitRate.toStringAsFixed(1)}%, '
      'avgTime: ${averageExecutionTime.inMilliseconds}ms)';
}
