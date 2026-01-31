import 'dart:async';
import 'dart:ui'; // Diperlukan untuk efek kaca (jika pakai BackdropFilter)
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMiniGamesScreen extends StatefulWidget {
  const HomeMiniGamesScreen({super.key});

  @override
  State<HomeMiniGamesScreen> createState() => _HomeMiniGamesScreenState();
}

class _HomeMiniGamesScreenState extends State<HomeMiniGamesScreen> {
  // --- DATA GAMES ---
  final List<Map<String, dynamic>> _games = [
    {
      "title": "Creator's\nMatch",
      "color": const Color(0xFFFF9800), // Orange Block
      "icon": Icons.volunteer_activism_rounded,
      "route": "/game-creator",
      "locked": false,
      "isNew": true, // Penanda game baru
    },
    {
      "title": "Halal Food\nRun",
      "color": const Color(0xFF4CAF50), // Green Block
      "icon": Icons.fastfood_rounded,
      "route": "/game-halal",
      "locked": false,
      "isNew": false,
    },
    {
      "title": "Wudu\nPuzzle",
      "color": const Color(0xFF2196F3), // Blue Block
      "icon": Icons.water_drop_rounded,
      "route": "/game-wudu",
      "locked": true,
      "isNew": false,
    },
    {
      "title": "Shadow\nMatch",
      "color": const Color(0xFF9C27B0), // Purple Block
      "icon": Icons.light_mode_rounded,
      "route": "/game-shadow",
      "locked": true,
      "isNew": false,
    },
    {
      "title": "Hijaiyah\nPop",
      "color": const Color(0xFFE91E63), // Pink Block
      "icon": Icons.audiotrack_rounded,
      "route": "/game-hijaiyah",
      "locked": true,
      "isNew": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // BACKGROUND BERGAMBAR/GRADIENT
        // Kita beri sedikit corak kotak-kotak samar agar kesan Minecraft terasa di bg
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. HEADER (Back & Title) ---
              Padding(
                padding: EdgeInsets.all(AppSize.paddingMedium()),
                child: Row(
                  children: [
                    _buildGlassBackButton(context),
                    SizedBox(width: AppSize.gapM()),
                    Text(
                      "World of Games",
                      style: GoogleFonts.vt323(
                        // Font Pixelated jika ada, atau Poppins Bold
                        fontSize: 32, // Ukuran besar
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 0, // Hard shadow text
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. GRID GAMES ---
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.paddingMedium(),
                    0,
                    AppSize.paddingMedium(),
                    AppSize.paddingMedium(),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSize.scaleWidth(15),
                    mainAxisSpacing: AppSize.scaleWidth(15),
                    childAspectRatio: 0.8, // Sedikit lebih tinggi
                  ),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];

                    // Kita gunakan Widget terpisah agar bisa punya Controller animasi sendiri
                    return _GlassBlockCard(
                      index: index,
                      gameData: game,
                      // Logika: Game pertama (index 0) dan tidak dikunci adalah "Active"
                      isActiveGame: index == 0 && !game['locked'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), // Kaca transparan
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ==========================================================
// WIDGET KARTU GAME "GLASS BLOCK" (STATEFUL UNTUK ANIMASI)
// ==========================================================
class _GlassBlockCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> gameData;
  final bool isActiveGame;

  const _GlassBlockCard({
    required this.index,
    required this.gameData,
    required this.isActiveGame,
  });

  @override
  State<_GlassBlockCard> createState() => _GlassBlockCardState();
}

class _GlassBlockCardState extends State<_GlassBlockCard>
    with SingleTickerProviderStateMixin {
  // Controller untuk animasi "Breathing" (Active Game)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Variable untuk animasi Entry
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    // 1. SETUP ANIMASI PULSE (Hanya untuk Active Game)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActiveGame) {
      _pulseController.repeat(reverse: true);
    }

    // 2. SETUP ANIMASI ENTRY (Delay berdasarkan index)
    // Semakin besar index, semakin lama delay munculnya
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.gameData['color'] as Color;
    final isLocked = widget.gameData['locked'] as bool;

    // ANIMASI 1: ENTRY (Slide Up + Fade In)
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: _isVisible
            ? Offset.zero
            : const Offset(0, 0.2), // Dari bawah sedikit
        curve: Curves.elasticOut, // Efek memantul saat mendarat
        child: _buildCardContent(color, isLocked),
      ),
    );
  }

  Widget _buildCardContent(Color color, bool isLocked) {
    return ScaleTransition(
      scale: widget.isActiveGame
          ? _pulseAnimation
          : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            HapticFeedback.vibrate();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Ups! Selesaikan level sebelumnya dulu ya.",
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            HapticFeedback.heavyImpact();
            // AudioManager().playSfx('pop.mp3'); // Jangan lupa nyalakan sfx
            print("Buka Game");
          }
        },
        child: Container(
          // --- STYLE GLASS BLOCK ---
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLocked
                  ? [Colors.grey.withOpacity(0.4), Colors.grey.withOpacity(0.1)]
                  : [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLocked
                  ? Colors.grey.shade400
                  : Colors.white.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isLocked ? Colors.black : color).withOpacity(0.3),
                offset: const Offset(6, 6),
                blurRadius: 0, // HARD SHADOW
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // 1. Dekorasi Kilauan (Pojok Kiri Atas)
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // 2. CONTENT UTAMA (DIBUNGKUS CENTER AGAR DI TENGAH)
                Center(
                  // <--- TAMBAHKAN WIDGET INI
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Vertikal tengah
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Horizontal tengah
                    children: [
                      // ICON DALAM KOTAK
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.black12
                              : color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLocked
                                ? Colors.transparent
                                : color.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isLocked
                              ? Icons.lock_outline_rounded
                              : widget.gameData['icon'],
                          size: 32,
                          color: isLocked ? Colors.white60 : color,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TEXT JUDUL
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          widget.gameData['title'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isLocked ? Colors.white60 : Colors.white,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. INDICATOR "START!"
                if (widget.isActiveGame)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        "START!",
                        style: GoogleFonts.vt323(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
