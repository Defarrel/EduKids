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

class _LearnToDrawMenuScreenState extends State<LearnToDrawMenuScreen> {
  // Data Template
  final List<Map<String, String>> _tracingPages = [
    {'title': 'Alif, Ba, Ta', 'image': 'assets/images/alif.svg'},
    {'title': 'Sa, Zaa', 'image': 'assets/images/sa.svg'},
    {'title': 'Allah', 'image': 'assets/images/allah.svg'},
    {'title': 'Muhammad', 'image': 'assets/images/muhammad.svg'},
  ];

  final Map<String, Uint8List> _savedDrawings = {};

  @override
  void initState() {
    super.initState();
    AudioManager().playBgm('puzzle_bgm.mp3');
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    Color primaryGreen = AppColors.gameGreen;

    return Scaffold(
      backgroundColor: primaryGreen,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: primaryGreen,
                image: const DecorationImage(
                  image: AssetImage("assets/images/bg_learn.jpeg"),
                  opacity: 1,
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          AudioManager().playSfx('bubble-pop.mp3');
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: primaryGreen,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Let's Draw!",
                              style: GoogleFonts.fredoka(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Choose a pattern to start",
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Menu Grid
                Expanded(
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

                      return _buildMenuCard(item, primaryGreen, savedImage);
                    },
                  ),
                ),
              ],
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
            // Image Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: savedImage != null
                    ? EdgeInsets
                          .zero 
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
                    : Hero(
                        tag: item['image']!,
                        child: SvgPicture.asset(
                          item['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),

            // Title Area
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
                  // Ubah icon jika sudah selesai
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
