class MedicationRequestEndPoints {
  static String getAllMedicationRequest({required String patientId}) => "/practitioner/patients/$patientId/medication-requests";

  static String getAllMedicationRequestForAppointment({required String patientId, required String appointmentId,required String conditionId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions/$conditionId/medication-requests";

  static String getAllMedicationRequestForCondition({required String conditionId, required String patientId}) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/medication-requests";

  static String getDetailsMedicationRequest({required String medicationRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/medication-requests/$medicationRequestId";

  static String createMedicationRequest({required String patientId,required String appointmentId,required String conditionId,}) => "/practitioner/patients/$patientId/appointments/$appointmentId/conditions/$conditionId/medication-requests";

  static String updateMedicationRequest({required String medicationRequestId, required String patientId, required String conditionId}) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/medication-requests/$medicationRequestId";

  static String deleteMedicationRequest({required String medicationRequestId, required String patientId, required String conditionId}) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/medication-requests/$medicationRequestId";

  static String changeStatusMedicationRequest({required String medicationRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/medication-requests/$medicationRequestId/change-status";
}
