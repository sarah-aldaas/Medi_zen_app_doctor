import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ShowToast {
  static showToastError({required String message}) {
    return customShowToast(message: message, color: Colors.red);
  }

  static showToastSuccess({required String message}) {
    return customShowToast(message: message, color: Colors.green);
  }

  static customShowToast({required String message, required Color color}) {
    showToastWidget(
      Container(
        decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(3)), color: color),
        child: Padding(padding: const EdgeInsets.all(6.0), child: Text(message, style: const TextStyle(color: Colors.white))),
      ),
      animationCurve: Curves.easeInQuart,
      duration: const Duration(seconds: 5),
      position: ToastPosition.bottom,
    );
  }

  static void showToasts({required String message}) {}

  static void showToastInfo({required String message}) {}
}
