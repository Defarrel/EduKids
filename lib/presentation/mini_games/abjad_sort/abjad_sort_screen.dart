import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:edukids_app/core/components/finish_games.dart';
import 'package:edukids_app/core/components/win_games.dart';
import 'package:edukids_app/data/abjad_sort/abjad_sort_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';

class AbjadSortScreen extends StatefulWidget {
  const AbjadSortScreen({super.key});

  @override
  State<AbjadSortScreen> createState() => _AbjadSortScreenState();
}

class _AbjadSortScreenState extends State<AbjadSortScreen>
    with TickerProviderStateMixin {
  // Data
  final List<AbjadLevel> _levels = [
    AbjadLevel(
      answer: "ALLAH",
      imagePath: 'assets/images/Lafadz_Allah.png',
      hint: "God the Creator",
    ),
    AbjadLevel(
      answer: "MUHAMMAD",
      imagePath: 'assets/images/Lafadz_Muhammad.png',
      hint: "Our Beloved Prophet",
    ),
    AbjadLevel(
      answer: "KABAH",
      imagePath: 'assets/images/kabah.png',
      hint: "Qibla for Muslims",
    ),
    AbjadLevel(
      answer: "MEDINA",
      imagePath: 'assets/images/madinah.png',
      hint: "The Prophet's City",
    ),
    AbjadLevel(
      answer: "QURAN",
      imagePath: 'assets/images/quran.png',
      hint: "The Holy Book",
    ),
  ];

  // State
  int _currentIndex = 0;
  List<String> _currentLetters = [];
  bool _isGameFinished = false;
  late ConfettiController _confettiController;

  // Hand Pointer State
  bool _showHandTutorial = false;
  late AnimationController _handController;
  late Animation<Offset> _handSlideAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('puzzle_bgm.mp3');

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animasi geser kanan-kiri
    _handSlideAnimation =
        Tween<Offset>(
          begin: const Offset(-0.85, 0.2),
          end: const Offset(0.5, 0.2),
        ).animate(
          CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
        );

    _initializeLevel();
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _confettiController.dispose();
    _handController.dispose();
    super.dispose();
  }

  // Logic
  void _initializeLevel() {
    setState(() {
      _isGameFinished = false;
      String word = _levels[_currentIndex].answer;
      _currentLetters = word.split('');

      do {
        _currentLetters.shuffle();
      } while (_currentLetters.join() == word);

      if (_currentIndex == 0) {
        _showHandTutorial = true;
        _handController.repeat(reverse: true);
      } else {
        _showHandTutorial = false;
        _handController.stop();
      }
    });
  }

  void _hideTutorial() {
    if (_showHandTutorial) {
      setState(() {
        _showHandTutorial = false;
      });
      _handController.stop();
    }
  }

  void _onSwap(int oldIndex, int newIndex) {
    if (_isGameFinished) return;
    _hideTutorial();

    AudioManager().playSfx('bubble-pop.mp3');
    HapticFeedback.lightImpact();

    setState(() {
      final String temp = _currentLetters[oldIndex];
      _currentLetters[oldIndex] = _currentLetters[newIndex];
      _currentLetters[newIndex] = temp;
    });

    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (_currentLetters.join() == _levels[_currentIndex].answer) {
      setState(() => _isGameFinished = true);
      AudioManager().playSfx('pop.mp3');
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 1000), _showWinDialog);
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
              opacity: 0.5,
              child: Image.asset(
                "assets/images/bg_abjad.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeaderWithHint(level),
                const Spacer(flex: 2),
                _buildImageArea(level),
                const Spacer(flex: 3),
                _buildLetterSlotsWithHand(),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header dengan Hint
  Widget _buildHeaderWithHint(AbjadLevel level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              children: [
                Text(
                  "Word Sort",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level.hint,
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

  Widget _buildImageArea(AbjadLevel level) {
    return AnimatedScale(
      scale: _isGameFinished ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Image.asset(level.imagePath, fit: BoxFit.contain),
      ),
    );
  }

  // Gabungan Huruf dan Hand Pointer
  Widget _buildLetterSlotsWithHand() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Layer Huruf
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_currentLetters.length, (index) {
              return _buildDraggableLetter(index, _currentLetters[index]);
            }),
          ),
        ),

        // Layer Hand Pointer
        if (_showHandTutorial)
          Positioned(
            bottom: -10,
            child: IgnorePointer(
              child: SlideTransition(
                position: _handSlideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/hand_pointer.png',
                      width: 50,
                      height: 50,
                    ),
                    Text(
                      'Drag and Drop',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDraggableLetter(int index, String char) {
    List<Color> colors = [
      AppColors.gameGreen,
      AppColors.gamePink,
      AppColors.gamePurple,
      AppColors.gameYellow,
      Colors.orangeAccent,
    ];
    Color tileColor = colors[index % colors.length];

    return DragTarget<int>(
      onAccept: (draggedIndex) => _onSwap(draggedIndex, index),
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: _buildLetterTile(char, tileColor, isFeedback: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildLetterTile(char, Colors.grey),
          ),
          child: _buildLetterTile(char, tileColor),
        );
      },
    );
  }

  Widget _buildLetterTile(String char, Color color, {bool isFeedback = false}) {
    return Container(
      width: 55,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        char,
        style: GoogleFonts.fredoka(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
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
}
