// Hardcoded seed data for the first 20 Pokémon.
// Used as fallback when there is no network and the cache is empty.
// Images are loaded via cached_network_image (cached on first load).

const List<Map<String, dynamic>> kPokemonSeed = [
  {'id': 1,  'name': 'bulbasaur',  'types': ['grass', 'poison']},
  {'id': 2,  'name': 'ivysaur',    'types': ['grass', 'poison']},
  {'id': 3,  'name': 'venusaur',   'types': ['grass', 'poison']},
  {'id': 4,  'name': 'charmander', 'types': ['fire']},
  {'id': 5,  'name': 'charmeleon', 'types': ['fire']},
  {'id': 6,  'name': 'charizard',  'types': ['fire', 'flying']},
  {'id': 7,  'name': 'squirtle',   'types': ['water']},
  {'id': 8,  'name': 'wartortle',  'types': ['water']},
  {'id': 9,  'name': 'blastoise',  'types': ['water']},
  {'id': 10, 'name': 'caterpie',   'types': ['bug']},
  {'id': 11, 'name': 'metapod',    'types': ['bug']},
  {'id': 12, 'name': 'butterfree', 'types': ['bug', 'flying']},
  {'id': 13, 'name': 'weedle',     'types': ['bug', 'poison']},
  {'id': 14, 'name': 'kakuna',     'types': ['bug', 'poison']},
  {'id': 15, 'name': 'beedrill',   'types': ['bug', 'poison']},
  {'id': 25, 'name': 'pikachu',    'types': ['electric']},
  {'id': 39, 'name': 'jigglypuff', 'types': ['normal', 'fairy']},
  {'id': 52, 'name': 'meowth',     'types': ['normal']},
  {'id': 94, 'name': 'gengar',     'types': ['ghost', 'poison']},
  {'id': 150,'name': 'mewtwo',     'types': ['psychic']},
];
