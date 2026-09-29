import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokepoke/core/services/audio_service.dart';
import 'package:pokepoke/core/utils/type_colors.dart';
import 'package:pokepoke/core/widgets/poke_dark_dialog.dart';
import 'package:pokepoke/core/widgets/hold_to_spam_button.dart';
import 'package:pokepoke/core/widgets/shimmer_box.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';

class ProfileSafariScreen extends StatefulWidget {
  final VoidCallback? onGoToBattle;

  const ProfileSafariScreen({
    super.key,
    this.onGoToBattle,
  });

  @override
  State<ProfileSafariScreen> createState() => _ProfileSafariScreenState();
}

class _ProfileSafariScreenState extends State<ProfileSafariScreen> {
  bool _isParkView = true;



  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CaughtPokemon>>(
      valueListenable: BattlePenService.penNotifier,
      builder: (context, penList, _) {
        return Column(
          children: [
            _buildHeader(penList),
            _buildModeBar(penList),
            Expanded(
              child: penList.isEmpty
                  ? _buildEmptyState()
                  : (_isParkView
                      ? _RoamingParkView(
                          penList: penList,
                          typeColor: typeColor,
                          onTrain: (p) => _trainPokemon(p),
                          onOpenInventory: () => _openInventorySheet(penList),
                        )
                      : _buildInventoryGrid(penList)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(List<CaughtPokemon> penList) {
    final full = penList.length >= BattlePenService.maxCapacity;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          const Icon(Icons.pets, color: Color(0xFF4FC3F7), size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SAFARI PEN', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 2),
              Text('Hold to Train • Auto-Evolve', style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const Spacer(),
          // Audio mute/unmute
          ValueListenableBuilder<bool>(
            valueListenable: SafariAudioService.isMusicMuted,
            builder: (_, muted, child) => IconButton(
              icon: Icon(muted ? Icons.volume_off : Icons.volume_up,
                  size: 20, color: muted ? Colors.white38 : const Color(0xFFFFCC00)),
              onPressed: () => SafariAudioService.toggleMusic(),
            ),
          ),
          // Clickable X/20 SLOTS badge
          GestureDetector(
            onTap: () => _openInventorySheet(penList),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: full ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: full ? Colors.redAccent : const Color(0xFF4FC3F7).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Text('${penList.length}/${BattlePenService.maxCapacity} SLOTS',
                      style: GoogleFonts.pressStart2p(color: full ? Colors.redAccent : const Color(0xFF4FC3F7), fontSize: 8)),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 11, color: full ? Colors.redAccent : const Color(0xFF4FC3F7)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBar(List<CaughtPokemon> penList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _isParkView ? 'Pokémon roam freely! Hold +25 to spam train.' : 'Inventory Grid: Hold to train or release.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isParkView = !_isParkView),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_isParkView ? 'GRID' : 'PARK',
                    style: GoogleFonts.inter(color: const Color(0xFF4FC3F7), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInventorySheet(List<CaughtPokemon> penList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ValueListenableBuilder<List<CaughtPokemon>>(
          valueListenable: BattlePenService.penNotifier,
          builder: (context, updatedList, _) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFF18182E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(top: BorderSide(color: Color(0xFF4FC3F7), width: 1.5)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text('SAFARI INVENTORY', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 11)),
                        const Spacer(),
                        Text('${updatedList.length}/20', style: GoogleFonts.pressStart2p(color: const Color(0xFF4FC3F7), fontSize: 9)),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: updatedList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = updatedList[i];
                        return _InventoryTile(
                          pokemon: p,
                          color: typeColor(p.types.firstOrNull ?? 'normal'),
                          onTrain: () => _trainPokemon(p),
                          onRelease: () => _confirmRelease(p),
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

  Widget _buildInventoryGrid(List<CaughtPokemon> penList) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.84,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: penList.length,
      itemBuilder: (context, i) {
        final p = penList[i];
        return _SafariCard(
          pokemon: p,
          color: typeColor(p.types.firstOrNull ?? 'normal'),
          onTrain: () => _trainPokemon(p),
          onRelease: () => _confirmRelease(p),
        );
      },
    );
  }

  Future<void> _trainPokemon(CaughtPokemon p) async {
    final res = await BattlePenService.gainXp(p.uniqueId, amount: 25);
    if (!mounted) return;

    if (res.didEvolve) {
      _showEvolutionDialog(res);
    } else if (res.didLevelUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${p.displayName} leveled up to Lv. ${res.newLevel}!', style: GoogleFonts.inter()),
          duration: 1.seconds,
          backgroundColor: const Color(0xFF262640),
        ),
      );
    }
  }

  void _showEvolutionDialog(EvolutionResult r) {
    showDialog(
      context: context,
      builder: (ctx) => PokeDarkDialog(
        radius: 20,
        borderColor: const Color(0xFFFFCC00),
        borderWidth: 1.5,
        title: Text('EVOLUTION!', style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 13)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.newPokemonId != null)
              CachedNetworkImage(
                imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${r.newPokemonId}.png',
                width: 110,
                height: 110,
              ).animate().scale(duration: 400.ms),
            const SizedBox(height: 8),
            Text('${r.oldName} evolved into ${r.newName}!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('GREAT!')),
        ],
      ),
    );
  }

  void _confirmRelease(CaughtPokemon p) {
    showDialog(
      context: context,
      builder: (ctx) => PokeDarkDialog(
        title: Text('Release ${p.displayName}?', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 11)),
        content: Text('Release ${p.displayName} (Lv. ${p.level}) to free up 1 slot?',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              BattlePenService.releasePokemon(p.uniqueId);
            },
            child: const Text('RELEASE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fence, size: 54, color: Colors.white24),
          const SizedBox(height: 14),
          Text('SAFARI PEN EMPTY', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 6),
          Text('Walk in PokéWalk to catch wild Pokémon!', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onGoToBattle,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF1C1C)),
            child: Text('EXPLORE POKÉWALK', style: GoogleFonts.pressStart2p(fontSize: 8)),
          ),
        ],
      ),
    );
  }
}

// ── ROAMING PARK MEADOW VIEW ──────────────────────────────────────────────────
class _RoamingParkView extends StatefulWidget {
  final List<CaughtPokemon> penList;
  final Color Function(String) typeColor;
  final ValueChanged<CaughtPokemon> onTrain;
  final VoidCallback onOpenInventory;

  const _RoamingParkView({
    required this.penList,
    required this.typeColor,
    required this.onTrain,
    required this.onOpenInventory,
  });

  @override
  State<_RoamingParkView> createState() => _RoamingParkViewState();
}

class _RoamingParkViewState extends State<_RoamingParkView> {
  final Random _rng = Random();
  final Map<String, Alignment> _positions = {};
  Timer? _roamTimer;
  CaughtPokemon? _activeMon;

  @override
  void initState() {
    super.initState();
    _initPos();
    _roamTimer = Timer.periodic(2500.ms, (_) {
      if (!mounted) return;
      setState(() {
        for (final p in widget.penList) {
          final cur = _positions[p.uniqueId] ?? Alignment.center;
          _positions[p.uniqueId] = Alignment(
            (cur.x + (_rng.nextDouble() * 0.4 - 0.2)).clamp(-0.85, 0.85),
            (cur.y + (_rng.nextDouble() * 0.4 - 0.2)).clamp(-0.85, 0.85),
          );
        }
      });
    });
  }

  void _initPos() {
    for (final p in widget.penList) {
      _positions.putIfAbsent(p.uniqueId, () => Alignment((_rng.nextDouble() * 1.6) - 0.8, (_rng.nextDouble() * 1.6) - 0.8));
    }
  }

  @override
  void dispose() {
    _roamTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initPos();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      child: Stack(
        children: [
          // Meadow background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF13221C), Color(0xFF101C16)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
            ),
            child: Stack(
              children: [
                // Roaming Pokémon
                for (final mon in widget.penList)
                  AnimatedAlign(
                    key: ValueKey(mon.uniqueId),
                    duration: 2200.ms,
                    curve: Curves.easeInOut,
                    alignment: _positions[mon.uniqueId] ?? Alignment.center,
                    child: GestureDetector(
                      onTap: () => setState(() => _activeMon = mon),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: _activeMon?.uniqueId == mon.uniqueId ? const Color(0xFFFFCC00) : Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Lv.${mon.level}',
                                style: GoogleFonts.pressStart2p(
                                    color: _activeMon?.uniqueId == mon.uniqueId ? Colors.black : Colors.white, fontSize: 6.5)),
                          ),
                          CachedNetworkImage(
                            imageUrl: mon.spriteUrl,
                            width: 52,
                            height: 52,
                            placeholder: (context, url) => const SizedBox(width: 40, height: 40),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Floating Active Mon Trainer Banner (WITH HOLD TO SPAM!)
          if (_activeMon != null && widget.penList.any((p) => p.uniqueId == _activeMon!.uniqueId))
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: _FloatingTrainBubble(
                pokemon: widget.penList.firstWhere((p) => p.uniqueId == _activeMon!.uniqueId),
                onTrain: () => widget.onTrain(_activeMon!),
                onClose: () => setState(() => _activeMon = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingTrainBubble extends StatelessWidget {
  final CaughtPokemon pokemon;
  final VoidCallback onTrain;
  final VoidCallback onClose;

  const _FloatingTrainBubble({
    required this.pokemon,
    required this.onTrain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC00), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: Row(
        children: [
          CachedNetworkImage(imageUrl: pokemon.spriteUrl, width: 40, height: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${pokemon.displayName} (Lv.${pokemon.level})',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                LinearProgressIndicator(value: pokemon.xpProgress, minHeight: 4, backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4FC3F7))),
                Text('XP: ${pokemon.xp}/${pokemon.xpForNextLevel}', style: GoogleFonts.inter(color: Colors.white54, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // HOLD TO SPAM TRAIN BUTTON!
          HoldToSpamButton(
            onTrigger: onTrain,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF7C4DFF)]),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on, size: 11, color: Colors.white),
                Text('+25', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.white38), onPressed: onClose),
        ],
      ),
    );
  }
}

// ── INVENTORY TILE (WITH HOLD TO SPAM) ─────────────────────────────────────────
class _InventoryTile extends StatelessWidget {
  final CaughtPokemon pokemon;
  final Color color;
  final VoidCallback onTrain;
  final VoidCallback onRelease;

  const _InventoryTile({
    required this.pokemon,
    required this.color,
    required this.onTrain,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CachedNetworkImage(imageUrl: pokemon.spriteUrl, width: 44, height: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pokemon.displayName,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('Lv.${pokemon.level}', style: GoogleFonts.pressStart2p(color: color, fontSize: 7)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: pokemon.xpProgress, minHeight: 4, backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4FC3F7))),
                Text('XP: ${pokemon.xp} / ${pokemon.xpForNextLevel}', style: GoogleFonts.inter(color: Colors.white38, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // HOLD TO SPAM TRAIN!
          HoldToSpamButton(
            onTrigger: onTrain,
            decoration: BoxDecoration(color: const Color(0xFF6C5CE7), borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on, size: 10, color: Colors.white),
                Text('+25', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 7)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38), onPressed: onRelease),
        ],
      ),
    );
  }
}

// ── GRID CARD (WITH HOLD TO SPAM) ─────────────────────────────────────────────
class _SafariCard extends StatelessWidget {
  final CaughtPokemon pokemon;
  final Color color;
  final VoidCallback onTrain;
  final VoidCallback onRelease;

  const _SafariCard({
    required this.pokemon,
    required this.color,
    required this.onTrain,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lv.${pokemon.level}', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 7.5)),
              const Spacer(),
              GestureDetector(onTap: onRelease, child: const Icon(Icons.delete_outline, size: 14, color: Colors.white38)),
            ],
          ),
          Expanded(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: pokemon.spriteUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const ShimmerBox(size: 50),
              ),
            ),
          ),
          Text(pokemon.displayName,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          LinearProgressIndicator(value: pokemon.xpProgress, minHeight: 4, backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4FC3F7))),
          Text('${pokemon.xp}/${pokemon.xpForNextLevel} XP', style: GoogleFonts.inter(color: Colors.white38, fontSize: 8.5)),
          const SizedBox(height: 6),
          // HOLD TO SPAM TRAIN!
          HoldToSpamButton(
            onTrigger: onTrain,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF7C4DFF)]),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on, size: 10, color: Colors.white),
                  const SizedBox(width: 2),
                  Text('HOLD +25', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 6.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
