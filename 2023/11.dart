import 'dart:io';

import 'package:collection/collection.dart';

import '../utils/matrix.dart';

final example = """...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....""".split("\n");

void main() async {
  final input = await File('2023/11-input.txt').readAsLines();
  do1(example);
}

int do1(List<String> lines) {
  final universe = Universe.parse(lines);
  print(universe.matrix.format((e) => e is Galaxy ? "#" : "."));
  print("");

  final expanded = universe.expanded();
  print(expanded.matrix.format((e) => e is Galaxy ? "#" : "."));

  final galaxies = expanded.matrix.elements
      .where((e) => e.element is Galaxy)
      .map((e) => e.cast<Galaxy>())
      .toList();

  print(galaxies.length);
  final pairs = galaxies.indexed.expand((entry) {
    final (i, a) = entry;
    return galaxies.sublist(i + 1).map((b) => (a, b));
  });

  final distances = pairs.map(
    (e) {
      final dRow = (e.$2.row - e.$1.row).abs();
      final dColumn = (e.$2.column - e.$1.column).abs();

      final d = dRow + dColumn + (dRow != 0 && dColumn != 0 ? -1 : 0);

      print("${e.$1} | ${e.$2} -> $d");
      return d;
    },
  );

  print(distances);

  final sum = distances.sum;

  print(sum);
  return sum;
}

class Universe {
  final bool isExpanded;
  final Matrix<Galaxy?> matrix;

  const Universe(this.matrix, this.isExpanded);

  factory Universe.parse(List<String> lines) {
    return Universe(
      lines
          .map((e) =>
              e.split("").map((e) => e == "#" ? Galaxy() : null).toList())
          .toList(),
      false,
    );
  }

  Universe expanded() {
    if (isExpanded) return this;

    final expanded = matrix.toList();
    int insertedRows = 0;
    for (final (i, row) in matrix.indexed) {
      if (row.none((e) => e is Galaxy)) {
        expanded.insertRow(
          i + insertedRows + 1,
          List.filled(
            expanded.first.length,
            null,
            growable: true,
          ),
        );
        insertedRows++;
      }
    }

    int insertedColumns = 0;
    for (final (j, column) in matrix.columns.indexed) {
      if (column.none((e) => e is Galaxy)) {
        expanded.insertColumn(
          j + insertedColumns + 1,
          List.filled(
            expanded.length,
            null,
            growable: true,
          ),
        );
        insertedColumns++;
      }
    }

    print("inserted $insertedRows rows and $insertedColumns columns");

    return Universe(expanded, true);
  }
}

class Galaxy {}
