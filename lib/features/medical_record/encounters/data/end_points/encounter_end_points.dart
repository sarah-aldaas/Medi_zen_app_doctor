class EncounterEndPoints {
  static String forPatient({required String patientId}) => "/practitioner/patients/$patientId/encounters";

  static String forAppointment({required String patientId, required String appointmentId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/encounters";

  static String details({required String patientId, required String encounterId}) => "/practitioner/patients/$patientId/encounters/$encounterId";

  static String create({required String patientId}) => "/practitioner/patients/$patientId/encounters";

  static String update({required String patientId, required String encounterId}) => "/practitioner/patients/$patientId/encounters/$encounterId";

  static String finalize({required int patientId, required int encounterId}) => "/practitioner/patients/$patientId/encounters/$encounterId/final";

  static const String assignService = "/practitioner/assign-service-encounter";

  static const String unassignService = "/practitioner/unassign-service-encounter";

  static String appointmentServices({required int patientId, required int appointmentId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/services";
}
