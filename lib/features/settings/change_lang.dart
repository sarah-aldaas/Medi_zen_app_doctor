import 'package:flutter/material.dart';

import '../../base/widgets/custom_widgets/custom_appbar.dart';

class ChangeLang extends StatelessWidget {
  const ChangeLang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(title: "Change language", context: context),
      body: Text("Change lang"),
    );
  }
}
