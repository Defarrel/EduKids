import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class FinishGames extends StatelessWidget {
  final ConfettiController confettiController;
  final VoidCallback onMainMenuPressed;

  const FinishGames({
    super.key,
    required this.confettiController,
    required this.onMainMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        ScaleTransition(
          scale: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.elasticOut,
          ),
          child: SizedBox(
            width: 320,
            height: 380,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Blue Board
                Positioned(
                  top: 80,
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Text(
                          "All Levels Done!",
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "You are Amazing!",
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Green Ribbon
                Positioned(
                  top: 60,
                  child: SizedBox(
                    width: 320,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 65,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1B5E20),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "ALHAMDULILLAH",
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: [
                                const Shadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Decorative elements for ribbon
                        Positioned(
                          left: 20,
                          bottom: 8,
                          child: Transform.rotate(
                            angle: 0.8,
                            child: Container(
                              width: 20,
                              height: 20,
                              color: const Color(0xFF004D40),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: 8,
                          child: Transform.rotate(
                            angle: 0.8,
                            child: Container(
                              width: 20,
                              height: 20,
                              color: const Color(0xFF004D40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Medal Icon
                Positioned(
                  top: 0,
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
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.verified_rounded,
                        size: 90,
                        color: Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),
                // Main Menu Button
                Positioned(
                  bottom: 70,
                  child: GestureDetector(
                    onTap: onMainMenuPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF880E4F),
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        "MAIN MENU",
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            numberOfParticles: 50,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}
