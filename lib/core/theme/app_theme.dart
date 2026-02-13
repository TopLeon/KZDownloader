import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _createTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return GoogleFonts.montserratTextTheme(baseTheme).copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge:
          GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  static final lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromARGB(255, 246, 246, 247),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF09090B),
      brightness: Brightness.light,
      primary: const Color(0xFF09090B),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color.fromARGB(255, 225, 225, 230),
      secondary: const Color.fromARGB(255, 246, 246, 247),
      surface:
          const Color.fromARGB(255, 238, 238, 238), 
      surfaceContainerHighest: const Color(0xFFE4E4E7),
      onSurface: const Color(0xFF09090B),
      onSurfaceVariant: const Color(0xFF71717A),
      tertiary: Colors.white,
      error: Colors.red,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: Color(0xFFE4E4E7), width: 1),
      ),
      color: Color(0xFFFFFFFF),
    ),
    textTheme: _createTextTheme(Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF09090B),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF09090B)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.montserrat(),
      hintStyle: GoogleFonts.montserrat(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme:
        SnackBarThemeData(contentTextStyle: GoogleFonts.montserrat()),
    listTileTheme: ListTileThemeData(
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF334155),
      ),
      subtitleTextStyle: GoogleFonts.montserrat(
        fontSize: 13,
        color: const Color(0xFF64748B),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromARGB(255, 29, 29, 38),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 241, 241, 241),
      brightness: Brightness.dark,
      primaryContainer: const Color.fromARGB(255, 54, 54, 59),
      primary: const Color.fromARGB(255, 241, 241, 241),
      onPrimary: const Color(0xFF09090B),
      secondary: const Color.fromARGB(255, 29, 29, 38),
      surface: const Color.fromARGB(255, 24, 24, 32),
      surfaceContainerHighest: const Color(0xFF27272A),
      onSurface: const Color(0xFFFAFAFA),
      onSurfaceVariant: const Color(0xFFA1A1AA),
      outline: const Color.fromRGBO(51, 50, 63, 1),
      tertiary: const Color.fromRGBO(36, 36, 46, 1),
      error: const Color(0xFFCF6679),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        side: BorderSide(color: Color(0xFF27272A), width: 1),
      ),
      color: Color(0xFF18181B),
    ),
    textTheme: _createTextTheme(Brightness.dark),
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF8FAFC),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.montserrat(),
      hintStyle: GoogleFonts.montserrat(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme:
        SnackBarThemeData(contentTextStyle: GoogleFonts.montserrat()),
    listTileTheme: ListTileThemeData(
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFF8FAFC),
      ),
      subtitleTextStyle: GoogleFonts.montserrat(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
      ),
    ),
  );
}
