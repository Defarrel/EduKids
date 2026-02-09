import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/components/finish_games.dart';
import 'package:edukids_app/core/components/win_games.dart';
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
      title: "Mosque",
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

  // animation controller
  late AnimationController _entranceController;
  late Animation<double> _puzzleEntranceAnimation;

  @override
  void initState() {
    super.initState();

    AudioManager().playBgm('puzzle_bgm.mp3');

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _puzzleEntranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _entranceController.forward();

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
    AudioManager().playBgm('bgm.mp3');

    _handController.dispose();
    _confettiController.dispose();
    _entranceController.dispose();
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
      await Future.delayed(const Duration(milliseconds: 600));
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
      barrierLabel: "Finish",
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
    PuzzleLevel level = _levels[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.gameSkyBlue,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                "assets/images/bg_puzzle.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double w = constraints.maxWidth;
                double h = constraints.maxHeight;

                double headerHeight = h * 0.1;
                double footerHeight = h * 0.15;

                if (headerHeight < 70) headerHeight = 70;
                if (footerHeight < 60) footerHeight = 60;

                // Area tersedia untuk Puzzle
                double availableHeight = h - headerHeight - footerHeight;
                double availableWidth = w;

                double puzzleSize = min(availableWidth, availableHeight) - 24.0;

                if (puzzleSize < 0) puzzleSize = 0;

                double bgPadding = 6.0;
                double innerSize = puzzleSize - (bgPadding * 2);

                double pieceSpacing = isGameFinished ? 0 : 1.0;
                double pieceSize =
                    (innerSize - ((level.gridSize - 1) * pieceSpacing)) /
                    level.gridSize;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header Area
                    SizedBox(
                      height: headerHeight,
                      child: _buildCompactHeader(level),
                    ),

                    // Puzzle Area
                    Center(
                      child: ScaleTransition(
                        scale: _puzzleEntranceAnimation,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
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
                          child: isLoading
                              ? SizedBox(
                                  key: const ValueKey('loading_spinner'),
                                  width: puzzleSize,
                                  height: puzzleSize,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  key: ValueKey<int>(_currentIndex),
                                  width: puzzleSize,
                                  height: puzzleSize,
                                  child: AnimatedScale(
                                    scale: _isWinningZoom ? 1.05 : 1.0,
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
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Ghost Image
                                          Center(
                                            child: SizedBox(
                                              width: innerSize,
                                              height: innerSize,
                                              child: Opacity(
                                                opacity: 0.2,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        isGameFinished ? 0 : 4,
                                                      ),
                                                  child: Image.asset(
                                                    level.imagePath,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Pieces
                                          Positioned.fill(
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                bgPadding,
                                              ),
                                              child: Stack(
                                                children: [
                                                  ...List.generate(
                                                    level.gridSize *
                                                        level.gridSize,
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
                                                          (pieceSize +
                                                              pieceSpacing);
                                                      double left =
                                                          col *
                                                          (pieceSize +
                                                              pieceSpacing);

                                                      return AnimatedPositioned(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 600,
                                                            ),
                                                        curve: Curves
                                                            .easeInOutBack,
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
                                                      width: puzzleSize * 0.2,
                                                      height: puzzleSize * 0.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          if (isShuffling)
                                            Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                ),
                        ),
                      ),
                    ),

                    // Footer Area
                    SizedBox(
                      height: footerHeight,
                      width: double.infinity,
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
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/hand_pointer.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Drag to swap pieces",
                                  style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
          fit: BoxFit.fill,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Fix the Image!",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  level.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white),
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
}
