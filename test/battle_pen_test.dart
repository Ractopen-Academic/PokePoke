import 'package:flutter_test/flutter_test.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await BattlePenService.init();
  });

  group('BattlePenService & CaughtPokemon Tests', () {
    test('CaughtPokemon models XP progress and serialization accurately', () {
      final mon = CaughtPokemon(
        uniqueId: '1_test',
        pokemonId: 1,
        name: 'bulbasaur',
        types: ['grass', 'poison'],
        level: 5,
        xp: 125,
        caughtAt: DateTime.now(),
      );

      expect(mon.displayName, 'Bulbasaur');
      expect(mon.formattedId, '#001');
      expect(mon.xpForNextLevel, 250); // 5 * 50
      expect(mon.xpProgress, 0.5); // 125 / 250

      final map = mon.toMap();
      final revived = CaughtPokemon.fromMap(map);
      expect(revived.name, mon.name);
      expect(revived.level, mon.level);
      expect(revived.xp, mon.xp);
      expect(revived.types, mon.types);
    });

    test('Add caught Pokémon up to 20 capacity and enforce limit', () async {
      expect(BattlePenService.penNotifier.value.isEmpty, true);

      final dummyMon = PokemonEntry(
        id: 25,
        name: 'pikachu',
        types: ['electric'],
        height: 4,
        weight: 60,
      );

      // Add 20 Pokémon
      for (int i = 0; i < 20; i++) {
        final success = await BattlePenService.addCaughtPokemon(dummyMon);
        expect(success, true);
      }
      expect(BattlePenService.penNotifier.value.length, 20);

      // 21st Pokémon should fail because capacity is 20
      final overflowSuccess = await BattlePenService.addCaughtPokemon(dummyMon);
      expect(overflowSuccess, false);
      expect(BattlePenService.penNotifier.value.length, 20);
    });

    test('Release Pokémon frees up a slot in Safari Pen', () async {
      final dummyMon = PokemonEntry(
        id: 4,
        name: 'charmander',
        types: ['fire'],
        height: 6,
        weight: 85,
      );

      await BattlePenService.addCaughtPokemon(dummyMon);
      expect(BattlePenService.penNotifier.value.length, 1);

      final caughtId = BattlePenService.penNotifier.value.first.uniqueId;
      await BattlePenService.releasePokemon(caughtId);
      expect(BattlePenService.penNotifier.value.isEmpty, true);
    });

    test('Gain XP levels up Pokémon and triggers auto-evolution when level is reached', () async {
      final dummyMon = PokemonEntry(
        id: 1,
        name: 'bulbasaur',
        types: ['grass', 'poison'],
        height: 7,
        weight: 69,
      );

      await BattlePenService.addCaughtPokemon(dummyMon);
      final uniqueId = BattlePenService.penNotifier.value.first.uniqueId;

      // Train to gain XP
      final result1 = await BattlePenService.gainXp(uniqueId, amount: 25);
      expect(result1.didLevelUp, false);
      expect(BattlePenService.penNotifier.value.first.xp, 25);

      // Train enough to reach level 16 (Bulbasaur evolves into Ivysaur at Lv. 16)
      // Level 5 requires ~5500 XP to reach Lv 16. Let's give 10000 XP
      final resultEvolve = await BattlePenService.gainXp(uniqueId, amount: 10000);
      expect(resultEvolve.didLevelUp, true);
      expect(resultEvolve.didEvolve, true);
      expect(resultEvolve.newName, 'Ivysaur');
      expect(resultEvolve.newPokemonId, 2);

      // Check pen entry is now Ivysaur
      final currentMon = BattlePenService.penNotifier.value.first;
      expect(currentMon.pokemonId, 2);
      expect(currentMon.name, 'ivysaur');
    });
  });
}
