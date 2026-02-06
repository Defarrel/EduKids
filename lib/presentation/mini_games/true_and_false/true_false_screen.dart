import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/components/finish_games.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:edukids_app/data/true_and_false/true_and_false_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';

class TrueFalseScreen extends StatefulWidget {
  const TrueFalseScreen({super.key});

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  // Data Level
  final List<TrueFalseLevel> _levels = [
    TrueFalseLevel(
      imagePath: 'assets/images/Lafadz_Allah.png',
      question: "Is this the name of ALLAH?",
      isTrue: true,
    ),
    TrueFalseLevel(
      imagePath: 'assets/images/Lafadz_Muhammad.png',
      question: "Is this the name of ALLAH?",
      isTrue: false,
    ),
    TrueFalseLevel(
      imagePath: 'assets/images/kabah.png',
      question: "Is this the Qibla?",
      isTrue: true,
    ),
    TrueFalseLevel(
      imagePath: 'assets/images/quran.png',
      question: "Is this the Bible?",
      isTrue: false,
    ),
    TrueFalseLevel(
      imagePath: 'assets/images/madinah.png',
      question: "Is this the Mecca?",
      isTrue: false,
    ),
  ];

  // State
  int _currentIndex = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('puzzle_bgm.mp3');
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _confettiController.dispose();
    super.dispose();
  }

  // Logic
  void _checkAnswer(bool userChoice) {
    bool correctAnswer = _levels[_currentIndex].isTrue;

    if (userChoice == correctAnswer) {
      AudioManager().playSfx('pop.mp3');
      _showWinDialog();
    } else {
      AudioManager().playSfx(
        'bubble-pop.mp3',
      ); // Ganti dengan sound "wrong" nanti

      _showWrongDialog();
    }
  }

  void _nextLevel() {
    if (_currentIndex < _levels.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showFinishAllDialog();
    }
  }

  void _showWrongDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Wrong",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.redAccent, width: 5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Oops! Wrong Answer",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      decoration:
                          TextDecoration.none, 
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Don't give up! Try again.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gameSkyBlue,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gameSkyBlue.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          "Try Again",
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogs Menang & Finish
  void _showWinDialog() {
    bool isLastLevel = _currentIndex == _levels.length - 1;
    _confettiController.play();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return WinGames(
          isLastLevel: isLastLevel,
          confettiController: _confettiController,
          onActionPressed: () {
            Navigator.of(ctx).pop();
            _nextLevel();
          },
        );
      },
    );
  }

  void _showFinishAllDialog() {
    _confettiController.play();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return FinishGames(
          confettiController: _confettiController,
          onMainMenuPressed: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    final level = _levels[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.gameSkyBlue,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                "assets/images/bg_true_false.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Dimensions Calculation
                double h = constraints.maxHeight;
                double w = constraints.maxWidth;

                // Proporsi Layar
                double headerH = h * 0.15;
                if (headerH < 70) headerH = 70;

                double footerH = h * 0.20;
                if (footerH < 100) footerH = 100;

                double availableH = h - headerH - footerH;

                double cardWidth = min(w * 0.85, 500.0);
                double cardHeight = min(availableH * 0.9, 500.0);

                return Column(
                  children: [
                    SizedBox(height: headerH, child: _buildHeader()),

                    Expanded(
                      child: Center(
                        child: _buildQuestionCard(level, cardWidth, cardHeight),
                      ),
                    ),

                    SizedBox(
                      height: footerH,
                      child: _buildAnswerButtons(w > 600),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back,
                color: AppColors.gameSkyBlue,
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
                  "True or False?",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Think carefully!",
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              "${_currentIndex + 1} / ${_levels.length}",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TrueFalseLevel level, double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gameSkyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(level.imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            level.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: _gameButton(
              text: "FALSE",
              color: const Color(0xFFFF5252),
              icon: Icons.close_rounded,
              onTap: () => _checkAnswer(false),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _gameButton(
              text: "TRUE",
              color: const Color(0xFF4CAF50),
              icon: Icons.check_rounded,
              onTap: () => _checkAnswer(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double btnHeight = min(constraints.maxHeight, 100);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: btnHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 36),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
