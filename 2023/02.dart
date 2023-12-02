import 'dart:io';

import '../utils/iterable.dart';

final example = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""
    .split('\n');

void main() async {
  final input = await File('02-input.txt').readAsLines();
  do1(input);
  do2(input);
}

const bounds1 = Bounds(12, 13, 14);

int do1(List<String> lines) {
  final games = lines.nonEmpties().map((e) => Game.parse(e));
  final possibles = games.where((e) => bounds1.validGame(e));
  final sum = possibles.map((e) => e.id).sum();

  print(sum);

  return sum;
}

int do2(List<String> lines) {
  final games = lines.nonEmpties().map((e) => Game.parse(e));
  final powers = games.map((e) => e.minimalBound().power());
  final sum = powers.sum();

  print(sum);
  return sum;
}

class Game {
  final int id;
  final List<Draw> draws;

  Game(this.id, this.draws);

  factory Game.parse(String line) {
    final s1 = line.split(": ");
    final id = s1[0].split(' ')[1];
    final draws = Draw.parseAll(s1[1]);

    return Game(int.parse(id), draws);
  }

  Bounds minimalBound() => Bounds(
        draws.map((e) => e.red).max(),
        draws.map((e) => e.green).max(),
        draws.map((e) => e.blue).max(),
      );
}

class Bounds {
  final int red;
  final int green;
  final int blue;

  const Bounds(this.red, this.green, this.blue);

  bool validGame(Game game) => game.draws.every((draw) => validDraw(draw));

  bool validDraw(Draw draw) =>
      draw.red <= red && draw.green <= green && draw.blue <= blue;

  int power() => red * green * blue;
}

class Draw {
  final int red;
  final int green;
  final int blue;

  Draw(this.red, this.green, this.blue);

  factory Draw.parse(String draw) {
    final components = Map.fromEntries(draw.split(', ').map((e) {
      final s2 = e.split(' ');
      return MapEntry(s2[1], int.parse(s2[0]));
    }));

    return Draw(
      components['red'] ?? 0,
      components['green'] ?? 0,
      components['blue'] ?? 0,
    );
  }

  static List<Draw> parseAll(String draws) =>
      draws.split('; ').map((e) => Draw.parse(e)).toList();
}
