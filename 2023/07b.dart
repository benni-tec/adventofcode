import 'dart:io';
import 'dart:math';

import '../utils/iterable.dart';

void main() async {
  final input = await File('2023/07-input.txt').readAsLines();
  do1(input);
}

int do1(List<String> lines) {
  final hands = lines.map(Hand.parse).toList();
  hands.sort((a, b) => a.compareTo(b));
  hands.where((e) => e.cards.map((e) => e.symbol).contains('J')).forEach((e) {
    print("$e --> ${e.type()} | ${e.cards.countBy((e) => e.symbol).values}");
  });

  final sum = hands.indexed.map((e) => (e.$1 + 1) * e.$2.bid).sum();

  print(sum);
  return sum;
}

class Hand implements Comparable<Hand> {
  final int bid;
  final List<Card> cards;

  const Hand(this.cards, this.bid);

  factory Hand.parse(String line) {
    final s = line.split(' ');
    final cards = s[0].split('').map((e) => Card(e)).toList();
    final bid = int.parse(s[1]);
    return Hand(cards, bid);
  }

  HandType type() {
    final jokers = cards.where((e) => e.symbol == 'J').length;
    if (jokers >= 5) return HandType.FiveKind;

    final counts = cards
        .where((e) => e.symbol != 'J')
        .countBy((e) => e.symbol)
        .values
        .toList();

    counts.sort((a, b) => b.compareTo(a));

    final m = counts[0];
    if (m + jokers >= 5) return HandType.FiveKind;
    if (m + jokers >= 4) return HandType.FourKind;

    if (counts.contains(3) && counts.contains(2)) return HandType.FullHouse;

    final m2 = counts[1];
    final remaining = jokers - (3 - m);
    if (m2 + remaining >= 2) return HandType.FullHouse;

    if (m + jokers >= 3) return HandType.ThreeKind;

    int pairs = counts.where((e) => e == 2).length;
    pairs += min(counts.countEq(1), jokers);

    if (pairs == 2) return HandType.TwoPair;
    if (pairs == 1) return HandType.OnePair;
    return HandType.HighCard;
  }

  @override
  int compareTo(Hand other) {
    final hand = type().compareTo(other.type());
    if (hand != 0) return hand;

    for (int i = 0; i < min(cards.length, other.cards.length); i++) {
      final d = cards[i].compareTo(other.cards[i]);
      if (d != 0) return d;
    }

    return 0;
  }

  @override
  String toString() => cards.join();
}

enum HandType {
  HighCard,
  OnePair,
  TwoPair,
  ThreeKind,
  FullHouse,
  FourKind,
  FiveKind
}

extension Stuff on HandType {
  int compareTo(HandType other) => this.index.compareTo(other.index);
}

class Card implements Comparable<Card> {
  final String symbol;

  const Card(this.symbol);

  int get index => [
        'J',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'T',
        'Q',
        'K',
        'A'
      ].indexOf(symbol);

  @override
  int compareTo(Card other) => index.compareTo(other.index);

  @override
  bool operator ==(Object other) {
    if (other is! Card) return false;
    return symbol == other.symbol;
  }

  @override
  String toString() => symbol;
}
