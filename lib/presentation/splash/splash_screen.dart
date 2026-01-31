import 'dart:async';
import 'dart:math' as math;
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/material.dart';
import 'package:edukids_app/presentation/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoIntroController;
  late Animation<double> _scaleIntroAnimation;
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;
  late AnimationController _backgroundLoopController;

  @override
  void initState() {
    super.initState();

    // Intro Animation
    _logoIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleIntroAnimation = CurvedAnimation(
      parent: _logoIntroController,
      curve: Curves.elasticOut,
    );

    // Floating Animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _floatingAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.05),
        ).animate(
          CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
        );

    _logoIntroController.forward().then((value) {
      _floatingController.repeat(reverse: true);
    });

    // Loop Animation
    _backgroundLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _backgroundLoopController.repeat(reverse: true);

    // Timer
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoIntroController.dispose();
    _floatingController.dispose();
    _backgroundLoopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bgCyan,
                    AppColors.bgBlue,
                    AppColors.bgPurple,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Bubbles
          AnimatedBuilder(
            animation: _backgroundLoopController,
            builder: (context, child) {
              final t = _backgroundLoopController.value;
              final baseOpacity = 0.4 + (t * 0.5);

              return Stack(
                children: [
                  Positioned(
                    top: AppSize.screenHeight * 0.08,
                    left: AppSize.screenWidth * 0.1,
                    child: _buildBubble(size: 55, opacity: baseOpacity),
                  ),
                  Positioned(
                    top: AppSize.screenHeight * 0.15,
                    right: AppSize.screenWidth * 0.15,
                    child: _buildBubble(size: 40, opacity: baseOpacity * 0.9),
                  ),
                  Positioned(
                    top: AppSize.screenHeight * 0.05,
                    left: AppSize.screenWidth * 0.55,
                    child: _buildBubble(size: 25, opacity: baseOpacity * 0.7),
                  ),
                  Positioned(
                    top: AppSize.screenHeight * 0.28,
                    left: AppSize.screenWidth * 0.05,
                    child: _buildBubble(size: 45, opacity: baseOpacity * 0.85),
                  ),
                  Positioned(
                    top: AppSize.screenHeight * 0.25,
                    right: AppSize.screenWidth * 0.05,
                    child: _buildBubble(size: 30, opacity: baseOpacity * 0.75),
                  ),
                ],
              );
            },
          ),

          // Waves
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: AppSize.screenHeight * 0.35,
            child: AnimatedBuilder(
              animation: _backgroundLoopController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AnimatedWavePainter(_backgroundLoopController.value),
                );
              },
            ),
          ),

          // Logo
          Center(
            child: ScaleTransition(
              scale: _scaleIntroAnimation,
              child: SlideTransition(
                position: _floatingAnimation,
                child: Image.asset(
                  'assets/images/logo_sementara1.png',
                  height: AppSize.screenHeight * 0.70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bubble Widget
  Widget _buildBubble({required double size, required double opacity}) {
    return Container(
      width: AppSize.scaleWidth(size),
      height: AppSize.scaleWidth(size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withOpacity(opacity * 0.3),
        border: Border.all(
          color: AppColors.white.withOpacity(opacity * 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(opacity * 0.4),
            blurRadius: size * 0.5,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

// Wave Painter
class AnimatedWavePainter extends CustomPainter {
  final double value;
  AnimatedWavePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    // Back Wave
    _drawWave(
      canvas,
      size,
      opacity: 0.4,
      offsetY: size.height * 0.55,
      waveHeight: 25,
      speedMultiplier: -1.0,
    );
    // Front Wave
    _drawWave(
      canvas,
      size,
      opacity: 1.0,
      offsetY: size.height * 0.65,
      waveHeight: 35,
      speedMultiplier: 1.2,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double opacity,
    required double offsetY,
    required double waveHeight,
    required double speedMultiplier,
  }) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, size.height);

    for (double i = 0.0; i <= size.width; i++) {
      path.lineTo(
        i,
        offsetY +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (value * 2 * math.pi * speedMultiplier),
                ) *
                waveHeight,
      );
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedWavePainter oldDelegate) =>
      oldDelegate.value != value;
}
