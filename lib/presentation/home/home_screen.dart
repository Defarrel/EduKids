import 'dart:async';
import 'dart:math' as math;
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/presentation/home/settings.dart';
import 'package:edukids_app/presentation/mini_games/home_mini_games/home_mini_games_screen.dart';
import 'package:flutter/material.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Bubble Model
class Bubble {
  String id;
  double x;
  double y;
  double size;
  double speed;
  Color color;
  double swayOffset;
  double dirX;

  Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.swayOffset,
    required this.dirX,
  });
}

// Particle Model
class SplashParticle {
  String id;
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;

  SplashParticle({
    required this.id,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controllers
  late AnimationController _btnController;
  late Animation<double> _btnScaleAnimation;
  late AnimationController _logoFloatingController;
  late Animation<Offset> _logoFloatingAnimation;

  // Game Loop
  late Ticker _ticker;
  final math.Random _random = math.Random();
  double _time = 0;

  // Objects
  final List<Bubble> _bubbles = [];
  final List<SplashParticle> _particles = [];

  // Colors
  final List<Color> _bubbleColors = [
    AppColors.settingPink,
    const Color(0xFFFECFEF),
    const Color(0xFF96E6A1),
    AppColors.settingGreen,
    const Color(0xFFFFD1FF),
    AppColors.settingPurple,
    const Color(0xFFA18CD1),
    const Color(0xFFFAD0C4),
  ];

  @override
  void initState() {
    super.initState();

    // Animations
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _btnScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));
    _btnController.repeat(reverse: true);

    _logoFloatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _logoFloatingAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.03),
        ).animate(
          CurvedAnimation(
            parent: _logoFloatingController,
            curve: Curves.easeInOut,
          ),
        );
    _logoFloatingController.repeat(reverse: true);

    // Loop
    _ticker = createTicker((elapsed) {
      _updateGameLoop(elapsed.inMilliseconds / 1000.0);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _btnController.dispose();
    _logoFloatingController.dispose();
    super.dispose();
  }

  // Logic
  void _updateGameLoop(double dt) {
    if (!mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      _time += 0.005;

      // Update Bubbles
      if (_bubbles.length < 15 && _random.nextDouble() < 0.02) {
        _bubbles.add(
          Bubble(
            id:
                DateTime.now().toIso8601String() +
                _random.nextInt(9999).toString(),
            x: _random.nextDouble(),
            y: 1.1,
            size: _random.nextDouble() * 40 + 40,
            speed: _random.nextDouble() * 0.0015 + 0.0005,
            color: _bubbleColors[_random.nextInt(_bubbleColors.length)]
                .withOpacity(0.5),
            swayOffset: _random.nextDouble() * 2 * math.pi,
            dirX: (_random.nextDouble() - 0.5) * 0.0005,
          ),
        );
      }

      for (var i = _bubbles.length - 1; i >= 0; i--) {
        final b = _bubbles[i];
        b.y -= b.speed;
        b.x += math.sin(_time * 1.5 + b.swayOffset) * 0.0005 + b.dirX;
        if (b.y < -0.15) _bubbles.removeAt(i);
      }

      // Update Particles
      for (var i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.5;
        p.opacity -= 0.03;
        p.size *= 0.95;

        if (p.opacity <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  // Spawn Splash
  void _spawnSplash(double x, double y, Color color) {
    int particleCount = 8 + _random.nextInt(5);
    for (int i = 0; i < particleCount; i++) {
      double angle = _random.nextDouble() * 2 * math.pi;
      double speed = _random.nextDouble() * 5 + 2;

      _particles.add(
        SplashParticle(
          id: DateTime.now().microsecondsSinceEpoch.toString() + i.toString(),
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: _random.nextDouble() * 10 + 5,
          color: color.withOpacity(0.8),
        ),
      );
    }
  }

  // Pop Bubble
  void _popBubble(Bubble b, double screenWidth, double screenHeight) {
    AudioManager().playSfx('bubble-pop.mp3');
    HapticFeedback.lightImpact();

    double bubblePixelX = b.x * screenWidth + (b.size / 2);
    double bubblePixelY = b.y * screenHeight + (b.size / 2);

    _spawnSplash(bubblePixelX, bubblePixelY, b.color);

    setState(() {
      _bubbles.removeWhere((item) => item.id == b.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient BG
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgCyan, AppColors.bgBlue, AppColors.bgPurple],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Bubbles Layer
              ..._bubbles.map((b) {
                return Positioned(
                  key: ValueKey(b.id),
                  left: b.x * screenWidth,
                  top: b.y * screenHeight,
                  child: GestureDetector(
                    onTap: () => _popBubble(b, screenWidth, screenHeight),
                    child: Container(
                      width: b.size,
                      height: b.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b.color,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: b.color.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: b.size * 0.2,
                            left: b.size * 0.2,
                            child: Container(
                              width: b.size * 0.2,
                              height: b.size * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Particles Layer
              ..._particles.map((p) {
                return Positioned(
                  key: ValueKey(p.id),
                  left: p.x,
                  top: p.y,
                  child: Opacity(
                    opacity: p.opacity < 0 ? 0 : p.opacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.color,
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Settings Button
              Positioned(top: 16, left: 16, child: _buildSettingsButton()),

              // Center Content
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      SlideTransition(
                        position: _logoFloatingAnimation,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 60,
                                  spreadRadius: -10,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo_sementara1.png',
                              height: screenHeight * 0.70,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Play Button
                      ScaleTransition(
                        scale: _btnScaleAnimation,
                        child: GestureDetector(
                          onTap: () {
                            AudioManager().playSfx('bubble-pop.mp3');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HomeMiniGamesScreen(),
                              ),
                            );
                          },
                          child: _buildColorfulButton(screenHeight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        AudioManager().playSfx('bubble-pop.mp3');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0.5, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(scale: value, child: const Settings());
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings_rounded,
          color: AppColors.bgBlue,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildColorfulButton(double screenHeight) {
    double btnHeight = screenHeight * 0.14;
    double btnWidth = btnHeight * 4.2;

    return Container(
      width: btnWidth,
      height: btnHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        // Shadow
        boxShadow: [
          BoxShadow(
            color: AppColors.btnBlueMain.withOpacity(0.4),
            offset: const Offset(0, 12),
            blurRadius: 25,
            spreadRadius: -3,
          ),
        ],
        // Border
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
        // Gradient
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.btnCyanLight, AppColors.btnBlueMain],
        ),
      ),

      child: Stack(
        children: [
          // Inner Shadow
          Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),

          // Wet Highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: btnHeight * 0.5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(45),
                  bottom: Radius.elliptical(100, 25),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: btnHeight * 0.55,
                ),
                SizedBox(width: btnWidth * 0.04),
                Text(
                  "PLAY NOW",
                  style: GoogleFonts.fredoka(
                    fontSize: btnHeight * 0.35,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
