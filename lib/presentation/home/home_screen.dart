import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/presentation/home/settings.dart';
import 'package:edukids_app/presentation/mini_games/home_mini_games/home_mini_games_screen.dart';
import 'package:flutter/material.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 1. GANTI Mixin jadi TickerProviderStateMixin (wajib jika controller > 1)
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controller Tombol Play
  late AnimationController _btnController;
  late Animation<double> _btnScaleAnimation;

  // Controller Logo (BARU)
  late AnimationController _logoFloatingController;
  late Animation<Offset> _logoFloatingAnimation;

  @override
  void initState() {
    super.initState();

    // --- 1. SETUP ANIMASI TOMBOL (Pulse) ---
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _btnScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));

    _btnController.repeat(reverse: true);

    // --- 2. SETUP ANIMASI LOGO (Floating/Mengapung) ---
    _logoFloatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Durasi satu gerakan naik/turun
    );

    _logoFloatingAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.05), // Bergerak naik sedikit (5%)
        ).animate(
          CurvedAnimation(
            parent: _logoFloatingController,
            curve: Curves.easeInOut, // Gerakan halus
          ),
        );

    // Jalankan animasi logo berulang (naik-turun)
    _logoFloatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _btnController.dispose();
    _logoFloatingController.dispose(); // Wajib dispose controller baru
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // --- 1. SETTINGS BUTTON (DI KIRI ATAS) ---
              Positioned(
                top: AppSize.paddingMedium(),
                left: AppSize.paddingMedium(),
                child: _buildSettingsButton(),
              ),

              // --- 2. COIN BADGE (DI KANAN ATAS) ---
              Positioned(
                top: AppSize.paddingMedium(),
                right: AppSize.paddingMedium(),
                child: _buildModernCoinBadge(),
              ),

              // --- 3. CENTER: LOGO & BUTTON ---
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO (DIBUNGKUS SLIDE TRANSITION)
                    SlideTransition(
                      position:
                          _logoFloatingAnimation, // Pasang animasi di sini
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo_sementara.png',
                          width: AppSize.scaleWidth(320),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSize.scaleHeight(50)),

                    // PLAY BUTTON
                    ScaleTransition(
                      scale: _btnScaleAnimation,
                      child: GestureDetector(
                        onTap: () {
                          AudioManager().playSfx('bubble-pop.mp3');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeMiniGamesScreen(),
                            ),
                          );
                        },
                        child: _buildShinyButton(),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 4. FOOTER TEXT ---
              Positioned(
                bottom: AppSize.paddingMedium(),
                left: 0,
                right: 0,
                child: Text(
                  "Learn About Tauhid\nwith EduKids",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: AppSize.fontSmall(),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  // 1. TOMBOL SETTINGS BULAT
  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () {
        print("Settings Clicked");
        HapticFeedback.mediumImpact();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0.5, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(scale: value, child: const Settings());
              },
            );
          },
        );
      },
      child: Container(
        width: AppSize.scaleWidth(46),
        height: AppSize.scaleWidth(46),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFD54F), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.settings_rounded,
          color: AppColors.textSecondary,
          size: AppSize.scaleWidth(26),
        ),
      ),
    );
  }

  // 2. WIDGET COIN BADGE
  Widget _buildModernCoinBadge() {
    return Stack(
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: AppSize.scaleWidth(34),
            right: AppSize.scaleWidth(16),
            top: AppSize.scaleHeight(8),
            bottom: AppSize.scaleHeight(8),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFFD54F), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            "100",
            style: TextStyle(
              fontSize: AppSize.fontLarge(),
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFF8F00),
            ),
          ),
        ),
        Positioned(
          left: -AppSize.scaleWidth(6),
          child: Container(
            width: AppSize.scaleWidth(42),
            height: AppSize.scaleWidth(42),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFECB3), Color(0xFFFFCA28)],
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.star_rounded,
              color: const Color(0xFFF57F17),
              size: AppSize.scaleWidth(28),
            ),
          ),
        ),
      ],
    );
  }

  // 3. WIDGET SHINY BUTTON
  Widget _buildShinyButton() {
    return Container(
      width: AppSize.scaleWidth(240),
      height: AppSize.scaleHeight(75),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF66FF82), Color(0xFF4CD964), Color(0xFF2E7D32)],
          stops: [0.0, 0.4, 1.0],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.5),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            left: 20,
            right: 20,
            height: 25,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: AppSize.scaleWidth(38),
                ),
                SizedBox(width: AppSize.scaleWidth(10)),
                Text(
                  "PLAY NOW",
                  style: GoogleFonts.poppins(
                    fontSize: AppSize.fontXL(),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
