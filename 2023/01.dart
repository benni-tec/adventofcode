import 'dart:io';

import '../utils/regexp.dart';

const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
const numStrings = {
  'zero': '0',
  'one': '1',
  'two': '2',
  'three': '3',
  'four': '4',
  'five': '5',
  'six': '6',
  'seven': '7',
  'eight': '8',
  'nine': '9',
};

const example = [
  'two1nine',
  'eightwothree',
  "abcone2threexyz",
  "xtwone3four",
  "4nineeightseven2",
  "zoneight234",
  "7pqrstsixteen"
];

void main() async {
  do3(await File("01-input.txt").readAsLines());
}

int do2(List<String> lines) {
  final pattern =
      RegExp(numStrings.keys.reduce((a, b) => "$a|$b"), caseSensitive: false);
  print(pattern);

  final adjusted = lines.indexed.map((e) {
    final (i, line) = e;

    var n = line;
    while (true) {
      final match = pattern.firstMatch(n);
      if (match == null) break;

      final group = match.group(0)!;
      n = n.replaceRange(match.start, match.start + 1, numStrings[group]!);
    }

    if (n != line) print("CONV[${i + 1}]: $line -> $n");

    return n;
  });

  final nums = adjusted.indexed.map((e) {
    final (i, line) = e;
    final local = line.split('').where((e) => numbers.contains(e));

    final val = int.parse(local.first + local.last);
    print("EVAL[${i + 1}]: $line -> $val");

    return val;
  }).toList();

  print(nums);

  final sum = nums.reduce((a, b) => a + b);
  print(sum);
  return sum;
}

int do3(List<String> lines) {
  final pattern =
      RegExp(numStrings.keys.reduce((a, b) => "$a|$b"), caseSensitive: false);
  print(pattern);

  final adjusted = lines.indexed.map((e) {
    final (i, line) = e;
    final matches = pattern.allMatchesOverlapping(line);

    var n = line;
    for (final match in matches)
      n = n.replaceRange(
        match.start,
        match.start + 1,
        numStrings[match.group(0)!]!,
      );

    if (n != line) print("CONV[${i + 1}]: $line -> $n");

    return n;
  });

  final nums = adjusted.indexed.map((e) {
    final (i, line) = e;
    final local = line.split('').where((e) => numbers.contains(e));

    final val = int.parse(local.first + local.last);
    print("EVAL[${i + 1}]: $line -> $val");

    return val;
  }).toList();

  print(nums);

  final sum = nums.reduce((a, b) => a + b);
  print(sum);
  return sum;
}
