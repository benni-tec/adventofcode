import 'dart:io';
import 'package:collection/collection.dart';

import '../utils/iterable.dart';

const example = """LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)""";

void main() async {
  final input = await File("2023/08-input.txt").readAsLines();
  do2(input);
}

int do1(List<String> lines) {
  final directions = WrapAroundList(
    lines[0].split("").nonWhitespace().toList(),
  );

  final nodes = Map.fromEntries(
    lines.sublist(2).map(Node.parse).map((e) => MapEntry(e.id, e)),
  );

  Node current = nodes["AAA"]!;
  for (int i = 0; true; i++) {
    if (current.id == "ZZZ") return i;

    switch (directions[i]) {
      case "R":
        current = nodes[current.rightId]!;
        break;
      case "L":
        current = nodes[current.leftId]!;
        break;
      default:
        throw UnimplementedError();
    }
  }
}

int do2(List<String> lines) {
  final directions = WrapAroundList(
    lines[0].split("").nonWhitespace().toList(),
  );

  final _nodes = lines.sublist(2).map(Node.parse).toList();
  final nodes = Map.fromEntries(_nodes.map((e) => MapEntry(e.id, e)));

  List<List<Node>> loops = _nodes.where((e) => e.isStart).map((e) {
    List<Node> history = [];
    Node current = e;
    for (int i = 0; true; i++) {
      if (history.contains(current) && directions[i] == directions[history.indexOf(current)])
        return history;

      switch (directions[i]) {
        case "R":
          history.insert(0, nodes[current.rightId]!);
          break;
        case "L":
          history.insert(0, nodes[current.leftId]!);
          break;
        default:
          throw UnimplementedError();
      }
    }
  }).toList();

  print(loops);

  return 0;
}

int lcm(int a, int b) => (a ~/ a.gcd(b)) * b;

class Node {
  final String id;
  final String leftId;
  final String rightId;

  Node(this.id, this.leftId, this.rightId);

  factory Node.parse(String line) {
    final s = line.split(" = ");
    final children = s[1].replaceAll(RegExp(r"[()]"), "").split(", ");
    return Node(s[0], children[0], children[1]);
  }

  late final isLoop = id == leftId && id == rightId;
  late final isStart = id.endsWith("A");
  late final isEnd = id.endsWith("Z");
}

class WrapAroundList<E> extends DelegatingList<E> {
  WrapAroundList([List<E>? base]) : super(base ?? []);

  @override
  void operator []=(int index, E value) => super[index % length] = value;

  @override
  E operator [](int index) => super[index % length];
}
