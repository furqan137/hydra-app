import 'package:flutter/material.dart';

class AppThemes {
  // ================= DARK (DEFAULT / SYSTEM) =================
  // ❗ DO NOT CHANGE – your app already works perfectly here
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xFF050B18),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0FB9B1),
      secondary: Color(0xFF1FA2FF),
      background: Color(0xFF050B18),
      surface: Color(0xFF101B2B),
      onPrimary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF050B18),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardColor: const Color(0xFF101B2B),
    dividerColor: Colors.white12,

    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
  );

  // ================= LIGHT MODE (NEW & FIXED) =================
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xFFF6F7FB),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0FB9B1),
      secondary: Color(0xFF1FA2FF),
      background: Color(0xFFF6F7FB),
      surface: Colors.white,
      onPrimary: Colors.white,
      onBackground: Color(0xFF111827),
      onSurface: Color(0xFF111827),
    ),

    // ✅ APP BAR – CLEAN & READABLE
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111827),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF111827)),
      titleTextStyle: TextStyle(
        color: Color(0xFF111827),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ✅ CARDS / TILES
    cardColor: Colors.white,
    dividerColor: Colors.black12,

    // ✅ ICONS
    iconTheme: const IconThemeData(
      color: Color(0xFF374151),
    ),

    // ✅ TEXT – NO GREY CONFUSION
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF374151),
      ),
      bodySmall: TextStyle(
        color: Color(0xFF6B7280),
      ),
    ),

    // ✅ BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0FB9B1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),

    // ✅ INPUTS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
