import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:pokepoke/core/services/audio_service.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSafariScreen extends StatefulWidget {
  final Map<String, Color> typeColors;
  final VoidCallback? onGoToBattle;

  const ProfileSafariScreen({
    super.key,
    required this.typeColors,
    this.onGoToBattle,
  });

  @override
  State<ProfileSafariScreen> createState() => _ProfileSafariScreenState();
}

class _ProfileSafariScreenState extends State<ProfileSafariScreen> {
  // Mode: true for Roaming Park view, false for Grid Inventory view
  bool _isParkView = true;

  Color _typeColor(String type) =>
      widget.typeColors[type.toLowerCase()] ?? const Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CaughtPokemon>>(
      valueListenable: BattlePenService.penNotifier,
      builder: (context, penList, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, penList),
            _buildQuickActionBar(context, penList),
            Expanded(
              child: penList.isEmpty
                  ? _buildEmptyState(context)
                  : (_isParkView
                      ? _RoamingSafariParkView(
                          penList: penList,
                          typeColorResolver: _typeColor,
                          onTrain: (p) => _handleTrain(context, p),
                          onOpenInventory: () => _openInventorySheet(context, penList),
                        )
                      : _buildInventoryGrid(context, penList)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, List<CaughtPokemon> penList) {
    final isFull = penList.length >= BattlePenService.maxCapacity;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          const Icon(Icons.pets, color: Color(0xFF4FC3F7), size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAFARI PEN',
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Roaming Sanctuary & Training',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          const Spacer(),

          // Sound Toggle Button
          ValueListenableBuilder<bool>(
            valueListenable: SafariAudioService.isMusicMuted,
            builder: (context, isMuted, _) {
              return GestureDetector(
                onTap: () => SafariAudioService.toggleMusic(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isMuted ? Colors.white24 : const Color(0xFFFFCC00),
                    ),
                  ),
                  child: Icon(
                    isMuted ? Icons.volume_off : Icons.volume_up,
                    size: 16,
                    color: isMuted ? Colors.white38 : const Color(0xFFFFCC00),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Clickable X/20 SLOTS badge -> Opens list of pokemon to train or release!
          GestureDetector(
            onTap: () => _openInventorySheet(context, penList),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFull
                    ? Colors.red.withValues(alpha: 0.2)
                    : const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFull
                      ? Colors.redAccent
                      : const Color(0xFF4FC3F7).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${penList.length}/${BattlePenService.maxCapacity} SLOTS',
                    style: GoogleFonts.pressStart2p(
                      color: isFull ? Colors.redAccent : const Color(0xFF4FC3F7),
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 12,
                    color: isFull ? Colors.redAccent : const Color(0xFF4FC3F7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBar(BuildContext context, List<CaughtPokemon> penList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _isParkView
                    ? 'Pokémon roam freely! Tap any to train.'
                    : 'Inventory list: Train (+25 XP) or release.',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Toggle View Mode (Park vs Grid)
            GestureDetector(
              onTap: () => setState(() => _isParkView = !_isParkView),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isParkView ? Icons.grid_view : Icons.park,
                      size: 12,
                      color: const Color(0xFF4FC3F7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isParkView ? 'GRID' : 'PARK',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF4FC3F7),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Opens the requested bottom sheet with the full list of Pokémon to level up or release
  void _openInventorySheet(BuildContext context, List<CaughtPokemon> penList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ValueListenableBuilder<List<CaughtPokemon>>(
          valueListenable: BattlePenService.penNotifier,
          builder: (context, updatedList, _) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Color(0xFF18182E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFF4FC3F7), width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Sheet Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, color: Color(0xFF4FC3F7), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SAFARI INVENTORY',
                          style: GoogleFonts.pressStart2p(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${updatedList.length}/20',
                            style: GoogleFonts.pressStart2p(
                              color: const Color(0xFF4FC3F7),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  // Pokémon list
                  Expanded(
                    child: updatedList.isEmpty
                        ? Center(
                            child: Text(
                              'Safari Pen is empty!\nCatch Pokémon in PokéWalk.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: Colors.white38),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: updatedList.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final pokemon = updatedList[i];
                              final pColor = _typeColor(pokemon.types.firstOrNull ?? 'normal');
                              return _InventoryListTile(
                                pokemon: pokemon,
                                primaryColor: pColor,
                                onTrain: () => _handleTrain(context, pokemon),
                                onRelease: () => _confirmRelease(context, pokemon),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryGrid(BuildContext context, List<CaughtPokemon> penList) {
    return GridView.builder(
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
              'You haven\'t caught any Pokémon for your Safari Pen yet.\nWalk in the Battle tab to encounter and catch wild Pokémon!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 24),
            NeoPopTiltedButton(
              isFloating: true,
              onTapUp: widget.onGoToBattle,
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

// ── ROAMING SAFARI PARK VIEW (Where Pokémon actually move around!) ──────────────
class _RoamingSafariParkView extends StatefulWidget {
  final List<CaughtPokemon> penList;
  final Color Function(String) typeColorResolver;
  final ValueChanged<CaughtPokemon> onTrain;
  final VoidCallback onOpenInventory;

  const _RoamingSafariParkView({
    required this.penList,
    required this.typeColorResolver,
    required this.onTrain,
    required this.onOpenInventory,
  });

  @override
  State<_RoamingSafariParkView> createState() => _RoamingSafariParkViewState();
}

class _RoamingSafariParkViewState extends State<_RoamingSafariParkView> {
  final Random _rng = Random();
  final Map<String, Alignment> _positions = {};
  Timer? _roamTimer;
  CaughtPokemon? _selectedPokemon;

  @override
  void initState() {
    super.initState();
    _initPositions();
    _startRoamingCycle();
  }

  @override
  void didUpdateWidget(covariant _RoamingSafariParkView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.penList.length != oldWidget.penList.length) {
      _initPositions();
    }
  }

  @override
  void dispose() {
    _roamTimer?.cancel();
    super.dispose();
  }

  void _initPositions() {
    for (final p in widget.penList) {
      if (!_positions.containsKey(p.uniqueId)) {
        final x = (_rng.nextDouble() * 1.6) - 0.8;
        final y = (_rng.nextDouble() * 1.6) - 0.8;
        _positions[p.uniqueId] = Alignment(x, y);
      }
    }
  }

  void _startRoamingCycle() {
    _roamTimer?.cancel();
    // Every 2.5 seconds, all Pokémon wander gently to a new random location!
    _roamTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted) return;
      setState(() {
        for (final p in widget.penList) {
          final cur = _positions[p.uniqueId] ?? Alignment.center;
          final dx = (cur.x + (_rng.nextDouble() * 0.5 - 0.25)).clamp(-0.85, 0.85);
          final dy = (cur.y + (_rng.nextDouble() * 0.5 - 0.25)).clamp(-0.85, 0.85);
          _positions[p.uniqueId] = Alignment(dx, dy);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      child: Stack(
        children: [
          // Park Terrain Container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF14221D), Color(0xFF111E17)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.06),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                children: [
                  // Scenic Meadow Grid
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParkGridPainter(),
                    ),
                  ),

                  // Roaming Pokémon sprites!
                  for (final mon in widget.penList)
                    AnimatedAlign(
                      key: ValueKey(mon.uniqueId),
                      duration: const Duration(milliseconds: 2200),
                      curve: Curves.easeInOutCubic,
                      alignment: _positions[mon.uniqueId] ?? Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPokemon = mon;
                          });
                        },
                        child: _RoamingPokemonSprite(
                          pokemon: mon,
                          isSelected: _selectedPokemon?.uniqueId == mon.uniqueId,
                        ),
                      ),
                    ),

                  // Bottom park hint
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'Meadow Sanctuary: ${widget.penList.length} roaming Pokémon',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected Pokémon Floating Training Bubble
          if (_selectedPokemon != null &&
              widget.penList.any((p) => p.uniqueId == _selectedPokemon!.uniqueId))
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _FloatingTrainBanner(
                pokemon: widget.penList.firstWhere(
                  (p) => p.uniqueId == _selectedPokemon!.uniqueId,
                ),
                primaryColor: widget.typeColorResolver(
                  _selectedPokemon!.types.firstOrNull ?? 'normal',
                ),
                onTrain: () => widget.onTrain(_selectedPokemon!),
                onDismiss: () => setState(() => _selectedPokemon = null),
                onOpenInventory: widget.onOpenInventory,
              ),
            ),
        ],
      ),
    );
  }
}

class _RoamingPokemonSprite extends StatelessWidget {
  final CaughtPokemon pokemon;
  final bool isSelected;

  const _RoamingPokemonSprite({
    required this.pokemon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Level badge pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFCC00) : Colors.black87,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Text(
            'Lv. ${pokemon.level}',
            style: GoogleFonts.pressStart2p(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 6.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Sprite
        CachedNetworkImage(
          imageUrl: pokemon.spriteUrl,
          width: 58,
          height: 58,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox(width: 50, height: 50),
          errorWidget: (context, url, err) =>
              const Icon(Icons.catching_pokemon, size: 36, color: Colors.white38),
        ),
      ],
    );
  }
}

class _FloatingTrainBanner extends StatelessWidget {
  final CaughtPokemon pokemon;
  final Color primaryColor;
  final VoidCallback onTrain;
  final VoidCallback onDismiss;
  final VoidCallback onOpenInventory;

  const _FloatingTrainBanner({
    required this.pokemon,
    required this.primaryColor,
    required this.onTrain,
    required this.onDismiss,
    required this.onOpenInventory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: pokemon.spriteUrl,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      pokemon.displayName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lv. ${pokemon.level}',
                      style: GoogleFonts.pressStart2p(
                        color: const Color(0xFFFFCC00),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pokemon.xpProgress,
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'XP: ${pokemon.xp}/${pokemon.xpForNextLevel}',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Train button
          GestureDetector(
            onTap: onTrain,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on, size: 12, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    '+25',
                    style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Close button
          GestureDetector(
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}

// ── INVENTORY LIST TILE (Used in modal sheet) ──────────────────────────────────
class _InventoryListTile extends StatelessWidget {
  final CaughtPokemon pokemon;
  final Color primaryColor;
  final VoidCallback onTrain;
  final VoidCallback onRelease;

  const _InventoryListTile({
    required this.pokemon,
    required this.primaryColor,
    required this.onTrain,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Sprite
          CachedNetworkImage(
            imageUrl: pokemon.spriteUrl,
            width: 52,
            height: 52,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox(width: 52, height: 52),
          ),
          const SizedBox(width: 12),

          // Info & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pokemon.displayName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Lv. ${pokemon.level}',
                        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pokemon.xpProgress,
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'XP: ${pokemon.xp} / ${pokemon.xpForNextLevel}',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 9.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions: Train & Release
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTrain,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, size: 11, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        '+25',
                        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 7),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRelease,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, size: 15, color: Colors.white38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Grid Card (Alternative view)
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onTrain,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF7C4DFF)],
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
    );
  }
}

class _ParkGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
