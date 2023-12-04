import 'dart:io';
import 'dart:math';

import '../utils/iterable.dart';

const example = """Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""";

void main() async {
  final input = await File('2023/04-input.txt').readAsLines();
  do2(input);
}

int do1(List<String> lines) {
  final cards = lines.map(ScratchCard.parse);
  final sum = cards.map((e) => e.value).sum();

  print(sum);
  return sum;
}

int do2(List<String> lines) {
  final originals = lines.map(ScratchCard.parse).toList();
  final results = _do2recursive(originals, originals);
  results.addAll(originals);

  print(results.map((e) => e.id));
  print(results.length);
  return results.length;
}

List<ScratchCard> _do2(List<ScratchCard> original, List<ScratchCard> current) =>
    current.where((e) => e.winners.isNotEmpty).expand((card) {
      final copies =
          List.generate(card.winners.length, (index) => card.id + index + 1);
      // print("won ${card.id} with ${card.winners.length} -> copy $copies");

      return copies.map((i) => original.firstWhere((e) => e.id == i));
    }).toList();

List<ScratchCard> _do2recursive(List<ScratchCard> original, List<ScratchCard> current) {
  if (current.isEmpty) return [];

  final next = _do2(original, current);
  return [
    ...next,
    ..._do2recursive(original, next),
  ];
}

class ScratchCard {
  final int id;
  final List<int> winningNumbers;
  final List<int> numbers;

  ScratchCard(this.id, this.winningNumbers, this.numbers);

  factory ScratchCard.parse(String line) {
    final s1 = line.split(': ');
    final id = s1[0].split(' ').where((e) => e.trim().isNotEmpty).elementAt(1);
    final nums = s1[1].split(' | ');

    List<int> parseNums(String str) => str
        .split(' ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(int.parse)
        .toList();

    return ScratchCard(
      int.parse(id),
      parseNums(nums[0]),
      parseNums(nums[1]),
    );
  }

  List<int> get winners =>
      numbers.where((e) => winningNumbers.contains(e)).toList();

  int get value => winners.isEmpty ? 0 : pow(2, winners.length - 1) as int;
}
