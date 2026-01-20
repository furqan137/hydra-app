import 'package:flutter/material.dart';

class AppThemes {
  // ================= DARK THEME =================
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 🔥 SYSTEM SAFE: only override what is needed
    scaffoldBackgroundColor: const Color(0xFF050B18),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0FB9B1),
      secondary: Color(0xFF1FA2FF),
      surface: Color(0xFF101B2B),
      background: Color(0xFF050B18),

      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,

      error: Colors.redAccent,
      onError: Colors.white,
    ),

    // ================= APP BAR =================
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF050B18),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ================= SURFACES =================
    cardColor: const Color(0xFF101B2B),
    dividerColor: Colors.white12,

    // ================= ICONS =================
    iconTheme: const IconThemeData(color: Colors.white),

    // ================= TEXT =================
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        color: Colors.white60,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ================= BUTTONS =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0FB9B1),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0FB9B1),
      ),
    ),

    // ================= INPUT =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF101B2B),
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0FB9B1),
          width: 1.2,
        ),
      ),
    ),
  );

  // ================= LIGHT THEME =================
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 🔥 SYSTEM SAFE
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0FB9B1),
      secondary: Color(0xFF1FA2FF),
      surface: Colors.white,
      background: Color(0xFFF6F7FB),

      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF111827),
      onBackground: Color(0xFF111827),

      error: Colors.redAccent,
      onError: Colors.white,
    ),

    // ================= APP BAR =================
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

    // ================= SURFACES =================
    cardColor: Colors.white,
    dividerColor: Colors.black12,

    // ================= ICONS =================
    iconTheme: const IconThemeData(color: Color(0xFF374151)),

    // ================= TEXT =================
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF1F2937),
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF374151),
      ),
      bodySmall: TextStyle(
        color: Color(0xFF6B7280),
      ),
      labelLarge: TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w600,
      ),
    ),

    // ================= BUTTONS =================
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

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0FB9B1),
      ),
    ),

    // ================= INPUT =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      labelStyle: const TextStyle(color: Color(0xFF374151)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0FB9B1),
          width: 1.2,
        ),
      ),
    ),
  );
}
