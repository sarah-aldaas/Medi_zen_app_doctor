part of 'otp_verify_password_cubit.dart';

@immutable
sealed class OtpVerifyPasswordState {}

final class OtpVerifyPasswordInitial extends OtpVerifyPasswordState {}
class OtpLoadingVerify extends OtpVerifyPasswordState {}

class OtpSuccess extends OtpVerifyPasswordState {
  final String message;

  OtpSuccess({required this.message});
}

class OtpResendSuccess extends OtpVerifyPasswordState {
  final String message;

  OtpResendSuccess({required this.message});
}

class OtpError extends OtpVerifyPasswordState {
  final String error;

  OtpError({required this.error});
}
