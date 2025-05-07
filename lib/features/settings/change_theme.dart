import 'package:flutter/material.dart';

import '../../base/widgets/custom_widgets/custom_appbar.dart';

class ChangeTheme extends StatelessWidget {
  const ChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(title: "Change Theme", context: context),
      body: Text("Change Theme"),
    );
  }
}
