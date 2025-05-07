import 'package:equatable/equatable.dart';

import '../model/appointments_model.dart';

class AppointmentState extends Equatable {
  final List<Appointment> appointments;

  AppointmentState({required this.appointments});

  @override
  List<Object> get props => [appointments];
}
