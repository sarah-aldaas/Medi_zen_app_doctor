import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String getGreeting(BuildContext context) {
    var now = DateTime.now();
    var hour = now.hour;
    var period = hour >= 12 ? 'PM' : 'AM';

    if (period == 'AM') {
      return "greetings.morning".tr(context);
    } else if (hour >= 12 && hour < 18) {
      return "greetings.afternoon".tr(context);
    } else {
      return "greetings.evening".tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(getGreeting(context), style: TextStyle(fontSize: 12));
  }
}
