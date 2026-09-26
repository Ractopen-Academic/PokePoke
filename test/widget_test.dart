import 'package:flutter_test/flutter_test.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';

void main() {
  group('PokemonEntry Size Scaling', () {
    test('Bulbasaur scales smaller than Venusaur', () {
      final bulbasaur = PokemonEntry(
        id: 1,
        name: 'bulbasaur',
        types: ['grass', 'poison'],
        height: 7,
        weight: 69,
      );

      final venusaur = PokemonEntry(
        id: 3,
        name: 'venusaur',
        types: ['grass', 'poison'],
        height: 20,
        weight: 1000,
      );

      expect(bulbasaur.spriteSize, lessThan(venusaur.spriteSize));
      expect(bulbasaur.spriteSize, inInclusiveRange(65.0, 72.0));
      expect(venusaur.spriteSize, inInclusiveRange(110.0, 115.0));
    });

    test('Min and max bounds are respected', () {
      final tiny = PokemonEntry(
        id: 10,
        name: 'caterpie',
        types: ['bug'],
        height: 1,
        weight: 10,
      );

      final giant = PokemonEntry(
        id: 95,
        name: 'onix',
        types: ['rock', 'ground'],
        height: 88,
        weight: 2100,
      );

      expect(tiny.spriteSize, equals(56.0));
      expect(giant.spriteSize, equals(114.0));
      expect(tiny.formattedHeight, equals('0.1 m'));
      expect(giant.formattedHeight, equals('8.8 m'));
    });
  });
}

