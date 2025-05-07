import 'package:flutter/material.dart';

import '../di/injection_container_common.dart';

class NavigatorService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  push(Widget page) {
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => page));
  }

  // Pop the top route from the navigator stack
  pop() {
    navigatorKey.currentState?.pop();
  }

  // Push a new route to the navigator stack by name
  pushWithName(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }
}

final navigatorService = serviceLocator<NavigatorService>();
