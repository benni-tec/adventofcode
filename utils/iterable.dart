import 'dart:math' as math;

extension Aggregations on Iterable<int> {
  int sum() => reduce((value, element) => value + element);
  int max() => reduce(math.max);
  int min() => reduce(math.min);
}

extension Empty on Iterable<String> {
  Iterable<String> nonEmpties() => where((element) => element.isNotEmpty);
  Iterable<String> empties() => where((element) => element.isEmpty);
}
