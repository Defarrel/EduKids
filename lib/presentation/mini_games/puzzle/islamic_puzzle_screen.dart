import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/data/puzzle/puzzle_level_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';

class IslamicPuzzleScreen extends StatefulWidget {
  const IslamicPuzzleScreen({super.key});

  @override
  State<IslamicPuzzleScreen> createState() => _IslamicPuzzleScreenState();
}

class _IslamicPuzzleScreenState extends State<IslamicPuzzleScreen>
    with TickerProviderStateMixin {
  // Data
  final List<PuzzleLevel> _levels = [
    PuzzleLevel(
      title: "Lafadz Allah",
      imagePath: 'assets/images/Lafadz_Allah.png',
      gridSize: 3,
    ),
    PuzzleLevel(
      title: "Lafadz Muhammad",
      imagePath: 'assets/images/Lafadz_Muhammad.png',
      gridSize: 3,
    ),
    PuzzleLevel(
      title: "Ka'bah",
      imagePath: 'assets/images/kabah.png',
      gridSize: 3,
    ),
    PuzzleLevel(
      title: "Masjid",
      imagePath: 'assets/images/masjid.png',
      gridSize: 3,
    ),
    PuzzleLevel(
      title: "Muslim dress",
      imagePath: 'assets/images/baju_muslim.png',
      gridSize: 3,
    ),
  ];

  // State
  int _currentIndex = 0;
  late List<int> pieceCurrentPos;
  bool isGameFinished = false;
  bool isLoading = true;
  bool isShuffling = false;
  bool showHandTutorial = false;
  bool _isWinningZoom = false;

  // Controllers
  late AnimationController _handController;
  late Animation<Offset> _handSlideAnimation;
  late Animation<double> _handScaleAnimation;
  late ConfettiController _confettiController;

  // Lifecycle
  @override
  void initState() {
    super.initState();

    // BGM Setup
    AudioManager().playBgm('puzzle_bgm.mp3');

    // Controllers Setup
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Animations
    _handScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0.8), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 20),
    ]).animate(_handController);

    _handSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0)).animate(
          CurvedAnimation(
            parent: _handController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
          ),
        );

    _initializeLevel();
  }

  @override
  void dispose() {
    // Reset BGM
    AudioManager().playBgm('bgm.mp3');

    // Cleanup
    _handController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Logic
  void _initializeLevel() async {
    setState(() {
      isLoading = true;
      isGameFinished = false;
      isShuffling = true;
      showHandTutorial = false;
      _isWinningZoom = false;
    });

    PuzzleLevel currentLevel = _levels[_currentIndex];

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await precacheImage(AssetImage(currentLevel.imagePath), context);

    int total = currentLevel.gridSize * currentLevel.gridSize;
    pieceCurrentPos = List.generate(total, (index) => index);

    setState(() {
      isLoading = false;
    });

    _animateSlideShuffle();
  }

  Future<void> _animateSlideShuffle() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    AudioManager().playSfx('shuffle_cards.mp3');

    int totalSwaps = 12;
    Random rng = Random();

    for (int i = 0; i < totalSwaps; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      setState(() {
        int gridIndexA = rng.nextInt(pieceCurrentPos.length);
        int gridIndexB = rng.nextInt(pieceCurrentPos.length);

        while (gridIndexA == gridIndexB) {
          gridIndexB = rng.nextInt(pieceCurrentPos.length);
        }

        int pieceIdAtA = pieceCurrentPos.indexWhere((pos) => pos == gridIndexA);
        int pieceIdAtB = pieceCurrentPos.indexWhere((pos) => pos == gridIndexB);

        pieceCurrentPos[pieceIdAtA] = gridIndexB;
        pieceCurrentPos[pieceIdAtB] = gridIndexA;

        HapticFeedback.selectionClick();
      });
    }

    bool isSolved = true;
    for (int i = 0; i < pieceCurrentPos.length; i++) {
      if (pieceCurrentPos[i] != i) {
        isSolved = false;
        break;
      }
    }

    if (isSolved) {
      setState(() {
        int last = pieceCurrentPos.length - 1;
        int secondLast = pieceCurrentPos.length - 2;
        int temp = pieceCurrentPos[last];
        pieceCurrentPos[last] = pieceCurrentPos[secondLast];
        pieceCurrentPos[secondLast] = temp;
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isShuffling = false;
    });

    if (_currentIndex == 0) {
      setState(() => showHandTutorial = true);
      _handController.repeat();
    }
  }

  void _onPieceDrop(int draggedPieceId, int targetPieceId) {
    if (isShuffling || isGameFinished) return;
    _hideTutorial();
    if (draggedPieceId == targetPieceId) return;

    setState(() {
      int posA = pieceCurrentPos[draggedPieceId];
      int posB = pieceCurrentPos[targetPieceId];
      pieceCurrentPos[draggedPieceId] = posB;
      pieceCurrentPos[targetPieceId] = posA;

      AudioManager().playSfx('bubble-pop.mp3');
      HapticFeedback.lightImpact();

      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    bool isWin = true;
    for (int id = 0; id < pieceCurrentPos.length; id++) {
      if (pieceCurrentPos[id] != id) {
        isWin = false;
        break;
      }
    }

    if (isWin) {
      _hideTutorial();
      setState(() {
        isGameFinished = true;
        _isWinningZoom = true;
      });

      AudioManager().playSfx('pop.mp3');
      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(milliseconds: 1500), _showWinDialog);
    }
  }

  void _hideTutorial() {
    if (showHandTutorial) {
      setState(() => showHandTutorial = false);
      _handController.stop();
    }
  }

  void _nextLevel() {
    if (_currentIndex < _levels.length - 1) {
      setState(() => _currentIndex++);
      _initializeLevel();
    } else {
      _showFinishAllDialog();
    }
  }

  // Dialogs
  void _showWinDialog() {
    bool isLastLevel = _currentIndex == _levels.length - 1;

    _confettiController.stop();
    _confettiController.play();

    Future.delayed(const Duration(seconds: 1), () {
      _confettiController.stop();
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Win",
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: SizedBox(
                width: 320,
                height: 380,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Board
                    Positioned(
                      top: 80,
                      child: Container(
                        width: 280,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            Text(
                              "Level Completed!",
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 40,
                                  ),
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Ribbon
                    Positioned(
                      top: 60,
                      child: SizedBox(
                        width: 320,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD32F2F),
                                    Color(0xFFFF5252),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFB71C1C),
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "MASYAALLAH",
                                style: GoogleFonts.fredoka(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    const Shadow(
                                      offset: Offset(2, 2),
                                      color: Colors.black38,
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 8,
                              child: Transform.rotate(
                                angle: 0.8,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  color: const Color(0xFF880E4F),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 8,
                              child: Transform.rotate(
                                angle: 0.8,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  color: const Color(0xFF880E4F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Trophy
                    Positioned(
                      top: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.6),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.emoji_events_rounded,
                            size: 90,
                            color: Color(0xFFFFD700),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Button
                    Positioned(
                      bottom: 70,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _nextLevel();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFE65100),
                                blurRadius: 0,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            isLastLevel ? "FINISH" : "NEXT",
                            style: GoogleFonts.fredoka(
                              color: const Color(0xFFBF360C),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Confetti Layer
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                gravity: 0.3,
                minBlastForce: 10,
                maxBlastForce: 30,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return child;
      },
    );
  }

  void _showFinishAllDialog() {
    _confettiController.play();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Finish",
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: SizedBox(
                width: 320,
                height: 380,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Board
                    Positioned(
                      top: 80,
                      child: Container(
                        width: 280,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            Text(
                              "All Levels Done!",
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "You are Amazing!",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Ribbon
                    Positioned(
                      top: 60,
                      child: SizedBox(
                        width: 320,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF43A047),
                                    Color(0xFF66BB6A),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF1B5E20),
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "ALHAMDULILLAH",
                                style: GoogleFonts.fredoka(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                  shadows: [
                                    const Shadow(
                                      offset: Offset(2, 2),
                                      color: Colors.black38,
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 8,
                              child: Transform.rotate(
                                angle: 0.8,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  color: const Color(0xFF004D40),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 8,
                              child: Transform.rotate(
                                angle: 0.8,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  color: const Color(0xFF004D40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Medal
                    Positioned(
                      top: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.verified_rounded,
                            size: 90,
                            color: Color(0xFFFFD700),
                          ),
                          Positioned(
                            top: 25,
                            right: 25,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Button
                    Positioned(
                      bottom: 70,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF880E4F),
                                blurRadius: 0,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            "MAIN MENU",
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Confetti Layer
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.3,
                minBlastForce: 10,
                maxBlastForce: 40,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return child;
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    PuzzleLevel level = _levels[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.gameSkyBlue,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/images/bg_puzzle.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double w = constraints.maxWidth;
                double h = constraints.maxHeight;

                double headerH = 70;
                double footerH = 60;
                double availableH = h - headerH - footerH;

                double puzzleSize = min(w * 0.95, availableH * 0.85);

                double bgPadding = 6.0;
                double innerSize = puzzleSize - (bgPadding * 2);

                double pieceSpacing = isGameFinished ? 0 : 1.0;
                double pieceSize =
                    (innerSize - ((level.gridSize - 1) * pieceSpacing)) /
                    level.gridSize;

                return Column(
                  children: [
                    // Header
                    SizedBox(
                      height: headerH,
                      child: _buildCompactHeader(level),
                    ),

                    const Spacer(),

                    // Puzzle Area
                    isLoading
                        ? SizedBox(
                            width: puzzleSize,
                            height: puzzleSize,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : AnimatedScale(
                            scale: _isWinningZoom ? 1.6 : 1.3,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOutBack,
                            child: SizedBox(
                              width: puzzleSize,
                              height: puzzleSize,
                              child: Stack(
                                children: [
                                  // White Board
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                          isGameFinished ? 16 : 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Ghost Image
                                  Positioned.fill(
                                    child: Padding(
                                      padding: EdgeInsets.all(bgPadding),
                                      child: Opacity(
                                        opacity: 0.2,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            isGameFinished ? 0 : 12,
                                          ),
                                          child: Image.asset(
                                            level.imagePath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Pieces
                                  Positioned.fill(
                                    child: Padding(
                                      padding: EdgeInsets.all(bgPadding),
                                      child: Stack(
                                        children: [
                                          ...List.generate(
                                            level.gridSize * level.gridSize,
                                            (pieceId) {
                                              int currentGridIndex =
                                                  pieceCurrentPos[pieceId];
                                              int row =
                                                  currentGridIndex ~/
                                                  level.gridSize;
                                              int col =
                                                  currentGridIndex %
                                                  level.gridSize;

                                              double top =
                                                  row *
                                                  (pieceSize + pieceSpacing);
                                              double left =
                                                  col *
                                                  (pieceSize + pieceSpacing);

                                              return AnimatedPositioned(
                                                duration: const Duration(
                                                  milliseconds: 600,
                                                ),
                                                curve: Curves.easeInOutBack,
                                                top: top,
                                                left: left,
                                                child:
                                                    _buildDraggableTargetPiece(
                                                      pieceId,
                                                      pieceSize,
                                                      innerSize,
                                                      level,
                                                    ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Hand Tutorial
                                  if (showHandTutorial)
                                    Positioned(
                                      top: puzzleSize * 0.15,
                                      left: puzzleSize * 0.15,
                                      child: IgnorePointer(
                                        child: SlideTransition(
                                          position: _handSlideAnimation,
                                          child: ScaleTransition(
                                            scale: _handScaleAnimation,
                                            child: Image.asset(
                                              'assets/images/hand_pointer.png',
                                              width: 60,
                                              height: 60,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  if (isShuffling)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "Shuffling...",
                                          style: GoogleFonts.fredoka(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                    const Spacer(),

                    // Footer
                    SizedBox(
                      height: footerH,
                      child: Center(
                        child: Opacity(
                          opacity:
                              (isShuffling ||
                                  showHandTutorial ||
                                  isGameFinished)
                              ? 0.0
                              : 1.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/hand_pointer.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Drag to swap pieces",
                                  style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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

  // Widgets
  Widget _buildDraggableTargetPiece(
    int pieceId,
    double pieceSize,
    double totalSize,
    PuzzleLevel level,
  ) {
    if (isShuffling || isGameFinished) {
      return SizedBox(
        width: pieceSize,
        height: pieceSize,
        child: _buildImageTile(
          pieceId,
          totalSize,
          level.imagePath,
          level.gridSize,
          false,
        ),
      );
    }

    return DragTarget<int>(
      onAccept: (draggedId) => _onPieceDrop(draggedId, pieceId),
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: pieceId,
          feedback: Material(
            elevation: 10,
            color: Colors.transparent,
            child: SizedBox(
              width: pieceSize * 1.05,
              height: pieceSize * 1.05,
              child: _buildImageTile(
                pieceId,
                totalSize,
                level.imagePath,
                level.gridSize,
                true,
              ),
            ),
          ),
          childWhenDragging: Container(
            width: pieceSize,
            height: pieceSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: SizedBox(
            width: pieceSize,
            height: pieceSize,
            child: Stack(
              children: [
                _buildImageTile(
                  pieceId,
                  totalSize,
                  level.imagePath,
                  level.gridSize,
                  false,
                ),
                if (candidateData.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageTile(
    int id,
    double totalSize,
    String path,
    int gridSize,
    bool isFeedback,
  ) {
    int rowOriginal = id ~/ gridSize;
    int colOriginal = id % gridSize;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isGameFinished ? 0 : 6),
      child: FittedBox(
        fit: BoxFit.none,
        alignment: Alignment(
          (colOriginal / (gridSize - 1)) * 2 - 1,
          (rowOriginal / (gridSize - 1)) * 2 - 1,
        ),
        child: Image.asset(
          path,
          width: totalSize,
          height: totalSize,
          color: isGameFinished
              ? null
              : Colors.white.withOpacity(isFeedback ? 1.0 : 0.95),
          colorBlendMode: BlendMode.modulate,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _buildCompactHeader(PuzzleLevel level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: AppColors.gameSkyBlue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Fix the Image!",
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  level.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              "Level ${_currentIndex + 1}",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
