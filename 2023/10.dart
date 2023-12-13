import 'dart:io';

import '../utils/matrix.dart';

final example = """7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"""
    .split("\n");

void main() async {
  do2(await File("2023/10-input.txt").readAsLines());
}

int do1(List<String> lines) {
  final Matrix<String?> matrix = Matrix.fromRows(lines.map(
    (e) => e.split("").map((e) => e == "." ? null : e),
  ));

  final start = matrix.elements
      .firstWhere(
        (e) => e.element != null && Pipes.isStart(e.element!),
      )
      .cast<String>();

  int length;
  MatrixElement<String>? current = start;
  MatrixElement<String>? last;
  for (length = 0; true; length++) {
    (current, last) = _do1(matrix, current!, last);
    print(current);
    if (current == null) break;
  }

  length++;

  print(length / 2);
  return length ~/ 2;
}

(MatrixElement<String>?, MatrixElement<String>) _do1(
  Matrix<String?> matrix,
  MatrixElement<String> current,
  MatrixElement<String>? last,
) {
  for (final _e in Pipes.adjacent(matrix, current)) {
    if (_e == last) continue;
    if (_e.element == null) continue;
    final e = _e.cast<String>();

    if (Pipes.isStart(e.element)) {
      return (null, current);
    }

    return (e, current);
  }

  throw "Dead end!";
}

abstract class Pipes {
  static PipeType type(String? e) => switch (e) {
        "|" => PipeType.vertical,
        "-" => PipeType.horizontal,
        "S" => PipeType.start,
        "F" => PipeType.topLeft,
        "7" => PipeType.topRight,
        "L" => PipeType.bottomLeft,
        "J" => PipeType.bottomRight,
        _ => throw "Not a pipe!",
      };

  static bool isStart(String e) => e == "S";

  /// Yields all adjacent, existing and connecting pipes in a clock-wise fashion, starting at the top.
  static Iterable<MatrixElement<String?>> adjacent(
    Matrix<String?> matrix,
    MatrixElement<String> current,
  ) sync* {
    final top = current.row > 0;
    final left = current.column > 0;
    final bottom = current.row < matrix.rowLength - 1;
    final right = current.column < matrix.columnLength - 1;

    switch (type(current.element)) {
      case PipeType.vertical:
        if (top) yield matrix.elementAt(current.row - 1, current.column);
        if (bottom) yield matrix.elementAt(current.row + 1, current.column);
      case PipeType.horizontal:
        if (right) yield matrix.elementAt(current.row, current.column + 1);
        if (left) yield matrix.elementAt(current.row, current.column - 1);
      case PipeType.bottomRight:
        if (top) yield matrix.elementAt(current.row - 1, current.column);
        if (left) yield matrix.elementAt(current.row, current.column - 1);
      case PipeType.bottomLeft:
        if (top) yield matrix.elementAt(current.row - 1, current.column);
        if (right) yield matrix.elementAt(current.row, current.column + 1);
      case PipeType.topRight:
        if (bottom) yield matrix.elementAt(current.row + 1, current.column);
        if (left) yield matrix.elementAt(current.row, current.column - 1);
      case PipeType.topLeft:
        if (right) yield matrix.elementAt(current.row, current.column + 1);
        if (bottom) yield matrix.elementAt(current.row + 1, current.column);
      case PipeType.start:
        if (top) {
          final e = matrix.elementAt(current.row - 1, current.column);
          if (_checkType(
              e, [PipeType.vertical, PipeType.topLeft, PipeType.topRight]))
            yield e;
        }
        if (right) {
          final e = matrix.elementAt(current.row, current.column + 1);
          if (_checkType(e, [
            PipeType.horizontal,
            PipeType.topRight,
            PipeType.bottomRight
          ])) yield e;
        }
        if (bottom) {
          final e = matrix.elementAt(current.row + 1, current.column);
          if (_checkType(e, [
            PipeType.vertical,
            PipeType.bottomRight,
            PipeType.bottomLeft
          ])) yield e;
        }
        if (left) {
          final e = matrix.elementAt(current.row, current.column - 1);
          if (_checkType(
              e, [PipeType.horizontal, PipeType.topLeft, PipeType.bottomLeft]))
            yield e;
        }
    }
  }

  static bool _checkType(
          MatrixElement<String?> element, List<PipeType> allowed) =>
      element.element != null && allowed.contains(type(element.element));
}

enum PipeType {
  vertical,
  horizontal,
  start,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

int do2(List<String> lines) {
  final Matrix<String?> matrix = Matrix.fromRows(lines.map(
    (e) => e.split("").map((e) => e == "." ? null : e),
  ));

  final Matrix<Ground?> edges =
      Matrix.filled(matrix.rowLength, matrix.columnLength, null);

  final start = matrix.elements
      .firstWhere(
        (e) => e.element != null && Pipes.isStart(e.element!),
      )
      .cast<String>();

  // adds pipes
  for (final (i, row) in matrix.rows.indexed) {
    for (final (j, element) in row.indexed) {
      if (element != null) edges.set(i, j, Pipe());
    }
  }

  // adds loop
  MatrixElement<String>? current = start;
  MatrixElement<String>? last;
  while (true) {
    (current, last) = _do1(matrix, current!, last);

    if (current == null) break;
    edges.setAt(current, Loop(Pipes.type(current.element)));
  }

  // adds start
  edges.setAt(start, Loop(PipeType.start));

  var elements = edges.elements.toList();

  // calculate patches
  final patches = <List<Ground>>[];

  for (int i = 0; i < elements.length; i++) {
    final e = elements.elementAt(i);
    if (e.element != null) continue;

    final patch = <MatrixElement<Ground?>>[];
    void _recursive(MatrixElement<Ground?> offset) {
      if (offset.element != null) return;
      if (patch.contains(offset)) return;

      final s = edges.surrounding(offset);
      patch.addAll(s);
      s.forEach(_recursive);
    }

    _recursive(e);

    final _edges = patch.map((e) {
      final top = e.row > 0;
      final left = e.column > 0;
      final bottom = e.row < matrix.rowLength - 1;
      final right = e.column < matrix.columnLength - 1;

      return MatrixElement(
        e.row,
        e.column,
        Edge(
          boundsTop: top && matrix.elementAt(e.row - 1, e.column) is Loop,
          boundsLeft: left && matrix.elementAt(e.row, e.column - 1) is Loop,
          boundsBottom: bottom && matrix.elementAt(e.row + 1, e.column) is Loop,
          boundsRight: right && matrix.elementAt(e.row, e.column + 1) is Loop,
        ),
      );
    }).toList();

    final isComplete = _edges.any((e) => e.element.boundsBottom) &&
        _edges.any((e) => e.element.boundsTop) &&
        _edges.any((e) => e.element.boundsLeft) &&
        _edges.any((e) => e.element.boundsRight);

    if (isComplete) {
      patches.add(_edges.map((e) => e.element).toList());
      for (final e in _edges) {
        edges.setAt(e, e.element);
      }
    } else {
      for (final e in patch) {
        edges.setAt(e, e.element);
      }
    }

    elements = edges.elements.toList();
  }

  print(edges);
  edges.rows.forEach((row) => print(row.join()));

  return 0;
}

class Ground {
  const Ground();

  @override
  String toString() => "O";
}

class Pipe extends Ground {
  const Pipe();

  @override
  String toString() => "*";
}

class Loop extends Ground {
  final PipeType type;

  const Loop(this.type);

  @override
  String toString() => switch (type) {
        PipeType.vertical => "|",
        PipeType.horizontal => "-",
        PipeType.topLeft => "┌",
        PipeType.topRight => "┐",
        PipeType.bottomLeft => "└",
        PipeType.bottomRight => "┘",
        PipeType.start => "S",
      };
}

class Edge extends Ground {
  final bool boundsTop;
  final bool boundsLeft;
  final bool boundsBottom;
  final bool boundsRight;

  const Edge({
    required this.boundsTop,
    required this.boundsLeft,
    required this.boundsBottom,
    required this.boundsRight,
  });

  @override
  String toString() => "E";
}
