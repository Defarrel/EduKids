import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class WinGames extends StatelessWidget {
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
                // Board
                Positioned(
                  top: 80,
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B61FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Text(
                          "Level Completed!",
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.star, color: Colors.orange, size: 30),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 40,
                              ),
                            ),
                            Icon(Icons.star, color: Colors.orange, size: 30),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Ribbon
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
                              colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFB71C1C),
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
                            "MASYAALLAH",
                            style: GoogleFonts.fredoka(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                const Shadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black38,
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 8,
                          child: Transform.rotate(
                            angle: 0.8,
                            child: Container(
                              width: 20,
                              height: 20,
                              color: const Color(0xFF880E4F),
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
                              color: const Color(0xFF880E4F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Trophy
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
                              color: Colors.yellow.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 90,
                        color: Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),
                // Button
                Positioned(
                  bottom: 70,
                  child: GestureDetector(
                    onTap: onActionPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFE65100),
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        isLastLevel ? "FINISH" : "NEXT",
                        style: GoogleFonts.fredoka(
                          color: const Color(0xFFBF360C),
                          fontSize: 24,
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
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.3,
            minBlastForce: 10,
            maxBlastForce: 30,
          ),
        ),
      ],
    );
  }
}
