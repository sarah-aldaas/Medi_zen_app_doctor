import 'package:flutter_bloc/flutter_bloc.dart';


abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String error;
  ForgotPasswordError({required this.error});
}


class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  void sendResetLink(String email) async {
    emit(ForgotPasswordLoading());


    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty) {
      emit(ForgotPasswordSuccess());
    } else {
      emit(ForgotPasswordError(error: 'Please enter an email address'));
    }
  }
}