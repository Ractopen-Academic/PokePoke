import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSafariScreen extends StatelessWidget {
  final Map<String, Color> typeColors;
  final VoidCallback? onGoToBattle;

  const ProfileSafariScreen({
    super.key,
    required this.typeColors,
    this.onGoToBattle,
  });

  Color _typeColor(String type) =>
      typeColors[type.toLowerCase()] ?? const Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CaughtPokemon>>(
      valueListenable: BattlePenService.penNotifier,
      builder: (context, penList, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.pets, color: Color(0xFF4FC3F7), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'SAFARI PEN',
                    style: GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: penList.length >= BattlePenService.maxCapacity
                          ? Colors.red.withValues(alpha: 0.2)
                          : const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: penList.length >= BattlePenService.maxCapacity
                            ? Colors.redAccent
                            : const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${penList.length} / ${BattlePenService.maxCapacity} SLOTS',
                      style: GoogleFonts.inter(
                        color: penList.length >= BattlePenService.maxCapacity
                            ? Colors.redAccent
                            : const Color(0xFF4FC3F7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tip Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, size: 16, color: Color(0xFFFFCC00)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap a Pokémon to train (+25 XP). They auto-evolve when reaching their level!',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Grid or Empty State
            Expanded(
              child: penList.isEmpty
                  ? _buildEmptyState(context)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: penList.length,
                      itemBuilder: (context, i) {
                        final pokemon = penList[i];
                        return _SafariPokemonCard(
                          key: ValueKey(pokemon.uniqueId),
                          pokemon: pokemon,
                          primaryColor: _typeColor(pokemon.types.firstOrNull ?? 'normal'),
                          onTrain: () => _handleTrain(context, pokemon),
                          onRelease: () => _confirmRelease(context, pokemon),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleTrain(BuildContext context, CaughtPokemon pokemon) async {
    final result = await BattlePenService.gainXp(pokemon.uniqueId, amount: 25);

    if (!context.mounted) return;

    if (result.didEvolve) {
      _showEvolutionDialog(context, result);
    } else if (result.didLevelUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF262640),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.arrow_circle_up, color: Color(0xFFFFD600), size: 20),
              const SizedBox(width: 8),
              Text(
                '${pokemon.displayName} reached Level ${result.newLevel}!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showEvolutionDialog(BuildContext context, EvolutionResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFFCC00), size: 24),
            const SizedBox(width: 8),
            Text(
              'EVOLUTION!',
              style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 13),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.newPokemonId != null) ...[
              CachedNetworkImage(
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${result.newPokemonId}.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'What?! ${result.oldName ?? "Your Pokémon"} is evolving!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations!\nIt evolved into ${result.newName}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'AWESOME!',
              style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRelease(BuildContext context, CaughtPokemon pokemon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Release ${pokemon.displayName}?',
          style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 11),
        ),
        content: Text(
          'Are you sure you want to release ${pokemon.displayName} (Lv. ${pokemon.level}) back into the wild? This frees up 1 Safari slot.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              BattlePenService.releasePokemon(pokemon.uniqueId);
            },
            child: Text(
              'RELEASE',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fence, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'SAFARI PEN EMPTY',
              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              'You haven\'t kept any Pokémon in your Safari Pen yet.\nWalk in the Battle tab to encounter and catch wild Pokémon!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 24),
            NeoPopTiltedButton(
              isFloating: true,
              onTapUp: onGoToBattle,
              color: const Color(0xFFFF1C1C),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'GO WALK & CATCH',
                  style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafariPokemonCard extends StatelessWidget {
  final CaughtPokemon pokemon;
  final Color primaryColor;
  final VoidCallback onTrain;
  final VoidCallback onRelease;

  const _SafariPokemonCard({
    super.key,
    required this.pokemon,
    required this.primaryColor,
    required this.onTrain,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Level badge & Release button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        'Lv. ${pokemon.level}',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRelease,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 14, color: Colors.white38),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Sprite
                Expanded(
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: pokemon.spriteUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.white12,
                        highlightColor: Colors.white30,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.catching_pokemon,
                        color: Colors.white38,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Name
                Text(
                  pokemon.displayName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // XP Bar & Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${pokemon.xp}/${pokemon.xpForNextLevel}',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pokemon.xpProgress,
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                  ),
                ),
                const SizedBox(height: 8),

                // Train button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: onTrain,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C5CE7),
                            const Color(0xFF7C4DFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'TRAIN +25',
                            style: GoogleFonts.pressStart2p(
                              color: Colors.white,
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
