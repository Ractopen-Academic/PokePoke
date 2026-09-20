import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:pokepoke/core/services/cache_service.dart';

class PokemonEntry {
  final int id;
  final String name;
  final List<String> types;

  PokemonEntry({
    required this.id,
    required this.name,
    required this.types,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
  String get displayName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  factory PokemonEntry.fromMap(Map<String, dynamic> m) {
    return PokemonEntry(
      id: m['id'] as int,
      name: m['name'] as String,
      types: List<String>.from(m['types'] as List),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'types': types,
      };
}

// ---------------------------------------------------------------------------
// Hardcoded Pokémon #1–9 (verified via PokeAPI, always available offline)
// ---------------------------------------------------------------------------
final List<PokemonEntry> kBuiltInPokemon = [
  PokemonEntry(id: 1, name: 'bulbasaur',  types: ['grass', 'poison']),
  PokemonEntry(id: 2, name: 'ivysaur',    types: ['grass', 'poison']),
  PokemonEntry(id: 3, name: 'venusaur',   types: ['grass', 'poison']),
  PokemonEntry(id: 4, name: 'charmander', types: ['fire']),
  PokemonEntry(id: 5, name: 'charmeleon', types: ['fire']),
  PokemonEntry(id: 6, name: 'charizard',  types: ['fire', 'flying']),
  PokemonEntry(id: 7, name: 'squirtle',   types: ['water']),
  PokemonEntry(id: 8, name: 'wartortle',  types: ['water']),
  PokemonEntry(id: 9, name: 'blastoise',  types: ['water']),
];

class PokemonService {
  /// Returns immediately with the best available data (seed → cache → network).
  /// Background-fetches from network if stale, updating the cache for next run.
  static Future<List<PokemonEntry>> loadPokemon({
    void Function(String status)? onStatus,
  }) async {
    // 1. Always have at least the 9 built-ins
    List<PokemonEntry> result = List.from(kBuiltInPokemon);
    onStatus?.call('Built-in Pokédex loaded (${result.length} Pokémon)');

    // 2. Overlay with any cached data (may contain more entries)
    final cached = CacheService.getCachedPokemon();
    if (cached != null && cached.isNotEmpty) {
      result = cached.map(PokemonEntry.fromMap).toList();
      onStatus?.call('Cache loaded (${result.length} Pokémon)');
    }

    // 3. If cache is stale, kick off a background refresh (don't block UI)
    if (CacheService.isCacheStale()) {
      _backgroundRefresh(onStatus: onStatus);
    }

    return result;
  }

  /// Fires and forgets — updates cache in background after the app is loaded.
  static void _backgroundRefresh({void Function(String)? onStatus}) {
    Future(() async {
      final hasNet = await _hasNetwork();
      if (!hasNet) return;
      try {
        onStatus?.call('Background sync started…');
        final fresh = await _fetchFromNetwork();
        await CacheService.savePokemon(fresh.map((e) => e.toMap()).toList());
        onStatus?.call('Background sync complete (${fresh.length} Pokémon)');
      } catch (_) {
        // Silently ignore — user already has data
      }
    });
  }

  static Future<bool> _hasNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  static Future<List<PokemonEntry>> _fetchFromNetwork() async {
    final listRes = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'))
        .timeout(const Duration(seconds: 15));
    final listData = jsonDecode(listRes.body);
    final results = (listData['results'] as List).take(80).toList();

    // Fetch in small batches of 10 to avoid hammering the API
    final List<PokemonEntry> all = [];
    for (var i = 0; i < results.length; i += 10) {
      final batch = results.skip(i).take(10);
      final batchFutures = batch.map((p) async {
        final res = await http
            .get(Uri.parse(p['url'] as String))
            .timeout(const Duration(seconds: 10));
        final data = jsonDecode(res.body);
        final types = (data['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();
        return PokemonEntry(
          id: data['id'] as int,
          name: data['name'] as String,
          types: types,
        );
      }).toList();
      final batchResult = await Future.wait(batchFutures);
      all.addAll(batchResult);
    }
    return all;
  }
}
