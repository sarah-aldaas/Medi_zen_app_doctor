part of 'logout_cubit.dart';

@immutable
sealed class LogoutState {}

final class LogoutInitial extends LogoutState {}
class LogoutLoadingAllDevices extends LogoutState {}
class LogoutLoadingOnlyThisDevice extends LogoutState {}

class LogoutSuccess extends LogoutState {
  final String message;

  LogoutSuccess({required this.message});
}

class LogoutError extends LogoutState {
  final String error;
  LogoutError({required this.error});
}
