import 'package:flutter/material.dart';

class AppColors {
  static const Color oldLace = Color(0xFFF4EEE2);
  static const Color offBlack = Color(0xFF21242C);
  static const Color offBlack70 = Color(0xB321242C); // 70% opacity
  static const Color hairlineGray = Color(0xFFDBDCDD);
  static const Color navyDoesntHurt = Color(0xFF0B2149);
  static const Color grey = Color(0xFFF5F5F5); // whitesmoke
  static const Color sage = Color(0xFFC3D2AC);
  static const Color richardsons = Color(0xFFB6D2DA);
  static const Color blossom = Color(0xFFD6AFBC);
  static const Color peach = Color(0xFFEEAC7A);
  static const Color lemon = Color(0xFFFCB500);
  static const Color blueberry = Color(0xFF4832D9);
  static const Color wine = Color(0xFF5F1E5C);
  static const Color carrot = Color(0xFFF46A37);
  static const Color butterscotch = Color(0xFFDAB773);
  static const Color raisin = Color(0xFF54314C);
  static const Color jam = Color(0xFFAC4343);
  static const Color collard = Color(0xFF2C533C);
  static const Color cobalt = Color(0xFF1865F2);
  static const Color rind = Color(0xFF5BA26F);

  // Additional utility colors based on the palette
  static const Color primaryBackground = Color.fromARGB(255, 255, 252, 244);
  static const Color primaryText = offBlack;
  static const Color secondaryText = offBlack70;
  static const Color borderColor = hairlineGray;
  static const Color accent = lemon;
  static const Color success = rind;
  static const Color warning = carrot;
  static const Color error = jam;
  static const Color info = cobalt;

  // MaterialColor swatches (for theme usage)
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red /*(*.r * 255.0).round() */,
        g = color.green,
        b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  // Primary MaterialColor swatches
  static MaterialColor get primarySwatch => createMaterialColor(navyDoesntHurt);
  static MaterialColor get accentSwatch => createMaterialColor(lemon);
  static MaterialColor get successSwatch => createMaterialColor(rind);
}