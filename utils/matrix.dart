import 'dart:collection';
import 'iterable.dart';

class Matrix<E> {
  final List<List<E>> _internal;

  // constructors
  Matrix._(this._internal)
      : assert(_internal.every((e) => e.length == _internal.first.length));

  Matrix.empty() : _internal = [];

  factory Matrix.fromRows(Iterable<Iterable<E>> rows) =>
      Matrix._(rows.toLists());

  factory Matrix.fromColumns(Iterable<Iterable<E>> columns) {
    final _columns = columns.toLists();
    final rows = List.generate(
      _columns.first.length,
      (j) => List.generate(_columns.length, (i) => _columns[i][j]),
    );
    return Matrix._(rows);
  }

  factory Matrix.generate(
    int rowLength,
    int columnLength,
    E Function(int row, int column) generator,
  ) =>
      Matrix._(
        List.generate(
          rowLength,
          (i) => List.generate(columnLength, (j) => generator(i, j)),
        ),
      );

  factory Matrix.filled(int rowLength, int columnLength, E value) => Matrix._(
        List.generate(
          rowLength,
          (_) => List.filled(columnLength, value),
        ),
      );

  // rows and columns
  int get rowLength => _internal.length;

  int get columnLength => _internal.first.length;

  Iterable<Iterable<E>> get rows => _internal;

  Iterable<Iterable<E>> get columns => Iterable.generate(
        columnLength,
        (j) => Iterable.generate(
          rowLength,
          (i) => _internal[i][j],
        ),
      );

  void set(int row, int column, E value) => _internal[row][column] = value;

  void setAt(MatrixOffset offset, E value) =>
      _internal[offset.row][offset.column] = value;

  E valueAt(int row, int column) => _internal[row][column];

  MatrixElement<E> elementAt(int row, int column) =>
      MatrixElement.from(row, column, this);

  Iterable<MatrixElement<E>> get elements sync* {
    for (final (i, row) in _internal.indexed) {
      for (final (j, element) in row.indexed) {
        yield MatrixElement(i, j, element);
      }
    }
  }

  /// Yields all surrounding and existing elements in a clock-wise fashion, starting at the top-left.
  Iterable<MatrixElement<E>> surrounding(MatrixOffset offset) sync* {
    final top = offset.row > 0;
    final left = offset.column > 0;
    final bottom = offset.row < rowLength - 1;
    final right = offset.column < columnLength - 1;

    if (top && left) yield elementAt(offset.row - 1, offset.column - 1);
    if (top) yield elementAt(offset.row - 1, offset.column);
    if (top && right) yield elementAt(offset.row - 1, offset.column + 1);

    if (right) yield elementAt(offset.row, offset.column + 1);

    if (bottom && right) yield elementAt(offset.row + 1, offset.column + 1);
    if (bottom) yield elementAt(offset.row + 1, offset.column);
    if (bottom && left) yield elementAt(offset.row + 1, offset.column - 1);

    if (left) yield elementAt(offset.row, offset.column - 1);
  }

  void insertRow(int index, List<E> row) => _internal.insert(index, row);

  void insertColumn(int index, List<E> column) {
    for (final (i, row) in _internal.indexed) {
      row.insert(index, column[i]);
    }
  }

  Matrix<E> get transposed => Matrix.fromColumns(rows);

  Matrix<E> clone() => Matrix.fromRows(rows.toLists());

  Matrix<T> map<T>(T Function(E e) mapper) =>
      Matrix.fromRows(rows.map((e) => e.map(mapper)));

  @override
  String toString() =>
      rows.map((e) => e.map((e) => e.toString()).join()).join("\n");
}

class MatrixOffset {
  final int row;
  final int column;

  const MatrixOffset(this.row, this.column);

  MatrixOffset operator +(MatrixOffset other) =>
      MatrixOffset(row + other.row, column + other.column);

  MatrixOffset operator *(int factor) =>
      MatrixOffset(row * factor, column * factor);

  MatrixOffset operator -(MatrixOffset other) => this + other * -1;

  bool isAbove(MatrixOffset other) => row < other.row;

  bool isBelow(MatrixOffset other) => row > other.row;

  bool isLeft(MatrixOffset other) => column < other.column;

  bool isRight(MatrixOffset other) => column > other.column;

  @override
  String toString() => "($column, $row)";

  @override
  bool operator ==(Object? other) {
    if (other.runtimeType != MatrixOffset) return false;
    other = other as MatrixOffset;
    return row == other.row && column == other.column;
  }
}

class MatrixElement<E> extends MatrixOffset {
  final E element;

  const MatrixElement(super.row, super.column, this.element);

  MatrixElement.from(super.row, super.column, Matrix<E> matrix)
      : element = matrix.valueAt(row, column);

  MatrixElement<T> cast<T>() => MatrixElement(row, column, element as T);

  @override
  String toString() => "$element ${super.toString()}";

  @override
  bool operator ==(Object? other) {
    if (other is! MatrixElement) return false;
    return row == other.row &&
        column == other.column &&
        element == other.element;
  }
}
