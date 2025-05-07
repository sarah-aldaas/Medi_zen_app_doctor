import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  void login(String email, String password) {
    emit(LoginLoading());

    Future.delayed(const Duration(seconds: 3), () {
      if (email == 'test@example.com' && password == 'password') {
        emit(LoginSuccess());
      } else {
        emit(LoginError('Invalid email or password'));
      }
    });
  }
}
