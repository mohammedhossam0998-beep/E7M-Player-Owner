import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedHourglass extends StatefulWidget {
  const AnimatedHourglass({super.key});

  @override
  State<AnimatedHourglass> createState() => _AnimatedHourglassState();
}

class _AnimatedHourglassState extends State<AnimatedHourglass>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,

      builder: (_, child) {
        final scale = 0.95 + (controller.value * 0.08);

        final angle = sin(controller.value * pi * 2) * 0.08;

        final move = sin(controller.value * pi * 2) * 8;

        return Transform.translate(
          offset: Offset(0, move),

          child: Transform.rotate(
            angle: angle,

            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 130,

            height: 20,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),

              color: Colors.black12,
            ),
          ),

          const SizedBox(height: 8),

          Image.asset("assets/images/hourglass.png", width: 170, height: 170),
        ],
      ),
    );
  }
}
