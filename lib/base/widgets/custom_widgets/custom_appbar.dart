import 'package:flutter/material.dart';

AppBar customAppbar({required String title, required BuildContext context,Widget? leading, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    leading: leading,
    actions: actions,
  );
}
