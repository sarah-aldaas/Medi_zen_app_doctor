import 'package:intl/intl.dart';
class Appointment {
  final String patientName;
  final DateTime appointmentTime;

  Appointment({
    required this.patientName,
    required this.appointmentTime,
    required String patientFullName,
  });

  String get formattedTime => DateFormat('hh:mm a').format(appointmentTime);
  String get formattedDate =>
      DateFormat('EEEE, dd MMMM', 'ar_SA').format(appointmentTime);
}