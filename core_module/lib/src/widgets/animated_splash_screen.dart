import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // Lottie temporary disabled
import '../theme/app_colors.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  
  const AnimatedSplashScreen({super.key, required this.onFinished});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  bool _isFinished = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // Default fallback timer if Lottie fails to load entirely, or while Lottie is disabled
    _fallbackTimer = Timer(const Duration(seconds: 3), () { // Reduced from 6 to 3 for quick bypass
      _finish();
    });
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    _fallbackTimer?.cancel();
    if (mounted) {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for optimal rendering
    // final screenWidth = MediaQuery.of(context).size.width;
    // final lottieSize = screenWidth * 0.7 > 400.0 ? 400.0 : screenWidth * 0.7;

    return Scaffold(
      backgroundColor: AppColors.coffeeMilkPrimary, // Use a warm coffee background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.caramelGold),
            const SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(
                color: AppColors.caramelGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
        /* Lottie temporary disabled
        Lottie.asset(
          'assets/Coffee.json',
          package: 'coffee_shop_core',
          width: lottieSize, // Limit rendering size for Web performance
          height: lottieSize, // Limit rendering size for Web performance
          fit: BoxFit.contain,
          animate: true,
          repeat: false,
          frameRate: FrameRate.max, // Smooths out lag on Web
          filterQuality: FilterQuality.medium,
          onLoaded: (composition) {
            // Update fallback timer based on actual composition duration
            _fallbackTimer?.cancel();
            _fallbackTimer = Timer(composition.duration + const Duration(milliseconds: 500), () {
              _finish();
            });
          },
          errorBuilder: (context, error, stackTrace) {
            return const CircularProgressIndicator(color: AppColors.caramelGold);
          },
        )
        */
      ),
    );
  }
}
