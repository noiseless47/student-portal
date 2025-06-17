import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor
  AppTheme._();
  
  // Colors - Light Theme
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);

  // Colors - Dark Theme
  static const Color darkPrimaryColor = Color(0xFF1976D2);
  static const Color darkSecondaryColor = Color(0xFF2196F3);
  static const Color darkAccentColor = Color(0xFF42A5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkErrorColor = Color(0xFFCF6679);
  
  static const Color darkTextPrimary = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextHint = Color(0xFF9E9E9E);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF03DAC6), Color(0xFF018786)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Elevations
  static const double cardElevation = 2.0;
  static const double dialogElevation = 24.0;
  static const double buttonElevation = 4.0;
  
  // Radius
  static const double borderRadius = 16.0;
  static const double buttonRadius = 28.0;
  static BorderRadius defaultBorderRadius = BorderRadius.circular(borderRadius);
  static BorderRadius buttonBorderRadius = BorderRadius.circular(buttonRadius);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      textTheme: _getTextTheme(false),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: _getTextTheme(false).titleLarge?.copyWith(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: Color(0xFFE0E0E0),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.32);
          }
          return primaryColor;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.32);
          } else if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.12);
          } else if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(.5);
          }
          return Colors.grey.withOpacity(.5);
        }),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        error: darkErrorColor,
        background: darkBackgroundColor,
        surface: darkCardColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultBorderRadius,
          borderSide: const BorderSide(color: darkErrorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      textTheme: _getTextTheme(true),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: _getTextTheme(true).titleLarge?.copyWith(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: Color(0xFF2C2C2C),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCardColor,
        indicatorColor: darkPrimaryColor.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.32);
          }
          return darkPrimaryColor;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.32);
          } else if (states.contains(MaterialState.selected)) {
            return darkPrimaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.12);
          } else if (states.contains(MaterialState.selected)) {
            return darkPrimaryColor.withOpacity(.5);
          }
          return Colors.grey.withOpacity(.5);
        }),
      ),
    );
  }
  
  // Text Theme
  static TextTheme _getTextTheme(bool isDark) {
    final Color textPrimaryColor = isDark ? darkTextPrimary : textPrimary;
    final Color textSecondaryColor = isDark ? darkTextSecondary : textSecondary;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 60,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textPrimaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textPrimaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textPrimaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textSecondaryColor,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textSecondaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: textSecondaryColor,
      ),
    );
  }
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
} 