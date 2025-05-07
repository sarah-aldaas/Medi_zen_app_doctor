import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../di/injection_container_common.dart';

class LogService {
  final Logger log;
  static const _debug = kDebugMode;

  LogService({required this.log});

  void d(message) {
    if (_debug) {
      log.d(message);
    } else {
      return;
    }
  }

  void e(message, StackTrace current) {
    if (_debug) {
      log.e(message, stackTrace: current);
    } else {
      return;
    }
  }

  void i(message) {
    if (_debug) {
      log.i(message);
    } else {
      return;
    }
  }

  void l(Level level, message) {
    if (_debug) {
      log.log(level, message);
    } else {
      return;
    }
  }

  void t(message) {
    if (_debug) {
      log.t(message);
    } else {
      return;
    }
  }

  void w(message) {
    if (_debug) {
      log.w(message);
    } else {
      return;
    }
  }

  void f(message) {
    if (_debug) {
      log.f(message);
    } else {
      return;
    }
  }
}

final logger = serviceLocator<LogService>();
