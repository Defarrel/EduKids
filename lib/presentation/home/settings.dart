import 'package:edukids_app/core/audio/audio_manager.dart';
import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // --- STATE VARIABLES ---
  late bool _isBgmOn;
  late bool _isSfxOn;
  bool _isVibrationOn = true;

  @override
  void initState() {
    super.initState();
    // 1. SINKRONISASI DATA DARI AUDIO MANAGER
    _isBgmOn = AudioManager().isBgmOn;
    _isSfxOn = AudioManager().isSfxOn;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(AppSize.paddingMedium()),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // --- MAIN CARD (BACKGROUND) ---
          Container(
            padding: EdgeInsets.only(
              top: AppSize.scaleHeight(60), // Space untuk Header Icon
              bottom: AppSize.paddingMedium(),
              left: AppSize.paddingMedium(),
              right: AppSize.paddingMedium(),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // JUDUL
                  Text(
                    "SETTINGS",
                    style: GoogleFonts.poppins(
                      fontSize: AppSize.fontLarge(),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSize.gapM()),

                  // 1. MUSIC (SWITCH) - KEMBALI SEPERTI SEMULA
                  _buildSwitchItem(
                    title: "Music",
                    icon: Icons.music_note_rounded,
                    iconColor: Colors.pinkAccent,
                    value: _isBgmOn,
                    onChanged: (val) {
                      setState(() {
                        _isBgmOn = val;
                        // Panggil Toggle BGM di Manager
                        AudioManager().toggleBGM(val);

                        if (_isVibrationOn) HapticFeedback.selectionClick();
                      });
                    },
                  ),

                  _buildDivider(),

                  // 2. SOUND EFFECTS (SWITCH)
                  _buildSwitchItem(
                    title: "Sound Effects",
                    icon: Icons.volume_up_rounded,
                    iconColor: Colors.blueAccent,
                    value: _isSfxOn,
                    onChanged: (val) {
                      setState(() {
                        _isSfxOn = val;
                        // Panggil Toggle SFX di Manager
                        AudioManager().toggleSFX(val);

                        if (_isVibrationOn) HapticFeedback.selectionClick();
                      });
                    },
                  ),

                  _buildDivider(),

                  // 3. VIBRATION (SWITCH)
                  _buildSwitchItem(
                    title: "Vibration",
                    icon: Icons.vibration_rounded,
                    iconColor: Colors.orangeAccent,
                    value: _isVibrationOn,
                    onChanged: (val) {
                      setState(() {
                        _isVibrationOn = val;
                        if (val) HapticFeedback.heavyImpact();
                      });
                    },
                  ),

                  SizedBox(height: AppSize.gapL()),

                  // --- OK BUTTON ---
                  GestureDetector(
                    onTap: () {
                      if (_isVibrationOn) HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.scaleWidth(40),
                        vertical: AppSize.scaleHeight(10),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "OK",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize.fontMedium(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- HEADER ICON (Gear) ---
          Positioned(
            top: -AppSize.scaleWidth(35),
            child: Container(
              padding: EdgeInsets.all(AppSize.paddingSmall()),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
              ),
              child: Icon(
                Icons.settings_rounded,
                size: AppSize.scaleWidth(50),
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: SWITCH ROW ---
  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.gapS()),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: AppSize.scaleWidth(24)),
          ),
          SizedBox(width: AppSize.gapM()),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: AppSize.fontMedium(),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Garis Pembatas
  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 1.5,
      height: AppSize.gapM(),
    );
  }
}
