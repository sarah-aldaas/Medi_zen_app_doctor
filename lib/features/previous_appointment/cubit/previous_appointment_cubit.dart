import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/features/previous_appointment/cubit/previous_appointment_state.dart';

class PreviousAppointmentCubit extends Cubit<PreviousAppointmentState> {
  PreviousAppointmentCubit() : super(PreviousAppointmentInitial());

  void changeTab(String tabName) {
    emit(AppointmentTabChanged(tabName));
  }

  List<Appointment> getInactiveAppointments() {
    return [
      Appointment(
        patientName: 'John Doe',
        appointmentDate: 'Dec 12, 2025',
        appointmentTime: '16:00 PM',
        status: 'Cancelled',
        cancellationReason: 'Patient rescheduled appointment.',
      ),
      Appointment(
        patientName: 'Jane Smith',
        appointmentDate: 'Nov 5, 2025',
        appointmentTime: '10:30 AM',
        status: 'Completed',
      ),
    ];
  }

  List<Appointment> getPreviousAppointments() {
    return [
      Appointment(
        patientName: 'Alice Johnson',
        appointmentDate: 'May 15, 2020',
        appointmentTime: '09:00 AM',
        status: 'Completed',
      ),
      Appointment(
        patientName: 'Bob Brown',
        appointmentDate: 'Jan 10, 2021',
        appointmentTime: '14:00 PM',
        status: 'Completed',
      ),
    ];
  }
}

class Appointment {
  final String patientName;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? cancellationReason;

  Appointment({
    required this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.cancellationReason,
  });
}
