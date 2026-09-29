class PokemonSpeciesData {
  final int height; // decimetres (10 dm = 1.0 m)
  final int weight; // hectograms (10 hg = 1.0 kg)
  final String category;
  final String description;
  final List<String> abilities;
  final List<String> weaknesses;
  final String genderRatio;

  const PokemonSpeciesData({
    required this.height,
    required this.weight,
    required this.category,
    required this.description,
    required this.abilities,
    required this.weaknesses,
    this.genderRatio = '50% ♂ / 50% ♀',
  });
}

// ---------------------------------------------------------------------------
// Accurate official Pokédex physical specifications & lore for Gen 1 & starters
// ---------------------------------------------------------------------------
const Map<int, PokemonSpeciesData> kPokemonSpeciesInfo = {
  1: PokemonSpeciesData(
    height: 7,
    weight: 69,
    category: 'Seed Pokémon',
    description: 'A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon.',
    abilities: ['Overgrow', 'Chlorophyll'],
    weaknesses: ['Fire', 'Flying', 'Ice', 'Psychic'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  2: PokemonSpeciesData(
    height: 10,
    weight: 130,
    category: 'Seed Pokémon',
    description: 'When the bud on its back starts swelling, a sweet aroma wafts to indicate the flowers coming bloom.',
    abilities: ['Overgrow', 'Chlorophyll'],
    weaknesses: ['Fire', 'Flying', 'Ice', 'Psychic'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  3: PokemonSpeciesData(
    height: 20,
    weight: 1000,
    category: 'Seed Pokémon',
    description: 'The plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight.',
    abilities: ['Overgrow', 'Chlorophyll'],
    weaknesses: ['Fire', 'Flying', 'Ice', 'Psychic'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  4: PokemonSpeciesData(
    height: 6,
    weight: 85,
    category: 'Lizard Pokémon',
    description: 'The flame on its tail indicates Charizard\'s life force. If it is healthy, the flame burns brightly.',
    abilities: ['Blaze', 'Solar Power'],
    weaknesses: ['Water', 'Ground', 'Rock'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  5: PokemonSpeciesData(
    height: 11,
    weight: 190,
    category: 'Flame Pokémon',
    description: 'When it swings its burning tail, it elevates the temperature to unbearably high levels.',
    abilities: ['Blaze', 'Solar Power'],
    weaknesses: ['Water', 'Ground', 'Rock'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  6: PokemonSpeciesData(
    height: 17,
    weight: 905,
    category: 'Flame Pokémon',
    description: 'Spits fire that is hot enough to melt boulders. Known to cause forest fires unintentionally.',
    abilities: ['Blaze', 'Solar Power'],
    weaknesses: ['Water', 'Electric', 'Rock (4×)'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  7: PokemonSpeciesData(
    height: 5,
    weight: 90,
    category: 'Tiny Turtle Pokémon',
    description: 'Shoots water at prey while in the water. Withdraws into its shell when in danger.',
    abilities: ['Torrent', 'Rain Dish'],
    weaknesses: ['Electric', 'Grass'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  8: PokemonSpeciesData(
    height: 10,
    weight: 225,
    category: 'Turtle Pokémon',
    description: 'It is recognized by its large, furry tail. The tail becomes increasingly deep in color as it ages.',
    abilities: ['Torrent', 'Rain Dish'],
    weaknesses: ['Electric', 'Grass'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  9: PokemonSpeciesData(
    height: 16,
    weight: 855,
    category: 'Shellfish Pokémon',
    description: 'A brutal Pokémon with pressurized water jets on its shell. They are used for high-speed tackles.',
    abilities: ['Torrent', 'Rain Dish'],
    weaknesses: ['Electric', 'Grass'],
    genderRatio: '87.5% ♂ / 12.5% ♀',
  ),
  10: PokemonSpeciesData(
    height: 3,
    weight: 29,
    category: 'Worm Pokémon',
    description: 'Its short feet are tipped with suction pads that enable it to tirelessly climb slopes and walls.',
    abilities: ['Shield Dust', 'Run Away'],
    weaknesses: ['Fire', 'Flying', 'Rock'],
  ),
  11: PokemonSpeciesData(
    height: 7,
    weight: 99,
    category: 'Cocoon Pokémon',
    description: 'This Pokémon is vulnerable to attack while its shell is soft, exposing its weak and tender body.',
    abilities: ['Shed Skin'],
    weaknesses: ['Fire', 'Flying', 'Rock'],
  ),
  12: PokemonSpeciesData(
    height: 11,
    weight: 320,
    category: 'Butterfly Pokémon',
    description: 'In battle, it flaps its wings at great speed to release highly toxic dust into the air.',
    abilities: ['Compound Eyes', 'Tinted Lens'],
    weaknesses: ['Fire', 'Electric', 'Ice', 'Flying', 'Rock (4×)'],
  ),
  13: PokemonSpeciesData(
    height: 3,
    weight: 32,
    category: 'Hairy Bug Pokémon',
    description: 'Often found in forests and grasslands. It has a sharp, poisonous barb of about two inches on top of its head.',
    abilities: ['Shield Dust', 'Run Away'],
    weaknesses: ['Fire', 'Flying', 'Psychic', 'Rock'],
  ),
  14: PokemonSpeciesData(
    height: 6,
    weight: 100,
    category: 'Cocoon Pokémon',
    description: 'Almost incapable of moving, this Pokémon can only harden its shell to protect itself from predators.',
    abilities: ['Shed Skin'],
    weaknesses: ['Fire', 'Flying', 'Psychic', 'Rock'],
  ),
  15: PokemonSpeciesData(
    height: 10,
    weight: 295,
    category: 'Poison Bee Pokémon',
    description: 'It has three poisonous stingers on its forelegs and tail. They are used to peg enemies repeatedly.',
    abilities: ['Swarm', 'Sniper'],
    weaknesses: ['Fire', 'Flying', 'Psychic', 'Rock'],
  ),
  25: PokemonSpeciesData(
    height: 4,
    weight: 60,
    category: 'Mouse Pokémon',
    description: 'When several of these Pokémon gather, their electricity can build and cause lightning storms.',
    abilities: ['Static', 'Lightning Rod'],
    weaknesses: ['Ground'],
  ),
  39: PokemonSpeciesData(
    height: 5,
    weight: 55,
    category: 'Balloon Pokémon',
    description: 'Uses its alluring eyes to enrapture its foe. It then sings a pleasing melody that lulls the foe to sleep.',
    abilities: ['Cute Charm', 'Competitive'],
    weaknesses: ['Poison', 'Steel'],
    genderRatio: '25% ♂ / 75% ♀',
  ),
  52: PokemonSpeciesData(
    height: 4,
    weight: 42,
    category: 'Scratch Cat Pokémon',
    description: 'Adores circular objects. It wanders the streets on a nightly basis looking for dropped loose change.',
    abilities: ['Pickup', 'Technician'],
    weaknesses: ['Fighting'],
  ),
  94: PokemonSpeciesData(
    height: 15,
    weight: 405,
    category: 'Shadow Pokémon',
    description: 'Under a full moon, this Pokémon loves to mimic the shadows of people and laugh at their fright.',
    abilities: ['Cursed Body'],
    weaknesses: ['Ground', 'Psychic', 'Ghost', 'Dark'],
  ),
  150: PokemonSpeciesData(
    height: 20,
    weight: 1220,
    category: 'Genetic Pokémon',
    description: 'It was created by a scientist after years of horrific gene-splicing and DNA engineering experiments.',
    abilities: ['Pressure', 'Unnerve'],
    weaknesses: ['Bug', 'Ghost', 'Dark'],
    genderRatio: 'Genderless',
  ),
};

PokemonSpeciesData getSpeciesData(
  int id, {
  int? fallbackHeight,
  int? fallbackWeight,
}) {
  if (kPokemonSpeciesInfo.containsKey(id)) {
    return kPokemonSpeciesInfo[id]!;
  }

  return PokemonSpeciesData(
    height: fallbackHeight ?? 0,
    weight: fallbackWeight ?? 0,
    category: 'Unknown Pokémon',
    description: 'Species information is unavailable offline.',
    abilities: const [],
    weaknesses: const [],
  );
}
