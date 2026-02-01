import 'dart:async';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:edukids_app/presentation/mini_games/puzzle/islamic_puzzle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMiniGamesScreen extends StatefulWidget {
  const HomeMiniGamesScreen({super.key});

  @override
  State<HomeMiniGamesScreen> createState() => _HomeMiniGamesScreenState();
}

class _HomeMiniGamesScreenState extends State<HomeMiniGamesScreen> {
  // Game Data
  final List<Map<String, dynamic>> _games = [
    {
      "title": "Islamic\nPuzzle",
      "color": AppColors.gameSkyBlue,
      "icon": Icons.extension_rounded,
      "route": "/game-puzzle",
    },
    {
      "title": "True or\nFalse",
      "color": AppColors.gamePink,
      "icon": Icons.check_circle_rounded,
      "route": "/game-true-false",
    },
    {
      "title": "Halal\nColoring",
      "color": AppColors.gameYellow,
      "icon": Icons.palette_rounded,
      "route": "/game-coloring",
    },
    {
      "title": "Learn to\nDraw",
      "color": AppColors.gameGreen,
      "icon": Icons.brush_rounded,
      "route": "/game-drawing",
    },
    {
      "title": "Abjad\nSort",
      "color": AppColors.gamePurple,
      "icon": Icons.sort_by_alpha_rounded,
      "route": "/game-sorting",
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    final double itemAspectRatio = 1.4;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.bgCream,
          image: DecorationImage(
            image: AssetImage("assets/images/pattern_bg.png"),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.paddingMedium(),
                    vertical: 0,
                  ),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1 / itemAspectRatio,
                  ),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return _BubbleGameCard(index: index, gameData: game);
                  },
                ),
              ),

              const SizedBox(height: 10),
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

// Bubble Card Widget
// ... (Bagian atas kode HomeMiniGamesScreen biarkan saja, tidak berubah) ...

// GANTI CLASS _BubbleGameCard DENGAN INI:
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

  // Fungsi helper untuk menampilkan pesan jika game belum ada
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
    final String title = widget.gameData['title']; // Ambil judul game

    return AnimatedScale(
      scale: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          AudioManager().playSfx(
            'bubble-pop.mp3',
          ); // Pastikan nama file sound benar

          // --- LOGIKA NAVIGASI DI SINI ---

          // 1. Cek apakah ini Game Islamic Puzzle?
          if (title.contains("Puzzle")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IslamicPuzzleScreen(),
              ),
            );
          }
          // 2. Cek Game True/False (Nanti kalau sudah dibuat screennya)
          else if (title.contains("True")) {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => TrueFalseScreen()));
            _showComingSoon();
          }
          // 3. Cek Game Coloring
          else if (title.contains("Coloring")) {
            _showComingSoon();
          }
          // 4. Default untuk game lain
          else {
            _showComingSoon();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                offset: const Offset(0, 6),
                blurRadius: 10,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glare Effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
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
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.gameData['icon'],
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.1,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
