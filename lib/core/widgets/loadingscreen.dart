import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokepoke/core/services/cache_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokepoke/core/services/favourite_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/core/services/audio_service.dart';
import 'package:pokepoke/core/widgets/loading_screen/loading_screen.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/dashboard/home/home_screen.dart';

// Smogon-inspired tips (clean, competitive advice)
const List<String> _kTips = [
  'Stealth Rock chips 25% off Fire-types on switch — always pack Rapid Spin or Defog!',
  'Speed ties are broken randomly — always have a backup plan.',
  'Charizard-Y doubles Fire-type power with Drought. Pair with Solar Beam!',
  'Rain teams love Swift Swim users — Kingdra is a classic rain sweeper.',
  'Spore has 100% accuracy and puts targets to sleep. Only Grass-types are immune.',
  'Ghost-types are immune to Normal AND Fighting moves — great defensive typings.',
  'Ice Shard is priority — great for finishing off Dragon-types first.',
  'Dragon-types are only weak to Dragon, Ice, and Fairy. Fairy was added in Gen 6!',
  'Trick Room reverses speed order for 5 turns. Slow, bulky Pokémon love it.',
  'Choice Scarf boosts Speed 50% but locks you to one move. Use wisely!',
  'Eviolite boosts Def and Sp. Def 50% for Pokémon that can still evolve.',
  'Spikes stack to 3 layers, dealing up to 25% chip per switch-in.',
  'Electric Terrain boosts Electric moves 30% and prevents sleep.',
  'U-turn and Volt Switch let you hit and switch — great for momentum.',
  'Sandstorm deals 1/16 chip to non-Rock, Steel, or Ground types per turn.',
  'Snow (replacing Hail in Gen 9) boosts Ice-type Sp. Def by 50%.',
  'Knock Off removes held items and deals 1.5× damage if they had one.',
  'Protean changes Greninja\'s type to match every move it uses.',
  'Critical hits ignore your Attack drops and the foe\'s Defense boosts.',
  'Weather Ball changes type and doubles power during weather effects!',
  'Steel-types resist 10 type matchups — excellent defensive pivots.',
  'Surf hits all adjacent Pokémon in Doubles — beware of hitting your partner!',
  'Quiver Dance raises Sp. Atk, Sp. Def, AND Speed — one of the best moves.',
  'Sheer Force removes secondary effects but boosts move power by 30%.',
  'Fairy-types are immune to Dragon moves — hard counters to Dragon sweepers.',
  'Pure Power doubles Attack, making Medicham hit incredibly hard.',
  'Focus Sash lets a full-HP Pokémon survive any one-hit KO with 1 HP.',
  'Substitute blocks status moves and lets you scout Choice-locked foes.',
  'Baton Pass transfers stat boosts to the next Pokémon — build a chain!',
  'Regenerator heals 1/3 HP on switching out — great for pivot Pokémon.',
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _rng = Random();
  String _currentTip = _kTips[0];
  Timer? _tipTimer;

  String _statusText = 'Initializing Pokédex…';
  double _progress = 0.0;
  List<PokemonEntry> _loadedPokemon = [];
  bool _navigated = false;

  // Stagger animation controller for the status text
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    // Suppress Flutter web raw keyboard assertion errors (debug-mode only bug)
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('raw_keyboard') ||
          details.exceptionAsString().contains('handleRawKeyEvent')) {
        return; // swallow
      }
      FlutterError.presentError(details);
    };

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _currentTip = _kTips[_rng.nextInt(_kTips.length)];
    _startTipCycle();

    // Run data loading AND a minimum display time in parallel
    Future.wait([
      _runInitialization(),
      Future.delayed(const Duration(milliseconds: 2800)), // min splash time
    ]).then((_) => _navigateToHome(_loadedPokemon));
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startTipCycle() {
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _currentTip = _kTips[_rng.nextInt(_kTips.length)]);
    });
  }

  void _navigateToHome(List<PokemonEntry> pokemon) {
    if (_navigated || !mounted) return;
    _navigated = true;
    _tipTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, a1, a2) =>
            HomeScreen(preloadedPokemon: pokemon.isNotEmpty ? pokemon : kBuiltInPokemon),
        transitionsBuilder: (_, anim, a2, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  Future<void> _runInitialization() async {
    // Hard 15s escape hatch in case anything truly hangs
    Timer(const Duration(seconds: 15), () {
      if (!_navigated && mounted) {
        _navigateToHome(_loadedPokemon.isNotEmpty ? _loadedPokemon : kBuiltInPokemon);
      }
    });

    _setStatus('Loading built-in Pokémon data…', 0.15);
    try {
      await CacheService.init().timeout(const Duration(seconds: 3));
      await FavouriteService.init().timeout(const Duration(seconds: 2));
      await BattlePenService.init().timeout(const Duration(seconds: 2));
      await SafariAudioService.init().timeout(const Duration(seconds: 2));
    } catch (_) {}

    _setStatus('Preparing Pokédex…', 0.55);
    try {
      final pokemon = await PokemonService.loadPokemon(
        onStatus: (msg) => _setStatus(msg, _progress),
      ).timeout(const Duration(seconds: 5));
      _loadedPokemon = pokemon;
      // Pre-cache first batch of sprites so they show up instantly on home screen with zero delay
      if (mounted) {
        for (final p in _loadedPokemon.take(16)) {
          precacheImage(CachedNetworkImageProvider(p.spriteUrl), context);
        }
      }
    } catch (_) {
      _loadedPokemon = kBuiltInPokemon;
    }

    _setStatus('Pokédex ready! (${_loadedPokemon.length} Pokémon)', 1.0);
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Stack(
          children: [
            // ── Animated background particles ──
            const _ParticleBg(),
            // ── Main content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // ── Logo block ──
                    _buildLogo(),
                    const Spacer(),
                    // ── Spinning pokeball ──
                    _buildPokeball(),
                    const Spacer(),
                    // ── Progress block ──
                    _buildProgress(),
                    const SizedBox(height: 24),
                    // ── Tip card ──
                    _buildTipCard(),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Pokéball icon with glow
        SvgPicture.asset('assets/images/pokeball.svg', width: 52, height: 52)
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut,
                duration: 900.ms),
        const SizedBox(height: 16),
        Text(
          'PokéPoke',
          style: GoogleFonts.pressStart2p(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 2,
            shadows: [
              const Shadow(
                color: Color(0xFFFF1C1C),
                blurRadius: 24,
                offset: Offset(0, 4),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 700.ms)
            .slideY(begin: 0.3, curve: Curves.easeOut),
        const SizedBox(height: 8),
        Text(
          "Gotta Catch 'Em All",
          style: GoogleFonts.inter(
              color: Colors.white38, fontSize: 12, letterSpacing: 3),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 700.ms),
      ],
    );
  }

  Widget _buildPokeball() {
    return const LoadingScreen(size: 100)
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut,
            duration: 800.ms, delay: 300.ms);
  }

  Widget _buildProgress() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _statusText,
            key: ValueKey(_statusText),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
          ),
        ),
        const SizedBox(height: 10),
        // Progress bar with animated glow
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 5,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF1C1C)),
              ),
            ),
            // Glow overlay
            if (_progress > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: (MediaQuery.of(context).size.width - 56) * _progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1C1C).withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tips_and_updates_outlined,
                  color: Color(0xFFFF1C1C), size: 14),
              const SizedBox(width: 6),
              Text(
                'TRAINER TIP',
                style: GoogleFonts.pressStart2p(
                    color: const Color(0xFFFF1C1C),
                    fontSize: 8,
                    letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
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
                  color: Colors.white70, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }
}

// ─── Particle background ──────────────────────────────────────────────────────
class _ParticleBg extends StatefulWidget {
  const _ParticleBg();

  @override
  State<_ParticleBg> createState() => _ParticleBgState();
}

class _ParticleBgState extends State<_ParticleBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => CustomPaint(
        painter: _ParticlePainter(_ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;
  static final _rng = Random(42);
  static final _particles = List.generate(18, (i) {
    return (
      _rng.nextDouble(),           // x fraction
      _rng.nextDouble(),           // y fraction
      _rng.nextDouble() * 3 + 1,  // speed
      _rng.nextDouble() * 4 + 2,  // radius
      _rng.nextDouble() * 0.4 + 0.05, // opacity
    );
  });

  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Glowing orbs
    for (final (dx, dy, speed, r, opacity) in _particles) {
      final x = (dx + t * speed * 0.04) % 1.0;
      final y = (dy + t * speed * 0.015) % 1.0;
      paint.shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(x * size.width, y * size.height), radius: r * 3));
      canvas.drawCircle(Offset(x * size.width, y * size.height), r, paint);
    }

    // Big subtle orbs (red + purple)
    final wave = sin(t * 2 * pi);
    for (final (dx, dy, r, color) in [
      (0.2, 0.25, 140.0, const Color(0xFFFF1C1C)),
      (0.8, 0.65, 110.0, const Color(0xFF7C4DFF)),
    ]) {
      paint.shader = RadialGradient(
        colors: [color.withValues(alpha: 0.12 + wave * 0.04), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * dx, size.height * dy), radius: r));
      canvas.drawCircle(
          Offset(size.width * dx, size.height * dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
