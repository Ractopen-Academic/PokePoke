import 'dart:async';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokepoke/core/services/cache_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/core/widgets/loading_screen/loading_screen.dart';
import 'package:pokepoke/features/dashboard/home/home_screen.dart';

// ---------------------------------------------------------------------------
// Smogon-inspired tips and tricks
// ---------------------------------------------------------------------------
const List<String> _kTips = [
  '💡 Tip: Stealth Rock chips off 25% HP from Fire-types switching in — always pack Rapid Spin or Defog!',
  '⚡ Tip: Speed ties are broken randomly. Always have a backup if you rely on outspeeding a foe.',
  '🔥 Tip: Charizard-Y doubles the power of Fire-type moves with Drought. Pair it with Solar Beam!',
  '💧 Tip: Rain teams love Swift Swim users — Kingdra and Kabutops are classic sweepers in rain.',
  '🌿 Tip: Spore has 100% accuracy and puts the target to sleep. Only Grass-types are immune.',
  '👻 Tip: Ghost-types are immune to Normal AND Fighting moves — great defensive typings.',
  '🧊 Tip: Ice Shard is a priority move that always goes first — great for finishing off Dragon-types.',
  '🐉 Tip: Dragon-types are only weak to Dragon, Ice, and Fairy — Fairy was added in Gen 6!',
  '🌀 Tip: Trick Room reverses the speed order for 5 turns. Slow, bulky Pokémon love it.',
  '🎯 Tip: Choice Scarf boosts Speed by 50% but locks you into one move. Use it wisely!',
  '🛡️ Tip: Eviolite boosts Defense and Sp. Def by 50% for Pokémon that can still evolve.',
  '🌟 Tip: Entry hazards like Spikes stack up to 3 layers, dealing up to 25% chip per switch-in.',
  '💫 Tip: Terrain moves like Electric Terrain boost Electric moves 30% and prevent sleep.',
  '🔄 Tip: U-turn and Volt Switch let you hit and switch simultaneously — great for momentum.',
  '🏔️ Tip: Sandstorm deals 1/16 chip per turn to non-Rock, Steel, or Ground types.',
  '❄️ Tip: Snow (replacing Hail in Gen 9) boosts Ice-type Sp. Def by 50%.',
  '🌙 Tip: Knock Off removes the target\'s held item and deals 1.5× damage if they had one.',
  '🎭 Tip: Protean (Greninja\'s ability) changes its type to match every move it uses.',
  '⚔️ Tip: Critical hits ignore Attack drops on the attacker and Defense boosts on the defender.',
  '🌈 Tip: Weather Ball doubles in power and changes type during weather — use it on weather teams!',
  '🧲 Tip: Steel-types resist 10 different type matchups, making them excellent defensive pivots.',
  '🌊 Tip: Surf hits all adjacent Pokémon in Doubles — be careful not to hit your partner!',
  '🎪 Tip: Baton Pass transfers all stat boosts to the next Pokémon. Build a pass chain wisely.',
  '🦋 Tip: Quiver Dance raises Sp. Atk, Sp. Def, and Speed — one of the best boosting moves.',
  '💎 Tip: Sheer Force removes secondary effects of moves but boosts their power by 30%.',
  '🌺 Tip: Fairy-types are immune to Dragon moves — great counters to late-game Dragon sweepers.',
  '🏋️ Tip: Pure Power doubles the user\'s Attack stat, making Medicham hit incredibly hard.',
  '🎯 Tip: Stone Edge has a high critical hit ratio — great for punishing evasion boosts.',
  '🔮 Tip: Focus Sash lets a full-health Pokémon survive any one-hit KO with 1 HP.',
  '🌀 Tip: Substitute blocks status conditions and lets you scout for Choice-locked moves.',
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Tip cycling
  final _rng = Random();
  String _currentTip = _kTips[0];
  Timer? _tipTimer;

  // Loading state
  String _statusText = 'Initializing Pokédex…';
  double _progress = 0.0;
  List<PokemonEntry> _loadedPokemon = [];

  @override
  void initState() {
    super.initState();
    _currentTip = _kTips[_rng.nextInt(_kTips.length)];
    _startTipCycle();
    _runInitialization();
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  void _startTipCycle() {
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _currentTip = _kTips[_rng.nextInt(_kTips.length)];
      });
    });
  }

  Future<void> _runInitialization() async {
    // Step 1: Init cache / seed
    _setStatus('Loading built-in Pokémon data…', 0.1);
    await CacheService.init();
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 2: Load pokemon (cache or network)
    _setStatus('Checking local cache…', 0.25);
    await Future.delayed(const Duration(milliseconds: 300));

    final pokemon = await PokemonService.loadPokemon(
      onStatus: (msg) {
        // Parse progress from "Downloading (X/Y)"
        final match = RegExp(r'(\d+)/(\d+)').firstMatch(msg);
        if (match != null) {
          final done = int.tryParse(match.group(1) ?? '0') ?? 0;
          final total = int.tryParse(match.group(2) ?? '1') ?? 1;
          _setStatus(msg, 0.3 + 0.65 * (done / total));
        } else {
          _setStatus(msg, _progress);
        }
      },
    );

    _setStatus('Pokédex ready! (${pokemon.length} Pokémon)', 1.0);
    _loadedPokemon = pokemon;

    // Brief pause so user sees 100%
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, _, _) =>
                HomeScreen(preloadedPokemon: _loadedPokemon),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
          ),
        );
      }
    }
  }

  void _setStatus(String msg, double progress) {
    if (!mounted) return;
    setState(() {
      _statusText = msg;
      _progress = progress.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: Text(
                  'PokéPoke',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                    shadows: [
                      const Shadow(
                        color: Color(0xFFFF1C1C),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 700),
                child: Text(
                  'Gotta Catch \'Em All',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Spacer(),
              // Spinning pokeball
              FadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 600),
                child: const LoadingScreen(size: 110),
              ),
              const Spacer(),
              // Progress bar
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _statusText,
                        key: ValueKey(_statusText),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 6,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF1C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Tips section
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _currentTip,
                      key: ValueKey(_currentTip),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
