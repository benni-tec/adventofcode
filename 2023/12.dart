import '../utils/iterable.dart';
import '../utils/regexp.dart';

final example = """???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"""
    .split("\n");

void main() async {
  do1(example);
}

int do1(List<String> lines) {
  final _lines = lines.map(Line.parse);
  print(_lines.map((e) => e.possibilities()));

  return 0;
}

class Line {
  final String string;
  final List<int> groupCounts;

  const Line(this.string, this.groupCounts);

  factory Line.parse(String line) {
    final s = line.split(" ");
    final groups = s[1].split(",").map(int.parse);

    return Line(s[0], groups.toList());
  }

  int possibilities() {
    // final allGroups = _groups();
    // final unknown = <int>[];

    // final regex = RegExp(
    //   "[?.]*" + groupCounts.map((e) => "[#?]{$e}+").join("[?.]+") + "[?.]*",
    // );

    int check(String str, List<int> counts, int depth) {
      print(" " * depth + "$str $counts");
      if (str.isEmpty && counts.isEmpty) {
        print("match!");
        return 1;
      }
      if (str.isEmpty || counts.isEmpty) return 0;

      final first = str.substring(0, 1);
      switch (first) {
        case ".":
          return check(str.substring(1), counts, depth + 1);
        case "#":
          if (_consecutiveNonDots(str) == counts.first) {
            final int further = str.length - 1 < counts.first + 1
                ? counts.length == 1
                    ? 1
                    : 0
                : check("." + str.substring(counts.first + 1),
                    counts.sublist(1), depth + 1);

            return further + check(str.substring(1), counts, depth + 1);
          } else {
            return 0;
          }
        case "?":
          return check("." + str.substring(1), counts, depth) +
              check("#" + str.substring(1), counts, depth);
        default:
          throw "Unknown symbol: $first";
      }
    }

    return check(string, groupCounts, 0);
  }

  List<Group> _groups() {
    final out = <Group>[Group(string.substring(0, 1), 0, 0)];
    final chars = string.split("");
    for (final (i, char) in chars.indexed) {
      if (out.last.symbol == char)
        out.last.length += 1;
      else {
        out.add(Group(char, i, 1));
      }
    }

    for (final group in out) {
      if (group.symbol != "?") continue;

      if (chars[group.start - 1] == "#") {
        group.start += 1;
        group.length -= 1;
      }

      if (chars[group.start + group.length] == "#") {
        group.length -= 1;
      }
    }

    return out;
  }

  static int _consecutiveNonDots(String str) {
    for (int i = 0; i < str.length; i++) {
      if (str[i] == ".") return i;
    }

    return str.length;
  }

  @override
  String toString() => "$string ${groupCounts}";
}

class Group {
  final String symbol;
  int start;
  int length;

  Group(this.symbol, this.start, this.length);
}

