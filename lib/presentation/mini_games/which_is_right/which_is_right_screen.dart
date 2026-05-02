import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
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
    WhichLevel(
      question: "Which is the Ka'bah?",
      leftImage: 'assets/images/madinah.png',
      rightImage: 'assets/images/kabah.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which drink is Halal?",
      leftImage: 'assets/images/honey.png',
      rightImage: 'assets/images/beer.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which is Eid food?",
      leftImage: 'assets/images/kue_ulang_tahun.png',
      rightImage: 'assets/images/ketupat.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which one do Muslim boys wear on their head?",
      leftImage: 'assets/images/peci.png',
      rightImage: 'assets/images/topi_koboi.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "What do we use for Dhikr?",
      leftImage: 'assets/images/kalkulator.png',
      rightImage: 'assets/images/tasbih.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which is used for Wudu?",
      leftImage: 'assets/images/air.png',
      rightImage: 'assets/images/milk.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which is a pillar of Islam?",
      leftImage: 'assets/images/sholat.png',
      rightImage: 'assets/images/pilar.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which animal is Haram to eat?",
      leftImage: 'assets/images/kambing.png',
      rightImage: 'assets/images/pig.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which one do Muslims walk around seven times?",
      leftImage: 'assets/images/kabah.png',
      rightImage: 'assets/images/gunung.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which building do Muslims go to on Friday?",
      leftImage: 'assets/images/masjid.png',
      rightImage: 'assets/images/taman_bermain.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which one do Muslims face when they pray?",
      leftImage: 'assets/images/kabah.png',
      rightImage: 'assets/images/matahari.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which one should we wear when going for Hajj?",
      leftImage: 'assets/images/baju_muslim.png',
      rightImage: 'assets/images/baju_ihram.png',
      isLeftCorrect: false,
    ),
    WhichLevel(
      question: "Which one makes a sound to call us to pray?",
      leftImage: 'assets/images/adzan.png',
      rightImage: 'assets/images/nyanyi.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which one is the house of Allah?",
      leftImage: 'assets/images/masjid.png',
      rightImage: 'assets/images/rumah.png',
      isLeftCorrect: true,
    ),
    WhichLevel(
      question: "Which is the Prophet's city?",
      leftImage: 'assets/images/madinah.png',
      rightImage: 'assets/images/gunung.png',
      isLeftCorrect: true,
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
      barrierLabel: "Wrong".tr(),
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
    List<String> words = question.tr().split(' ');

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

    switch (_currentIndex % 20) {
      case 0:
        return DotPatternPainter(color: patternColor);
      case 1:
        return WavyPatternPainter(color: patternColor);
      case 2:
        return GridPatternPainter(color: patternColor);
      case 3:
        return CrossPatternPainter(color: patternColor);
      case 4:
        return DiagonalStripesPainter(color: patternColor);
      case 5:
        return CircleOutlinePainter(color: patternColor);
      case 6:
        return StarPatternPainter(color: patternColor);
      case 7:
        return ZigZagPatternPainter(color: patternColor);
      case 8:
        return HexagonPatternPainter(color: patternColor);
      case 9:
        return CheckeredPatternPainter(color: patternColor);
      case 10:
        return TrianglePatternPainter(color: patternColor);
      case 11:
        return DiamondPatternPainter(color: patternColor);
      case 12:
        return SpiralDotPatternPainter(color: patternColor);
      case 13:
        return BrickPatternPainter(color: patternColor);
      case 14:
        return ArrowPatternPainter(color: patternColor);
      case 15:
        return ScalePatternPainter(color: patternColor);
      case 16:
        return PlusPatternPainter(color: patternColor);
      case 17:
        return DashedGridPatternPainter(color: patternColor);
      case 18:
        return ConfettiPatternPainter(color: patternColor);
      case 19:
        return RingPatternPainter(color: patternColor);
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
                double headerH = max(h * 0.15, 70.0);
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
                                      "OR".tr(),
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
                  "Which is right?".tr(),
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
                  "Think fast and choose wisely!".tr(),
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
              "Level".tr() + " ${_currentIndex + 1}",
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

class CircleOutlinePainter extends CustomPainter {
  final Color color;
  CircleOutlinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double spacing = 30;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPatternPainter extends CustomPainter {
  final Color color;
  StarPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double spacing = 40;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        _drawStar(canvas, paint, Offset(x, y), 5, 8, 4);
      }
    }
  }

  void _drawStar(
    Canvas canvas,
    Paint paint,
    Offset center,
    int points,
    double outerRadius,
    double innerRadius,
  ) {
    var path = Path();
    var angle = -pi / 2.0;
    var step = pi / points;

    path.moveTo(
      center.dx + outerRadius * cos(angle),
      center.dy + outerRadius * sin(angle),
    );

    for (int i = 0; i < points; i++) {
      angle += step;
      path.lineTo(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      angle += step;
      path.lineTo(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ZigZagPatternPainter extends CustomPainter {
  final Color color;
  ZigZagPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double spacingY = 25;
    double spacingX = 20;

    for (double y = spacingY; y < size.height + spacingY; y += spacingY) {
      final path = Path()..moveTo(0, y);
      bool isUp = true;
      for (double x = 0; x < size.width + spacingX; x += spacingX) {
        path.lineTo(x, isUp ? y - 10 : y + 10);
        isUp = !isUp;
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonPatternPainter extends CustomPainter {
  final Color color;
  HexagonPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double radius = 15;
    double width = sqrt(3) * radius;
    double height = 2 * radius;

    for (double y = 0; y < size.height + height; y += height * 0.75) {
      double offsetX = (y / (height * 0.75)) % 2 == 0 ? 0 : width / 2;
      for (double x = offsetX; x < size.width + width; x += width) {
        _drawHexagon(canvas, paint, Offset(x, y), radius);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle =
          2 * pi / 6 * (i + 0.5); // Putar 30 derajat agar flat di atas
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckeredPatternPainter extends CustomPainter {
  final Color color;
  CheckeredPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    double squareSize = 20;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        if (((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePatternPainter extends CustomPainter {
  final Color color;
  TrianglePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double spacing = 30;

    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final path = Path()
          ..moveTo(x, y + spacing)
          ..lineTo(x + spacing / 2, y)
          ..lineTo(x + spacing, y + spacing)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiamondPatternPainter extends CustomPainter {
  final Color color;
  DiamondPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double s = 18;

    for (double y = s; y < size.height + s; y += s * 2) {
      for (double x = s; x < size.width + s; x += s * 2) {
        final path = Path()
          ..moveTo(x, y - s)
          ..lineTo(x + s, y)
          ..lineTo(x, y + s)
          ..lineTo(x - s, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpiralDotPatternPainter extends CustomPainter {
  final Color color;
  SpiralDotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    double spacing = 25;
    int row = 0;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      double offsetX = (row % 3) * (spacing / 3);
      for (double x = offsetX; x < size.width; x += spacing) {
        double radius = (row % 3 == 0)
            ? 4
            : (row % 3 == 1)
            ? 2.5
            : 1.5;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrickPatternPainter extends CustomPainter {
  final Color color;
  BrickPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double brickW = 40;
    double brickH = 20;
    int row = 0;

    for (double y = 0; y < size.height + brickH; y += brickH) {
      double offsetX = (row % 2 == 0) ? 0 : brickW / 2;
      for (double x = -brickW + offsetX; x < size.width + brickW; x += brickW) {
        canvas.drawRect(Rect.fromLTWH(x, y, brickW, brickH), paint);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArrowPatternPainter extends CustomPainter {
  final Color color;
  ArrowPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    double spacingX = 30;
    double spacingY = 25;

    for (double y = spacingY / 2; y < size.height; y += spacingY) {
      for (double x = spacingX / 2; x < size.width; x += spacingX) {
        canvas.drawLine(Offset(x - 8, y - 6), Offset(x, y), paint);
        canvas.drawLine(Offset(x, y), Offset(x + 8, y - 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScalePatternPainter extends CustomPainter {
  final Color color;
  ScalePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double r = 18;
    double spacingX = r * 1.5;
    double spacingY = r * 0.9;
    int row = 0;

    for (double y = 0; y < size.height + r; y += spacingY) {
      double offsetX = (row % 2 == 0) ? 0 : spacingX / 2;
      for (double x = offsetX - r; x < size.width + r; x += spacingX) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: r),
          pi,
          pi,
          false,
          paint,
        );
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlusPatternPainter extends CustomPainter {
  final Color color;
  PlusPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    double spacing = 28;
    double arm = 5;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x - arm, y), Offset(x + arm, y), paint);
        canvas.drawLine(Offset(x, y - arm), Offset(x, y + arm), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedGridPatternPainter extends CustomPainter {
  final Color color;
  DashedGridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double spacing = 25;
    double dashLen = 6;
    double gap = 4;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += dashLen + gap) {
        canvas.drawLine(Offset(x, y), Offset(x, y + dashLen), paint);
      }
    }
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += dashLen + gap) {
        canvas.drawLine(Offset(x, y), Offset(x + dashLen, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ConfettiPatternPainter extends CustomPainter {
  final Color color;
  ConfettiPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final shapes = [
      Rect.fromLTWH(0, 0, 8, 4),
      Rect.fromLTWH(0, 0, 4, 8),
      Rect.fromLTWH(0, 0, 5, 5),
    ];
    double spacingX = 35;
    double spacingY = 30;
    int i = 0;

    for (double y = spacingY / 2; y < size.height; y += spacingY) {
      for (double x = spacingX / 2; x < size.width; x += spacingX) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate((i % 4) * pi / 4);
        canvas.drawRect(shapes[i % shapes.length], paint);
        canvas.restore();
        i++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RingPatternPainter extends CustomPainter {
  final Color color;
  RingPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double spacing = 32;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 6, paint);
        canvas.drawCircle(Offset(x, y), 11, paint);
      }
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
