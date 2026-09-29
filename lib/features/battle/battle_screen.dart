import 'dart:async';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pokepoke/core/services/audio_service.dart';
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
    with TickerProviderStateMixin {
  final Random _rng = Random();

  // Walking state (Target distance is SECRET/HIDDEN from the user)
  int _currentSteps = 0;
  late int _targetSteps; // 10 to 50 random steps, hidden from UI
  int _sessionStepsWalked = 0;

  // Real pedometer sensor state
  bool _pedometerEnabled = false;
  int? _lastHardwareStepCount;
  StreamSubscription<StepCount>? _stepSubscription;
  String _sensorStatusMessage = 'Sensor Off';

  // Wild Pokémon encounter state
  PokemonEntry? _wildPokemon;
  Timer? _roamTimer;
  Alignment _roamAlignment = Alignment.center;
  int _tapCount = 0; // requires 2 taps to catch
  bool _isCapturing = false;
  bool _showHitFlash = false;

  // Walking visual simulation controllers
  late AnimationController _walkAnimController;
  late AnimationController _radarScanController;

  @override
  void initState() {
    super.initState();
    _resetSecretTarget();

    _walkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _radarScanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Auto-start safari music if not muted
    SafariAudioService.playBgm();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _roamTimer?.cancel();
    _walkAnimController.dispose();
    _radarScanController.dispose();
    super.dispose();
  }

  void _resetSecretTarget() {
    // Secret range 10 to 50 steps
    _targetSteps = 10 + _rng.nextInt(41);
    _currentSteps = 0;
  }

  // Request user permission for real hardware pedometer step detection
  Future<void> _promptAndEnablePedometer() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hardware step sensors are not available on Web. Use the Walk simulator button!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF262640),
        ),
      );
      return;
    }

    if (_pedometerEnabled) {
      await _stepSubscription?.cancel();
      setState(() {
        _pedometerEnabled = false;
        _sensorStatusMessage = 'Sensor Off';
      });
      return;
    }

    // Ask user permission
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF00E676), width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.directions_walk, color: Color(0xFF00E676), size: 24),
            const SizedBox(width: 8),
            Text(
              'REAL STEP TRACKER',
              style: GoogleFonts.pressStart2p(color: const Color(0xFF00E676), fontSize: 11),
            ),
          ],
        ),
        content: Text(
          'Allow PokéPoke to access your physical activity sensors? Every real step you take will advance your Pokémon exploration (+1 step)!',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('NOT NOW', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'GRANT PERMISSION',
              style: GoogleFonts.inter(
                color: const Color(0xFF00E676),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final status = await Permission.activityRecognition.request();
      if (!mounted) return;

      if (status.isGranted) {
        _startListeningToPedometer();
      } else {
        setState(() {
          _sensorStatusMessage = 'Permission Denied';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Activity recognition permission was not granted.',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error requesting activity permission: $e');
    }
  }

  void _startListeningToPedometer() {
    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (!mounted) return;
          if (_lastHardwareStepCount == null) {
            _lastHardwareStepCount = event.steps;
            setState(() {
              _pedometerEnabled = true;
              _sensorStatusMessage = 'Sensor Active';
            });
            return;
          }

          final delta = event.steps - _lastHardwareStepCount!;
          if (delta > 0) {
            _lastHardwareStepCount = event.steps;
            for (int i = 0; i < delta; i++) {
              _stepForward(isRealStep: true);
            }
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _pedometerEnabled = false;
            _sensorStatusMessage = 'Sensor Unavailable';
          });
        },
        cancelOnError: true,
      );

      setState(() {
        _pedometerEnabled = true;
        _sensorStatusMessage = 'Sensor Active';
      });
    } catch (e) {
      setState(() {
        _pedometerEnabled = false;
        _sensorStatusMessage = 'Sensor Error';
      });
    }
  }

  void _stepForward({bool isRealStep = false}) {
    if (_wildPokemon != null || _isCapturing) return;

    if (!isRealStep) {
      HapticFeedback.lightImpact();
    }
    _walkAnimController.forward(from: 0.0);

    setState(() {
      _currentSteps += 1;
      _sessionStepsWalked += 1;

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
    _roamTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted || _wildPokemon == null || _isCapturing) return;
      setState(() {
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

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _showHitFlash = false);
    });

    if (_tapCount < 2) {
      return; // 1 more tap needed!
    }

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
      _resetSecretTarget();
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
          'Your Safari Pen is at max capacity (${BattlePenService.maxCapacity}/${BattlePenService.maxCapacity}). Release a Pokémon in your Safari Pen to catch ${mon.name.toUpperCase()}.',
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
              'Added to your Safari Pen (${BattlePenService.penNotifier.value.length}/${BattlePenService.maxCapacity}). Click the Slots button to train or inspect!',
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

  // Mystery signal level based on secret progress (WITHOUT revealing target steps)
  String get _mysterySignalLabel {
    if (_wildPokemon != null) return 'ENCOUNTER ACTIVE!';
    final ratio = (_currentSteps / _targetSteps).clamp(0.0, 1.0);
    if (ratio < 0.25) return 'TALL GRASS: QUIET';
    if (ratio < 0.55) return 'TALL GRASS: RUSTLING...';
    if (ratio < 0.85) return 'SIGNALS DETECTED NEARBY!';
    return 'WILD POKÉMON VERY CLOSE!';
  }

  Color get _mysterySignalColor {
    if (_wildPokemon != null) return const Color(0xFFFFCC00);
    final ratio = (_currentSteps / _targetSteps).clamp(0.0, 1.0);
    if (ratio < 0.25) return Colors.white38;
    if (ratio < 0.55) return const Color(0xFF81C784);
    if (ratio < 0.85) return const Color(0xFFFFB74D);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSimulatedMysteryRadarCard(),
        Expanded(
          child: _wildPokemon != null
              ? _buildWildEncounterField()
              : _buildSimulatedWalkingMeadow(),
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
                'Walk or Simulate to Find Wild Pokémon',
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
                        '${penList.length}/20 SLOTS',
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

  // FAKE VISUAL SIMULATION & RADAR CARD (exact steps needed is hidden!)
  Widget _buildSimulatedMysteryRadarCard() {
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
                    Icon(Icons.radar, size: 16, color: _mysterySignalColor),
                    const SizedBox(width: 6),
                    Text(
                      _mysterySignalLabel,
                      style: GoogleFonts.pressStart2p(
                        color: _mysterySignalColor,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                // Pedometer hardware sensor toggle
                GestureDetector(
                  onTap: _promptAndEnablePedometer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _pedometerEnabled
                          ? const Color(0xFF00E676).withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _pedometerEnabled
                            ? const Color(0xFF00E676)
                            : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _pedometerEnabled
                              ? Icons.sensors
                              : Icons.sensors_off_outlined,
                          size: 12,
                          color: _pedometerEnabled
                              ? const Color(0xFF00E676)
                              : Colors.white38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sensorStatusMessage.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: _pedometerEnabled
                                ? const Color(0xFF00E676)
                                : Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Animated fake radar simulation wave
            AnimatedBuilder(
              animation: _radarScanController,
              builder: (context, _) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (_radarScanController.value).clamp(0.05, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _mysterySignalColor.withValues(alpha: 0.1),
                              _mysterySignalColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mystery Encounter: Walking…',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                ),
                Text(
                  'Steps Walked: $_sessionStepsWalked',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Simulated walking meadow with fake walking visual animation
  Widget _buildSimulatedWalkingMeadow() {
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

            // Simulated walking visual avatar & animated grass
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.12).animate(
                CurvedAnimation(
                  parent: _walkAnimController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer radar ping
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E676).withValues(alpha: 0.05),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E676).withValues(alpha: 0.12),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_walk,
                        size: 54,
                        color: Color(0xFF00E676),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Text(
              'TALL GRASS MEADOW',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _pedometerEnabled
                    ? 'Motion sensor active! Real physical steps will advance your search.'
                    : 'Walk around in the real world or tap below to simulate steps.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(),

            // Simulated Walk Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: NeoPopTiltedButton(
                isFloating: true,
                onTapUp: () => _stepForward(isRealStep: false),
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
                              if (_showHitFlash)
                                Text(
                                  'HIT!',
                                  style: GoogleFonts.pressStart2p(
                                    color: Colors.redAccent,
                                    fontSize: 10,
                                  ),
                                ),
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
