import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFF66E87);
  static const Color deepPink = Color(0xFFE14C67);
  static const Color lightPink = Color(0xFFFFE5EA);
  static const Color peach = Color(0xFFFFF0E3);
  static const Color sky = Color(0xFFE8F3FF);
  static const Color mint = Color(0xFFE8F8EF);
  static const Color amber = Color(0xFFFFF4D8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgColor = Color(0xFFFFFAF7);
  static const Color textDark = Color(0xFF2D2432);
  static const Color textGray = Color(0xFF7C7381);
  static const Color stroke = Color(0xFFF4D7DE);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFFB9C7), Color(0xFFF66E87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFF0E3), Color(0xFFFFE5EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        colorScheme: const ColorScheme.light(
          primary: primaryPink,
          secondary: deepPink,
          surface: white,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyLarge: TextStyle(fontSize: 15, color: textDark, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, color: textGray, height: 1.45),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        cardTheme: CardThemeData(
          color: white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: stroke),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryPink,
            foregroundColor: white,
            disabledBackgroundColor: primaryPink.withOpacity(0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textDark,
            side: const BorderSide(color: stroke),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          hintStyle: const TextStyle(color: textGray),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: stroke),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: stroke),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: primaryPink, width: 1.4),
          ),
        ),
      );
}
