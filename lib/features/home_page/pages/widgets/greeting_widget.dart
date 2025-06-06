import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String getGreeting() {
    var now = DateTime.now();
    var hour = now.hour;
    var period = hour >= 12 ? 'PM' : 'AM';
    String emoji = '';

    if (period == 'AM') {
      emoji = '☀️';
      return 'Good Morning $emoji';
    } else if (hour >= 12 && hour < 18) {
      emoji = '🌤️'; // Or ☀️
      return 'Good Afternoon $emoji';
    } else {
      emoji = '🌙';
      return 'Good Evening $emoji';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(getGreeting(), style: TextStyle(fontSize: 15));
  }
}
