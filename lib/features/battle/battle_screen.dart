import 'dart:async';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:pokepoke/core/services/pokemon_service.dart';
import 'package:pokepoke/features/battle/data/battle_pen_service.dart';
import 'package:pokepoke/features/battle/data/caught_pokemon.dart';
import 'package:shimmer/shimmer.dart';

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

class _BattleScreenState extends State<BattleScreen>
    with SingleTickerProviderStateMixin {
  final Random _rng = Random();

  // Walking state
  int _currentSteps = 0;
  late int _targetSteps;
  int _totalStepsWalked = 0;

  // Wild Pokémon encounter state
  PokemonEntry? _wildPokemon;
  Timer? _roamTimer;
  Alignment _roamAlignment = Alignment.center;
  int _tapCount = 0; // needs 2 taps to catch
  bool _isCapturing = false;
  bool _showHitFlash = false;

  late AnimationController _stepBounceController;

  @override
  void initState() {
    super.initState();
    _resetTargetSteps();
    _stepBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _roamTimer?.cancel();
    _stepBounceController.dispose();
    super.dispose();
  }

  void _resetTargetSteps() {
    // Range 10 to 50 steps
    _targetSteps = 10 + _rng.nextInt(41);
    _currentSteps = 0;
  }

  void _stepForward() {
    if (_wildPokemon != null || _isCapturing) return;

    HapticFeedback.lightImpact();
    _stepBounceController.forward(from: 0.0);

    setState(() {
      _currentSteps += 1;
      _totalStepsWalked += 1;

      if (_currentSteps >= _targetSteps) {
        _triggerWildEncounter();
      }
    });
  }

  void _triggerWildEncounter() {
    final pool = widget.allPokemon.isNotEmpty ? widget.allPokemon : kBuiltInPokemon;
    final randomMon = pool[_rng.nextInt(pool.length)];

    setState(() {
      _wildPokemon = randomMon;
      _tapCount = 0;
      _roamAlignment = Alignment.center;
      _isCapturing = false;
    });

    _startRoamingTimer();
  }

  void _startRoamingTimer() {
    _roamTimer?.cancel();
    // Roam and spread out randomly across field every 1.2s
    _roamTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted || _wildPokemon == null || _isCapturing) return;
      setState(() {
        // Random position between -0.75 and +0.75 on both axes
        final dx = (_rng.nextDouble() * 1.5) - 0.75;
        final dy = (_rng.nextDouble() * 1.5) - 0.75;
        _roamAlignment = Alignment(dx, dy);
      });
    });
  }

  Future<void> _handlePokemonTapped() async {
    if (_wildPokemon == null || _isCapturing) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _tapCount += 1;
      _showHitFlash = true;
    });

    // Reset hit flash effect
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _showHitFlash = false);
    });

    if (_tapCount < 2) {
      // 1st tap feedback
      return;
    }

    // 2nd tap: Catch the Pokémon!
    _roamTimer?.cancel();
    setState(() {
      _isCapturing = true;
    });

    final caughtMon = _wildPokemon!;
    final penFull = BattlePenService.penNotifier.value.length >= BattlePenService.maxCapacity;

    if (penFull) {
      _showPenFullDialog(caughtMon);
      return;
    }

    final success = await BattlePenService.addCaughtPokemon(caughtMon);

    if (!mounted) return;

    if (success) {
      _showCaughtDialog(caughtMon);
    }
  }

  void _fleeEncounter() {
    _roamTimer?.cancel();
    setState(() {
      _wildPokemon = null;
      _tapCount = 0;
      _isCapturing = false;
      _resetTargetSteps();
    });
  }

  void _showPenFullDialog(PokemonEntry mon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E34),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'SAFARI PEN FULL',
              style: GoogleFonts.pressStart2p(color: Colors.redAccent, fontSize: 11),
            ),
          ],
        ),
        content: Text(
          'Your Safari Pen has reached the maximum capacity of ${BattlePenService.maxCapacity} Pokémon!\n\nRelease some Pokémon in your Safari Pen to catch ${mon.name.toUpperCase()}.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _fleeEncounter();
            },
            child: Text('RELEASE WILD', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _fleeEncounter();
              widget.onGoToSafari?.call();
            },
            child: Text(
              'GO TO SAFARI PEN',
              style: GoogleFonts.inter(
                color: const Color(0xFF4FC3F7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCaughtDialog(PokemonEntry mon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.catching_pokemon, color: Color(0xFFFFCC00), size: 24),
            const SizedBox(width: 8),
            Text(
              'GOTCHA!',
              style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 13),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: mon.spriteUrl,
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              '${mon.name.toUpperCase()} was caught!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Added to your Safari Pen (${BattlePenService.penNotifier.value.length}/${BattlePenService.maxCapacity}). Train it in your Profile to level up and evolve!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _fleeEncounter();
            },
            child: Text(
              'KEEP WALKING',
              style: GoogleFonts.pressStart2p(color: Colors.white60, fontSize: 8),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _fleeEncounter();
              widget.onGoToSafari?.call();
            },
            child: Text(
              'VIEW IN PEN',
              style: GoogleFonts.pressStart2p(color: const Color(0xFFFFCC00), fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildStatusCard(),
        Expanded(
          child: _wildPokemon != null ? _buildWildEncounterField() : _buildWalkingMeadow(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: Color(0xFF00E676), size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POKÉWALK',
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Walk & Tap to Catch Wild Pokémon',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          // Button to Safari Pen
          ValueListenableBuilder<List<CaughtPokemon>>(
            valueListenable: BattlePenService.penNotifier,
            builder: (context, penList, _) {
              return GestureDetector(
                onTap: widget.onGoToSafari,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pets, size: 14, color: Color(0xFF4FC3F7)),
                      const SizedBox(width: 6),
                      Text(
                        'PEN ${penList.length}/20',
                        style: GoogleFonts.pressStart2p(
                          color: const Color(0xFF4FC3F7),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final remaining = (_targetSteps - _currentSteps).clamp(0, _targetSteps);
    final progress = (_currentSteps / _targetSteps).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E34),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFFFCC00)),
                    const SizedBox(width: 6),
                    Text(
                      _wildPokemon != null
                          ? 'WILD ENCOUNTER ACTIVE!'
                          : '$remaining STEPS UNTIL ENCOUNTER',
                      style: GoogleFonts.pressStart2p(
                        color: _wildPokemon != null
                            ? const Color(0xFFFFCC00)
                            : Colors.white70,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_currentSteps / $_targetSteps',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _wildPokemon != null ? 1.0 : progress,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _wildPokemon != null
                      ? const Color(0xFFFFCC00)
                      : const Color(0xFF00E676),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Range: 10–50 steps',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                ),
                Text(
                  'Total Walked: $_totalStepsWalked steps',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Meadow state when walking
  Widget _buildWalkingMeadow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF161628),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withValues(alpha: 0.05),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Animated walking indicator
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                CurvedAnimation(
                  parent: _stepBounceController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_walk,
                    size: 64,
                    color: Color(0xFF00E676),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'TALL GRASS MEADOW',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Walk through the meadow to find rare Pokémon roaming.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const Spacer(),

            // Walk Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: NeoPopTiltedButton(
                isFloating: true,
                onTapUp: _stepForward,
                color: const Color(0xFF00E676),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_walk, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'TAKE STEP (+1)',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Active wild encounter field with roaming Pokémon
  Widget _buildWildEncounterField() {
    final mon = _wildPokemon!;
    final tapsLeft = (2 - _tapCount).clamp(0, 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF17172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFCC00).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Top encounter banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC00).withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  FadeInLeft(
                    child: Text(
                      'WILD ${mon.name.toUpperCase()} APPEARED!',
                      style: GoogleFonts.pressStart2p(
                        color: const Color(0xFFFFCC00),
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _fleeEncounter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FLEE',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tap counter instructions banner
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app, size: 16, color: Color(0xFFFF5252)),
                  const SizedBox(width: 6),
                  Text(
                    tapsLeft == 2
                        ? 'TAP 2 TIMES TO CATCH!'
                        : '1 MORE TAP TO CATCH!',
                    style: GoogleFonts.pressStart2p(
                      color: tapsLeft == 1 ? const Color(0xFFFF5252) : Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // Roaming Arena Field
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Grid background lines for arena feel
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ArenaGridPainter(),
                      ),
                    ),

                    // Roaming Wild Pokémon
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeInOutCubic,
                      alignment: _roamAlignment,
                      child: GestureDetector(
                        onTap: _handlePokemonTapped,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _showHitFlash
                                ? Colors.redAccent.withValues(alpha: 0.4)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Floating hit indicator
                              if (_showHitFlash)
                                Text(
                                  'HIT!',
                                  style: GoogleFonts.pressStart2p(
                                    color: Colors.redAccent,
                                    fontSize: 10,
                                  ),
                                ),
                              // Pokemon sprite
                              CachedNetworkImage(
                                imageUrl: mon.spriteUrl,
                                width: 130,
                                height: 130,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.white12,
                                  highlightColor: Colors.white24,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: Colors.white12,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              )
                                  .animate(
                                    target: _showHitFlash ? 1.0 : 0.0,
                                  )
                                  .shake(duration: const Duration(milliseconds: 250)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  mon.formattedId,
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Hint indicator at bottom of field
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Pokemon is roaming! Tap it before it moves!',
                          style: GoogleFonts.inter(
                            color: Colors.white30,
                            fontSize: 10,
                          ),
                        ),
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
}

class _ArenaGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    const step = 30.0;
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
