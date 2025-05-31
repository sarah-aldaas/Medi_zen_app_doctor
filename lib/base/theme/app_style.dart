import 'package:flutter/material.dart';

import 'app_color.dart';

class AppStyles {
  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
    textStyle: const TextStyle(
      fontSize: 18,
      color: Colors.black,
    ),
  );

  static final socialButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    padding: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  );
  static const TextStyle titleStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static final elevatedButtonStyleGoogle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
    textStyle: const TextStyle(
      fontSize: 16,
      color: AppColors.whiteColor,
    ),
  );

  static final elevatedButtonStyleApple = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(),
    backgroundColor: AppColors.whiteColor,
    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
    textStyle: const TextStyle(
      fontSize: 16,
      color: AppColors.blackColor,
    ),
  );
  static TextStyle complaintTextStyle = TextStyle(
    color: AppColors.red,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.red,
    decorationThickness: 2.0,
    fontSize: 16,
  );

  static TextStyle appBarTitle = TextStyle();

  static TextStyle heading = TextStyle();

  static TextStyle bodyText = TextStyle();

  static var primaryButtonStyle;

  static TextStyle titleTextStyle=TextStyle();

  static var instructionTextStyle;

  static var buttonTextStyle;

  static var linkTextStyle;

  static var greetingTextStyle;

  static var buttonSeeAll;
}
