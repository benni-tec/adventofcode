import 'dart:math' as math;

extension Aggregations on Iterable<int> {
  int sum() => length == 0 ? 0 : reduce((value, element) => value + element);

  int max() => reduce(math.max);

  int min() => reduce(math.min);
}

extension Empty on Iterable<String> {
  Iterable<String> nonEmpties() => where((element) => element.isNotEmpty);

  Iterable<String> empties() => where((element) => element.isEmpty);

  Iterable<String> nonWhitespace() => map((e) => e.trim()).where((element) => element.isNotEmpty);
}

extension Nested<T> on Iterable<Iterable<T>> {
  Iterable<T> flatten() => expand((element) => element);
}

extension Groups<T> on Iterable<T> {
  Map<K, List<T>> groupBy<K>(K Function(T e) key) =>
      fold(<K, List<T>>{}, (map, element) {
        final k = key(element);
        final list = map[k];
        if (list == null)
          map[k] = [element];
        else
          list.add(element);
        return map;
      });

  Map<K, int> countBy<K>(K Function(T e) key) =>
      fold(<K, int>{}, (map, element) {
        final k = key(element);
        final v = map[k];
        if (v == null)
          map[k] = 1;
        else
          map[k] = v + 1;
        return map;
      });
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
