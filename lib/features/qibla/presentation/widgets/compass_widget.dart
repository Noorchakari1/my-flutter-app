import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/constants/app_constants.dart';
import '../../data/providers/qibla_provider.dart';

class CompassWidget extends ConsumerWidget {
  const CompassWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaNotifierProvider);
    final isPointingToQibla = ref.watch(isPointingToQiblaProvider);
    final relativeQiblaAngle = ref.watch(relativeQiblaAngleProvider);

    return qiblaState.when(
      data: (qiblaModel) {
        if (qiblaModel == null ||
            !qiblaModel.isLocationAvailable ||
            !qiblaModel.isCompassAvailable) {
          return const _CompassError();
        }

        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Compass background
              _CompassBackground(),

              // Compass needle (pointing North)
              Transform.rotate(
                angle: -qiblaModel.compassAngle * (pi / 180),
                child: _CompassNeedle(),
              ),

              // Qibla indicator
              Transform.rotate(
                angle: relativeQiblaAngle * (pi / 180),
                child: _QiblaIndicator(isPointingToQibla: isPointingToQibla),
              ),

              // Center dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _CompassLoading(),
      error: (error, _) => const _CompassError(),
    );
  }
}

class _CompassBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: CustomPaint(
        painter: _CompassBackgroundPainter(),
      ),
    );
  }
}

class _CompassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = AppConstants.primaryColor.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw compass circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 3), paint);
    }

    // Draw cardinal direction lines
    final linePaint = Paint()
      ..color = AppConstants.primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final startX = center.dx + cos(angle) * (radius * 0.8);
      final startY = center.dy + sin(angle) * (radius * 0.8);
      final endX = center.dx + cos(angle) * (radius * 0.9);
      final endY = center.dy + sin(angle) * (radius * 0.9);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        linePaint,
      );
    }

    // Draw minor direction lines
    final minorLinePaint = Paint()
      ..color = AppConstants.primaryColor.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + pi / 8;
      final startX = center.dx + cos(angle) * (radius * 0.85);
      final startY = center.dy + sin(angle) * (radius * 0.85);
      final endX = center.dx + cos(angle) * (radius * 0.9);
      final endY = center.dy + sin(angle) * (radius * 0.9);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        minorLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassNeedle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red, Colors.white],
          stops: [0.0, 0.5],
        ),
      ),
    );
  }
}

class _QiblaIndicator extends StatelessWidget {
  final bool isPointingToQibla;

  const _QiblaIndicator({required this.isPointingToQibla});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isPointingToQibla ? Colors.green : Colors.orange,
            boxShadow: [
              BoxShadow(
                color: (isPointingToQibla ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPointingToQibla ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'قبله',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _CompassLoading extends StatelessWidget {
  const _CompassLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }
}

class _CompassError extends StatelessWidget {
  const _CompassError();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Compass Error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
