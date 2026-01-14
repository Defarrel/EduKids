import 'package:flutter/material.dart';

class AppSize {
  static late double screenWidth;
  static late double screenHeight;

  static const double baseWidth = 390;
  static const double baseHeight = 844;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  static double scaleWidth(double size) {
    return size * screenWidth / baseWidth;
  }

  static double scaleHeight(double size) {
    return size * screenHeight / baseHeight;
  }

  static double paddingSmall() => scaleWidth(8);
  static double paddingMedium() => scaleWidth(16);
  static double paddingLarge() => scaleWidth(24);

  static double radiusSmall() => scaleWidth(8);
  static double radiusMedium() => scaleWidth(16);
  static double radiusLarge() => scaleWidth(24);

  static double gapS() => scaleHeight(8);
  static double gapM() => scaleHeight(16);
  static double gapL() => scaleHeight(24);

  static double fontSmall() => scaleWidth(12);
  static double fontMedium() => scaleWidth(16);
  static double fontLarge() => scaleWidth(20);
  static double fontXL() => scaleWidth(28);
}
