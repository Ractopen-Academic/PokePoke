import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokepoke/core/data/pokemon_seed.dart';

const String _kCacheKey = 'pokemon_list_v2';
const String _kCacheTimestampKey = 'pokemon_cache_ts_v2';
// Refresh cache after 24 h
const Duration _kCacheTTL = Duration(hours: 24);

class CacheService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedIfEmpty();
  }

  /// Write seed data into cache if no cached data exists yet
  static Future<void> _seedIfEmpty() async {
    if (_prefs == null) return;
    final existing = _prefs!.getStringList(_kCacheKey);
    if (existing == null || existing.isEmpty) {
      final seedJson =
          kPokemonSeed.map((m) => jsonEncode(m)).toList();
      await _prefs!.setStringList(_kCacheKey, seedJson);
      // Don't set timestamp so a network refresh is triggered on first load
    }
  }

  static List<Map<String, dynamic>>? getCachedPokemon() {
    final raw = _prefs?.getStringList(_kCacheKey);
    if (raw == null || raw.isEmpty) return null;
    return raw
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> savePokemon(
      List<Map<String, dynamic>> list) async {
    final encoded = list.map((m) => jsonEncode(m)).toList();
    await _prefs?.setStringList(_kCacheKey, encoded);
    await _prefs?.setInt(
        _kCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch);
  }

  static bool isCacheStale() {
    final ts = _prefs?.getInt(_kCacheTimestampKey);
    if (ts == null) return true;
    final age = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(ts));
    return age > _kCacheTTL;
  }
}
