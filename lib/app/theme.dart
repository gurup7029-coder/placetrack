import 'package:flutter/material.dart';

class PlaceTrackTheme {
  // Brand colors
  static const Color primary = Color(0xFF1A56DB);      // Indigo blue
  static const Color secondary = Color(0xFF7E3AF2);    // Violet
  static const Color accent = Color(0xFF0E9F6E);       // Emerald green
  static const Color surface = Color(0xFFF9FAFB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111928);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color danger = Color(0xFFE02424);

  // Dark mode colors
  static const Color darkBg = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Dynamic Theme Helpers based on current ThemeMode / Brightness
  static Color primaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color secondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }

  static Color cardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : cardBg;
  }

  static Color surfaceBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : border;
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Inter'),
        hintStyle: const TextStyle(color: textSecondary, fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEF2FF),
        labelStyle: const TextStyle(color: primary, fontFamily: 'Inter', fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      cardColor: darkCard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: const Color(0xFF3B82F6),
        secondary: const Color(0xFFA855F7),
        surface: darkCard,
        error: const Color(0xFFEF4444),
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: darkBg,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkTextPrimary, fontFamily: 'Inter'),
        bodyMedium: TextStyle(color: darkTextPrimary, fontFamily: 'Inter'),
        bodySmall: TextStyle(color: darkTextSecondary, fontFamily: 'Inter'),
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        titleSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCard,
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        contentTextStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, fontFamily: 'Inter'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFFEF4444)),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary, fontFamily: 'Inter'),
        hintStyle: const TextStyle(color: darkTextSecondary, fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF60A5FA),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: const TextStyle(color: Color(0xFF93C5FD), fontFamily: 'Inter', fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: darkBorder),
      ),
    );
  }

  // ==========================================
  // EXCLUSIVE WEB-ONLY THEME (High-Tech Enterprise Navy & Cyan)
  // ==========================================
  static ThemeData webDark() {
    const webBg = Color(0xFF070B14);           // Deep obsidian navy
    const webSurface = Color(0xFF0D1424);      // Sleek surface
    const webCard = Color(0xFF131D33);         // Glass navy card
    const webBorder = Color(0xFF1E2D4D);       // Soft tech border
    const webPrimary = Color(0xFF4F46E5);      // Electric Indigo
    const webAccent = Color(0xFF06B6D4);       // Neon Cyan
    const webSecondary = Color(0xFF8B5CF6);    // Violet
    const webTextPrimary = Color(0xFFF1F5F9);  // Crisp white
    const webTextSecondary = Color(0xFF94A3B8);// Muted silver

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      cardColor: webCard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: webPrimary,
        brightness: Brightness.dark,
        primary: webPrimary,
        secondary: webSecondary,
        surface: webCard,
        error: const Color(0xFFF43F5E),
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: webBg,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: webTextPrimary, fontFamily: 'Inter'),
        bodyMedium: TextStyle(color: webTextPrimary, fontFamily: 'Inter'),
        bodySmall: TextStyle(color: webTextSecondary, fontFamily: 'Inter'),
        titleLarge: TextStyle(color: webTextPrimary, fontWeight: FontWeight.bold, fontFamily: 'Inter', letterSpacing: -0.5),
        titleMedium: TextStyle(color: webTextPrimary, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        titleSmall: TextStyle(color: webTextPrimary, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: webCard,
        titleTextStyle: TextStyle(color: webTextPrimary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        contentTextStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, fontFamily: 'Inter'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: webSurface,
        foregroundColor: webTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: webTextPrimary,
          fontSize: 19,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: webCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: webBorder, width: 1.2),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A101D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: webBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: webBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: webAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: webTextSecondary, fontFamily: 'Inter'),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: webPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: webAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        ),
      ),
      dividerTheme: const DividerThemeData(color: webBorder, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF131D33),
        labelStyle: const TextStyle(color: webAccent, fontFamily: 'Inter', fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: webBorder),
      ),
    );
  }

  static ThemeData webLight() {
    const webLightBg = Color(0xFFF8FAFC);
    const webLightCard = Color(0xFFFFFFFF);
    const webLightBorder = Color(0xFFE2E8F0);
    const webLightPrimary = Color(0xFF4338CA);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      cardColor: webLightCard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: webLightPrimary,
        brightness: Brightness.light,
        primary: webLightPrimary,
        secondary: const Color(0xFF7C3AED),
        surface: webLightBg,
        error: const Color(0xFFE11D48),
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: webLightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: webLightBorder),
        ),
      ),
    );
  }
}
