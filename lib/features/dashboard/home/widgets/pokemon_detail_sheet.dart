import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokepoke/core/data/pokemon_seed.dart';
import 'package:pokepoke/core/data/pokemon_species_data.dart';
import 'package:pokepoke/core/services/cache_service.dart';
import 'package:pokepoke/core/services/evolution_service.dart';
import 'package:pokepoke/core/services/favourite_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';

class PokemonDetailSheet extends StatefulWidget {
  final PokemonEntry initialPokemon;
  final Map<String, Color> typeColors;

  const PokemonDetailSheet({
    super.key,
    required this.initialPokemon,
    required this.typeColors,
  });

  static Future<void> show(
    BuildContext context, {
    required PokemonEntry pokemon,
    required Map<String, Color> typeColors,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PokemonDetailSheet(
        initialPokemon: pokemon,
        typeColors: typeColors,
      ),
    );
  }

  @override
  State<PokemonDetailSheet> createState() => _PokemonDetailSheetState();
}

class _PokemonDetailSheetState extends State<PokemonDetailSheet> {
  late PokemonEntry _currentPokemon;
  EvolutionChainData? _evolutionChain;
  bool _loadingEvolution = true;

  @override
  void initState() {
    super.initState();
    _currentPokemon = widget.initialPokemon;
    _loadEvolutionChain();
  }

  Color _typeColor(String type) =>
      widget.typeColors[type.toLowerCase()] ?? const Color(0xFFBDBDBD);

  Future<void> _loadEvolutionChain() async {
    setState(() => _loadingEvolution = true);
    final chain = await EvolutionService.getEvolutionChain(
      _currentPokemon.id,
      _currentPokemon.name,
    );
    if (mounted) {
      setState(() {
        _evolutionChain = chain;
        _loadingEvolution = false;
      });
    }
  }

  void _switchToPokemon(EvolutionNode node) {
    if (node.id == _currentPokemon.id) return;

    PokemonEntry? found;
    final cached = CacheService.getCachedPokemon();
    if (cached != null) {
      final match = cached.where((m) => m['id'] == node.id).firstOrNull;
      if (match != null) {
        found = PokemonEntry.fromMap(match);
      }
    }
    if (found == null) {
      final seed = kPokemonSeed.where((m) => m['id'] == node.id).firstOrNull;
      if (seed != null) {
        found = PokemonEntry.fromMap(seed);
      }
    }

    final species = getSpeciesData(node.id);
    setState(() {
      _currentPokemon = found ??
          PokemonEntry(
            id: node.id,
            name: node.name,
            types: _currentPokemon.types,
            height: species.height,
            weight: species.weight,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _typeColor(_currentPokemon.types.first);
    final secondaryColor = _currentPokemon.types.length > 1
        ? _typeColor(_currentPokemon.types[1])
        : primaryColor.withValues(alpha: 0.6);

    final species = getSpeciesData(
      _currentPokemon.id,
      fallbackHeight: _currentPokemon.height,
      fallbackWeight: _currentPokemon.weight,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141424),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top drag pill
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header bar (Without the close X)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPokemon.formattedId,
                          style: GoogleFonts.pressStart2p(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentPokemon.displayName,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Species category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        species.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favourite toggle button
                    ValueListenableBuilder<Set<int>>(
                      valueListenable: FavouriteService.favouritesNotifier,
                      builder: (context, favIds, _) {
                        final isFav = favIds.contains(_currentPokemon.id);
                        return GestureDetector(
                          onTap: () =>
                              FavouriteService.toggleFavourite(_currentPokemon.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? const Color(0xFFFF3B56).withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isFav
                                    ? const Color(0xFFFF3B56)
                                    : Colors.white24,
                              ),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav
                                  ? const Color(0xFFFF3B56)
                                  : Colors.white60,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Type pills
                    Wrap(
                      spacing: 8,
                      children: _currentPokemon.types.map((type) {
                        final color = _typeColor(type);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color, width: 1.2),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Pokémon Centerfold Display
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background radial glow
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.45),
                                  secondaryColor.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Pokémon Sprite with smooth scale & fade transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutBack,
                              ),
                              child: FadeTransition(opacity: anim, child: child),
                            ),
                            child: Image.network(
                              _currentPokemon.spriteUrl,
                              key: ValueKey(_currentPokemon.id),
                              width: 165,
                              height: 165,
                              fit: BoxFit.contain,
                              errorBuilder: (_, p0, p1) => const Icon(
                                Icons.catching_pokemon,
                                color: Colors.white38,
                                size: 80,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pokédex Flavor Text / Lore Quote
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote,
                              size: 18, color: primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              species.description,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dimensions Card (Height, Weight, Scale)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _specItem(
                            icon: Icons.straighten,
                            label: 'HEIGHT',
                            value: _currentPokemon.formattedHeight,
                          ),
                          Container(width: 1, height: 28, color: Colors.white12),
                          _specItem(
                            icon: Icons.scale,
                            label: 'WEIGHT',
                            value: _currentPokemon.formattedWeight,
                          ),
                          Container(width: 1, height: 28, color: Colors.white12),
                          _specItem(
                            icon: Icons.female,
                            label: 'GENDER RATIO',
                            value: species.genderRatio,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ─── Abilities Section ──────────────────────────────────
                    Text(
                      '⚡ ABILITIES',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: species.abilities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ability = entry.value;
                        final isHidden = index > 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isHidden
                                ? Colors.purple.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isHidden
                                  ? Colors.purple.withValues(alpha: 0.4)
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ability,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isHidden) ...[
                                const SizedBox(width: 5),
                                Text(
                                  '(HIDDEN)',
                                  style: GoogleFonts.inter(
                                    color: Colors.purpleAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // ─── Weaknesses Section ─────────────────────────────────
                    Text(
                      '🛡️ WEAKNESSES (2× DAMAGE)',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: species.weaknesses.map((weakType) {
                        final typeKey = weakType.split(' ').first.toLowerCase();
                        final color = _typeColor(typeKey);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            weakType.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ─── Evolution Chain Card ──────────────────────────────
                    Text(
                      '⚡ EVOLUTIONARY PATH',
                      style: GoogleFonts.pressStart2p(
                        color: const Color(0xFFFFCC00),
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFCC00).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: _loadingEvolution
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFFCC00),
                                  ),
                                ),
                              ),
                            )
                          : (_evolutionChain == null ||
                                  !_evolutionChain!.hasEvolution)
                              ? Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFCC00), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${_currentPokemon.displayName} does not evolve.',
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _buildEvolutionNodes(primaryColor),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Base Combat Stats ─────────────────────────────────
                    Text(
                      '⚔️ BASE COMBAT STATS',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _statBar('HP', 45 + (_currentPokemon.id % 60),
                              const Color(0xFFFF5252)),
                          const SizedBox(height: 8),
                          _statBar('ATTACK', 49 + ((_currentPokemon.id * 3) % 70),
                              const Color(0xFFFF7A00)),
                          const SizedBox(height: 8),
                          _statBar('DEFENSE', 49 + ((_currentPokemon.id * 5) % 65),
                              const Color(0xFFFFD600)),
                          const SizedBox(height: 8),
                          _statBar('SPEED', 45 + ((_currentPokemon.id * 7) % 65),
                              const Color(0xFF00E5FF)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _specItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white38),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEvolutionNodes(Color activeColor) {
    final widgets = <Widget>[];
    final nodes = _evolutionChain!.nodes;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final isCurrent = node.id == _currentPokemon.id;

      // Stage card
      widgets.add(
        GestureDetector(
          onTap: () => _switchToPokemon(node),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? activeColor.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? activeColor : Colors.white12,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Image.network(
                  node.spriteUrl,
                  width: 54,
                  height: 54,
                  fit: BoxFit.contain,
                  errorBuilder: (_, p0, p1) => const Icon(
                    Icons.catching_pokemon,
                    size: 30,
                    color: Colors.white24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  node.displayName,
                  style: GoogleFonts.inter(
                    color: isCurrent ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

      // Arrow and evolution trigger to next stage
      if (i < nodes.length - 1) {
        final nextNode = nodes[i + 1];
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCC00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFCC00).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    nextNode.trigger ?? 'Evolves',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFCC00),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFFFFCC00),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _statBar(String label, int value, Color color) {
    final clamped = value.clamp(1, 150);
    final ratio = clamped / 150.0;

    return Row(
      children: [
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$clamped',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 7,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
