import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'first_state.dart';


class StartCubit extends Cubit<StartState> {
  StartCubit() : super(StartInitial());

  void navigateToLogin(context) {
    emit(StartNavigationToLogin());
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navigateToSignUp(context) {
    emit(StartNavigationToSignUp());
  }
}