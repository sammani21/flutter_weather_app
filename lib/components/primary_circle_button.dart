import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryCircleButton extends StatelessWidget {
  final double progress;
  final VoidCallback onPressed;

  const PrimaryCircleButton({
    super.key,
    required this.progress,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.progress),
              backgroundColor: AppColors.progressBackground,
              strokeWidth: 2,
            ),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
