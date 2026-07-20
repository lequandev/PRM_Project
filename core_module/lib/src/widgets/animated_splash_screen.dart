import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  
  const AnimatedSplashScreen({super.key, required this.onFinished});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  int _stage = 0;
  
  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }
  
  void _startAnimationSequence() {
    // STAGE 1: Dot Appearance (0.0s - 0.8s)
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _stage = 1);
    });
    
    // STAGE 2: Massive Circle Reveal (0.8s - 2.0s)
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _stage = 2);
    });
    
    // STAGE 3: Drop-down Logo & Loading (2.0s - 4.5s)
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _stage = 3);
    });
    
    // STAGE 4: Onboarding Slide-Up (4.5s+)
    Timer(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _stage = 4);
    });
    
    // FINISH: Auto transition at 9.0s
    Timer(const Duration(milliseconds: 9000), () {
      if (mounted) widget.onFinished();
    });
  }

  // Minimalist Coffee Cup SVG
  final String _logoSvg = '''
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M35 30C35 25 40 20 40 15" stroke="currentColor" stroke-width="4" stroke-linecap="round"/>
    <path d="M50 30C50 22 55 18 55 10" stroke="currentColor" stroke-width="4" stroke-linecap="round"/>
    <path d="M65 30C65 25 70 20 70 15" stroke="currentColor" stroke-width="4" stroke-linecap="round"/>
    <path d="M25 40H75V60C75 73.8071 63.8071 85 50 85C36.1929 85 25 73.8071 25 60V40Z" fill="currentColor" fill-opacity="0.1" stroke="currentColor" stroke-width="4" stroke-linejoin="round"/>
    <path d="M75 45H85C87.7614 45 90 47.2386 90 50V55C90 60.5228 85.5228 65 80 65H73" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15 90H85" stroke="currentColor" stroke-width="4" stroke-linecap="round"/>
  </svg>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roastedBrownText, // Deep Roasted Coffee Brown
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Color Fix: When dot fully expands, switch background to avoid clip edges
          AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _stage >= 3 ? 1.0 : 0.0,
            child: Container(color: AppColors.coffeeMilkPrimary),
          ),
          
          // STAGE 1 & 2: The Expanding Circle (MUST ONLY USE TRANSFORM)
          if (_stage < 3)
            AnimatedScale(
              duration: Duration(milliseconds: _stage == 2 ? 1200 : 700),
              // Buttery-smooth liquid expansion per requirement
              curve: _stage == 2 
                  ? const Cubic(0.76, 0.0, 0.24, 1.0) 
                  : Curves.easeOutBack,
              // Fixed container massive scale factor
              scale: _stage == 0 ? 0.0 : (_stage == 1 ? 1.0 : 150.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _stage == 0 ? 0.0 : 1.0,
                child: Container(
                  width: 64, // Fixed size to prevent layout thrashing
                  height: 64, // Fixed size to prevent layout thrashing
                  decoration: const BoxDecoration(
                    color: AppColors.coffeeMilkPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            
          // STAGE 3: Logo & Loading (Fades out and slides up in Stage 4)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: (_stage >= 3 && _stage < 4) ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: _stage >= 4 ? Curves.easeIn : Curves.elasticOut, // Spring physics drop
              transform: Matrix4.translationValues(0, _stage < 3 ? -100 : (_stage == 3 ? 0 : -50), 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.string(
                    _logoSvg,
                    width: 100,
                    height: 100,
                    colorFilter: const ColorFilter.mode(AppColors.roastedBrownText, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'COFFEE SHOP',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.0,
                      color: AppColors.roastedBrownText,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Sleek Linear Progress Indicator
                  if (_stage >= 3)
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          // Fills smoothly from 0 to 1 over exactly 2.5s
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2500),
                          curve: Curves.easeInOutSine,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.caramelGold),
                              backgroundColor: AppColors.roastedBrownText.withOpacity(0.1),
                              minHeight: 4,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // STAGE 4: Onboarding Screen Slide-Up
          AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: _stage >= 4 ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: const Cubic(0.25, 1.0, 0.5, 1.0), // Smooth decelerating slide up
              transform: Matrix4.translationValues(0, _stage >= 4 ? 0 : 50, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Placeholder Onboarding Image
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: AppColors.roastedBrownText.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.caramelGold.withOpacity(0.3), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.coffee_maker_outlined, size: 80, color: AppColors.caramelGold),
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Everything you need\nfor your morning brew',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.roastedBrownText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Order ahead, earn rewards, and discover new premium flavors every day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.roastedBrownText.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 64),
                    // Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: widget.onFinished,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roastedBrownText,
                          foregroundColor: AppColors.coffeeMilkPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
