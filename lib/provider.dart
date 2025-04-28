import 'dart:math';

import 'package:flamejam2025/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Counter extends StateNotifier<int> {
  Counter() : super(0);

  void increment() {
    state++;
  }
}

final counterProvider = StateNotifierProvider<Counter, int>((final ref) {
  return Counter();
});

final random = Random();

final boxStreamProvider = StreamProvider<List<Box>>((ref) {
  return Stream.periodic(const Duration(seconds: 2), (inc) {
    final value = random.nextBool();
    return [value ? Box.vertical : Box.horizontal];
  });
});
