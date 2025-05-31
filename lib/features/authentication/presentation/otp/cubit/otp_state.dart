part of 'otp_cubit.dart';

abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpLoadingVerify extends OtpState {}

class OtpLoadingResend extends OtpState {}

class OtpSuccess extends OtpState {
  final String message;

  OtpSuccess({required this.message});
}

class OtpResendSuccess extends OtpState {
  final String message;

  OtpResendSuccess({required this.message});
}

class OtpError extends OtpState {
  final String error;

  OtpError({required this.error});
}

class OtpTimerRunning extends OtpState {
  final int seconds;

  OtpTimerRunning({required this.seconds});
}

class OtpTimerFinished extends OtpState {}
