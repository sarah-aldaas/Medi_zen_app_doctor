part of 'forgot_password_cubit.dart';

@immutable
sealed class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  ForgotPasswordSuccess({required this.message});
}

class ForgotPasswordError extends ForgotPasswordState {
  final String error;
  ForgotPasswordError({required this.error});
}

