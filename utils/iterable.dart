import 'dart:math' as math;

extension Aggregations on Iterable<int> {
  int sum() => isEmpty ? 0 : reduce((value, element) => value + element);

  int max() => isEmpty ? 0 : reduce(math.max);

  int min() => isEmpty ? 0 : reduce(math.min);
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

  int count(bool Function(T) test) => where(test).length;
  int countEq(T test) => count((p0) => p0 == test);

  Iterable<R> pair<S, R>(Iterable<S> other, R Function(T, S) join) sync* {
    final i1 = this.iterator;
    final i2 = other.iterator;

    while (true) {
      final n1 = i1.moveNext();
      final n2 = i2.moveNext();
      if (n1 != n2) throw "Bad State: Iterables have different lengths!";
      if (!n1) break;

      yield join(i1.current, i2.current);
    }
  }
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

  Iterable<S> expandPrint<S>(Iterable<S> Function(T e) toElements) {
    final i = expand(toElements).toList();
    print("${i.length} - ${i.sublist(0, 11)}");
    return i;
  }
}
