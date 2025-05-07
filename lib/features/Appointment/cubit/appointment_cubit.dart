import 'package:bloc/bloc.dart';

import '../model/appointments_model.dart';
import 'appointments_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit()
    : super(AppointmentState(appointments: _initialAppointments()));

  static List<Appointment> _initialAppointments() {
    return [
      Appointment(
        patientName: 'ليلى أحمد',
        appointmentTime: DateTime(2025, 5, 5, 10, 30),
        patientFullName: '',
      ),
      Appointment(
        patientName: 'يوسف محمد',
        appointmentTime: DateTime(2025, 5, 5, 11, 00),
        patientFullName: '',
      ),
      Appointment(
        patientName: 'سارة علي',
        appointmentTime: DateTime(2025, 5, 6, 14, 00),
        patientFullName: '',
      ),
      Appointment(
        patientName: 'خالد إبراهيم',
        appointmentTime: DateTime(2025, 5, 7, 9, 00),
        patientFullName: '',
      ),
      Appointment(
        patientName: 'نورة حسن',
        appointmentTime: DateTime(2025, 5, 7, 15, 30),
        patientFullName: '',
      ),
      Appointment(
        patientName: 'أحمد سعيد',
        appointmentTime: DateTime(2025, 5, 8, 12, 00),
        patientFullName: '',
      ),
    ];
  }
}
