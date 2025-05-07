import '../model/previous_appointment_model.dart';

abstract class PreviousAppointmentState {}

class PreviousAppointmentInitial extends PreviousAppointmentState {}

class PreviousAppointmentLoading extends PreviousAppointmentState {}

class PreviousAppointmentLoaded extends PreviousAppointmentState {
  final List<PreviousAppointment> previous_appointments;

  PreviousAppointmentLoaded(this.previous_appointments);
}

class PreviousAppointmentError extends PreviousAppointmentState {
  final String message;

  PreviousAppointmentError(this.message);
}
