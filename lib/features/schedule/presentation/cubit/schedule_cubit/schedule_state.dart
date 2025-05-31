part of 'schedule_cubit.dart';

@immutable
sealed class ScheduleState {}

final class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleSuccess extends ScheduleState {
  final List<ScheduleModel> schedules;
  final bool hasMore;
  final PaginatedResponse<ScheduleModel>? paginatedResponse;

  ScheduleSuccess({
    required this.schedules,
    required this.hasMore,
    this.paginatedResponse,
  });
}

class ScheduleDetailsLoaded extends ScheduleState {
  final ScheduleModel schedule;

  ScheduleDetailsLoaded({required this.schedule});
}

class ScheduleCreated extends ScheduleState {}

class ScheduleUpdated extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String error;

  ScheduleError({required this.error});
}