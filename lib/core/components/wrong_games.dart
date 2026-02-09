import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/constant/colors.dart';

class WrongGames extends StatefulWidget {
  final VoidCallback onRetryPressed;

  const WrongGames({super.key, required this.onRetryPressed});

  @override
  State<WrongGames> createState() => _WrongGamesState();
}

class _WrongGamesState extends State<WrongGames> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _dialogScale;
  late Animation<double> _iconScale;
  late Animation<double> _accentPulse;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _dialogScale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _iconScale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
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
                // Ribbon Tails (Back)
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
                          color: Colors.red.withOpacity(0.3),
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
                                  icon: Icons.close_rounded,
                                  color: Colors.redAccent.withOpacity(0.2),
                                  size: 30,
                                  rotate: -0.2,
                                ),
                                _buildAccent(
                                  top: 50,
                                  right: -10,
                                  icon: Icons.warning_rounded,
                                  color: Colors.orange.withOpacity(0.3),
                                  size: 40,
                                  rotate: 0.3,
                                ),
                                _buildAccent(
                                  top: 80,
                                  left: 50,
                                  icon: Icons.circle,
                                  color: Colors.grey.withOpacity(0.4),
                                  size: 10,
                                ),
                                _buildAccent(
                                  top: 110,
                                  right: 30,
                                  icon: Icons.change_history,
                                  color: Colors.red.withOpacity(0.5),
                                  size: 20,
                                  rotate: 1.0,
                                ),
                                _buildAccent(
                                  top: 120,
                                  left: -15,
                                  icon: Icons.bolt_rounded,
                                  color: Colors.yellow.withOpacity(0.5),
                                  size: 50,
                                  rotate: -0.5,
                                ),
                                _buildAccent(
                                  bottom: 50,
                                  left: -5,
                                  icon: Icons.circle_outlined,
                                  color: Colors.redAccent,
                                  size: 35,
                                  rotate: 0.1,
                                ),
                                _buildAccent(
                                  bottom: 40,
                                  right: 10,
                                  icon: Icons.square_rounded,
                                  color: Colors.orangeAccent,
                                  size: 20,
                                  rotate: 0.8,
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
                                  "Wrong Answer",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "Don't give up!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
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
                                colors: [
                                  Color(0xFFE53935),
                                  Color(0xFFFF5252),
                                ], // Red Gradient
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
                              "OOPS!",
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

                // Floating Icon (X Mark)
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
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.cancel_rounded,
                            size: 130,
                            color: Color(0xFFD32F2F),
                            shadows: [
                              Shadow(
                                color: Colors.black26,
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
                                color: Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Button
                Positioned(
                  bottom: -25,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: GestureDetector(
                      onTap: widget.onRetryPressed,
                      child: Container(
                        width: cardWidth * 0.7,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gameSkyBlue, Colors.blueAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "TRY AGAIN",
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
            color: const Color(0xFFB71C1C), 
            gradient: LinearGradient(
              colors: [const Color(0xFFB71C1C), const Color(0xFFC62828)],
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
      child: Container(
        width: 10,
        height: 10,
        color: const Color(0xFF8E0000), 
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
