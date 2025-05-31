part of 'appointment_cubit.dart';

@immutable
abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentListSuccess extends AppointmentState {
  final PaginatedResponse<AppointmentModel> paginatedResponse;
  final bool hasMore;

  AppointmentListSuccess({required this.paginatedResponse, required this.hasMore});
}

class AppointmentDetailsSuccess extends AppointmentState {
  final AppointmentModel appointment;

  AppointmentDetailsSuccess({required this.appointment});
}

class AppointmentActionSuccess extends AppointmentState {}

class AppointmentError extends AppointmentState {
  final String error;

  AppointmentError({required this.error});
}