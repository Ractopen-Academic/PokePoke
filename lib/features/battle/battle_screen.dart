import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pokepoke/core/services/audio_service.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/core/widgets/hold_to_spam_button.dart';
import 'package:pokepoke/core/widgets/poke_dark_dialog.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';

class BattleScreen extends StatefulWidget {
  final List<PokemonEntry> allPokemon;
  final VoidCallback? onGoToSafari;

  const BattleScreen({
    super.key,
    required this.allPokemon,
    this.onGoToSafari,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final Random _rng = Random();

  // Walking state (Target is secret/concealed from user)
  int _currentSteps = 0;
  late int _targetSteps;
  int _sessionSteps = 0;

  // Pedometer sensor
  bool _pedometerActive = false;
  int? _initialSteps;
  StreamSubscription<StepCount>? _stepSub;
  String _sensorLabel = 'SENSOR OFF';

  // Encounter state
  PokemonEntry? _wildPokemon;
  Timer? _roamTimer;
  Alignment _wildPos = Alignment.center;
  int _tapCount = 0;
  bool _isCapturing = false;
  bool _hitFlash = false;

  @override
  void initState() {
    super.initState();
    _resetTarget();
    SafariAudioService.playBgm();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _roamTimer?.cancel();
    super.dispose();
  }

  void _resetTarget() {
    _targetSteps = 10 + _rng.nextInt(41); // Secret 10-50 steps
    _currentSteps = 0;
  }

  Future<void> _togglePedometer() async {
    if (kIsWeb) {
      _showToast('Sensors not supported on Web. Use Hold-to-Walk!');
      return;
    }

    if (_pedometerActive) {
      await _stepSub?.cancel();
      setState(() {
        _pedometerActive = false;
        _sensorLabel = 'SENSOR OFF';
      });
      return;
    }

    final granted = await showDialog<bool>(
      context: context,
      builder: (ctx) => PokeDarkDialog(
        borderColor: const Color(0xFF00E676),
        title: Text(
          'PEDOMETER ACCESS',
          style: GoogleFonts.pressStart2p(color: const Color(0xFF00E676), fontSize: 11),
        ),
        content: Text(
          'Allow physical step tracking? Real steps will advance your PokéWalk exploration (+1 step)!',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ALLOW')),
        ],
      ),
    );

    if (granted != true) return;

    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      _showToast('Activity permission denied');
      return;
    }

    try {
      _stepSub = Pedometer.stepCountStream.listen(
        (event) {
          if (!mounted) return;
          if (_initialSteps == null) {
            _initialSteps = event.steps;
            setState(() {
              _pedometerActive = true;
              _sensorLabel = 'SENSOR ON';
            });
            return;
          }
          final delta = event.steps - _initialSteps!;
          if (delta > 0) {
            _initialSteps = event.steps;
            for (int i = 0; i < delta; i++) {
              _stepForward();
            }
          }
        },
        onError: (_) => setState(() {
          _pedometerActive = false;
          _sensorLabel = 'UNAVAILABLE';
        }),
      );
      setState(() {
        _pedometerActive = true;
        _sensorLabel = 'SENSOR ON';
      });
    } catch (_) {}
  }

  void _stepForward() {
    if (_wildPokemon != null || _isCapturing) return;

    setState(() {
      _currentSteps++;
      _sessionSteps++;
      if (_currentSteps >= _targetSteps) {
        _startEncounter();
      }
    });
  }

  void _startEncounter() {
    final pool = widget.allPokemon.isNotEmpty ? widget.allPokemon : kBuiltInPokemon;
    setState(() {
      _wildPokemon = pool[_rng.nextInt(pool.length)];
      _tapCount = 0;
      _wildPos = Alignment.center;
      _isCapturing = false;
    });

    _roamTimer?.cancel();
    _roamTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted || _wildPokemon == null || _isCapturing) return;
      setState(() {
        _wildPos = Alignment((_rng.nextDouble() * 1.5) - 0.75, (_rng.nextDouble() * 1.5) - 0.75);
      });
    });
  }

  Future<void> _tapPokemon() async {
    if (_wildPokemon == null || _isCapturing) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _tapCount++;
      _hitFlash = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _hitFlash = false);
    });

    if (_tapCount < 2) return;

    // 2nd Tap -> Capture!
    _roamTimer?.cancel();
    setState(() => _isCapturing = true);

    final mon = _wildPokemon!;
    final full = BattlePenService.penNotifier.value.length >= BattlePenService.maxCapacity;

    if (full) {
      _showPenFullDialog(mon);
      return;
    }

    final ok = await BattlePenService.addCaughtPokemon(mon);
    if (mounted && ok) _showCaughtDialog(mon);
  }

  void _flee() {
    _roamTimer?.cancel();
    setState(() {
      _wildPokemon = null;
      _tapCount = 0;
      _isCapturing = false;
      _resetTarget();
    });
  }

  void _showPenFullDialog(PokemonEntry mon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PokeDarkDialog(
        backgroundColor: const Color(0xFF1E1E34),
        title: Text('PEN FULL (20/20)', style: GoogleFonts.pressStart2p(color: Colors.redAccent, fontSize: 11)),
        content: Text('Your Safari Pen is at max capacity! Release some Pokémon to catch ${mon.displayName}.',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); _flee(); }, child: const Text('RELEASE WILD')),
          TextButton(onPressed: () { Navigator.pop(ctx); _flee(); widget.onGoToSafari?.call(); },
              child: const Text('GO TO PEN', style: TextStyle(color: Color(0xFF4FC3F7)))),
        ],
      ),
    );
  }

  void _showCaughtDialog(PokemonEntry mon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PokeDarkDialog(
        radius: 20,
        borderColor: const Color(0xFFFFCC00),
        borderWidth: 1.5,
        title: Row(
          children: [
            const Icon(Icons.catching_pokemon, color: Color(0xFFFFCC00), size: 22),
            const SizedBox(width: 8),
            Text('GOTCHA!', style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 13)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(imageUrl: mon.spriteUrl, width: 100, height: 100).animate().scale(duration: 300.ms),
            const SizedBox(height: 8),
            Text('${mon.displayName} caught!', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Added to Safari Pen (${BattlePenService.penNotifier.value.length}/20).',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); _flee(); }, child: const Text('KEEP WALKING')),
          TextButton(onPressed: () { Navigator.pop(ctx); _flee(); widget.onGoToSafari?.call(); },
              child: const Text('VIEW IN PEN', style: TextStyle(color: Color(0xFFFFCC00)))),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: 2.seconds));
  }

  String get _radarLabel {
    if (_wildPokemon != null) return 'ENCOUNTER ACTIVE!';
    final r = (_currentSteps / _targetSteps).clamp(0.0, 1.0);
    if (r < 0.25) return 'TALL GRASS: QUIET';
    if (r < 0.55) return 'TALL GRASS: RUSTLING...';
    if (r < 0.85) return 'SIGNALS NEARBY!';
    return 'POKÉMON VERY CLOSE!';
  }

  Color get _radarColor {
    if (_wildPokemon != null) return const Color(0xFFFFCC00);
    final r = (_currentSteps / _targetSteps).clamp(0.0, 1.0);
    if (r < 0.25) return Colors.white38;
    if (r < 0.55) return const Color(0xFF81C784);
    if (r < 0.85) return const Color(0xFFFFB74D);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildRadarCard(),
        Expanded(
          child: _wildPokemon != null ? _buildArena() : _buildWalkMeadow(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: Color(0xFF00E676), size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('POKÉWALK', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Hold to Walk or Move Physically',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
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
          // Pen slots shortcut
          ValueListenableBuilder<List<CaughtPokemon>>(
            valueListenable: BattlePenService.penNotifier,
            builder: (_, list, child) => GestureDetector(
              onTap: widget.onGoToSafari,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.4)),
                ),
                child: Text('${list.length}/20 PEN',
                    style: GoogleFonts.pressStart2p(color: const Color(0xFF4FC3F7), fontSize: 8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.radar, size: 15, color: _radarColor)
                        .animate(onPlay: (c) => c.repeat())
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1200.ms),
                    const SizedBox(width: 6),
                    Text(_radarLabel, style: GoogleFonts.pressStart2p(color: _radarColor, fontSize: 8)),
                  ],
                ),
                GestureDetector(
                  onTap: _togglePedometer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _pedometerActive ? const Color(0xFF00E676).withValues(alpha: 0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _pedometerActive ? const Color(0xFF00E676) : Colors.white24),
                    ),
                    child: Text(_sensorLabel,
                        style: GoogleFonts.inter(
                            color: _pedometerActive ? const Color(0xFF00E676) : Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Simulated radar scan wave
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                color: Colors.white10,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(_radarColor),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hold button to auto-walk!', style: GoogleFonts.inter(color: Colors.white38, fontSize: 9.5)),
                Text('Steps: $_sessionSteps',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkMeadow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF161628),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated walking indicator
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E676).withValues(alpha: 0.12),
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(Icons.directions_walk, size: 50, color: Color(0xFF00E676)),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 800.ms),
            const SizedBox(height: 16),
            Text('TALL GRASS MEADOW', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 11)),
            const SizedBox(height: 6),
            Text('Press & HOLD to turbo-walk!', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
            const Spacer(),
            // HOLD TO SPAM WALK BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: HoldToSpamButton(
                onTrigger: _stepForward,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.3), blurRadius: 10),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, color: Colors.black, size: 18),
                    const SizedBox(width: 8),
                    Text('HOLD TO WALK (+1)',
                        style: GoogleFonts.pressStart2p(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArena() {
    final mon = _wildPokemon!;
    final left = 2 - _tapCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF17172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFCC00).withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            // Top encounter banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0x33FFCC00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  Text('WILD ${mon.name.toUpperCase()}!',
                      style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 9))
                      .animate().fadeIn().slideX(begin: -0.3, curve: Curves.easeOut),
                  const Spacer(),
                  GestureDetector(
                    onTap: _flee,
                    child: Text('FLEE', style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(left == 2 ? 'TAP 2 TIMES TO CATCH!' : '1 MORE TAP TO CATCH!',
                  style: GoogleFonts.pressStart2p(color: left == 1 ? const Color(0xFFFF5252) : Colors.white, fontSize: 9)),
            ),
            // Roaming arena
            Expanded(
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: 900.ms,
                    curve: Curves.easeInOut,
                    alignment: _wildPos,
                    child: GestureDetector(
                      onTap: _tapPokemon,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _hitFlash ? Colors.redAccent.withValues(alpha: 0.4) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_hitFlash) Text('HIT!', style: GoogleFonts.pressStart2p(color: Colors.redAccent, fontSize: 10)),
                            CachedNetworkImage(
                              imageUrl: mon.spriteUrl,
                              width: 120,
                              height: 120,
                              placeholder: (context, url) => const SizedBox(width: 80, height: 80),
                            ).animate(target: _hitFlash ? 1.0 : 0.0).shake(duration: 250.ms),
                            const SizedBox(height: 2),
                            Text(mon.formattedId,
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
