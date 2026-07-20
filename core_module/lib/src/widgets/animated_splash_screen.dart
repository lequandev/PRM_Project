import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
    // Default fallback timer if Lottie fails to load entirely
    _fallbackTimer = Timer(const Duration(seconds: 6), () {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final lottieSize = screenWidth * 0.7 > 400.0 ? 400.0 : screenWidth * 0.7;

    return Scaffold(
      backgroundColor: AppColors.coffeeMilkPrimary, // Use a warm coffee background
      body: Center(
        child: Lottie.asset(
          'assets/Coffee Cup.json',
          package: 'coffee_shop_core',
          width: lottieSize, // Limit rendering size for Web performance
          height: lottieSize, // Limit rendering size for Web performance
          fit: BoxFit.contain,
          animate: true,
          repeat: true, // Use native Lottie repeat to avoid disappearing bugs on Web
          frameRate: const FrameRate(30), // Force 30fps for smooth web animation
          filterQuality: FilterQuality.medium,
          onLoaded: (composition) {
            // Cancel fallback since it loaded successfully
            _fallbackTimer?.cancel();
            
            // Đếm đúng 6 giây sau đó mới chuyển màn hình
            Timer(const Duration(seconds: 6), () {
              if (mounted) {
                _finish();
              }
            });
          },
          errorBuilder: (context, error, stackTrace) {
            return const CircularProgressIndicator(color: AppColors.caramelGold);
          },
        ),
      ),
    );
  }
}
