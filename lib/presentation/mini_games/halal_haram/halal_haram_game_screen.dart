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

class _HalalHaramGameScreenState extends State<HalalHaramGameScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  int currentIndex = 0;
  int score = 0;
  bool isGameOver = false;

  bool showHandTutorial = true;
  late AnimationController _handController;
  late Animation<Offset> _handSlideAnimation;
  late Animation<double> _handScaleAnimation;

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

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _handScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0.8), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 20),
    ]).animate(_handController);

    _handSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-5.3, 1), 
        ).animate(
          CurvedAnimation(
            parent: _handController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
          ),
        );

    if (currentIndex == 0) {
      _handController.repeat();
    }
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _confettiController.dispose();
    _handController.dispose();
    super.dispose();
  }

  void _hideTutorial() {
    if (showHandTutorial) {
      setState(() => showHandTutorial = false);
      _handController.stop();
    }
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
            child: Image.asset(
              "assets/images/bg_halal_haram.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double w = constraints.maxWidth;
                double h = constraints.maxHeight;

                double headerH = max(h * 0.1, 70.0);

                double cardSize = w * 0.20;

                double binWidth = w * 0.23;
                double binHeight = h * 0.32;

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: headerH,
                      child: _buildHeader(),
                    ),

                    Positioned(
                      left: -20,
                      bottom: h * 0.2, 
                      child: _buildBinDropZone(
                        "HALAL",
                        "assets/images/keranjang.png",
                        true,
                        binWidth,
                        binHeight,
                      ),
                    ),

                    Positioned(
                      right: -20,
                      bottom: h * 0.2,
                      child: _buildBinDropZone(
                        "HARAM",
                        "assets/images/trash_red.png",
                        false,
                        binWidth,
                        binHeight,
                      ),
                    ),

                    Positioned(
                      top: headerH,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Align(
                          alignment: const Alignment(0, 0.1),
                          child: isGameOver
                              ? const SizedBox()
                              : Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    _buildDraggableItem(cardSize),

                                    // Tutorial Hand
                                    if (showHandTutorial)
                                      IgnorePointer(
                                        child: SlideTransition(
                                          position: _handSlideAnimation,
                                          child: ScaleTransition(
                                            scale: _handScaleAnimation,
                                            child: Image.asset(
                                              'assets/images/hand_pointer.png',
                                              width: 80,
                                              height: 80,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
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
                    shadows: [
                      const Shadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
                Text(
                  "Drag The Food!",
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      const Shadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
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
      onDragStarted: () {
        _hideTutorial();
        AudioManager().playSfx('bubble-pop.mp3');
      },
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
              // Label Text
              Text(
                label,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width > 120 ? 20 : 16,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 7)],
                ),
              ),
              const SizedBox(height: 5),
              // Bin Image
              Image.asset(
                asset,
                width: width,
                height: height,
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
