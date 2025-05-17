import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> slideAnimation;
  final Animation<double> fadeAnimation;

  const WeatherIcon({
    super.key,
    required this.scaleAnimation,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, slideAnimation.value),
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/weather_3d.png',
                  height: size.height * 0.25,
                  width: size.width * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
