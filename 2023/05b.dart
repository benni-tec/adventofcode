import 'dart:collection';
import 'dart:io';
import '../utils/iterable.dart';

const example = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4""";

void main() async {
  do2(await File('2023/05-input.txt').readAsLines(), Platform.lineTerminator);
}

int do2(List<String> lines, String terminator) {
  final almanac = Almanac.parse(lines, terminator);

  final ranges = almanac.seeds
      .expandPrint(almanac.seedsToSoil.split)
      .expandPrint(almanac.soilToFertilizer.split)
      .expandPrint(almanac.fertilizerToWater.split)
      .expandPrint(almanac.waterToLight.split)
      .expandPrint(almanac.lightToTemperature.split)
      .expandPrint(almanac.temperatureToHumidity.split)
      .expandPrint(almanac.humidityToLocation.split).toList();

  print(ranges.length);

  final minn = ranges.map((e) => e.start).min();

  print(minn);
  return minn;
}

class Seed {
  final int id;
  final int soil;
  final int fertilizer;
  final int water;
  final int light;
  final int temperature;
  final int humidity;
  final int location;

  Seed({
    required this.id,
    required this.soil,
    required this.fertilizer,
    required this.water,
    required this.light,
    required this.temperature,
    required this.humidity,
    required this.location,
  });

  @override
  String toString() =>
      "Seed(id: $id, s: $soil, f: $fertilizer, w: $water, l: $light, t: $temperature, h: $humidity, l: $location)";
}

class Almanac {
  final List<Range> seeds;
  final RangeMappedList seedsToSoil;
  final RangeMappedList soilToFertilizer;
  final RangeMappedList fertilizerToWater;
  final RangeMappedList waterToLight;
  final RangeMappedList lightToTemperature;
  final RangeMappedList temperatureToHumidity;
  final RangeMappedList humidityToLocation;

  Almanac({
    required this.seeds,
    required this.seedsToSoil,
    required this.soilToFertilizer,
    required this.fertilizerToWater,
    required this.waterToLight,
    required this.lightToTemperature,
    required this.temperatureToHumidity,
    required this.humidityToLocation,
  });

  static MapEntry<String, RangeMappedList> parsePart(
      String part, String terminator) {
    final data = part.split(terminator);
    final s = data[0].split(' ');
    return MapEntry(
      s[0],
      RangeMappedList(data.sublist(1).map(RangeMapper.parse).toList()),
    );
  }

  factory Almanac.parse(List<String> lines, String terminator) {
    final parts = lines.join(terminator).split(terminator * 2);
    final seeds = parts[0]
        .replaceFirst("seeds: ", "")
        .split(' ')
        .map(int.parse)
        .fold([<int>[]], (value, element) {
      if (value.last.length < 2)
        value.last.add(element);
      else
        value.add([element]);

      return value;
    });

    final _maps =
        parts.sublist(1).nonWhitespace().map((e) => parsePart(e, terminator));
    final maps = Map.fromEntries(_maps);

    return Almanac(
      seeds: seeds.map((e) => Range(e[0], e[1])).toList(),
      seedsToSoil: maps["seed-to-soil"]!,
      soilToFertilizer: maps["soil-to-fertilizer"]!,
      fertilizerToWater: maps["fertilizer-to-water"]!,
      waterToLight: maps["water-to-light"]!,
      lightToTemperature: maps["light-to-temperature"]!,
      temperatureToHumidity: maps["temperature-to-humidity"]!,
      humidityToLocation: maps["humidity-to-location"]!,
    );
  }
}

class RangeMapper {
  final int destinationStart;
  final int sourceStart;
  final int length;

  RangeMapper(this.destinationStart, this.sourceStart, this.length);

  factory RangeMapper.parse(String line) {
    final s = line.split(" ").nonWhitespace().map(int.parse).toList();
    return RangeMapper(s[0], s[1], s[2]);
  }

  late final destinationEnd = destinationStart + length - 1;
  late final sourceEnd = sourceStart + length - 1;

  late final source = Range(sourceStart, sourceEnd);
  late final destination = Range(destinationStart, destinationEnd);

  bool containsSourceIndex(int index) =>
      index >= sourceStart && index <= sourceEnd;

  int operator [](int index) {
    assert(containsSourceIndex(index));
    final offset = index - sourceStart;
    return destinationStart + offset;
  }
}

class Range {
  final int start;
  final int end;

  const Range(this.start, this.end);

  @override
  String toString() => "($start, $end)";
}

class RangeMappedList extends ListBase<int> {
  final List<RangeMapper> ranges;
  final int length;

  RangeMappedList(this.ranges)
      : length = ranges.map((e) => e.sourceEnd).max() + 1;

  @override
  set length(int) => throw UnimplementedError();

  @override
  int operator [](int index) {
    if (index > length - 1) return index;
    for (final range in ranges) {
      if (range.containsSourceIndex(index)) return range[index];
    }

    return index;
  }

  @override
  void operator []=(int index, int value) => throw UnimplementedError();

  Iterable<Range> split(Range range) sync* {
    int current = range.start;
    for (final mapper in ranges) {
      if (mapper.sourceStart > current)
        yield Range(current, mapper.sourceStart - 1);

      if (mapper.containsSourceIndex(range.end)) {
        yield Range(mapper.destinationStart, mapper[range.end]);
        break;
      }

      yield mapper.destination;
      current = mapper.sourceEnd + 1;
    }

    if (current <= range.end) yield Range(current, range.end);
  }
}
