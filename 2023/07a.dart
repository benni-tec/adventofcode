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
  print(hands);

  final sum = hands.indexed.map((e) => (e.$1 + 1) * e.$2.bid).sum();

  print(sum);
  return sum;
}

class Card implements Comparable<Card> {
  final String symbol;

  const Card(this.symbol);

  int get index => [
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'T',
        'J',
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
    final counts = cards.countBy((e) => e.symbol).values;
    print("$this -> $counts");

    if (counts.length == 1) return HandType.FiveKind;
    if (counts.any((e) => e == 4)) return HandType.FourKind;
    if (counts.any((e) => e == 3) && counts.any((e) => e == 2)) return HandType.FullHouse;
    if (counts.any((e) => e == 3)) return HandType.ThreeKind;

    final pairs = counts.where((e) => e == 2);
    if (pairs.length == 2) return HandType.TwoPair;
    if (pairs.length == 1) return HandType.OnePair;
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
