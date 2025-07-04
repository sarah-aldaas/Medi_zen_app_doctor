part of 'vacation_cubit.dart';

@immutable
sealed class VacationState {}

final class VacationInitial extends VacationState {}

class VacationLoading extends VacationState {}

class VacationSuccess extends VacationState {
  final List<VacationModel> vacations;
  final bool hasMore;
  final PaginatedResponse<VacationModel>? paginatedResponse;

  VacationSuccess({
    required this.vacations,
    required this.hasMore,
    this.paginatedResponse,
  });
}

class VacationDetailsLoaded extends VacationState {
  final VacationModel vacation;

  VacationDetailsLoaded({required this.vacation});
}

class VacationCreated extends VacationState {}
class VacationDeleted extends VacationState {}

class VacationUpdated extends VacationState {}

class VacationError extends VacationState {
  final String error;

  VacationError({required this.error});
}