import 'dart:math' as math;

extension Aggregations on Iterable<int> {
  int sum() => length == 0 ? 0 : reduce((value, element) => value + element);
  int max() => reduce(math.max);
  int min() => reduce(math.min);
}

extension Empty on Iterable<String> {
  Iterable<String> nonEmpties() => where((element) => element.isNotEmpty);
  Iterable<String> empties() => where((element) => element.isEmpty);
}

extension Nested<T> on Iterable<Iterable<T>> {
  Iterable<T> flatten() => expand((element) => element);
}

extension Permutations<T> on Iterable<T> {
  Iterable<T> sorted(int Function(T a, T b) compare) {
    final permutation = List.generate(length, (index) => index);
    permutation.sort((ai, bi) => compare(elementAt(ai), elementAt(bi)));

    return permutation.map((e) => elementAt(e));
  }

  Iterable<T> reversed() {
    final l = length;
    final permutation = List.generate(l, (index) => l - index - 1);

    return permutation.map((e) => elementAt(e));
  }
}
