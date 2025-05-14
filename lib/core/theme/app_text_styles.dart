import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextTheme get textThemeLight {
    return GoogleFonts.openSansTextTheme(_textTheme(AppColors.textBlack));
  }

  static TextTheme get textThemeDark {
    return GoogleFonts.openSansTextTheme(_textTheme(AppColors.textWhite));
  }

  static TextTheme _textTheme(Color defaultTextColor) {

    const fontWeightSemiBold = FontWeight.w600;
    const fontWeightRegular = FontWeight.w400;

    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: -0.25),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: fontWeightSemiBold,
          color: defaultTextColor,
          letterSpacing: 0.15),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: fontWeightSemiBold,
          color: defaultTextColor,
          letterSpacing: 0.15),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: fontWeightSemiBold,
          color: defaultTextColor,
          letterSpacing: 0.1),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0.5),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0.25),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: fontWeightRegular,
          color: defaultTextColor,
          letterSpacing: 0.4),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: fontWeightSemiBold,
          color: defaultTextColor,
          letterSpacing: 0.1),
      labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: fontWeightSemiBold,
          color: defaultTextColor,
          letterSpacing: 0.5),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: fontWeightSemiBold,
          color: defaultTextColor,
          letterSpacing: 0.5),
    );
  }
}
