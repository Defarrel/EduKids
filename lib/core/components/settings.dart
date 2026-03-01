import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart'; 

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool _isBgmOn;
  late bool _isSfxOn;
  bool _isVibrationOn = true;

  final Color _greenPrimary = const Color(0xFF2E7D32);
  final Color _greenLight = const Color(0xFF66BB6A);

  @override
  void initState() {
    super.initState();
    _isBgmOn = AudioManager().isBgmOn;
    _isSfxOn = AudioManager().isSfxOn;
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Cek status bahasa saat ini langsung dari easy_localization
    bool isEn = context.locale.languageCode == 'en';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.05,
      ),
      child: Center(
        child: SizedBox(
          width: screenWidth * 0.6,
          height: screenHeight * 0.8,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Panel Background
              Container(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.09,
                  bottom: screenHeight * 0.03,
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: _greenPrimary.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SETTINGS".tr(), 
                      style: GoogleFonts.fredoka(
                        fontSize: screenHeight * 0.06,
                        fontWeight: FontWeight.w700,
                        color: _greenPrimary,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(2, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Scrollable Area
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildGameRow(
                              title: "Music".tr(), // Gunakan .tr()
                              icon: Icons.music_note_rounded,
                              color: AppColors.settingPink,
                              value: _isBgmOn,
                              screenHeight: screenHeight,
                              onChanged: (val) {
                                setState(() {
                                  _isBgmOn = val;
                                  AudioManager().toggleBGM(val);
                                  if (_isVibrationOn)
                                    HapticFeedback.selectionClick();
                                  AudioManager().playSfx('bubble-pop.mp3');
                                });
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            _buildGameRow(
                              title: "Sound FX".tr(), // Gunakan .tr()
                              icon: Icons.volume_up_rounded,
                              color: _greenLight,
                              value: _isSfxOn,
                              screenHeight: screenHeight,
                              onChanged: (val) {
                                setState(() {
                                  _isSfxOn = val;
                                  AudioManager().toggleSFX(val);
                                  if (_isVibrationOn)
                                    HapticFeedback.selectionClick();
                                  if (val)
                                    AudioManager().playSfx('bubble-pop.mp3');
                                });
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            _buildGameRow(
                              title: "Vibration".tr(), // Gunakan .tr()
                              icon: Icons.vibration_rounded,
                              color: AppColors.settingPurple,
                              value: _isVibrationOn,
                              screenHeight: screenHeight,
                              onChanged: (val) {
                                setState(() {
                                  _isVibrationOn = val;
                                  if (val) HapticFeedback.heavyImpact();
                                  AudioManager().playSfx('bubble-pop.mp3');
                                });
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            _buildLanguageRow(
                              title: "Language".tr(), // Gunakan .tr()
                              icon: Icons.language_rounded,
                              color: Colors.blueAccent,
                              isEnglish: isEn,
                              screenHeight: screenHeight,
                              onChanged: (newIsEn) {
                                // Ganti bahasa global
                                if (newIsEn) {
                                  context.setLocale(const Locale('en'));
                                } else {
                                  context.setLocale(const Locale('zh'));
                                }

                                if (_isVibrationOn)
                                  HapticFeedback.selectionClick();
                                AudioManager().playSfx('bubble-pop.mp3');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    GestureDetector(
                      onTap: () {
                        if (_isVibrationOn) HapticFeedback.mediumImpact();
                        AudioManager().playSfx('bubble-pop.mp3');
                        Navigator.of(context).pop();
                      },
                      child: _buildGlossyOkButton(screenHeight, screenWidth),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: -screenHeight * 0.07,
                child: Container(
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _greenPrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: _greenPrimary, width: 4),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    size: screenHeight * 0.09,
                    color: _greenPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row Item Biasa
  Widget _buildGameRow({
    required String title,
    required IconData icon,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
    required double screenHeight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: screenHeight * 0.035),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: screenHeight * 0.05,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
            ),
          ),
          _buildCustomToggle(value, onChanged, color, screenHeight),
        ],
      ),
    );
  }

  // Row Khusus Bahasa
  Widget _buildLanguageRow({
    required String title,
    required IconData icon,
    required Color color,
    required bool isEnglish,
    required Function(bool) onChanged,
    required double screenHeight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: screenHeight * 0.035),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: screenHeight * 0.05,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
            ),
          ),
          _buildLanguageToggle(isEnglish, onChanged, color, screenHeight),
        ],
      ),
    );
  }

  // Toggle Biasa (ON/OFF)
  Widget _buildCustomToggle(
    bool value,
    Function(bool) onChanged,
    Color activeColor,
    double screenHeight,
  ) {
    double width = screenHeight * 0.12;
    double height = screenHeight * 0.06;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: value ? activeColor : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: Container(
            width: height - 8,
            height: height - 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              value ? Icons.check_rounded : Icons.close_rounded,
              size: height * 0.4,
              color: value ? activeColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Toggle Bahasa (EN / 繁)
  Widget _buildLanguageToggle(
    bool isEnglish,
    Function(bool) onChanged,
    Color activeColor,
    double screenHeight,
  ) {
    double width = screenHeight * 0.12;
    double height = screenHeight * 0.06;

    return GestureDetector(
      onTap: () => onChanged(!isEnglish),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: isEnglish ? activeColor : Colors.orangeAccent,
        ),
        child: AnimatedAlign(
          alignment: isEnglish ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: Container(
            width: height - 8,
            height: height - 8,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              isEnglish ? "EN" : "繁",
              style: GoogleFonts.fredoka(
                color: isEnglish ? activeColor : Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: height * 0.35,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // OK Button
  Widget _buildGlossyOkButton(double screenHeight, double screenWidth) {
    double btnHeight = screenHeight * 0.1;
    double btnWidth = screenWidth * 0.25;

    return Container(
      width: btnWidth,
      height: btnHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: _greenPrimary.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_greenLight, _greenPrimary],
        ),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: btnHeight * 0.5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(46),
                  bottom: Radius.elliptical(100, 30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "OK".tr(), // Gunakan .tr()
            style: GoogleFonts.fredoka(
              fontSize: btnHeight * 0.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  offset: const Offset(1, 2),
                  color: _greenPrimary.withOpacity(0.8),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
