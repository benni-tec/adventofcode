import 'dart:io';
import 'dart:math';

import '../utils/geometry.dart';
import '../utils/iterable.dart';
import '../utils/regexp.dart';

const example = """467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...\$.*....
.664.598..""";

void main() async {
  final input = await File('2023/03-input.txt').readAsLines();
  do2(input);
}

int do1(List<String> lines) {
  final schematic = EngineSchematic.parse(lines);

  final compounds = schematic.matrix.flatten().whereType<PartNumber>().toSet();

  final adjacent = compounds.where((e) => schematic.hasAdjacentSymbol(e));
  final sum = adjacent.map((e) => e.number).sum();

  print(sum);
  return sum;
}

int do2(List<String> lines) {
  final schematic = EngineSchematic.parse(lines);
  final gears =
      schematic.matrix.flatten().whereType<Gear>().map((e) => MapEntry(
            e,
            schematic
                .adjacent(e.point.toRectangle())
                .whereType<PartNumber>()
                .toSet(),
          ));

  final ratioGears = gears.where((e) => e.value.length == 2);

  final ratios =
      ratioGears.map((e) => e.value.first.number * e.value.last.number);
  final sum = ratios.sum();

  print(sum);
  return sum;
}

class EngineSchematic {
  final List<List<Entity?>> matrix;

  const EngineSchematic(this.matrix);

  factory EngineSchematic.parse(List<String> lines) {
    final matrix = lines.indexed.map((e) {
      final (y, line) = e;
      final out = <Entity?>[];

      // compound tracker
      int start = 0;
      final current = <int>[];

      void compound() {
        final com = PartNumber(current, Vector(start, y));
        out.addAll(List.filled(current.length, com));
        current.clear();
      }

      for (final (x, char) in line.split('').indexed) {
        if (numbers.contains(char)) {
          if (current.isEmpty) start = x;
          current.add(int.parse(char));
        } else {
          if (current.isNotEmpty) compound();
          switch (char) {
            case ".":
              out.add(null);
              break;
            case "*":
              out.add(Gear(Vector(x, y)));
              break;
            default:
              out.add(Symbol(char, Vector(x, y)));
          }
        }
      }

      if (current.isNotEmpty) compound();

      return out;
    }).toList();

    return EngineSchematic(matrix);
  }

  Entity? at(Vector point) => matrix[point.y][point.x];

  List<Entity> adjacent(Rectangle box) {
    final points = <Vector>[];

    final maxX = matrix.map((e) => e.length).max() - 1;
    final maxY = matrix.length - 1;

    final left = box.start.x > 0;
    final right = box.end.x < maxX;
    final top = box.start.y > 0;
    final bottom = box.end.y < maxY;

    // above
    if (top)
      points.addAll(List.generate(
        box.width,
        (index) => Vector(index + box.start.x, box.start.y - 1),
      ));

    // below
    if (bottom)
      points.addAll(List.generate(
        box.width,
        (index) => Vector(index + box.start.x, box.end.y + 1),
      ));

    // sides
    if (left) points.add(box.start + Vector(-1, 0));
    if (right) points.add(box.end + Vector(1, 0));

    // corners
    if (left && top) points.add(box.topLeft + Vector(-1, -1));
    if (left && bottom) points.add(box.bottomLeft + Vector(-1, 1));
    if (right && top) points.add(box.topRight + Vector(1, -1));
    if (right && bottom) points.add(box.bottomRight + Vector(1, 1));

    return points.map(at).nonNulls.toList();
  }

  bool hasAdjacentSymbol(PartNumber number) {
    final points = adjacent(number.box);
    print(
        "${number.number} | ${number.box.width} ${points.length}/${number.box.width * 2 + 6} - $points");
    return points.any((element) => element is Symbol);
  }
}

abstract class Entity {
  const Entity();

  Rectangle get box;
}

class PartNumber extends Entity {
  final int number;
  final Rectangle box;

  PartNumber(Iterable<int> numbers, Vector start)
      : box = Rectangle(start, start + Vector(numbers.length - 1, 0)),
        number = numbers.reversed().indexed.map((e) {
          final (i, n) = e;
          return n * pow(10, i) as int;
        }).sum();

  @override
  bool operator ==(Object other) {
    if (other is! PartNumber) return false;
    return box == other.box && number == other.number;
  }
}

class Symbol extends Entity {
  final String symbol;
  final Vector point;

  const Symbol(this.symbol, this.point);

  @override
  Rectangle get box => point.toRectangle();
}

class Gear extends Symbol {
  Gear(Vector point) : super("*", point);
}
