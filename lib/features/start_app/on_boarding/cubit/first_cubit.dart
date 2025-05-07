import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'first_state.dart';

class FirstCubit extends Cubit<FirstState> {
  FirstCubit() : super(FirstInitial());

  void changePage(int index) {
    emit(FirstPageIndexChanged(index));
  }

  void navigateToLogin(context) {
    emit(FirstNavigationToLogin());
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navigateToFirst(context) {
    emit(FirstNavigationToFirst());
    Navigator.pushReplacementNamed(context, '/welcome');
  }
}