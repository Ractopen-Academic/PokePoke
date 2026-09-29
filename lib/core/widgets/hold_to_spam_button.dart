import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A button that executes [onTrigger] on tap, and continuously spams [onTrigger]
/// at a rapid [interval] while being held down!
class HoldToSpamButton extends StatefulWidget {
  final VoidCallback onTrigger;
  final Widget child;
  final Duration initialDelay;
  final Duration interval;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry padding;
  final double pressedScale;

  const HoldToSpamButton({
    super.key,
    required this.onTrigger,
    required this.child,
    this.initialDelay = const Duration(milliseconds: 250),
    this.interval = const Duration(milliseconds: 90),
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.pressedScale = 0.94,
  });

  @override
  State<HoldToSpamButton> createState() => _HoldToSpamButtonState();
}

class _HoldToSpamButtonState extends State<HoldToSpamButton> {
  Timer? _holdTimer;
  Timer? _spamTimer;
  bool _isPressed = false;

  void _startSpam() {
    _stopSpam();
    setState(() => _isPressed = true);

    // Initial instant tap
    widget.onTrigger();
    HapticFeedback.lightImpact();

    // Start hold timer to begin rapid spam
    _holdTimer = Timer(widget.initialDelay, () {
      _spamTimer = Timer.periodic(widget.interval, (_) {
        if (!mounted) return;
        widget.onTrigger();
        HapticFeedback.selectionClick();
      });
    });
  }

  void _stopSpam() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _spamTimer?.cancel();
    _spamTimer = null;
    if (_isPressed && mounted) {
      setState(() => _isPressed = false);
    }
  }

  @override
  void dispose() {
    _stopSpam();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startSpam(),
      onTapUp: (_) => _stopSpam(),
      onTapCancel: () => _stopSpam(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: widget.padding,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }
}
