import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable shimmer placeholder — circular shape, consistent style across screens.
class ShimmerBox extends StatelessWidget {
  final double size;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.size,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white12,
      highlightColor: Colors.white30,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white12,
          shape: shape,
        ),
      ),
    );
  }
}
