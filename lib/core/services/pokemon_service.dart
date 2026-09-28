import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:pokepoke/core/data/pokemon_species_data.dart';
import 'package:pokepoke/core/services/cache_service.dart';

class PokemonEntry {
  final int id;
  final String name;
  final List<String> types;
  final int height; // decimetres (10 dm = 1.0 m)
  final int weight; // hectograms (10 hg = 1.0 kg)

  PokemonEntry({
    required this.id,
    required this.name,
    required this.types,
    this.height = 10,
    this.weight = 100,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
  String get displayName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');

  String get formattedHeight => '${(height / 10).toStringAsFixed(1)} m';
  String get formattedWeight => '${(weight / 10).toStringAsFixed(1)} kg';

  /// Responsive sprite sizing:
  /// Small Pokémon (e.g. Caterpie, Sandshrew, Bulbasaur) scale around 72-78px,
  /// mid-stages (Ivysaur, Raichu) around 82-88px,
  /// large stages (Charizard, Ekans) around 96-102px,
  /// and giants (Venusaur, Arbok) scale up to 125px!
  double get spriteSize {
    const minH = 3.0; // 0.3 m
    const maxH = 35.0; // 3.5 m (Arbok)
    const minSize = 72.0;
    const maxSize = 125.0;

    final clampedH = height.clamp(minH.toInt(), maxH.toInt()).toDouble();
    final factor = (clampedH - minH) / (maxH - minH);
    return minSize + factor * (maxSize - minSize);
  }

  // Use the smaller sprite — loads fast, CORS-friendly on web
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  factory PokemonEntry.fromMap(Map<String, dynamic> m) {
    final id = m['id'] as int;
    final species = getSpeciesData(id);
    final rawH = (m['height'] as num?)?.toInt();
    final rawW = (m['weight'] as num?)?.toInt();

    // Auto-heal old cached entries where height was defaulted to 10
    final resolvedHeight = (rawH != null && (rawH != 10 || species.height == 10))
        ? rawH
        : species.height;
    final resolvedWeight = (rawW != null && (rawW != 100 || species.weight == 100))
        ? rawW
        : species.weight;

    return PokemonEntry(
      id: id,
      name: m['name'] as String,
      types: List<String>.from(m['types'] as List),
      height: resolvedHeight,
      weight: resolvedWeight,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'types': types,
        'height': height,
        'weight': weight,
      };
}

// ---------------------------------------------------------------------------
// Hardcoded Pokémon #1–9 (verified via PokeAPI curl, always available offline)
// ---------------------------------------------------------------------------
final List<PokemonEntry> kBuiltInPokemon = [
  PokemonEntry(id: 1, name: 'bulbasaur',  types: ['grass', 'poison'], height: 7,  weight: 69),
  PokemonEntry(id: 2, name: 'ivysaur',    types: ['grass', 'poison'], height: 10, weight: 130),
  PokemonEntry(id: 3, name: 'venusaur',   types: ['grass', 'poison'], height: 20, weight: 1000),
  PokemonEntry(id: 4, name: 'charmander', types: ['fire'],            height: 6,  weight: 85),
  PokemonEntry(id: 5, name: 'charmeleon', types: ['fire'],            height: 11, weight: 190),
  PokemonEntry(id: 6, name: 'charizard',  types: ['fire', 'flying'],  height: 17, weight: 905),
  PokemonEntry(id: 7, name: 'squirtle',   types: ['water'],           height: 5,  weight: 90),
  PokemonEntry(id: 8, name: 'wartortle',  types: ['water'],           height: 10, weight: 225),
  PokemonEntry(id: 9, name: 'blastoise',  types: ['water'],           height: 16, weight: 855),
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

  /// Fetch a single Pokémon by name or Pokédex number directly from PokeAPI.
  static Future<PokemonEntry?> fetchSinglePokemon(String query) async {
    final clean = query.trim().toLowerCase().replaceAll('#', '');
    if (clean.isEmpty) return null;

    try {
      final res = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$clean'),
        headers: {'User-Agent': 'PokePoke-App'},
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final id = data['id'] as int;
        final types = (data['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();
        final species = getSpeciesData(id);
        final height = (data['height'] as num?)?.toInt() ?? species.height;
        final weight = (data['weight'] as num?)?.toInt() ?? species.weight;

        return PokemonEntry(
          id: id,
          name: data['name'] as String,
          types: types,
          height: height,
          weight: weight,
        );
      }
    } catch (_) {}
    return null;
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
        final species = getSpeciesData(id);
        final height = (data['height'] as num?)?.toInt() ?? species.height;
        final weight = (data['weight'] as num?)?.toInt() ?? species.weight;
        return PokemonEntry(
          id: data['id'] as int,
          name: data['name'] as String,
          types: types,
          height: height,
          weight: weight,
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
        final species = getSpeciesData(id);
        final height = (data['height'] as num?)?.toInt() ?? species.height;
        final weight = (data['weight'] as num?)?.toInt() ?? species.weight;
        return PokemonEntry(
          id: data['id'] as int,
          name: data['name'] as String,
          types: types,
          height: height,
          weight: weight,
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
