import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouriteService {
  static const String _kKey = 'favourite_pokemon_ids_v1';
  static SharedPreferences? _prefs;
  static final ValueNotifier<Set<int>> favouritesNotifier =
      ValueNotifier<Set<int>>({});

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs?.getStringList(_kKey) ?? [];
    final ids = list.map((s) => int.tryParse(s)).whereType<int>().toSet();
    favouritesNotifier.value = ids;
  }

  static bool isFavourite(int id) {
    return favouritesNotifier.value.contains(id);
  }

  static Future<bool> toggleFavourite(int id) async {
    final updated = Set<int>.from(favouritesNotifier.value);
    final isNowFav = !updated.contains(id);
    if (isNowFav) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    favouritesNotifier.value = updated;

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setStringList(
      _kKey,
      updated.map((i) => i.toString()).toList(),
    );
    return isNowFav;
  }
}
