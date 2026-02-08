import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/constant/colors.dart';

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
                // Ribbon Tails
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

                // Main Card
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
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background Accents
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(31),
                            child: Stack(
                              children: [
                                _buildAccent(
                                  top: 60,
                                  left: 10,
                                  icon: Icons.celebration_rounded,
                                  color: Colors.orange,
                                  size: 30,
                                  rotate: -0.2,
                                ),
                                _buildAccent(
                                  top: 50,
                                  right: -10,
                                  icon: Icons.favorite_rounded,
                                  color: Colors.teal.withOpacity(0.3),
                                  size: 40,
                                  rotate: 0.3,
                                ),
                                _buildAccent(
                                  top: 80,
                                  left: 50,
                                  icon: Icons.circle,
                                  color: Colors.lightBlue.withOpacity(0.4),
                                  size: 10,
                                ),
                                _buildAccent(
                                  top: 110,
                                  right: 30,
                                  icon: Icons.change_history,
                                  color: Colors.green.withOpacity(0.5),
                                  size: 20,
                                  rotate: 1.0,
                                ),
                                _buildAccent(
                                  top: 120,
                                  left: -15,
                                  icon: Icons.bolt_rounded,
                                  color: Colors.amber.withOpacity(0.5),
                                  size: 50,
                                  rotate: -0.5,
                                ),
                                _buildAccent(
                                  bottom: 50,
                                  left: -5,
                                  icon: Icons.circle_outlined,
                                  color: Colors.teal,
                                  size: 35,
                                  rotate: 0.1,
                                ),
                                _buildAccent(
                                  bottom: 40,
                                  right: 10,
                                  icon: Icons.square_rounded,
                                  color: Colors.indigoAccent,
                                  size: 20,
                                  rotate: 0.8,
                                ),
                                _buildAccent(
                                  bottom: 20,
                                  left: 30,
                                  icon: Icons.diamond_outlined,
                                  color: Colors.purple.withOpacity(0.5),
                                  size: 25,
                                  rotate: 0.4,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 50),

                                Text(
                                  "All Levels Done!",
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

                // Ribbon Front
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
                          // Banner
                          Container(
                            width: cardWidth + 20,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
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
                              "CONGRATS!",
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

                          // Folds
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

                // Medal Icon
                Positioned(
                  top: -125,
                  child: ScaleTransition(
                    scale: _iconScale,
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
                                  color: Colors.purpleAccent.withOpacity(0.5),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 130,
                            color: Color(0xFFFFD700),
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

                // Main Menu Button
                Positioned(
                  bottom: -25,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: GestureDetector(
                      onTap: widget.onMainMenuPressed,
                      child: Container(
                        width: cardWidth * 0.7,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrangeAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "MAIN MENU",
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 20,
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

                // Confetti
                Positioned(
                  top: -220,
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

  // Helpers

  Widget _buildRibbonTail(bool isLeft) {
    return Transform.rotate(
      angle: isLeft ? -0.2 : 0.2,
      child: ClipPath(
        clipper: RibbonTailClipper(),
        child: Container(
          width: 50,
          height: 60,
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

  Widget _buildRibbonFold(bool isLeft) {
    return ClipPath(
      clipper: SimpleTriangleClipper(isLeft),
      child: Container(width: 10, height: 10, color: const Color(0xFF00332C)),
    );
  }

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
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            color: Colors.amber,
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

// Clippers

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
