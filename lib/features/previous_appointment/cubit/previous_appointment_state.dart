abstract class PreviousAppointmentState {}

class PreviousAppointmentInitial extends PreviousAppointmentState {}

class AppointmentTabChanged extends PreviousAppointmentState {
  final String tabName;

  AppointmentTabChanged(this.tabName);
}
