class Vector {
  final int x;
  final int y;

  const Vector(this.x, this.y);

  const Vector.all(int value)
      : x = value,
        y = value;

  operator +(Vector other) => Vector(x + other.x, y + other.y);

  Rectangle toRectangle() => Rectangle(this, this);

  @override
  bool operator ==(Object other) {
    if (other is! Vector) return false;
    return x == other.x && y == other.y;
  }

  @override
  String toString() => "($x, $y)";
}

class Rectangle {
  final Vector start;
  final Vector end;

  int get width => end.x - start.x + 1;
  int get height => end.y - start.y + 1;

  Rectangle(this.start, this.end)
      : assert(start.x <= end.x),
        assert(start.y <= end.y);

  bool get isZero => start.x == end.x && start.y == end.y;

  bool get isLine => (start.x == end.x || start.y == end.y) && !isZero;

  Vector get topLeft => start;

  Vector get topRight => Vector(end.x, start.y);

  Vector get bottomLeft => Vector(start.x, end.y);

  Vector get bottomRight => end;

  @override
  bool operator ==(Object other) {
    if (other is! Rectangle) return false;
    return start == other.start && end == other.end;
  }
}
