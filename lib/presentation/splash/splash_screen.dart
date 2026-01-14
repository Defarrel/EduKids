import 'dart:async';
import 'dart:math' as math;
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/material.dart';
import 'package:edukids_app/core/constant/colors.dart';
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

    _logoIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleIntroAnimation = CurvedAnimation(
      parent: _logoIntroController,
      curve: Curves.elasticOut, 
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    );

    _floatingAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(
            0.0,
            -0.05,
          ), 
        ).animate(
          CurvedAnimation(
            parent: _floatingController,
            curve: Curves.easeInOut,
          ),
        );

    _logoIntroController.forward().then((value) {
      _floatingController.repeat(reverse: true);
    });

    _backgroundLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), 
    );
    _backgroundLoopController.repeat(); 

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: AppSize.screenHeight * 0.3,
              child: AnimatedBuilder(
                animation: _backgroundLoopController,
                builder: (context, child) {
                  final t = _backgroundLoopController.value;
                  return Stack(
                    children: [
                      // Ombak 1
                      Positioned(
                        top: AppSize.scaleHeight(40),
                        left: AppSize.scaleWidth(-20) + (screenWidth * 0.1 * t),
                        child: _buildOrnament(size: 60, opacity: 0.3),
                      ),
                      Positioned(
                        top: AppSize.scaleHeight(80),
                        right:
                            AppSize.scaleWidth(-30) + (screenWidth * 0.15 * t),
                        child: _buildOrnament(size: 40, opacity: 0.2),
                      ),
                      Positioned(
                        top:
                            AppSize.scaleHeight(20) +
                            (10 * math.sin(t * 2 * math.pi)),
                        left: screenWidth * 0.6,
                        child: _buildOrnament(size: 30, opacity: 0.25),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Ombak 2
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: AppSize.screenHeight * 0.45,
              child: AnimatedBuilder(
                animation: _backgroundLoopController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AnimatedWavePainter(
                      _backgroundLoopController.value,
                    ),
                  );
                },
              ),
            ),

            Center(
              child: ScaleTransition(
                scale: _scaleIntroAnimation, 
                child: SlideTransition(
                  position:
                      _floatingAnimation, 
                  child: Image.asset(
                    'lib/core/assets/images/logo_sementara.png',
                    width: AppSize.scaleWidth(280),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget 
  Widget _buildOrnament({required double size, required double opacity}) {
    return Container(
      width: AppSize.scaleWidth(size),
      height: AppSize.scaleWidth(size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(opacity * 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}

class AnimatedWavePainter extends CustomPainter {
  final double value;
  AnimatedWavePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    // Ombak Belakang
    _drawWave(
      canvas,
      size,
      opacity: 0.4,
      offsetY: size.height * 0.55,
      waveHeight: 25,
      speedMultiplier: -1.0,
    );
    // Ombak Depan
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
      ..color = Colors.white.withOpacity(opacity)
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
