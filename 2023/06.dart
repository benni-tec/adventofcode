import 'dart:io';

import '../utils/iterable.dart';

void main() async {
  final input = await File('2023/06-input.txt').readAsLines();
  do2(input);
}

int do1(List<String> lines) {
  final races = Race.parse1(lines);
  final counts = races.map((e) => e.winningTimings.length);
  final product = counts.reduce((a, b) => a * b);

  print(product);
  return product;
}

int do2(List<String> lines) {
  final race = Race.parse2(lines);
  final sum = race.winningTimings.length;

  print(sum);
  return sum;
}

class Race {
  final int duration; /// in ms
  final int currentRecord; /// in mm

  const Race(this.duration, this.currentRecord);

  static List<Race> parse1(List<String> lines) {
    final times = lines[0].split(": ")[1].split(" ").nonWhitespace().map(int.parse);
    final distances = lines[1].split(": ")[1].split(" ").nonWhitespace().map(int.parse);

    return times.pair(distances, (time, distance) => Race(time, distance)).toList();
  }

  static Race parse2(List<String> lines) {
    final time = int.parse(lines[0].split(": ")[1].replaceAll(" ", ""));
    final distance = int.parse(lines[1].split(": ")[1].replaceAll(" ", ""));

    return Race(time, distance);
  }

  bool isWinning(int timing) {
    final movingTime = duration - timing;
    return timing * movingTime > currentRecord;
  }

  Iterable<int> get winningTimings => Iterable.generate(duration, (i) => i).where(isWinning);
}
