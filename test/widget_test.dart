import 'package:flutter_test/flutter_test.dart';
import 'package:pokepoke/core/data/pokemon_species_data.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';

void main() {
  group('PokemonEntry API parsing', () {
    test('reads API fields and falls back to species dimensions', () {
      final pokemon = PokemonEntry.fromApi({
        'id': 1,
        'name': 'bulbasaur',
        'types': [
          {
            'type': {'name': 'grass'},
          },
          {
            'type': {'name': 'poison'},
          },
        ],
      });

      expect(pokemon.types, ['grass', 'poison']);
      expect(pokemon.height, 7);
      expect(pokemon.weight, 69);
    });

    test('uses dimensions returned by the API', () {
      final pokemon = PokemonEntry.fromApi({
        'id': 1,
        'name': 'bulbasaur',
        'types': [
          {
            'type': {'name': 'grass'},
          },
        ],
        'height': 8,
        'weight': 75,
      });

      expect(pokemon.height, 8);
      expect(pokemon.weight, 75);
    });

    test('does not invent measurements for unknown offline species', () {
      final pokemon = PokemonEntry.fromApi({
        'id': 999,
        'name': 'unknown',
        'types': [
          {
            'type': {'name': 'normal'},
          },
        ],
      });
      final species = getSpeciesData(pokemon.id);

      expect(pokemon.height, 0);
      expect(pokemon.weight, 0);
      expect(pokemon.formattedHeight, '—');
      expect(pokemon.formattedWeight, '—');
      expect(species.abilities, isEmpty);
      expect(species.weaknesses, isEmpty);
    });
  });

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
      expect(bulbasaur.spriteSize, inInclusiveRange(76.0, 82.0));
      expect(venusaur.spriteSize, inInclusiveRange(98.0, 105.0));
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

      expect(tiny.spriteSize, equals(72.0));
      expect(giant.spriteSize, equals(125.0));
      expect(tiny.formattedHeight, equals('0.1 m'));
      expect(giant.formattedHeight, equals('8.8 m'));
    });
  });
}
