import 'dart:async';
import 'dart:collection';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/components/wrong_games.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    AudioManager().playBgm('puzzle_bgm.mp3');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleCorrectDrop() {
    AudioManager().playSfx('correct.mp3');
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Wrong",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return WrongGames(
          onRetryPressed: () {
            Navigator.of(context).pop();
          },
        );
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
    return Scaffold(
      backgroundColor: AppColors.gameYellow,
      body: Stack(
        children: [
          // Background pattern
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
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInstruction(),
                Expanded(
                  child: Center(
                    child: isGameOver
                        ? const SizedBox()
                        : _buildDraggableItem(),
                  ),
                ),
                _buildBinsArea(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // content: UI Widgets
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(
            Icons.arrow_back_rounded,
            AppColors.gameYellow,
            () => Navigator.pop(context),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Think carefully!",
                  style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          _scoreBadge("$score", Icons.star_rounded, AppColors.white),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gameOrange.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        "Drag the food to the right place!",
        style: GoogleFonts.fredoka(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDraggableItem() {
    final item = _foodItems[currentIndex];
    return Draggable<bool>(
      data: item['isHalal'],
      feedback: Transform.scale(scale: 1.1, child: _foodCard(item, true)),
      childWhenDragging: Opacity(opacity: 0.0, child: _foodCard(item)),
      child: _foodCard(item),
    );
  }

  Widget _foodCard(Map<String, dynamic> item, [bool isDragging = false]) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 350,
        height: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(item['image'], fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBinsArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBinDropZone(
          "HALAL",
          "assets/images/keranjang.png",
          Icons.check_circle_outline,
          true,
        ),
        _buildBinDropZone(
          "HARAM",
          "assets/images/trash_red.png",
          Icons.dangerous_outlined,
          false,
        ),
      ],
    );
  }

  Widget _buildBinDropZone(
    String label,
    String asset,
    IconData icon,
    bool accepts,
  ) {
    return DragTarget<bool>(
      onAccept: (data) =>
          data == accepts ? _handleCorrectDrop() : _handleWrongDrop(),
      builder: (context, candidate, rejected) {
        bool hovering = candidate.isNotEmpty;
        return AnimatedScale(
          scale: hovering ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 7),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    asset,
                    width: 250,
                    colorBlendMode: BlendMode.srcATop,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
      );

  Widget _scoreBadge(String val, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white30),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          val,
          style: GoogleFonts.fredoka(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
