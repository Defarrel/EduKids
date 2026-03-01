import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';

class FinishGames extends StatefulWidget {
  final ConfettiController confettiController;
  final VoidCallback onMainMenuPressed;

  const FinishGames({
    super.key,
    required this.confettiController,
    required this.onMainMenuPressed,
  });

  @override
  State<FinishGames> createState() => _FinishGamesState();
}

class _FinishGamesState extends State<FinishGames>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _dialogScale;
  late Animation<double> _iconScale;
  late Animation<double> _star1Scale;
  late Animation<double> _star2Scale;
  late Animation<double> _star3Scale;
  late Animation<double> _accentPulse;

  @override
  void initState() {
    super.initState();
    AudioManager().playSfx('finish_sfx.mp3');
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

    _iconScale = CurvedAnimation(
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
        double cardHeight = min(constraints.maxHeight * 0.35, 260.0);
        if (cardHeight < 190) cardHeight = 190;

        double scale = cardHeight / 260.0;
        double cardWidth = min(
          constraints.maxWidth * 0.85,
          320.0 * (scale > 1 ? 1 : scale + 0.1),
        );

        return Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Ribbon Tails
                Positioned(
                  top: 25 * scale,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: SizedBox(
                      width: cardWidth + (50 * scale),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRibbonTail(true, scale),
                          _buildRibbonTail(false, scale),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Card
                ScaleTransition(
                  scale: _dialogScale,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35 * scale),
                      border: Border.all(color: Colors.white, width: 4 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 40 * scale,
                          offset: Offset(0, 20 * scale),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background Accents
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(31 * scale),
                            child: Stack(
                              children: [
                                _buildAccent(
                                  top: 60 * scale,
                                  left: 10 * scale,
                                  icon: Icons.celebration_rounded,
                                  color: Colors.orange,
                                  size: 30 * scale,
                                  rotate: -0.2,
                                ),
                                _buildAccent(
                                  top: 50 * scale,
                                  right: -10 * scale,
                                  icon: Icons.favorite_rounded,
                                  color: Colors.teal.withOpacity(0.3),
                                  size: 40 * scale,
                                  rotate: 0.3,
                                ),
                                _buildAccent(
                                  top: 80 * scale,
                                  left: 50 * scale,
                                  icon: Icons.circle,
                                  color: Colors.lightBlue.withOpacity(0.4),
                                  size: 10 * scale,
                                ),
                                _buildAccent(
                                  top: 110 * scale,
                                  right: 30 * scale,
                                  icon: Icons.change_history,
                                  color: Colors.green.withOpacity(0.5),
                                  size: 20 * scale,
                                  rotate: 1.0,
                                ),
                                _buildAccent(
                                  top: 120 * scale,
                                  left: -15 * scale,
                                  icon: Icons.bolt_rounded,
                                  color: Colors.amber.withOpacity(0.5),
                                  size: 50 * scale,
                                  rotate: -0.5,
                                ),
                                _buildAccent(
                                  bottom: 50 * scale,
                                  left: -5 * scale,
                                  icon: Icons.circle_outlined,
                                  color: Colors.teal,
                                  size: 35 * scale,
                                  rotate: 0.1,
                                ),
                                _buildAccent(
                                  bottom: 40 * scale,
                                  right: 10 * scale,
                                  icon: Icons.square_rounded,
                                  color: Colors.indigoAccent,
                                  size: 20 * scale,
                                  rotate: 0.8,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20 * scale,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 50 * scale),
                                Text(
                                  "All Levels Done!".tr(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22 * scale,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                SizedBox(height: 15 * scale),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStar(_star1Scale, 45 * scale, -0.2),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 20 * scale,
                                      ),
                                      child: _buildStar(
                                        _star2Scale,
                                        60 * scale,
                                        0,
                                      ),
                                    ),
                                    _buildStar(_star3Scale, 45 * scale, 0.2),
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

                // Ribbon Front
                Positioned(
                  top: -15 * scale,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: SizedBox(
                      width: cardWidth + (20 * scale),
                      height: 60 * scale,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: cardWidth + (20 * scale),
                            padding: EdgeInsets.symmetric(vertical: 10 * scale),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10 * scale),
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
                              "CONGRATS!".tr(),
                              style: GoogleFonts.fredoka(
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0 * scale,
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
                            bottom: -8 * scale,
                            left: 0,
                            child: _buildRibbonFold(true, scale),
                          ),
                          Positioned(
                            bottom: -8 * scale,
                            right: 0,
                            child: _buildRibbonFold(false, scale),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Medal Icon
                Positioned(
                  top: -125 * scale,
                  child: ScaleTransition(
                    scale: _iconScale,
                    child: SizedBox(
                      width: 140 * scale,
                      height: 140 * scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100 * scale,
                            height: 100 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.5),
                                  blurRadius: 50 * scale,
                                  spreadRadius: 10 * scale,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 130 * scale,
                            color: const Color(0xFFFFD700),
                            shadows: [
                              Shadow(
                                color: Colors.deepOrange,
                                blurRadius: 0,
                                offset: Offset(0, 5 * scale),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 35 * scale,
                            right: 35 * scale,
                            child: Container(
                              width: 18 * scale,
                              height: 18 * scale,
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

                // Main Menu Button
                Positioned(
                  bottom: -25 * scale,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: GestureDetector(
                      onTap: widget.onMainMenuPressed,
                      child: Container(
                        width: cardWidth * 0.7,
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrangeAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(50 * scale),
                          border: Border.all(
                            color: Colors.white,
                            width: 3 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.5),
                              blurRadius: 15 * scale,
                              offset: Offset(0, 8 * scale),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "MAIN MENU".tr(),
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5 * scale,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Confetti
                Positioned(
                  top: -220 * scale,
                  child: ConfettiWidget(
                    confettiController: widget.confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.teal,
                      Colors.orange,
                      Colors.yellow,
                      Colors.purpleAccent,
                      Colors.blue,
                      Colors.redAccent,
                    ],
                    gravity: 0.3,
                    numberOfParticles: 50,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helpers
  Widget _buildRibbonTail(bool isLeft, double scale) {
    return Transform.rotate(
      angle: isLeft ? -0.2 : 0.2,
      child: ClipPath(
        clipper: RibbonTailClipper(),
        child: Container(
          width: 50 * scale,
          height: 60 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFF004D40),
            gradient: LinearGradient(
              colors: [const Color(0xFF004D40), const Color(0xFF00695C)],
              begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRibbonFold(bool isLeft, double scale) => ClipPath(
    clipper: SimpleTriangleClipper(isLeft),
    child: Container(
      width: 10 * scale,
      height: 10 * scale,
      color: const Color(0xFF00332C),
    ),
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
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 20 * (size / 60),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: size,
            shadows: [
              Shadow(
                color: Colors.deepOrange,
                blurRadius: 0,
                offset: Offset(0, 4 * (size / 60)),
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

// Clippers
class RibbonTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height - (size.height * 0.25));
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
