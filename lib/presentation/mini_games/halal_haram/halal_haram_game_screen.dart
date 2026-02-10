import 'dart:math';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/components/wrong_games.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/constant/sizes.dart';

class HalalHaramGameScreen extends StatefulWidget {
  const HalalHaramGameScreen({super.key});

  @override
  State<HalalHaramGameScreen> createState() => _HalalHaramGameScreenState();
}

class _HalalHaramGameScreenState extends State<HalalHaramGameScreen> {
  late ConfettiController _confettiController;
  int currentIndex = 0;
  int score = 0;
  bool isGameOver = false;

  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Fried Chicken',
      'image': 'assets/images/chicken.png',
      'isHalal': true,
    },
    {
      'name': 'Alcohol / Wine',
      'image': 'assets/images/wine.png',
      'isHalal': false,
    },
    {'name': 'Cow Milk', 'image': 'assets/images/milk.png', 'isHalal': true},
    {'name': 'Snake', 'image': 'assets/images/snake.png', 'isHalal': false},
    {'name': 'Fish', 'image': 'assets/images/fish.png', 'isHalal': true},
    {
      'name': 'Fresh Apple',
      'image': 'assets/images/apple.png',
      'isHalal': true,
    },
    {
      'name': 'Pork / Bacon',
      'image': 'assets/images/pork.png',
      'isHalal': false,
    },
    {'name': 'Beer', 'image': 'assets/images/beer.png', 'isHalal': false},
    {'name': 'Honey', 'image': 'assets/images/honey.png', 'isHalal': true},
    {'name': 'date fruit', 'image': 'assets/images/kurma.png', 'isHalal': true},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    AudioManager().playBgm('bgm_halal.mp3');
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _confettiController.dispose();
    super.dispose();
  }

  void _handleCorrectDrop() {
    AudioManager().playSfx('correct.mp3');
    HapticFeedback.lightImpact();

    setState(() {
      score += 10;
      if (currentIndex < _foodItems.length - 1) {
        currentIndex++;
      } else {
        isGameOver = true;
        _showWinDialog();
      }
    });
  }

  void _handleWrongDrop() {
    AudioManager().playSfx('wrong.mp3');
    HapticFeedback.heavyImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Wrong",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return WrongGames(onRetryPressed: () => Navigator.of(context).pop());
      },
    );
  }

  void _showWinDialog() {
    AudioManager().playSfx('win.mp3');
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinGames(
        isLastLevel: true,
        confettiController: _confettiController,
        onActionPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return Scaffold(
      backgroundColor: AppColors.gameYellow,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                "assets/images/bg_halal_haram.jpeg",
                repeat: ImageRepeat.repeat,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double w = constraints.maxWidth;
                double h = constraints.maxHeight;

                double headerH = max(h * 0.1, 70.0);
                double binsH = max(h * 0.25, 140.0);
                double availableForCard = h - headerH - binsH;

                return Column(
                  children: [
                    SizedBox(height: headerH, child: _buildHeader()),
                    Expanded(
                      child: Center(
                        child: isGameOver
                            ? const SizedBox()
                            : _buildDraggableItem(
                                min(w * 0.6, availableForCard),
                              ),
                      ),
                    ),
                    SizedBox(height: binsH, child: _buildBinsArea(w, binsH)),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back,
                color: AppColors.gameYellow,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halal or Haram?",
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Drag The Food!",
                  style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          _scoreBadge("$score", Icons.star_rounded, Colors.white),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(double size) {
    final item = _foodItems[currentIndex];
    return Draggable<bool>(
      data: item['isHalal'],
      onDragStarted: () => AudioManager().playSfx('bubble-pop.mp3'),
      feedback: Transform.scale(scale: 1.1, child: _foodCard(item, size)),
      childWhenDragging: Opacity(opacity: 0.0, child: _foodCard(item, size)),
      child: _foodCard(item, size),
    );
  }

  Widget _foodCard(Map<String, dynamic> item, double size) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(item['image'], fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBinsArea(double screenWidth, double areaHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBinDropZone(
          "HALAL",
          "assets/images/keranjang.png",
          true,
          screenWidth * 0.4,
          areaHeight,
        ),
        _buildBinDropZone(
          "HARAM",
          "assets/images/trash_red.png",
          false,
          screenWidth * 0.4,
          areaHeight,
        ),
      ],
    );
  }

  Widget _buildBinDropZone(
    String label,
    String asset,
    bool accepts,
    double width,
    double height,
  ) {
    return DragTarget<bool>(
      onAccept: (data) =>
          data == accepts ? _handleCorrectDrop() : _handleWrongDrop(),
      builder: (context, candidate, rejected) {
        bool hovering = candidate.isNotEmpty;
        return AnimatedScale(
          scale: hovering ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width > 200 ? 24 : 18,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 7)],
                ),
              ),
              Image.asset(
                asset,
                width: width,
                height: height * 0.75,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _scoreBadge(String val, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(width: 8),
        Text(
          val,
          style: GoogleFonts.fredoka(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
