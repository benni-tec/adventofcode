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

int do1(List<String> lines, String terminator) {
  final almanac = Almanac.parse(lines, terminator);
  // print(almanac);
  // print(almanac.soilToFertilizer);
  final min = almanac.map((seed) => seed.location).min();

  print(min);
  return min;
}

int do2(List<String> lines, String terminator) {
  final almanac = Almanac.parse2(lines, terminator);
  final minn = almanac.map((e) => e.location).min();

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

class Almanac extends Iterable<Seed> {
  final Iterable<int> seeds;
  final List<int> seedsToSoil;
  final List<int> soilToFertilizer;
  final List<int> fertilizerToWater;
  final List<int> waterToLight;
  final List<int> lightToTemperature;
  final List<int> temperatureToHumidity;
  final List<int> humidityToLocation;

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

  static MapEntry<String, List<int>> parsePart(String part, String terminator) {
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
        .split(" ")
        .nonWhitespace()
        .map(int.parse);
    final _maps = parts
        .sublist(1)
        .nonWhitespace()
        .map((e) => parsePart(e, terminator));
    final maps = Map.fromEntries(_maps);

    return Almanac(
      seeds: seeds,
      seedsToSoil: maps["seed-to-soil"]!,
      soilToFertilizer: maps["soil-to-fertilizer"]!,
      fertilizerToWater: maps["fertilizer-to-water"]!,
      waterToLight: maps["water-to-light"]!,
      lightToTemperature: maps["light-to-temperature"]!,
      temperatureToHumidity: maps["temperature-to-humidity"]!,
      humidityToLocation: maps["humidity-to-location"]!,
    );
  }

  factory Almanac.parse2(List<String> lines, String terminator) {
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
    }).expand((pair) {
      print(pair);
      return Iterable.generate(pair[1], (i) => i + pair[0]);
    });
    final _maps = parts
        .sublist(1)
        .nonWhitespace()
        .map((e) => parsePart(e, terminator));
    final maps = Map.fromEntries(_maps);

    return Almanac(
      seeds: seeds,
      seedsToSoil: maps["seed-to-soil"]!,
      soilToFertilizer: maps["soil-to-fertilizer"]!,
      fertilizerToWater: maps["fertilizer-to-water"]!,
      waterToLight: maps["water-to-light"]!,
      lightToTemperature: maps["light-to-temperature"]!,
      temperatureToHumidity: maps["temperature-to-humidity"]!,
      humidityToLocation: maps["humidity-to-location"]!,
    );
  }

  @override
  int get length => seeds.length;

  @override
  Iterator<Seed> get iterator => seeds.map((id) {
        final soil = seedsToSoil[id];
        final fertilizer = soilToFertilizer[soil];
        final water = fertilizerToWater[fertilizer];
        final light = waterToLight[water];
        final temperature = lightToTemperature[light];
        final humidity = temperatureToHumidity[temperature];
        final location = humidityToLocation[humidity];

        return Seed(
          id: id,
          soil: soil,
          fertilizer: fertilizer,
          water: water,
          light: light,
          temperature: temperature,
          humidity: humidity,
          location: location,
        );
      }).iterator;
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

  bool containsSourceIndex(int index) =>
      index >= sourceStart && index <= sourceEnd;

  int operator [](int index) {
    assert(containsSourceIndex(index));
    final offset = index - sourceStart;
    return destinationStart + offset;
  }
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
}
