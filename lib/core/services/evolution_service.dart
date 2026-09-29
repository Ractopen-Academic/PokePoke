import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokepoke/core/services/cache_service.dart';

class EvolutionNode {
  final int id;
  final String name;
  final String? trigger; // e.g. "Level 16", "Thunder Stone", "Trade"

  const EvolutionNode({
    required this.id,
    required this.name,
    this.trigger,
  });

  String get displayName =>
      name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        if (trigger != null) 'trigger': trigger,
      };

  factory EvolutionNode.fromMap(Map<String, dynamic> m) => EvolutionNode(
        id: m['id'] as int,
        name: m['name'] as String,
        trigger: m['trigger'] as String?,
      );
}

class EvolutionChainData {
  final List<EvolutionNode> nodes;
  const EvolutionChainData({required this.nodes});

  bool get hasEvolution => nodes.length > 1;

  Map<String, dynamic> toMap() => {
        'nodes': nodes.map((n) => n.toMap()).toList(),
      };

  factory EvolutionChainData.fromMap(Map<String, dynamic> m) =>
      EvolutionChainData(
        nodes: (m['nodes'] as List)
            .map((e) => EvolutionNode.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

class EvolutionService {
  static final Map<int, EvolutionChainData> _cache = {};

  // Instant offline definitions for seed/Gen-1 starters and staples
  static final Map<int, EvolutionChainData> _builtInChains = {
    // Bulbasaur line
    1: _chain([
      const EvolutionNode(id: 1, name: 'bulbasaur'),
      const EvolutionNode(id: 2, name: 'ivysaur', trigger: 'Level 16'),
      const EvolutionNode(id: 3, name: 'venusaur', trigger: 'Level 32'),
    ]),
    2: _chain([
      const EvolutionNode(id: 1, name: 'bulbasaur'),
      const EvolutionNode(id: 2, name: 'ivysaur', trigger: 'Level 16'),
      const EvolutionNode(id: 3, name: 'venusaur', trigger: 'Level 32'),
    ]),
    3: _chain([
      const EvolutionNode(id: 1, name: 'bulbasaur'),
      const EvolutionNode(id: 2, name: 'ivysaur', trigger: 'Level 16'),
      const EvolutionNode(id: 3, name: 'venusaur', trigger: 'Level 32'),
    ]),

    // Charmander line
    4: _chain([
      const EvolutionNode(id: 4, name: 'charmander'),
      const EvolutionNode(id: 5, name: 'charmeleon', trigger: 'Level 16'),
      const EvolutionNode(id: 6, name: 'charizard', trigger: 'Level 36'),
    ]),
    5: _chain([
      const EvolutionNode(id: 4, name: 'charmander'),
      const EvolutionNode(id: 5, name: 'charmeleon', trigger: 'Level 16'),
      const EvolutionNode(id: 6, name: 'charizard', trigger: 'Level 36'),
    ]),
    6: _chain([
      const EvolutionNode(id: 4, name: 'charmander'),
      const EvolutionNode(id: 5, name: 'charmeleon', trigger: 'Level 16'),
      const EvolutionNode(id: 6, name: 'charizard', trigger: 'Level 36'),
    ]),

    // Squirtle line
    7: _chain([
      const EvolutionNode(id: 7, name: 'squirtle'),
      const EvolutionNode(id: 8, name: 'wartortle', trigger: 'Level 16'),
      const EvolutionNode(id: 9, name: 'blastoise', trigger: 'Level 36'),
    ]),
    8: _chain([
      const EvolutionNode(id: 7, name: 'squirtle'),
      const EvolutionNode(id: 8, name: 'wartortle', trigger: 'Level 16'),
      const EvolutionNode(id: 9, name: 'blastoise', trigger: 'Level 36'),
    ]),
    9: _chain([
      const EvolutionNode(id: 7, name: 'squirtle'),
      const EvolutionNode(id: 8, name: 'wartortle', trigger: 'Level 16'),
      const EvolutionNode(id: 9, name: 'blastoise', trigger: 'Level 36'),
    ]),

    // Caterpie line
    10: _chain([
      const EvolutionNode(id: 10, name: 'caterpie'),
      const EvolutionNode(id: 11, name: 'metapod', trigger: 'Level 7'),
      const EvolutionNode(id: 12, name: 'butterfree', trigger: 'Level 10'),
    ]),
    11: _chain([
      const EvolutionNode(id: 10, name: 'caterpie'),
      const EvolutionNode(id: 11, name: 'metapod', trigger: 'Level 7'),
      const EvolutionNode(id: 12, name: 'butterfree', trigger: 'Level 10'),
    ]),
    12: _chain([
      const EvolutionNode(id: 10, name: 'caterpie'),
      const EvolutionNode(id: 11, name: 'metapod', trigger: 'Level 7'),
      const EvolutionNode(id: 12, name: 'butterfree', trigger: 'Level 10'),
    ]),

    // Weedle line
    13: _chain([
      const EvolutionNode(id: 13, name: 'weedle'),
      const EvolutionNode(id: 14, name: 'kakuna', trigger: 'Level 7'),
      const EvolutionNode(id: 15, name: 'beedrill', trigger: 'Level 10'),
    ]),
    14: _chain([
      const EvolutionNode(id: 13, name: 'weedle'),
      const EvolutionNode(id: 14, name: 'kakuna', trigger: 'Level 7'),
      const EvolutionNode(id: 15, name: 'beedrill', trigger: 'Level 10'),
    ]),
    15: _chain([
      const EvolutionNode(id: 13, name: 'weedle'),
      const EvolutionNode(id: 14, name: 'kakuna', trigger: 'Level 7'),
      const EvolutionNode(id: 15, name: 'beedrill', trigger: 'Level 10'),
    ]),

    // Pikachu line
    25: _chain([
      const EvolutionNode(id: 172, name: 'pichu'),
      const EvolutionNode(id: 25, name: 'pikachu', trigger: 'High Friendship'),
      const EvolutionNode(id: 26, name: 'raichu', trigger: 'Thunder Stone'),
    ]),

    // Jigglypuff line
    39: _chain([
      const EvolutionNode(id: 174, name: 'igglybuff'),
      const EvolutionNode(id: 39, name: 'jigglypuff', trigger: 'High Friendship'),
      const EvolutionNode(id: 40, name: 'wigglytuff', trigger: 'Moon Stone'),
    ]),

    // Meowth line
    52: _chain([
      const EvolutionNode(id: 52, name: 'meowth'),
      const EvolutionNode(id: 53, name: 'persian', trigger: 'Level 28'),
    ]),

    // Gengar line
    94: _chain([
      const EvolutionNode(id: 92, name: 'gastly'),
      const EvolutionNode(id: 93, name: 'haunter', trigger: 'Level 25'),
      const EvolutionNode(id: 94, name: 'gengar', trigger: 'Trade'),
    ]),

    // Mewtwo (Legendary - No Evolution)
    150: _chain([
      const EvolutionNode(id: 150, name: 'mewtwo'),
    ]),
  };

  static EvolutionChainData _chain(List<EvolutionNode> nodes) =>
      EvolutionChainData(nodes: nodes);

  /// Get evolution chain for a Pokémon by ID, with built-in instant data and PokeAPI fallback.
  static Future<EvolutionChainData> getEvolutionChain(int pokemonId, String fallbackName) async {
    // Check in-memory cache
    if (_cache.containsKey(pokemonId)) {
      return _cache[pokemonId]!;
    }

    // Check built-in instant dictionary
    if (_builtInChains.containsKey(pokemonId)) {
      final data = _builtInChains[pokemonId]!;
      _cache[pokemonId] = data;
      return data;
    }

    // Check persistent disk cache
    final cachedData = CacheService.getCachedEvolutionChain(pokemonId);
    if (cachedData != null) {
      try {
        final parsed = EvolutionChainData.fromMap(cachedData);
        _cache[pokemonId] = parsed;
        return parsed;
      } catch (_) {}
    }

    // Attempt PokeAPI fetch
    try {
      final speciesRes = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$pokemonId'),
        headers: {'User-Agent': 'PokePoke-App'},
      ).timeout(const Duration(seconds: 6));

      if (speciesRes.statusCode == 200) {
        final speciesData = jsonDecode(speciesRes.body);
        final evolutionChainUrl = speciesData['evolution_chain']?['url'] as String?;

        if (evolutionChainUrl != null) {
          final evoRes = await http.get(
            Uri.parse(evolutionChainUrl),
            headers: {'User-Agent': 'PokePoke-App'},
          ).timeout(const Duration(seconds: 6));

          if (evoRes.statusCode == 200) {
            final evoData = jsonDecode(evoRes.body);
            final nodes = <EvolutionNode>[];
            _parseChainNode(evoData['chain'], nodes);
            if (nodes.isNotEmpty) {
              final result = EvolutionChainData(nodes: nodes);
              _cache[pokemonId] = result;
              // Persist chain for this id and all related nodes
              final map = result.toMap();
              for (final node in nodes) {
                _cache[node.id] = result;
                await CacheService.saveEvolutionChain(node.id, map);
              }
              return result;
            }
          }
        }
      }
    } catch (_) {
      // Fall through to fallback
    }

    // Fallback: single-stage node
    final fallback = EvolutionChainData(
      nodes: [EvolutionNode(id: pokemonId, name: fallbackName)],
    );
    _cache[pokemonId] = fallback;
    return fallback;
  }

  static void _parseChainNode(Map<String, dynamic>? rawNode, List<EvolutionNode> outList, [String? trigger]) {
    if (rawNode == null) return;

    final species = rawNode['species'] as Map<String, dynamic>?;
    if (species != null) {
      final name = species['name'] as String;
      final url = species['url'] as String;
      // Extract ID from URL: e.g. "https://pokeapi.co/api/v2/pokemon-species/1/"
      final id = _extractIdFromUrl(url);
      if (id != null) {
        outList.add(EvolutionNode(
          id: id,
          name: name,
          trigger: trigger,
        ));
      }
    }

    final evolvesTo = rawNode['evolves_to'] as List?;
    if (evolvesTo != null && evolvesTo.isNotEmpty) {
      for (final next in evolvesTo) {
        final nextMap = next as Map<String, dynamic>;
        final details = (nextMap['evolution_details'] as List?)?.firstOrNull as Map<String, dynamic>?;
        final nextTrigger = _formatTrigger(details);
        _parseChainNode(nextMap, outList, nextTrigger);
      }
    }
  }

  static int? _extractIdFromUrl(String url) {
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      return int.tryParse(segments.last);
    }
    return null;
  }

  static String _formatTrigger(Map<String, dynamic>? details) {
    if (details == null) return 'Evolves';
    final minLevel = details['min_level'];
    if (minLevel != null) return 'Level $minLevel';

    final item = details['item']?['name'] as String?;
    if (item != null) {
      return item.split('-').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
    }

    final triggerName = details['trigger']?['name'] as String?;
    if (triggerName == 'trade') return 'Trade';
    if (details['min_happiness'] != null) return 'High Friendship';

    return 'Special Condition';
  }
}
