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

  // Use the smaller sprite — loads fast, CORS-friendly on web
  String get spriteUrl =>
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
// Hardcoded Pokémon #1–9 (verified via PokeAPI curl, always available offline)
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
  static const int _pageSize = 10;

  /// Returns immediately with built-ins or cache. Background refresh if stale.
  static Future<List<PokemonEntry>> loadPokemon({
    void Function(String status)? onStatus,
  }) async {
    // Always have at least the 9 built-ins
    List<PokemonEntry> result = List.from(kBuiltInPokemon);
    onStatus?.call('Built-in Pokédex loaded (${result.length} Pokémon)');

    // Overlay with cache if we have more
    final cached = CacheService.getCachedPokemon();
    if (cached != null && cached.length > result.length) {
      result = cached.map(PokemonEntry.fromMap).toList();
      onStatus?.call('Cache loaded (${result.length} Pokémon)');
    }

    // Background refresh if stale
    if (CacheService.isCacheStale()) {
      _backgroundRefresh();
    }

    return result;
  }

  /// Fetch the next [_pageSize] Pokémon starting at [offset] (by Pokédex number).
  /// Appends to the current cached list and returns the full updated list.
  static Future<List<PokemonEntry>> fetchMore({
    required int offset,
    required List<PokemonEntry> existing,
  }) async {
    final hasNet = await _hasNetwork();
    if (!hasNet) return existing;

    // Fetch offset+1 to offset+pageSize (PokeAPI is 0-indexed, Pokédex is 1-indexed)
    final futures = List.generate(_pageSize, (i) async {
      final id = offset + i + 1; // IDs start at 1
      if (id > 1025) return null; // Pokédex cap
      try {
        final res = await http
            .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'))
            .timeout(const Duration(seconds: 8));
        final data = jsonDecode(res.body);
        final types = (data['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();
        return PokemonEntry(
          id: data['id'] as int,
          name: data['name'] as String,
          types: types,
        );
      } catch (_) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    final newEntries = results.whereType<PokemonEntry>().toList();
    newEntries.sort((a, b) => a.id.compareTo(b.id));

    // Merge: keep existing, add new (avoid duplicates by id)
    final existingIds = existing.map((e) => e.id).toSet();
    final merged = [
      ...existing,
      ...newEntries.where((e) => !existingIds.contains(e.id)),
    ];

    // Persist to cache
    await CacheService.savePokemon(merged.map((e) => e.toMap()).toList());
    return merged;
  }

  static void _backgroundRefresh() {
    Future(() async {
      final hasNet = await _hasNetwork();
      if (!hasNet) return;
      try {
        final fresh = await _fetchFirstPage();
        await CacheService.savePokemon(fresh.map((e) => e.toMap()).toList());
      } catch (_) {}
    });
  }

  static Future<bool> _hasNetwork() async {
    try {
      final result = await Connectivity()
          .checkConnectivity()
          .timeout(const Duration(seconds: 3));
      return result.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  static Future<List<PokemonEntry>> _fetchFirstPage() async {
    final futures = List.generate(20, (i) async {
      final id = i + 1;
      try {
        final res = await http
            .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'))
            .timeout(const Duration(seconds: 8));
        final data = jsonDecode(res.body);
        final types = (data['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();
        return PokemonEntry(
          id: data['id'] as int,
          name: data['name'] as String,
          types: types,
        );
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    return results.whereType<PokemonEntry>().toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }
}
