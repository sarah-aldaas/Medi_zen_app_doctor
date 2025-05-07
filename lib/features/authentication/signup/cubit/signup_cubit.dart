import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/features/authentication/signup/cubit/signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  void signup(
    String firstName,
    String lastName,
    String email,
    String password,
  ) {
    emit(SignupLoading());

    Future.delayed(const Duration(seconds: 2), () {
      if (firstName.isNotEmpty &&
          lastName.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty) {
        emit(SignupSuccess());
      } else {
        emit(SignupError("Please fill in all fields."));
      }
    });
  }
}
