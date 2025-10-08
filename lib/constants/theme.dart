import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ana Renkler
  static const Color primary = Color.fromARGB(255, 20, 156, 134);
  static const Color secondary = Color.fromARGB(255, 59, 148, 155);
  static const Color error = Color.fromARGB(255, 218, 66, 66);
  static const Color success = Color.fromARGB(255, 70, 182, 76);
  static const Color warning = Color.fromARGB(255, 243, 170, 59);
  static const Color info = Color.fromARGB(255, 46, 158, 209);
  static const Color surfaceLight = Color(0xFF1E222A);

  // Arka Plan Renkleri
  static const Color backgroundTop = Color(0xFF171923);
  static const Color backgroundCenter = Color(0xFF0F1117);
  static const Color backgroundBottom = Color(0xFF0A0C10);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundTop,
      backgroundCenter,
      backgroundBottom,
    ],
  );

  // Metin Renkleri
  static const text = Color(0xFFE0E0E0);
  static const textSecondary = Color(0xFF9E9E9E);

  // Soft Gradyan Renkler
  static const gradientColors = [
    // Professional Dark
    [
      Color(0xFF1A1F25),
      Color(0xFF2D3436),
    ],
    // Deep Slate
    [
      Color(0xFF17212B),
      Color(0xFF2A3C4D),
    ],
    // Elegant Night
    [
      Color(0xFF1E222A),
      Color(0xFF353B45),
    ],
    // Dark Ocean
    [
      Color(0xFF162029),
      Color(0xFF2B3A4A),
    ],
    // Modern Charcoal
    [
      Color(0xFF1D2228),
      Color(0xFF333940),
    ],
  ];

  // Gölge ve Opaklık
  static const shadowOpacity = 0.2;
  static const hoverOpacity = 0.1;
  static const splashOpacity = 0.1;
  static const borderOpacity = 0.1;

  // Köşe Yuvarlaklığı
  static const borderRadiusSmall = 8.0;
  static const borderRadiusMedium = 12.0;
  static const borderRadiusLarge = 16.0;
  static const borderRadiusXLarge = 24.0;

  // Boşluk Değerleri
  static const spacingXSmall = 4.0;
  static const spacingSmall = 8.0;
  static const spacingMedium = 16.0;
  static const spacingLarge = 24.0;
  static const spacingXLarge = 32.0;

  // Tema Verisi
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          error: error,
          background: backgroundTop,
          surface: backgroundCenter,
          onPrimary: text,
          onSecondary: text,
          onBackground: text,
          onSurface: text,
          onError: backgroundTop,
        ),
        scaffoldBackgroundColor: backgroundTop,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: text,
          displayColor: text,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: text,
          ),
          iconTheme: const IconThemeData(color: text),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: backgroundCenter,
          elevation: 0,
          indicatorColor: primary.withOpacity(hoverOpacity),
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: backgroundCenter,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(shadowOpacity),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: backgroundCenter,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            borderSide: const BorderSide(color: primary),
          ),
          contentPadding: const EdgeInsets.all(spacingMedium),
        ),
        iconTheme: const IconThemeData(
          color: text,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: backgroundCenter,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1F1D2B),
          foregroundColor: Colors.white,
        ),
        dividerTheme: DividerThemeData(
          color: textSecondary.withOpacity(borderOpacity),
          thickness: 1,
          space: spacingMedium,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: primary,
          textColor: text,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: backgroundCenter,
          contentTextStyle: GoogleFonts.poppins(
            color: text,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: backgroundCenter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: backgroundCenter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadiusLarge),
            ),
          ),
        ),
      );

  // Gradyan Arka Plan
  static BoxDecoration getGradientBackground(int index) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors[index % gradientColors.length],
        ),
      );

  // Kart Gölgesi
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(shadowOpacity),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  // Buton Stili
  static ButtonStyle getButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsets? padding,
  }) =>
      ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor ?? primary),
        foregroundColor: MaterialStateProperty.all(foregroundColor ?? text),
        padding: MaterialStateProperty.all(
          padding ??
              const EdgeInsets.symmetric(
                horizontal: spacingLarge,
                vertical: spacingMedium,
              ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(borderRadius ?? borderRadiusMedium),
          ),
        ),
      );

  static const Color border = Color(0xFFE0E0E0);
}
