import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/components/finish_games.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:edukids_app/core/components/wrong_games.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:edukids_app/data/right_wrong/right_wrong_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WhichIsRightScreen extends StatefulWidget {
  const WhichIsRightScreen({super.key});

  @override
  State<WhichIsRightScreen> createState() => _WhichIsRightScreenState();
}

class _WhichIsRightScreenState extends State<WhichIsRightScreen>
    with TickerProviderStateMixin {
  // Data Level
  final List<WhichLevel> _levels = [
    WhichLevel(
      question: "Which one is Allah's creation?",
      leftImage: 'assets/images/matahari.png',
      rightImage: 'assets/images/mobil.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which one is man-made?",
      leftImage: 'assets/images/gunung.png',
      rightImage: 'assets/images/masjid.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which one do we use for Sujud?",
      leftImage: 'assets/images/sajadah.png',
      rightImage: 'assets/images/baju_muslim.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which is the Qur'an?",
      leftImage: 'assets/images/buku.png',
      rightImage: 'assets/images/quran.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which is Sunnah food?",
      leftImage: 'assets/images/burger.png',
      rightImage: 'assets/images/kurma.png',
      isLeftCorrect: false,
    ),
  ];

  // State
  int _currentIndex = 0;
  bool _isGameFinished = false;
  late ConfettiController _confettiController;

  // Animation Controllers
  late AnimationController _entranceController;
  late Animation<double> _questionEntranceAnimation;
  late Animation<double> _cardsEntranceAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('bgm_which.mp3');

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _questionEntranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _cardsEntranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
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

  void _checkAnswer(bool userPickedLeft) {
    if (_isGameFinished) return;

    bool correctAnswer = _levels[_currentIndex].isLeftCorrect;

    if (userPickedLeft == correctAnswer) {
      AudioManager().playSfx('pop.mp3');
      _showWinDialog();
    } else {
      AudioManager().playSfx('bubble-pop.mp3');
      HapticFeedback.heavyImpact();
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

  // Dialogs
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

  Widget _buildColorfulQuestion(String question) {
    List<String> words = question.split(' ');

    List<Color> wordColors = [
      const Color(0xFFFF5252), 
      const Color(0xFF40C4FF), 
      const Color(0xFFFFD740),
      const Color(0xFF69F0AE), 
      const Color(0xFFE040FB),
      const Color(0xFFFFAB40), 
    ];

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
                fontSize: 38,
                fontWeight: FontWeight.w900,
                foreground: isOutline
                    ? (Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
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

  CustomPainter _getPatternForLevel() {
    Color patternColor = AppColors.gameRed.withOpacity(0.08);

    switch (_currentIndex % 5) {
      case 0:
        return DotPatternPainter(color: patternColor); 
      case 1:
        return WavyPatternPainter(color: patternColor); 
      case 2:
        return GridPatternPainter(color: patternColor); 
      case 3:
        return CrossPatternPainter(color: patternColor); 
      case 4:
        return DiagonalStripesPainter(
          color: patternColor,
        ); 
      default:
        return DotPatternPainter(color: patternColor);
    }
  }

  // UI Build
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
                "assets/images/bg_right.jpeg",
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double h = constraints.maxHeight;
                double headerH = max(h * 0.1, 70.0);
                double questionH = max(h * 0.15, 120.0);
                double availableH = h - headerH - questionH - 40;

                return Column(
                  children: [
                    SizedBox(height: headerH, child: _buildHeader()),

                    SizedBox(
                      height: questionH,
                      child: Center(
                        child: ScaleTransition(
                          scale: _questionEntranceAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                key: ValueKey(level.question),
                                child: _buildColorfulQuestion(level.question),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
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
                          child: Container(
                            key: ValueKey<int>(_currentIndex),
                            alignment: Alignment.center,
                            child: ScaleTransition(
                              scale: _cardsEntranceAnimation,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: _BouncingButton(
                                      onTap: () => _checkAnswer(true),
                                      child: _buildImageCard(
                                        level.leftImage,
                                        availableH,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 70,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "OR",
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 28,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.gameRed
                                                .withOpacity(0.8),
                                            offset: const Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _BouncingButton(
                                      onTap: () => _checkAnswer(false),
                                      child: _buildImageCard(
                                        level.rightImage,
                                        availableH,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: AppColors.gameRed, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Which is right?",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 0,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Think fast and choose wisely!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
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

  Widget _buildImageCard(String imagePath, double availableHeight) {
    return Container(
      height: min(availableHeight * 1.3, 500.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.gameRed, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.gameRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _getPatternForLevel())),
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DotPatternPainter extends CustomPainter {
  final Color color;
  DotPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    double spacing = 20;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavyPatternPainter extends CustomPainter {
  final Color color;
  WavyPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    double spacing = 30;
    for (double y = spacing / 2; y < size.height + 10; y += spacing) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x < size.width; x += 40) {
        path.quadraticBezierTo(x + 10, y - 5, x + 20, y);
        path.quadraticBezierTo(x + 30, y + 5, x + 40, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPatternPainter extends CustomPainter {
  final Color color;
  GridPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double spacing = 25;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CrossPatternPainter extends CustomPainter {
  final Color color;
  CrossPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    double spacing = 30;
    double crossSize = 6;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiagonalStripesPainter extends CustomPainter {
  final Color color;
  DiagonalStripesPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    double spacing = 20;

    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
