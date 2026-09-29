class CaughtPokemon {
  final String uniqueId;
  final int pokemonId;
  final String name;
  final List<String> types;
  int level;
  int xp;
  final DateTime caughtAt;

  CaughtPokemon({
    required this.uniqueId,
    required this.pokemonId,
    required this.name,
    required this.types,
    this.level = 5,
    this.xp = 0,
    required this.caughtAt,
  });

  String get displayName =>
      name.isEmpty ? 'Pokemon' : name[0].toUpperCase() + name.substring(1).replaceAll('-', ' ');

  String get formattedId => '#${pokemonId.toString().padLeft(3, '0')}';

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

  int get xpForNextLevel => level * 50;

  double get xpProgress => (xp / xpForNextLevel).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() => {
        'uniqueId': uniqueId,
        'pokemonId': pokemonId,
        'name': name,
        'types': types,
        'level': level,
        'xp': xp,
        'caughtAt': caughtAt.millisecondsSinceEpoch,
      };

  factory CaughtPokemon.fromMap(Map<String, dynamic> m) => CaughtPokemon(
        uniqueId: m['uniqueId'] as String,
        pokemonId: m['pokemonId'] as int,
        name: m['name'] as String,
        types: List<String>.from(m['types'] as List),
        level: (m['level'] as num?)?.toInt() ?? 5,
        xp: (m['xp'] as num?)?.toInt() ?? 0,
        caughtAt: DateTime.fromMillisecondsSinceEpoch(
            (m['caughtAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
      );
}
