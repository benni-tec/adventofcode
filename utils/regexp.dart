const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

extension Overlaping on RegExp {
  List<RegExpMatch> allMatchesOverlapping(String input, [int start = 0]) {
    final out = <RegExpMatch>[];

    var current = start;
    while (true) {
      final match = firstMatch(input.substring(current));
      if (match == null) break;

      out.add(_OffsetMatch(match, current));
      current = match.start + current + 1;
    }

    return out;
  }

  RegExpMatch? firstMatchFrom(String input, int start) {
    final match = firstMatch(input.substring(start));
    return match == null ? null : _OffsetMatch(match, start);
  }
}

class _OffsetMatch implements RegExpMatch {
  final int offset;
  final RegExpMatch original;

  _OffsetMatch(this.original, this.offset);

  @override
  int get start => original.start + offset;

  @override
  int get end => original.end + offset;

  // Passthroughs

  @override
  String? operator [](int group) => original[group];

  @override
  String? group(int group) => original.group(group);

  @override
  int get groupCount => original.groupCount;

  @override
  Iterable<String> get groupNames => original.groupNames;

  @override
  List<String?> groups(List<int> groupIndices) => original.groups(groupIndices);

  @override
  String get input => original.input;

  @override
  String? namedGroup(String name) => original.namedGroup(name);

  @override
  RegExp get pattern => original.pattern;
}
