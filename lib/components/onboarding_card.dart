import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String imagePath;
  final double scaleValue;
  final double translateValue;

  const OnboardingCard({
    super.key,
    required this.imagePath,
    required this.scaleValue,
    required this.translateValue,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(translateValue)
        ..scale(scaleValue),
      child: Opacity(
        opacity: scaleValue,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
