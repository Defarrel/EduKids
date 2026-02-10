import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';

class WinGames extends StatefulWidget {
  final bool isLastLevel;
  final ConfettiController confettiController;
  final VoidCallback onActionPressed;

  const WinGames({
    super.key,
    required this.isLastLevel,
    required this.confettiController,
    required this.onActionPressed,
  });

  @override
  State<WinGames> createState() => _WinGamesState();
}

class _WinGamesState extends State<WinGames> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _dialogScale;
  late Animation<double> _trophyScale;
  late Animation<double> _star1Scale;
  late Animation<double> _star2Scale;
  late Animation<double> _star3Scale;
  late Animation<double> _accentPulse;

  @override
  void initState() {
    super.initState();
    AudioManager().playSfx('win_sfx.mp3'); 
    widget.confettiController.stop(); 
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.confettiController.play();
      }
    });

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dialogScale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _trophyScale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
    );

    _star1Scale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 0.7, curve: Curves.bounceOut),
    );
    _star2Scale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 0.8, curve: Curves.bounceOut),
    );
    _star3Scale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 0.9, curve: Curves.bounceOut),
    );

    _accentPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = min(constraints.maxWidth * 0.85, 320.0);
        double cardHeight = 260;

        return Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 25,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: SizedBox(
                      width: cardWidth + 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRibbonTail(true),
                          _buildRibbonTail(false),
                        ],
                      ),
                    ),
                  ),
                ),
                ScaleTransition(
                  scale: _dialogScale,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gamePurple.withOpacity(0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(31),
                            child: Stack(
                              children: [
                                _buildAccent(
                                  top: 60,
                                  left: 10,
                                  icon: Icons.star_rounded,
                                  color: AppColors.gameYellow,
                                  size: 30,
                                  rotate: -0.2,
                                ),
                                _buildAccent(
                                  top: 50,
                                  right: -10,
                                  icon: Icons.favorite_rounded,
                                  color: AppColors.gamePink.withOpacity(0.3),
                                  size: 40,
                                  rotate: 0.3,
                                ),
                                _buildAccent(
                                  top: 80,
                                  left: 50,
                                  icon: Icons.circle,
                                  color: AppColors.gameSkyBlue.withOpacity(0.4),
                                  size: 10,
                                ),
                                _buildAccent(
                                  top: 110,
                                  right: 30,
                                  icon: Icons.change_history,
                                  color: AppColors.gameGreen.withOpacity(0.5),
                                  size: 20,
                                  rotate: 1.0,
                                ),
                                _buildAccent(
                                  top: 120,
                                  left: -15,
                                  icon: Icons.bolt_rounded,
                                  color: AppColors.gameYellow.withOpacity(0.5),
                                  size: 50,
                                  rotate: -0.5,
                                ),
                                _buildAccent(
                                  top: 130,
                                  right: -5,
                                  icon: Icons.star_rate_rounded,
                                  color: AppColors.gamePurple.withOpacity(0.4),
                                  size: 35,
                                  rotate: 0.2,
                                ),
                                _buildAccent(
                                  bottom: 50,
                                  left: -5,
                                  icon: Icons.circle_outlined,
                                  color: AppColors.gameSkyBlue,
                                  size: 35,
                                  rotate: 0.1,
                                ),
                                _buildAccent(
                                  bottom: 40,
                                  right: 10,
                                  icon: Icons.square_rounded,
                                  color: AppColors.gameGreen,
                                  size: 20,
                                  rotate: 0.8,
                                ),
                                _buildAccent(
                                  bottom: 70,
                                  right: 50,
                                  icon: Icons.star_border_rounded,
                                  color: AppColors.gameYellow,
                                  size: 18,
                                  rotate: -0.1,
                                ),
                                _buildAccent(
                                  bottom: 20,
                                  left: 30,
                                  icon: Icons.diamond_outlined,
                                  color: AppColors.gamePurple.withOpacity(0.5),
                                  size: 25,
                                  rotate: 0.4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 50),
                                Text(
                                  "Level Completed!",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStar(_star1Scale, 45, -0.2),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: _buildStar(_star2Scale, 60, 0),
                                    ),
                                    _buildStar(_star3Scale, 45, 0.2),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -15,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: SizedBox(
                      width: cardWidth + 20,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: cardWidth + 20,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gamePink, Color(0xFFFF80AB)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "MASYAALLAH",
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                decoration: TextDecoration.none,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -8,
                            left: 0,
                            child: _buildRibbonFold(true),
                          ),
                          Positioned(
                            bottom: -8,
                            right: 0,
                            child: _buildRibbonFold(false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -125,
                  child: ScaleTransition(
                    scale: _trophyScale,
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.5),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.emoji_events_rounded,
                            size: 130,
                            color: AppColors.gameYellow,
                            shadows: [
                              Shadow(
                                color: Colors.deepOrange,
                                blurRadius: 0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 35,
                            right: 35,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -25,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: GestureDetector(
                      onTap: widget.onActionPressed,
                      child: Container(
                        width: cardWidth * 0.7,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.btnCyanLight,
                              AppColors.btnBlueMain,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.btnBlueMain.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.isLastLevel ? "FINISH" : "NEXT",
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            decoration: TextDecoration.none,
                            shadows: [
                              const Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -220,
                  child: ConfettiWidget(
                    confettiController: widget.confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      AppColors.gameGreen,
                      AppColors.gamePink,
                      AppColors.gameYellow,
                      AppColors.gameSkyBlue,
                      Colors.orange,
                      Colors.purpleAccent,
                    ],
                    gravity: 0.3,
                    numberOfParticles: 50,
                    minBlastForce: 20,
                    maxBlastForce: 60,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRibbonTail(bool isLeft) {
    return Transform.rotate(
      angle: isLeft ? -0.2 : 0.2,
      child: ClipPath(
        clipper: RibbonTailClipper(),
        child: Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFAD1457),
            gradient: LinearGradient(
              colors: [const Color(0xFF880E4F), const Color(0xFFAD1457)],
              begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRibbonFold(bool isLeft) => ClipPath(
    clipper: SimpleTriangleClipper(isLeft),
    child: Container(width: 10, height: 10, color: const Color(0xFF6A0D41)),
  );

  Widget _buildStar(Animation<double> animation, double size, double rotate) {
    return ScaleTransition(
      scale: animation,
      child: Transform.rotate(
        angle: rotate,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: AppColors.gameYellow,
            size: size,
            shadows: const [
              Shadow(
                color: Colors.deepOrange,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccent({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required IconData icon,
    required Color color,
    required double size,
    double rotate = 0.0,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ScaleTransition(
        scale: _accentPulse,
        child: Transform.rotate(
          angle: rotate * pi,
          child: Opacity(
            opacity: 0.6,
            child: Icon(icon, color: color, size: size),
          ),
        ),
      ),
    );
  }
}

class RibbonTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height - 15);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SimpleTriangleClipper extends CustomClipper<Path> {
  final bool isLeft;
  SimpleTriangleClipper(this.isLeft);
  @override
  Path getClip(Size size) {
    final path = Path();
    if (isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
