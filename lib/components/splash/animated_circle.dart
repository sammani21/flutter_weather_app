import 'package:flutter/material.dart';

class AnimatedCircle extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final Alignment alignment;

  const AnimatedCircle({
    super.key,
    required this.animation,
    required this.size,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          );
        },
      ),
    );
  }
}
