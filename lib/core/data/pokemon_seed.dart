// Hardcoded seed data for the first 20 Pokémon.
// Used as fallback when there is no network and the cache is empty.
// Images are loaded via cached_network_image (cached on first load).

const List<Map<String, dynamic>> kPokemonSeed = [
  {'id': 1,  'name': 'bulbasaur',  'types': ['grass', 'poison'], 'height': 7,  'weight': 69},
  {'id': 2,  'name': 'ivysaur',    'types': ['grass', 'poison'], 'height': 10, 'weight': 130},
  {'id': 3,  'name': 'venusaur',   'types': ['grass', 'poison'], 'height': 20, 'weight': 1000},
  {'id': 4,  'name': 'charmander', 'types': ['fire'],            'height': 6,  'weight': 85},
  {'id': 5,  'name': 'charmeleon', 'types': ['fire'],            'height': 11, 'weight': 190},
  {'id': 6,  'name': 'charizard',  'types': ['fire', 'flying'],  'height': 17, 'weight': 905},
  {'id': 7,  'name': 'squirtle',   'types': ['water'],           'height': 5,  'weight': 90},
  {'id': 8,  'name': 'wartortle',  'types': ['water'],           'height': 10, 'weight': 225},
  {'id': 9,  'name': 'blastoise',  'types': ['water'],           'height': 16, 'weight': 855},
  {'id': 10, 'name': 'caterpie',   'types': ['bug'],             'height': 3,  'weight': 29},
  {'id': 11, 'name': 'metapod',    'types': ['bug'],             'height': 7,  'weight': 99},
  {'id': 12, 'name': 'butterfree', 'types': ['bug', 'flying'],  'height': 11, 'weight': 320},
  {'id': 13, 'name': 'weedle',     'types': ['bug', 'poison'],   'height': 3,  'weight': 32},
  {'id': 14, 'name': 'kakuna',     'types': ['bug', 'poison'],   'height': 6,  'weight': 100},
  {'id': 15, 'name': 'beedrill',   'types': ['bug', 'poison'],   'height': 10, 'weight': 295},
  {'id': 25, 'name': 'pikachu',    'types': ['electric'],        'height': 4,  'weight': 60},
  {'id': 39, 'name': 'jigglypuff', 'types': ['normal', 'fairy'], 'height': 5,  'weight': 55},
  {'id': 52, 'name': 'meowth',     'types': ['normal'],          'height': 4,  'weight': 42},
  {'id': 94, 'name': 'gengar',     'types': ['ghost', 'poison'], 'height': 15, 'weight': 405},
  {'id': 150,'name': 'mewtwo',     'types': ['psychic'],         'height': 20, 'weight': 1220},
];
