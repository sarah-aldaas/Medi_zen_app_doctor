import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF47BD93);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color secondaryColor = Color(0xFF47BD93);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF333333);
  static const Color greyColor = Colors.grey;
  static const Color grey500Color = Color(0xFF9E9E9E);
  static const Color greenLightColor = Color(0xFFA5D6A7);
  static const Color green300Color = Color(0xFF81C784);
  static const Color blueColor = Colors.blue;
  static const Color green300 = Color(0xFF81C784);
  static const Color backGroundLogo = Color(0xFF154329);
  static const Color grey = Colors.grey;
  static const Color lightGrey = Colors.grey;
  static const Color red = Colors.redAccent;
  /////////////////////
  static const Color primaryColor1 = Colors.blue;
  static const Color secondaryColor1 = Colors.amber;
  static const Color accentColor = Colors.green;
  static const Color primaryColor3 = Color(0xFF1A237E); // مثال
  static const Color accentColor3 = Color(0xFFFFD54F); // مثال

  // الألوان الخاصة بحالات المرضى
  static Color get conditionStable => Colors.green[400]!;
  static Color get conditionImproving => Colors.orange[400]!;
  static Color get conditionNeedsFollowUp => Colors.red[400]!;
  static Color get conditionUnderTreatment => Colors.blue[400]!;
  static Color get conditionRecovered => Colors.teal[400]!;
  static Color get conditionDefault => Colors.grey[600]!;
}
