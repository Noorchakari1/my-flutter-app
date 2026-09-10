import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Continuously flips the app logo around the Y axis for compact locations,
/// such as the home app bar.
class RotatingLogo extends StatefulWidget {
  final double size;
  final Color? color;
  final String assetPath;

  const RotatingLogo({
    super.key,
    this.size = 38,
    this.color,
    this.assetPath = AppConstants.logoPath,
  });

  @override
  State<RotatingLogo> createState() => _RotatingLogoState();
}

class _RotatingLogoState extends State<RotatingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AOP logo',
      image: true,
      child: AnimatedBuilder(
        animation: _controller,
        child: Image.asset(
          widget.assetPath,
          width: widget.size,
          height: widget.size,
          color: widget.color,
          fit: BoxFit.contain,
        ),
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_controller.value * math.pi * 2),
          child: child,
        ),
      ),
    );
  }
}
