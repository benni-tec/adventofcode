import 'dart:io';
import 'dart:math';

import '../utils/iterable.dart';
import '../utils/matrix.dart';

void main() async {
  final input = await File("2023/13-patrick.txt").readAsLines();
  do2(input);
}

int do1(List<String> lines) {
  final raw = lines.fold([<String>[]], (list, element) {
    if (element.trim().isEmpty)
      list.add([]);
    else
      list.last.add(element);
    return list;
  });

  final patterns = raw.map((e) => Pattern.parse(e.nonWhitespace().toList()));
  print(patterns);

  final horizontals = patterns.expand((e) => e.horizontalReflection());
  final verticals = patterns.expand((e) => e.verticalReflection());

  final sum = verticals.sum() + horizontals.sum() * 100;
  print(sum);

  return sum;
}

int do2(List<String> lines) {
  final raw = lines.fold([<String>[]], (list, element) {
    if (element.trim().isEmpty)
      list.add([]);
    else
      list.last.add(element);
    return list;
  });

  final patterns = raw.map((e) => Pattern.parse(e.nonWhitespace().toList()));
  print(patterns);

  final horizontals = patterns.expand((e) => e.smudgesHorizontal().difference(e.horizontalReflection()));
  final verticals = patterns.expand((e) => e.smudgesVertical().difference(e.verticalReflection()));

  final sum = verticals.sum() + horizontals.sum() * 100;
  print(sum);

  return sum;
}

class Pattern {
  final Matrix<String> pattern;

  const Pattern(this.pattern);

  Pattern.parse(List<String> lines)
      : pattern = lines.map((e) => e.split("")).toList();

  Set<int> horizontalReflection() =>
      _reflection(pattern.map((e) => e.join()).toList());

  Set<int> verticalReflection() =>
      _reflection(pattern.columns.map((e) => e.join()).toList());

  Set<int> _reflection(List<String> lines) {
    final candidates = <int>[];
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i] == lines[i + 1]) candidates.add(i + 1);
    }

    final mirrors = <int>{};
    canLoop:
    for (final candidate in candidates) {
      final before = lines.sublist(0, candidate).reversed.toList();
      final after = lines.sublist(candidate);

      for (int i = 0; i < min(before.length, after.length); i++) {
        if (before[i] != after[i]) continue canLoop;
      }

      mirrors.add(candidate);
    }

    return mirrors;
  }

  Set<int> smudgesHorizontal() =>
      _smudges(pattern.map((e) => e.join()).toList());

  Set<int> smudgesVertical() =>
      _smudges(pattern.columns.map((e) => e.join()).toList());

  Set<int> _smudges(List<String> lines) {
    final possibles = <int>{};
    for (int i = 0; i < lines.length; i++) {
      for (int j = 0; j < lines.first.length; j++) {
        final cp = lines.toList();
        final ch = cp[i][j] == "." ? "#" : ".";

        cp[i] = cp[i].substring(0, j) + ch + cp[i].substring(j + 1);

        possibles.addAll(_reflection(cp));
      }
    }

    return possibles;
  }
}
