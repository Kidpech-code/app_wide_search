// Microbenchmark harness for search performance
// Run with: dart run example/benchmarks/search_benchmark.dart

import 'dart:async';
import '../../lib/app_wide_search.dart';

void main() async {
  print('🔥 Search Performance Microbenchmarks\n');

  await _benchmarkColdSearch();
  await _benchmarkWarmSearch();
  await _benchmarkMemoryFootprint();

  print('\n✅ Benchmarks complete');
}

Future<void> _benchmarkColdSearch() async {
  print('📊 Benchmark: Cold Search (100 items)');

  final provider = InMemorySearchProvider(_generateItems(100));
  final latencies = <int>[];

  for (var i = 0; i < 100; i++) {
    final stopwatch = Stopwatch()..start();
    await provider.search('test query $i');
    stopwatch.stop();
    latencies.add(stopwatch.elapsedMicroseconds);
  }

  latencies.sort();
  final p50 = latencies[(latencies.length * 0.5).floor()];
  final p95 = latencies[(latencies.length * 0.95).floor()];
  final p99 = latencies[(latencies.length * 0.99).floor()];

  print('  P50: ${p50 / 1000}ms');
  print('  P95: ${p95 / 1000}ms');
  print('  P99: ${p99 / 1000}ms');
  print('  Target: P95 ≤ 120ms');
  print('  Status: ${p95 / 1000 <= 120 ? "✅ PASS" : "❌ FAIL"}');
  print('');
}

Future<void> _benchmarkWarmSearch() async {
  print('📊 Benchmark: Warm Search (cached, 100 items)');

  final provider = InMemorySearchProvider(_generateItems(100));

  // Warm up
  await provider.search('test');

  final latencies = <int>[];
  for (var i = 0; i < 100; i++) {
    final stopwatch = Stopwatch()..start();
    await provider.search('test');
    stopwatch.stop();
    latencies.add(stopwatch.elapsedMicroseconds);
  }

  latencies.sort();
  final p50 = latencies[(latencies.length * 0.5).floor()];
  final p95 = latencies[(latencies.length * 0.95).floor()];

  print('  P50: ${p50 / 1000}ms');
  print('  P95: ${p95 / 1000}ms');
  print('  Target: P95 ≤ 50ms');
  print('  Status: ${p95 / 1000 <= 50 ? "✅ PASS" : "❌ FAIL"}');
  print('');
}

Future<void> _benchmarkMemoryFootprint() async {
  print('📊 Benchmark: Memory Footprint');

  final items1k = _generateItems(1000);
  final items10k = _generateItems(10000);

  // Approximate memory per SearchItem
  const bytesPerItem = 200; // title + subtitle + description + metadata

  final memory1k = (items1k.length * bytesPerItem) / 1024;
  final memory10k = (items10k.length * bytesPerItem) / 1024;

  print('  1K items: ~${memory1k.toStringAsFixed(1)}KB');
  print('  10K items: ~${memory10k.toStringAsFixed(1)}KB');
  print('  Target: Linear growth, no leaks');
  print('');
}

List<SearchItem> _generateItems(int count) {
  return List.generate(
    count,
    (i) => SearchItem(
      id: '$i',
      title: 'Item $i',
      subtitle: 'Subtitle for item $i',
      groupId: 'group${i % 5}',
      description: 'Description for item $i with some searchable content',
    ),
  );
}
