class PreviousAppointment {
  final String imageUrl;
  final String patientFullName;
  final String appointmentType;
  final DateTime appointmentDate;
  final String appointmentTime;
  String? status;

  PreviousAppointment({
    required this.imageUrl,
    required this.patientFullName,
    required this.appointmentType,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status,
    required String patientName,
  });
}
