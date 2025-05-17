import 'package:flutter/material.dart';
import '../components/splash/animated_circle.dart';
import '../components/splash/weather_icon.dart';
import '../components/splash/app_name_text.dart';
import '../components/splash/loading_indicator.dart';
import '../theme/app_colors.dart';
import '../pages/get_started_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const GetStartedPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: size.height * 0.1,
              right: 20,
              child: AnimatedCircle(
                animation: _scaleAnimation,
                size: 100,
                alignment: Alignment.topRight,
              ),
            ),
            Positioned(
              bottom: size.height * 0.15,
              left: 20,
              child: AnimatedCircle(
                animation: _scaleAnimation,
                size: 80,
                alignment: Alignment.bottomLeft,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeatherIcon(
                    scaleAnimation: _scaleAnimation,
                    slideAnimation: _slideAnimation,
                    fadeAnimation: _fadeAnimation,
                  ),
                  const SizedBox(height: 40),
                  AppNameText(
                    slideAnimation: _slideAnimation,
                    fadeAnimation: _fadeAnimation,
                  ),
                  const SizedBox(height: 30),
                  LoadingIndicator(fadeAnimation: _fadeAnimation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
