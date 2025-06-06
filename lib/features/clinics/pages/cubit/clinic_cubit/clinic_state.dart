part of 'clinic_cubit.dart';

@immutable
sealed class ClinicState {}

final class ClinicInitial extends ClinicState {}

class ClinicLoading extends ClinicState {
  final bool isInitialLoad;

  ClinicLoading({this.isInitialLoad = true});
}

class ClinicEmpty extends ClinicState {
  final String message;

  ClinicEmpty({required this.message});

}

class ClinicSuccess extends ClinicState {
  final List<ClinicModel> clinics;

  ClinicSuccess({required this.clinics});
}

class ClinicLoadedSuccess extends ClinicState {
  final ClinicModel clinic;

  ClinicLoadedSuccess({required this.clinic});
}

class ClinicError extends ClinicState {
  final String error;

  ClinicError({required this.error});
}
