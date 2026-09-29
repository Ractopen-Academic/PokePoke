import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pokepoke/core/data/pokemon_species_data.dart';
import 'package:pokepoke/core/services/evolution_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EvolutionResult {
  final bool didEvolve;
  final bool didLevelUp;
  final int newLevel;
  final String? oldName;
  final String? newName;
  final int? newPokemonId;

  const EvolutionResult({
    required this.didEvolve,
    required this.didLevelUp,
    required this.newLevel,
    this.oldName,
    this.newName,
    this.newPokemonId,
  });
}

class BattlePenService {
  static const String _kPenKey = 'safari_pen_pokemon_v1';
  static const int maxCapacity = 20;

  static SharedPreferences? _prefs;
  static final ValueNotifier<List<CaughtPokemon>> penNotifier =
      ValueNotifier<List<CaughtPokemon>>([]);

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getStringList(_kPenKey);
    if (raw != null && raw.isNotEmpty) {
      final list = raw
          .map((s) {
            try {
              return CaughtPokemon.fromMap(jsonDecode(s) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<CaughtPokemon>()
          .toList();
      penNotifier.value = list;
    } else {
      penNotifier.value = [];
    }
  }

  static Future<void> _save() async {
    if (_prefs == null) return;
    final encoded = penNotifier.value.map((p) => jsonEncode(p.toMap())).toList();
    await _prefs!.setStringList(_kPenKey, encoded);
  }

  /// Add a newly caught Pokémon. Returns false if pen is full (20 max).
  static Future<bool> addCaughtPokemon(PokemonEntry pokemon) async {
    if (penNotifier.value.length >= maxCapacity) {
      return false; // Pen full
    }

    final newCaught = CaughtPokemon(
      uniqueId: '${pokemon.id}_${DateTime.now().millisecondsSinceEpoch}',
      pokemonId: pokemon.id,
      name: pokemon.name,
      types: List.from(pokemon.types),
      level: 5,
      xp: 0,
      caughtAt: DateTime.now(),
    );

    penNotifier.value = [...penNotifier.value, newCaught];
    await _save();
    return true;
  }

  /// Discard/release a Pokémon from the Safari Pen
  static Future<void> releasePokemon(String uniqueId) async {
    penNotifier.value =
        penNotifier.value.where((p) => p.uniqueId != uniqueId).toList();
    await _save();
  }

  /// Click Pokémon to gain XP, level up, and auto-evolve when level condition is met
  static Future<EvolutionResult> gainXp(String uniqueId, {int amount = 25}) async {
    final list = List<CaughtPokemon>.from(penNotifier.value);
    final index = list.indexWhere((p) => p.uniqueId == uniqueId);
    if (index == -1) {
      return const EvolutionResult(didEvolve: false, didLevelUp: false, newLevel: 1);
    }

    final pokemon = list[index];
    pokemon.xp += amount;
    bool leveledUp = false;

    // Check for level up
    while (pokemon.xp >= pokemon.xpForNextLevel && pokemon.level < 100) {
      pokemon.xp -= pokemon.xpForNextLevel;
      pokemon.level += 1;
      leveledUp = true;
    }

    bool evolved = false;
    String? oldName;
    String? newName;
    int? newId;

    if (leveledUp) {
      // Check auto-evolution
      try {
        final chain = await EvolutionService.getEvolutionChain(
          pokemon.pokemonId,
          pokemon.name,
        );

        if (chain.hasEvolution) {
          final nodes = chain.nodes;
          final nodeIndex = nodes.indexWhere((n) => n.id == pokemon.pokemonId);

          if (nodeIndex >= 0 && nodeIndex < nodes.length - 1) {
            final nextNode = nodes[nodeIndex + 1];
            final trigger = nextNode.trigger ?? '';

            // Extract minimum level requirement if present (e.g. "Level 16", "Level 32")
            int requiredLevel = 16;
            final match = RegExp(r'Level\s*(\d+)', caseSensitive: false).firstMatch(trigger);
            if (match != null) {
              requiredLevel = int.tryParse(match.group(1)!) ?? 16;
            } else if (trigger.toLowerCase().contains('stone') ||
                trigger.toLowerCase().contains('trade') ||
                trigger.toLowerCase().contains('friendship')) {
              requiredLevel = (nodeIndex + 1) * 20; // Default trigger level
            }

            if (pokemon.level >= requiredLevel) {
              // Trigger Auto-Evolution!
              oldName = pokemon.displayName;
              newName = nextNode.displayName;
              newId = nextNode.id;

              // Update Pokémon attributes
              final updatedTypes = _resolveTypesForEvolved(nextNode.id, pokemon.types);
              final evolvedPokemon = CaughtPokemon(
                uniqueId: pokemon.uniqueId,
                pokemonId: nextNode.id,
                name: nextNode.name,
                types: updatedTypes,
                level: pokemon.level,
                xp: pokemon.xp,
                caughtAt: pokemon.caughtAt,
              );

              list[index] = evolvedPokemon;
              evolved = true;
            }
          }
        }
      } catch (_) {}
    }

    penNotifier.value = list;
    await _save();

    return EvolutionResult(
      didEvolve: evolved,
      didLevelUp: leveledUp,
      newLevel: list[index].level,
      oldName: oldName,
      newName: newName,
      newPokemonId: newId,
    );
  }

  static List<String> _resolveTypesForEvolved(int id, List<String> fallbackTypes) {
    if (kPokemonSpeciesInfo.containsKey(id)) {
      // Use standard starter/seed types if known
      final starterTypes = {
        2: ['grass', 'poison'],
        3: ['grass', 'poison'],
        5: ['fire'],
        6: ['fire', 'flying'],
        8: ['water'],
        9: ['water'],
        11: ['bug'],
        12: ['bug', 'flying'],
        14: ['bug', 'poison'],
        15: ['bug', 'poison'],
        26: ['electric'],
        40: ['normal', 'fairy'],
        53: ['normal'],
        93: ['ghost', 'poison'],
        94: ['ghost', 'poison'],
      };
      if (starterTypes.containsKey(id)) {
        return starterTypes[id]!;
      }
    }
    return fallbackTypes;
  }
}
