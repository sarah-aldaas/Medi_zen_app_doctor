class ConditionsEndPoints {
  static String getAllConditions({required String patientId}) =>
      "/practitioner/patients/$patientId/conditions";

  static String getAllConditionsForAppointment({
    required String patientId,
    required String appointmentId,
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions";

  static String getDetailsCondition({
    required String patientId,
    required String conditionId,
  }) => "/practitioner/patients/$patientId/conditions/$conditionId";

  static String getAllObservationServiceRequest({required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/observation";

  static String getAllImagingStudyServiceRequest({required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/imaging-study";

  static String getLast10Encounters({required String patientId}) =>
      "/practitioner/get-last-encounters/$patientId";

  static String createCondition({required String patientId, required String appointmentId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions";

  static String updateCondition({
    required String patientId,
    required String conditionId,
  }) => "/practitioner/patients/$patientId/conditions/$conditionId";

  static String deleteCondition({
    required String patientId,
    required String conditionId,
  }) => "/practitioner/patients/$patientId/conditions/$conditionId";
}
