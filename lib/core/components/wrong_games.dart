import 'dart:math';
import 'package:edukids_app/core/audio/audio_manager.dart';
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
    AudioManager().playSfx('wrong.mp3');
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
                // Ribbon Tails (Back)
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
                          color: Colors.red.withOpacity(0.3),
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
                                  icon: Icons.close_rounded,
                                  color: Colors.redAccent.withOpacity(0.2),
                                  size: 30 * scale,
                                  rotate: -0.2,
                                ),
                                _buildAccent(
                                  top: 50 * scale,
                                  right: -10 * scale,
                                  icon: Icons.warning_rounded,
                                  color: Colors.orange.withOpacity(0.3),
                                  size: 40 * scale,
                                  rotate: 0.3,
                                ),
                                _buildAccent(
                                  top: 80 * scale,
                                  left: 50 * scale,
                                  icon: Icons.circle,
                                  color: Colors.grey.withOpacity(0.4),
                                  size: 10 * scale,
                                ),
                                _buildAccent(
                                  top: 110 * scale,
                                  right: 30 * scale,
                                  icon: Icons.change_history,
                                  color: Colors.red.withOpacity(0.5),
                                  size: 20 * scale,
                                  rotate: 1.0,
                                ),
                                _buildAccent(
                                  top: 120 * scale,
                                  left: -15 * scale,
                                  icon: Icons.bolt_rounded,
                                  color: Colors.yellow.withOpacity(0.5),
                                  size: 50 * scale,
                                  rotate: -0.5,
                                ),
                                _buildAccent(
                                  bottom: 50 * scale,
                                  left: -5 * scale,
                                  icon: Icons.circle_outlined,
                                  color: Colors.redAccent,
                                  size: 35 * scale,
                                  rotate: 0.1,
                                ),
                                _buildAccent(
                                  bottom: 40 * scale,
                                  right: 10 * scale,
                                  icon: Icons.square_rounded,
                                  color: Colors.orangeAccent,
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
                                  "Wrong Answer",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 28 * scale,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                SizedBox(height: 10 * scale),
                                Text(
                                  "Don't give up!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 20 * scale,
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
                                colors: [Color(0xFFE53935), Color(0xFFFF5252)],
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
                              "OOPS!",
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

                // Floating Icon (X Mark)
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
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 50 * scale,
                                  spreadRadius: 10 * scale,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.cancel_rounded,
                            size: 130 * scale,
                            color: const Color(0xFFD32F2F),
                            shadows: [
                              Shadow(
                                color: Colors.black26,
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
                  bottom: -25 * scale,
                  child: ScaleTransition(
                    scale: _dialogScale,
                    child: GestureDetector(
                      onTap: widget.onRetryPressed,
                      child: Container(
                        width: cardWidth * 0.7,
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gameSkyBlue, Colors.blueAccent],
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
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 15 * scale,
                              offset: Offset(0, 8 * scale),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "TRY AGAIN",
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

  Widget _buildRibbonFold(bool isLeft, double scale) {
    return ClipPath(
      clipper: SimpleTriangleClipper(isLeft),
      child: Container(
        width: 10 * scale,
        height: 10 * scale,
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
