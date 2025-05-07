import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_screen_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit() : super(SplashScreenInitial());

  void SplashScreenTimer(context) {
    Timer(const Duration(seconds: 3), () {
      emit(SplashScreenNavigation());
      Navigator.pushReplacementNamed(context, '/on_boarding'); // Or '/welcome'
    });
  }
}