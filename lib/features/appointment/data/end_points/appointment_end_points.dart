class AppointmentEndPoints {
  static String finishAppointment({required int appointmentId}) => "/practitioner/appointments/$appointmentId/finish";

  static String getAppointmentsByPatient({required String patientId}) => "/practitioner/appointments-by-patient/$patientId";

  static const String getMyAppointments = "/practitioner/my-appointments-doctor";

  static String getDetailsAppointment({required String appointmentId}) => "/practitioner/appointments/$appointmentId";
}
