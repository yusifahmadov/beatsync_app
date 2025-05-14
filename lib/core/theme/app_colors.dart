import 'package:flutter/material.dart';

class AppColors {

  static const Color primaryRed =
      Color(0xFFC62828); 
  static const Color primaryRedLight = Color(0xFFFFCDD2); 
  static const Color primaryRedDark = Color(0xFFB71C1C); 



  static const Color secondaryTeal = Color(0xFF00796B); 
  static const Color secondaryTealLight = Color(0xFFB2DFDB); 





  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGrey = Color(0xFFF5F5F5); 
  static const Color mediumGrey = Color(0xFF9E9E9E); 
  static const Color darkGrey = Color(0xFF212121); 
  static const Color textBlack = Color(0xFF1F1F1F);
  static const Color textWhite = Color(0xFFFCFCFC);
  static const Color textGrey = Color(0xFF616161); 


  static const Color errorRed = Color(0xFFD32F2F); 
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningOrange = Color(0xFFFFA000);



  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryRed,
    onPrimary: white,
    primaryContainer: primaryRedLight,
    onPrimaryContainer: primaryRedDark,
    secondary: secondaryTeal, 
    onSecondary: white,
    secondaryContainer: secondaryTealLight, 
    onSecondaryContainer: secondaryTeal, 
    tertiary: primaryRedLight, 
    onTertiary: primaryRedDark,
    error: errorRed,
    onError: white,
    surface: white, 
    onSurface: textBlack,
    surfaceContainerHighest: lightGrey, 
    onSurfaceVariant: textGrey,
    outline: mediumGrey,
    shadow: black, 
    inverseSurface: darkGrey, 
    onInverseSurface: textWhite,
    inversePrimary: primaryRedLight, 
  );


  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryRedLight, 
    onPrimary: textBlack, 
    primaryContainer: primaryRedDark,
    onPrimaryContainer: primaryRedLight,
    secondary: secondaryTealLight, 
    onSecondary: textBlack,
    secondaryContainer: secondaryTeal,
    onSecondaryContainer: secondaryTealLight,
    tertiary: primaryRed,
    onTertiary: white,
    error: errorRed, 
    onError: textBlack,
    surface: Color(0xFF2A2A2A), 
    onSurface: textWhite,
    surfaceContainerHighest: Color(0xFF303030),
    onSurfaceVariant: mediumGrey, 
    outline: mediumGrey,
    shadow: black,
    inverseSurface: lightGrey,
    onInverseSurface: textBlack,
    inversePrimary: primaryRedDark,
  );
}
