class MedicationEndPoints {
  static String getAllMedication({required String patientId}) =>
      "/practitioner/patients/$patientId/medications";

  static String getAllMedicationForAppointment({
    required String appointmentId,
    required String patientId,
    required String conditionId,
    required String medicationRequestId,
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions/$conditionId/medication-requests/$medicationRequestId/medications";

  static String getAllMedicationForMedicationRequest({
    required String medicationRequestId,
    required String patientId,
    required String conditionId,
  }) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/medication-requests/$medicationRequestId/medications";

  static String getDetailsMedication({
    required String medicationId,
    required String patientId,
  }) => "/practitioner/patients/$patientId/medications/$medicationId";

  static String createMedication({required String patientId,required String appointmentId,required String conditionId,required String medicationRequestId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions/$conditionId/medication-requests/$medicationRequestId/medications";

  static String updateMedication({
    required String patientId,
    required String medicationId,
    required String conditionId,
    required String medicationRequestId,
  }) => "/practitioner/patients/$patientId/conditions/$conditionId/medication-requests/$medicationRequestId/medications/$medicationId";

  static String deleteMedication({
    required String patientId,
    required String medicationId,
    required String conditionId,
    required String medicationRequestId,
  }) => "/practitioner/patients/$patientId/conditions/$conditionId/medication-requests/$medicationRequestId/medications/$medicationId";

  static String changeStatusMedication({
    required String patientId,
    required String medicationId,
  }) =>
      "/practitioner/patients/$patientId/medications/$medicationId/change-status";
}
