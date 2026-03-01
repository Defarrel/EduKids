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
  final List<TrueFalseLevel> _levels = [
    TrueFalseLevel(
      imagePath: 'assets/images/allah_white.png',
      question: "Is this the name of ALLAH?",
      isTrue: true,
    ),
    TrueFalseLevel(
      imagePath: 'assets/images/muhammad_white.png',
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

  int _currentIndex = 0;
  bool _showTutorial = true;
  late ConfettiController _confettiController;

  late AnimationController _tutorialController;
  late Animation<double> _handYAnimation;
  late Animation<double> _handScaleAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('bgm_true.mp3');
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _tutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _handYAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 20.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 20.0, end: 20.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 20.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_tutorialController);

    _handScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
    ]).animate(_tutorialController);
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _confettiController.dispose();
    _tutorialController.dispose();
    super.dispose();
  }

  void _checkAnswer(bool userChoice) {
    if (_showTutorial) {
      setState(() => _showTutorial = false);
    }

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
      setState(() => _currentIndex++);
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
      pageBuilder: (context, anim1, anim2) =>
          WrongGames(onRetryPressed: () => Navigator.of(context).pop()),
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
      pageBuilder: (ctx, anim1, anim2) => WinGames(
        isLastLevel: isLastLevel,
        confettiController: _confettiController,
        onActionPressed: () {
          Navigator.of(ctx).pop();
          Future.delayed(const Duration(milliseconds: 300), () => _nextLevel());
        },
      ),
    );
  }

  void _showFinishAllDialog() {
    _confettiController.play();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) => FinishGames(
        confettiController: _confettiController,
        onMainMenuPressed: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildColorfulQuestion(String question, bool isTablet) {
    List<String> words = question.split(' ');
    List<Color> wordColors = [
      const Color(0xFFFF5252),
      const Color(0xFF40C4FF),
      const Color(0xFFFFD740),
      const Color(0xFF69F0AE),
      const Color(0xFFE040FB),
      const Color(0xFFFFAB40),
    ];

    double fontSize = isTablet ? 36 : 26;

    Widget buildLayer({required bool isOutline}) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: words.asMap().entries.map((entry) {
            int idx = entry.key;
            String word = entry.value;
            Color color = wordColors[idx % wordColors.length];

            return TextSpan(
              text: "$word ",
              style: GoogleFonts.fredoka(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                foreground: isOutline
                    ? (Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = isTablet
                            ? 6
                            : 4 
                        ..color = Colors.white)
                    : (Paint()..color = color),
                shadows: isOutline
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            );
          }).toList(),
        ),
      );
    }

    return Stack(
      children: [buildLayer(isOutline: true), buildLayer(isOutline: false)],
    );
  }

  Widget _buildHeader(bool isTablet) {
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
                    fontSize: isTablet ? 24 : 20, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Think carefully!",
                  style: GoogleFonts.fredoka(
                    fontSize: isTablet ? 18 : 14,
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

  @override
  Widget build(BuildContext context) {
    final level = _levels[_currentIndex];
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/bg_true.jpeg", fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: max(size.height * 0.12, 80.0),
                  child: _buildHeader(isTablet),
                ),
                const Spacer(),
              ],
            ),
          ),

          Positioned(
            top: isTablet ? size.height * 0.15 : size.height * 0.12,
            left: size.width * 0.2,
            right: size.width * 0.2,
            height: isTablet ? size.height * 0.42 : size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(level.imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 10),
                _buildColorfulQuestion(level.question, isTablet),
              ],
            ),
          ),

          Positioned(
            bottom: isTablet ? size.height * 0.12 : size.height * 0.05,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RealisticGameButton(
                  imagePath: 'assets/images/btn_false.png',
                  onTap: () => _checkAnswer(false),
                  isTablet: isTablet,
                ),

                SizedBox(width: isTablet ? size.width * 0.2 : size.width * 0.1),

                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior:
                      Clip.none,
                  children: [
                    RealisticGameButton(
                      imagePath: 'assets/images/btn_true.png',
                      onTap: () => _checkAnswer(true),
                      isTablet: isTablet,
                    ),

                    if (_currentIndex == 0 && _showTutorial)
                      IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _tutorialController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -30 + _handYAnimation.value),
                              child: Transform.scale(
                                scale: _handScaleAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/images/hand_pointer.png',
                            width: isTablet ? 100 : 80,
                            height: isTablet ? 100 : 80,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class RealisticGameButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final bool isTablet;

  const RealisticGameButton({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.isTablet,
  });

  @override
  State<RealisticGameButton> createState() => _RealisticGameButtonState();
}

class _RealisticGameButtonState extends State<RealisticGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double btnSize = widget.isTablet ? 120 : 90;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: btnSize,
        height: btnSize,
        transform: Matrix4.identity()
          ..translate(0.0, _isPressed ? 12.0 : 0.0)
          ..scale(_isPressed ? 0.95 : 1.0),
        child: Image.asset(widget.imagePath, fit: BoxFit.contain),
      ),
    );
  }
}
