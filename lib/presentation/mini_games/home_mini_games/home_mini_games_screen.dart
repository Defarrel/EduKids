import 'dart:async';
import 'package:edukids_app/presentation/mini_games/alphabet_sort/alphabet_sort_screen.dart';
import 'package:edukids_app/presentation/mini_games/coloring/halal_coloring_menu_screen.dart';
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
      "image": "assets/images/bg_true_false.jpeg",
    },
    {
      "title": "Halal\nColoring",
      "color": AppColors.gameYellow,
      "icon": Icons.palette_rounded,
      "route": "/game-coloring",
      "image": "assets/images/bg_halal.jpeg",
    },
    {
      "title": "Learn to\nDraw",
      "color": AppColors.gameGreen,
      "icon": Icons.brush_rounded,
      "route": "/game-drawing",
      "image": "assets/images/bg_learn.jpeg",
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
      "image": "assets/images/bg_right.jpeg",
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
            colors: [
              AppColors.btnBlueMain,
              AppColors.bgBlue,
              AppColors.gameSkyBlue,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
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
                      "Mini Games",
                      style: GoogleFonts.fredoka(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        shadows: [
                          const BoxShadow(
                            color: Colors.black12,
                            offset: Offset(1, 1),
                            blurRadius: 1,
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              color: Colors.cyan.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.cyan.shade100, width: 1.5),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.gameSkyBlue,
          size: 20,
        ),
      ),
    );
  }
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
          "Game ini sedang dibuat, tunggu ya!",
          style: GoogleFonts.fredoka(),
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
        widget.gameData['image'] ?? "assets/images/bg_puzzle.png";

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
              } else if (title.contains("Coloring")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalalColoringMenuScreen(),
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
              } else {
                _showComingSoon();
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background
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
                              Colors.black.withOpacity(0.4),
                            ],
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
                          color: Colors.black.withOpacity(0.65),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.gameData['icon'],
                              size: iconSize,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                title.replaceAll("\n", " "),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.1,
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
