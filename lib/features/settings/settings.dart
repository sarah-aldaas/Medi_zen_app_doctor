import 'package:flutter/material.dart';
import '../../base/widgets/custom_widgets/custom_appbar.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(title: "Settings", context: context),
      body: Text("Settings"),
    );
  }
}
