part of 'encounter_cubit.dart';

@immutable
abstract class EncounterState {}

class EncounterInitial extends EncounterState {}

class EncounterLoading extends EncounterState {}

class EncounterListSuccess extends EncounterState {
  final PaginatedResponse<EncounterModel> paginatedResponse;
  final bool hasMore;

  EncounterListSuccess({required this.paginatedResponse, required this.hasMore});
}

class EncounterDetailsSuccess extends EncounterState {
  final EncounterModel? encounter;

  EncounterDetailsSuccess({required this.encounter});
}

class EncounterActionSuccess extends EncounterState {}

class AppointmentServicesSuccess extends EncounterState {
  final List<HealthCareServiceModel> services;

  AppointmentServicesSuccess({required this.services});
}

class EncounterError extends EncounterState {
  final String error;

  EncounterError({required this.error});
}