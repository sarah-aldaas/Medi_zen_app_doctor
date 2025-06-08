part of 'patient_cubit.dart';

@immutable
sealed class PatientState {}

final class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientSuccess extends PatientState {
  final List<PatientModel> patients;
  final bool hasMore;
  final PaginatedResponse<PatientModel>? paginatedResponse;

  PatientSuccess({
    required this.patients,
    required this.hasMore,
    this.paginatedResponse,
  });
}

class PatientDetailsLoaded extends PatientState {
  final PatientModel patient;

  PatientDetailsLoaded({required this.patient});
}

class PatientUpdated extends PatientState {}

class PatientError extends PatientState {
  final String error;

  PatientError({required this.error});
}