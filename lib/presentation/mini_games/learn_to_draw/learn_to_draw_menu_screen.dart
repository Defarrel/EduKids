import 'dart:math';
import 'dart:typed_data';
import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:edukids_app/presentation/mini_games/learn_to_draw/learn_to_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnToDrawMenuScreen extends StatefulWidget {
  const LearnToDrawMenuScreen({super.key});

  @override
  State<LearnToDrawMenuScreen> createState() => _LearnToDrawMenuScreenState();
}

class _LearnToDrawMenuScreenState extends State<LearnToDrawMenuScreen>
    with TickerProviderStateMixin {
  final List<Map<String, String>> _tracingPages = [
    {'title': 'Alif, Ba, Ta', 'image': 'assets/images/alif.svg'},
    {'title': 'Sa, Zaa', 'image': 'assets/images/sa.svg'},
    {'title': 'Allah', 'image': 'assets/images/allah.svg'},
    {'title': 'Muhammad', 'image': 'assets/images/muhammad.svg'},
  ];

  final Map<String, Uint8List> _savedDrawings = {};

  // Animation Controllers
  late AnimationController _entranceController;
  late Animation<double> _headerAnimation;
  late Animation<double> _gridAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('bgm_draw.mp3');

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _gridAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    AudioManager().playBgm('bgm.mp3');
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    Color primaryGreen = AppColors.gameGreen;

    return Scaffold(
      backgroundColor: primaryGreen,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg_learn.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double h = constraints.maxHeight;
                double headerH = max(h * 0.1, 70.0);

                return Column(
                  children: [
                    ScaleTransition(
                      scale: _headerAnimation,
                      child: SizedBox(
                        height: headerH,
                        child: _buildHeader(primaryGreen),
                      ),
                    ),

                    Expanded(
                      child: ScaleTransition(
                        scale: _gridAnimation,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: _tracingPages.length,
                          itemBuilder: (context, index) {
                            final item = _tracingPages[index];
                            final savedImage = _savedDrawings[item['title']];
                            return _buildMenuCard(
                              item,
                              primaryGreen,
                              savedImage,
                            );
                          },
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

  // Header dan Menu Card 
  Widget _buildHeader(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: themeColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's Draw!",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 7),
                    ],
                  ),
                ),
                Text(
                  "Choose a pattern",
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 7),
                    ],
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
              "Menu",
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

  Widget _buildMenuCard(
    Map<String, String> item,
    Color themeColor,
    Uint8List? savedImage,
  ) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        AudioManager().playSfx('bubble-pop.mp3');

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LearnToDrawScreen(
              templateImage: item['image']!,
              initialImage: savedImage,
            ),
          ),
        );

        if (result != null && result is Uint8List) {
          setState(() {
            _savedDrawings[item['title']!] = result;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 8),
              blurRadius: 15,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: savedImage != null
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(23),
                  ),
                ),
                child: savedImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(23),
                        ),
                        child: Image.memory(savedImage, fit: BoxFit.cover),
                      )
                    : SvgPicture.asset(item['image']!, fit: BoxFit.contain),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item['title']!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                  ),
                  Icon(
                    savedImage != null
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    color: savedImage != null ? Colors.orange : themeColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
