import 'package:flutter/material.dart';
import 'app_color.dart';

final ThemeData lightTheme = ThemeData(

  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor,
    surface: Colors.white,
    background: Colors.white,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    onBackground: Colors.black87,
    onError: Colors.white,
  ),
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.white,
    iconTheme: IconThemeData(color: AppColors.primaryColor),
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    elevation: 0,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(color: Colors.white),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: AppColors.primaryColor,
    unselectedLabelColor: Colors.black54,
    // indicator: UnderlineTabIndicator(
    //   borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
    // ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor.withOpacity(0.5);
      }
      return Colors.grey.withOpacity(0.5);
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
  ),
  inputDecorationTheme: InputDecorationTheme(
    // filled: true,
    // fillColor: Colors.white,
    focusColor: AppColors.primaryColor,
    hoverColor: AppColors.primaryColor.withOpacity(0.1),
    labelStyle: TextStyle(color: AppColors.primaryColor),
    floatingLabelStyle: TextStyle(color: AppColors.primaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: Colors.redAccent, width: 2),
    ),
    errorStyle: TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.w500,
    ),

  ),

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryColor,
    selectionColor: AppColors.primaryColor.withOpacity(0.4),
    selectionHandleColor: AppColors.primaryColor,
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor,
    surface: Colors.grey[850]!,
    background: Colors.grey[900]!,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
  ),
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    color: Colors.grey[850],
    iconTheme: IconThemeData(color: AppColors.primaryColor),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    elevation: 0,
  ),
  tabBarTheme: TabBarTheme(
    labelColor: AppColors.primaryColor,
    unselectedLabelColor: Colors.white70,
    // indicator: UnderlineTabIndicator(
    //   borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
    // ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor.withOpacity(0.5);
      }
      return Colors.grey.withOpacity(0.5);
    }),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryColor;
      }
      return Colors.grey;
    }),
  ),
  inputDecorationTheme: InputDecorationTheme(
    // filled: true,
    // fillColor: Colors.grey[800],
    focusColor: AppColors.primaryColor,
    hoverColor: AppColors.primaryColor.withOpacity(0.1),
    labelStyle: TextStyle(color: AppColors.primaryColor),
    floatingLabelStyle: TextStyle(color: AppColors.primaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: Colors.redAccent, width: 2),
    ),
    errorStyle: TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.w500,
    ),
  ),

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryColor,
    selectionColor: AppColors.primaryColor.withOpacity(0.4),
    selectionHandleColor: AppColors.primaryColor,
  ),
  useMaterial3: true,
);