import 'package:flutter/material.dart';

import 'app_color.dart';


final ThemeData lightTheme = ThemeData(
  // fontFamily: 'ChypreNorm',
  brightness: Brightness.light,
  secondaryHeaderColor: Colors.black87,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: AppColors.primaryColor,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(

    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(color: Colors.white),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: IconThemeData(
    color: AppColors.primaryColor,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
  ),
);


final ThemeData darkTheme = ThemeData(
  // fontFamily: 'ChypreNorm',
  brightness: Brightness.dark,
  secondaryHeaderColor: Colors.white,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    color: Colors.grey[850],
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(color: Colors.white),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: IconThemeData(
    color: AppColors.primaryColor,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
  ),
  cardTheme: CardTheme(
    color: Colors.grey[850],
    elevation: 2,
  ),
);