import 'dart:io';

typedef Matrix<E> = List<List<E>>;

extension MatrixOperations<E> on Matrix<E> {
  /// Yields all adjacent and existing elements in a clock-wise fashion, starting at the top.
  Iterable<MatrixElement<E>> surrounding(MatrixOffset offset) sync* {
    final top = offset.row > 0;
    final left = offset.column > 0;
    final bottom = offset.row < length - 1;
    final right = offset.column < first.length - 1;

    if (top && left) yield at(offset.row - 1, offset.column - 1);
    if (top) yield at(offset.row - 1, offset.column);
    if (top && right) yield at(offset.row - 1, offset.column + 1);

    if (right) yield at(offset.row, offset.column + 1);

    if (bottom && right) yield at(offset.row + 1, offset.column + 1);
    if (bottom) yield at(offset.row + 1, offset.column);
    if (bottom && left) yield at(offset.row + 1, offset.column - 1);

    if (left) yield at(offset.row, offset.column - 1);
  }

  MatrixElement<E> at(int row, int column) =>
      MatrixElement.from(row, column, this);

  Iterable<MatrixElement<E>> get elements sync* {
    for (final (i, row) in this.indexed) {
      for (final (j, element) in row.indexed) {
        yield MatrixElement(i, j, element);
      }
    }
  }

  MatrixOffset offset(MatrixOffset start, MatrixOffset end) => MatrixOffset(
        end.row - start.row,
        end.column - start.column,
      );

  MatrixElement<E> atOffset(MatrixOffset start, MatrixElement offset) => at(
        start.row + offset.row,
        start.column + offset.column,
      );

  void insertRow(int index, List<E> row) => insert(index, row);

  void insertColumn(int index, List<E> column) {
    for (final (i, row) in this.indexed) {
      row.insert(index, column[i]);
    }
  }

  Iterable<Iterable<E>> get columns => Iterable.generate(
        first.length,
        (j) => Iterable.generate(
          length,
          (i) => this[i][j],
        ),
      );

  Matrix<E> get transposed => columns.map((e) => e.toList()).toList();

  String format(String Function(E element) formatter) =>
      map((e) => e.map(formatter).join()).join("\n");
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

  bool get isAbove => column < 0;

  bool get isBelow => column > 0;

  bool get isLeft => row < 0;

  bool get isRight => row > 0;

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
      : element = matrix[row][column];

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
