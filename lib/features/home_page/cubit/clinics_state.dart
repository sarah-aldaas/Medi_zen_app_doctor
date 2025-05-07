import 'clinic.dart';

abstract class ClinicState {}

class ClinicInitial extends ClinicState {}

class ClinicLoading extends ClinicState {}

class ClinicLoaded extends ClinicState {
  final List<Clinic> clinics;

  ClinicLoaded(this.clinics);
}

class ClinicError extends ClinicState {
  final String errorMessage;

  ClinicError(this.errorMessage);
}
