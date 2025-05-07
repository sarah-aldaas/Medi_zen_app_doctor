import 'package:flutter/material.dart';

import '../../base/widgets/custom_widgets/custom_appbar.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(title: "Change password", context: context),
      body: Text("Change password"),);
  }
}
