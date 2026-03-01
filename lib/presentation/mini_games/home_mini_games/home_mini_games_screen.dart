import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:edukids_app/presentation/mini_games/alphabet_sort/alphabet_sort_screen.dart';
import 'package:edukids_app/presentation/mini_games/halal_haram/halal_haram_game_screen.dart';
import 'package:edukids_app/presentation/mini_games/learn_to_draw/learn_to_draw_menu_screen.dart';
import 'package:edukids_app/presentation/mini_games/true_and_false/true_false_screen.dart';
import 'package:edukids_app/presentation/mini_games/which_is_right/which_is_right_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:edukids_app/presentation/mini_games/puzzle/islamic_puzzle_screen.dart';

class HomeMiniGamesScreen extends StatefulWidget {
  const HomeMiniGamesScreen({super.key});

  @override
  State<HomeMiniGamesScreen> createState() => _HomeMiniGamesScreenState();
}

class _HomeMiniGamesScreenState extends State<HomeMiniGamesScreen> {
  // Data Game
  final List<Map<String, dynamic>> _games = [
    {
      "title": "Islamic\nPuzzle",
      "color": AppColors.gameSkyBlue,
      "icon": Icons.extension_rounded,
      "route": "/game-puzzle",
      "image": "assets/images/bg_puzzle.jpeg",
    },
    {
      "title": "True or\nFalse",
      "color": AppColors.gamePink,
      "icon": Icons.check_circle_rounded,
      "route": "/game-true-false",
      "image": "assets/images/bg_menu_true.jpeg",
    },
    {
      "title": "Halal\nHaram",
      "color": AppColors.gameYellow,
      "icon": Icons.checklist_rtl_rounded,
      "route": "/halal-hara,",
      "image": "assets/images/bg_menu_halal.jpeg",
    },
    {
      "title": "Learn to\nDraw",
      "color": AppColors.gameGreen,
      "icon": Icons.brush_rounded,
      "route": "/game-drawing",
      "image": "assets/images/bg_menu_learn.jpeg",
    },
    {
      "title": "Alphabet\nSort",
      "color": AppColors.gamePurple,
      "icon": Icons.sort_by_alpha_rounded,
      "route": "/game-sorting",
      "image": "assets/images/bg_alphabet.jpeg",
    },
    {
      "title": "Which is\nRight?",
      "color": AppColors.gameRed,
      "icon": Icons.question_mark_rounded,
      "route": "/game-right-wrong",
      "image": "assets/images/bg_menu_which.jpeg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    const double itemAspectRatio = 1.3;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF66BB6A), Color(0xFF43A047), Color(0xFF2E7D32)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1, // Transparan agar subtle
                child: CustomPaint(painter: IslamicPatternPainter()),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.paddingMedium(),
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _buildCompactBubbleBackButton(context),
                        const SizedBox(width: 12),
                        Text(
                          "Mini Games".tr(), // <-- Ditambahkan .tr()
                          style: GoogleFonts.fredoka(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Game Grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        AppSize.paddingMedium(),
                        10,
                        AppSize.paddingMedium(),
                        20,
                      ),
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: itemAspectRatio,
                          ),
                      itemCount: _games.length,
                      itemBuilder: (context, index) {
                        final game = _games[index];
                        return _BubbleGameCard(index: index, gameData: game);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBubbleBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        AudioManager().playSfx('bubble-pop.mp3');
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF2E7D32),
          size: 24,
        ),
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double patternSize = 60.0;

    for (double y = 0; y < size.height; y += patternSize) {
      for (double x = 0; x < size.width; x += patternSize) {
        Path path = Path();

        double cx = x + patternSize / 2;
        double cy = y + patternSize / 2;
        double r = patternSize / 2.5;

        path.moveTo(cx, cy - r);
        path.lineTo(cx + r, cy);
        path.lineTo(cx, cy + r);
        path.lineTo(cx - r, cy);
        path.close();

        double rSmall = r * 0.7;
        path.moveTo(cx - rSmall, cy - rSmall);
        path.lineTo(cx + rSmall, cy - rSmall);
        path.lineTo(cx + rSmall, cy + rSmall);
        path.lineTo(cx - rSmall, cy + rSmall);
        path.close();

        canvas.drawCircle(Offset(cx, cy), 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _BubbleGameCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> gameData;

  const _BubbleGameCard({required this.index, required this.gameData});

  @override
  State<_BubbleGameCard> createState() => _BubbleGameCardState();
}

class _BubbleGameCardState extends State<_BubbleGameCard> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Game is under development, please wait!"
              .tr(), // <-- Diubah dan ditambahkan .tr()
          style: GoogleFonts.fredoka(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.gameData['color'] as Color;
    final String title = widget.gameData['title'];
    final String imagePath =
        widget.gameData['image'] ?? "assets/images/bg_puzzle.jpeg";

    return LayoutBuilder(
      builder: (context, constraints) {
        double h = constraints.maxHeight;

        double iconSize = h * 0.15;
        double fontSize = h * 0.12;

        return AnimatedScale(
          scale: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              AudioManager().playSfx('bubble-pop.mp3');

              if (title.contains("Puzzle")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IslamicPuzzleScreen(),
                  ),
                );
              } else if (title.contains("Alphabet")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetSortScreen(),
                  ),
                );
              } else if (title.contains("True")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrueFalseScreen(),
                  ),
                );
              } else if (title.contains("Learn")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LearnToDrawMenuScreen(),
                  ),
                );
              } else if (title.contains("Which")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhichIsRightScreen(),
                  ),
                );
              } else if (title.contains("Halal")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalalHaramGameScreen(),
                  ),
                );
              } else {
                _showComingSoon();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: color.withOpacity(0.5)),
                      ),
                    ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Bottom Panel
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          border: const Border(
                            top: BorderSide(color: Colors.white24, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon Game
                            Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                widget.gameData['icon'],
                                size: iconSize,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Judul Game
                            Flexible(
                              child: Text(
                                title.tr().replaceAll(
                                  "\n",
                                  " ",
                                ), // <-- Ditambahkan .tr() SEBELUM .replaceAll
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
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
          ),
        );
      },
    );
  }
}
