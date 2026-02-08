import 'package:flutter/material.dart';

class AppColors {
  // --- 1. MAIN BACKGROUND (Pastel Gradient) ---
  // Digunakan di HomeScreen & SplashScreen
  static const bgCyan = Color(0xFF89f7fe);
  static const bgBlue = Color(0xFF66a6ff);
  static const bgPurple = Color(0xFFE0C3FC);
  static const bgCream = Color(0xFFFFFBEB); // Background Mini Games Screen

  // --- 2. UI BUTTONS (Soft Cloud / Glossy Style) ---
  // Digunakan untuk tombol "Play Now" dan "OK"
  static const btnCyanLight = Color(0xFF38F9D7); // Gradient Atas
  static const btnBlueMain = Color(0xFF4FACFE);  // Gradient Bawah & Shadow

  // --- 3. MINI GAMES CARDS (Vibrant Colors) ---
  // Digunakan untuk kartu game agar mencolok
  static const gameOrange = Color(0xFFFF9F1C); // Header Text "Fun Games!"
  static const gameSkyBlue = Color(0xFF4CC9F0); // Puzzle
  static const gamePink = Color(0xFFF72585);    // True/False
  static const gameYellow = Color(0xFFFFD166);  // Coloring
  static const gameGreen = Color(0xFF06D6A0);   // Drawing
  static const gamePurple = Color(0xFF9D4EDD);  // Sorting
    static const gameRed = Color.fromARGB(255, 205, 13, 58);  // Right or Wrong

  // --- 4. SETTINGS ICONS (Soft Pastels) ---
  // Digunakan untuk icon di menu Settings
  static const settingPink = Color(0xFFFF9A9E); // Music Icon
  static const settingGreen = Color(0xFF84FAB0); // Sound FX Icon
  static const settingPurple = Color(0xFFFBC2EB); // Vibration Icon

  // --- 5. TEXT & NEUTRALS ---
  static const textPrimary = Color(0xFF1E1E1E);
  static const textSecondary = Color(0xFF555555);
  static const white = Colors.white;
  static const grey = Color(0xFF9E9E9E);
}