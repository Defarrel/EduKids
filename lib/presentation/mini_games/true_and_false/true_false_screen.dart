import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/components/finish_games.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:edukids_app/core/components/wrong_games.dart';
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

class _TrueFalseScreenState extends State<TrueFalseScreen>
    with TickerProviderStateMixin {
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

  // Animation Controllers
  late AnimationController _entranceController;
  late Animation<double> _cardEntranceAnimation;
  late Animation<double> _buttonEntranceAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('bgm_true.mp3');
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardEntranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _buttonEntranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _confettiController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // Logic
  void _checkAnswer(bool userChoice) {
    bool correctAnswer = _levels[_currentIndex].isTrue;

    if (userChoice == correctAnswer) {
      AudioManager().playSfx('pop.mp3');
      _showWinDialog();
    } else {
      AudioManager().playSfx('bubble-pop.mp3');
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

            Future.delayed(const Duration(milliseconds: 300), () {
              _nextLevel();
            });
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
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                "assets/images/bg_true_false.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double h = constraints.maxHeight;
                double w = constraints.maxWidth;
                double headerH = max(h * 0.1, 70.0);
                double footerH = max(h * 0.20, 100.0);
                double availableH = h - headerH - footerH;
                double cardWidth = min(w * 0.5, 500.0);
                double cardHeight = min(availableH * 0.9, 500.0);

                return Column(
                  children: [
                    SizedBox(height: headerH, child: _buildHeader()),

                    Expanded(
                      child: Center(
                        child: ScaleTransition(
                          scale: _cardEntranceAnimation,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                            child: _buildQuestionCard(
                              key: ValueKey<int>(_currentIndex),
                              level: level,
                              width: cardWidth,
                              height: cardHeight,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: footerH,
                      child: ScaleTransition(
                        scale: _buttonEntranceAnimation,
                        child: _buildAnswerButtons(w > 600),
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
                color: AppColors.gamePink,
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
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              "Level ${_currentIndex + 1}",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required Key key,
    required TrueFalseLevel level,
    required double width,
    required double height,
  }) {
    return Container(
      key: key,
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
            child: _BouncingButton(
              onTap: () => _checkAnswer(false),
              child: _gameButtonContent(
                text: "FALSE",
                color: const Color(0xFFFF5252),
                icon: Icons.close_rounded,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _BouncingButton(
              onTap: () => _checkAnswer(true),
              child: _gameButtonContent(
                text: "TRUE",
                color: const Color(0xFF4CAF50),
                icon: Icons.check_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameButtonContent({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double btnHeight = min(constraints.maxHeight, 100);

        return Container(
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
        );
      },
    );
  }
}

class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncingButton({required this.child, required this.onTap});

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _handleTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
