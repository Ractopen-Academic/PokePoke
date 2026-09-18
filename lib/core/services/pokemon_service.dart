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

class PokemonService {
  /// Load pokemon: cache-first, network-refresh if stale/missing
  static Future<List<PokemonEntry>> loadPokemon({
    void Function(String status)? onStatus,
  }) async {
    // 1. Try cache first for instant display
    final cached = CacheService.getCachedPokemon();
    List<PokemonEntry>? cachedEntries;
    if (cached != null && cached.isNotEmpty) {
      cachedEntries = cached.map(PokemonEntry.fromMap).toList();
      onStatus?.call('Loaded ${cachedEntries.length} Pokémon from cache');
    }

    // 2. If cache is stale or empty, try network
    if (CacheService.isCacheStale() || cachedEntries == null) {
      final hasNet = await _hasNetwork();
      if (hasNet) {
        try {
          onStatus?.call('Fetching Pokédex from server…');
          final fresh = await _fetchFromNetwork(onStatus: onStatus);
          await CacheService.savePokemon(
              fresh.map((e) => e.toMap()).toList());
          return fresh;
        } catch (_) {
          // Network failed — return cached if we have it
        }
      }
    }

    return cachedEntries ?? [];
  }

  static Future<bool> _hasNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  static Future<List<PokemonEntry>> _fetchFromNetwork({
    void Function(String)? onStatus,
  }) async {
    final listRes = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'))
        .timeout(const Duration(seconds: 10));
    final listData = jsonDecode(listRes.body);
    final results = (listData['results'] as List).take(80).toList();

    onStatus?.call('Downloading Pokémon data (0/${results.length})…');

    int done = 0;
    final futures = results.map((p) async {
      final res = await http
          .get(Uri.parse(p['url'] as String))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      final types = (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList();
      done++;
      onStatus?.call('Downloading Pokémon data ($done/${results.length})…');
      return PokemonEntry(
        id: data['id'] as int,
        name: data['name'] as String,
        types: types,
      );
    }).toList();

    return Future.wait(futures);
  }
}
