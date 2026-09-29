import 'package:flutter_test/flutter_test.dart';
import 'package:pokepoke/core/services/cache_service.dart';
import 'package:pokepoke/core/services/evolution_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService.init();
  });

  group('Evolution and Index Caching', () {
    test('EvolutionNode and EvolutionChainData serialize correctly', () {
      final node1 = const EvolutionNode(id: 1, name: 'bulbasaur');
      final node2 = const EvolutionNode(id: 2, name: 'ivysaur', trigger: 'Level 16');
      final chain = EvolutionChainData(nodes: [node1, node2]);

      final map = chain.toMap();
      final reconstructed = EvolutionChainData.fromMap(map);

      expect(reconstructed.nodes.length, equals(2));
      expect(reconstructed.nodes[0].id, equals(1));
      expect(reconstructed.nodes[0].name, equals('bulbasaur'));
      expect(reconstructed.nodes[1].trigger, equals('Level 16'));
      expect(reconstructed.hasEvolution, isTrue);
    });

    test('CacheService persists and retrieves evolution chains', () async {
      final node = const EvolutionNode(id: 25, name: 'pikachu', trigger: 'High Friendship');
      final chain = EvolutionChainData(nodes: [node]);

      await CacheService.saveEvolutionChain(25, chain.toMap());
      final cached = CacheService.getCachedEvolutionChain(25);

      expect(cached, isNotNull);
      final restored = EvolutionChainData.fromMap(cached!);
      expect(restored.nodes.first.name, equals('pikachu'));
    });

    test('CacheService upsertPokemon adds new Pokémon and updates existing', () async {
      final p1 = PokemonEntry(
        id: 32,
        name: 'nidoran-m',
        types: ['poison'],
        height: 5,
        weight: 90,
      );

      await CacheService.upsertPokemon(p1.toMap());
      var cached = CacheService.getCachedPokemon()!;
      expect(cached.any((m) => m['id'] == 32), isTrue);

      final p1Updated = PokemonEntry(
        id: 32,
        name: 'nidoran-m',
        types: ['poison'],
        height: 6,
        weight: 95,
      );
      await CacheService.upsertPokemon(p1Updated.toMap());
      cached = CacheService.getCachedPokemon()!;
      final match = cached.firstWhere((m) => m['id'] == 32);
      expect(match['height'], equals(6));
    });

    test('EvolutionService returns instant built-in chains and caches them', () async {
      final chain = await EvolutionService.getEvolutionChain(1, 'bulbasaur');
      expect(chain.nodes.length, equals(3));
      expect(chain.nodes[0].name, equals('bulbasaur'));
      expect(chain.nodes[1].name, equals('ivysaur'));
      expect(chain.nodes[2].name, equals('venusaur'));
    });
  });
}
