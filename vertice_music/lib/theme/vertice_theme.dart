import 'package:flutter/material.dart';

class VerticeColors {
  static const Color background = Color(0xFF090711);
  static const Color surface = Color(0xFF151226);
  static const Color surfaceElevated = Color(0xFF1E1936);
  static const Color purpleNeon = Color(0xFF922CFF);
  static const Color purpleLight = Color(0xFFC987FF);
  static const Color border = Color(0xFF30264C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8AED1);
  static const Color textMuted = Color(0xFF7A7094);
  static const Color error = Color(0xFFFF5C7A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC987FF),
      Color(0xFF922CFF),
      Color(0xFF4F139E),
    ],
  );

  static const LinearGradient screenGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF231144),
      Color(0xFF090711),
      Color(0xFF090711),
    ],
  );
}

class VerticeTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: VerticeColors.background,
      canvasColor: VerticeColors.background,
      colorScheme: const ColorScheme.dark(
        primary: VerticeColors.purpleNeon,
        secondary: VerticeColors.purpleLight,
        surface: VerticeColors.surface,
        error: VerticeColors.error,
        onPrimary: VerticeColors.textPrimary,
        onSecondary: VerticeColors.background,
        onSurface: VerticeColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: VerticeColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: VerticeColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: VerticeColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: VerticeColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VerticeColors.surface,
        hintStyle: const TextStyle(color: VerticeColors.textMuted, fontSize: 14),
        prefixIconColor: VerticeColors.purpleLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VerticeColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VerticeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VerticeColors.purpleNeon, width: 1.5),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: VerticeColors.textPrimary,
        displayColor: VerticeColors.textPrimary,
      ),
    );
  }
}
