import 'package:flutter/material.dart';

class PokeDarkDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double radius;

  const PokeDarkDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.backgroundColor = const Color(0xFF1C1C30),
    this.borderColor,
    this.borderWidth = 1,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor!, width: borderWidth),
    ),
    title: title,
    content: content,
    actions: actions,
  );
}
