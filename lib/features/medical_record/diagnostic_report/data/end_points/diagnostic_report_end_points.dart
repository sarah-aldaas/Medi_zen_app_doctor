class DiagnosticReportEndPoints {
  static String getDetailsDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String getAllDiagnosticReport({required String patientId}) =>
      "/practitioner/patients/$patientId/diagnostic-reports";

  static String getAllDiagnosticReportOfAppointment({
    required String appointmentId,
    required String patientId,
    required String conditionId,
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions/$conditionId/diagnostic-reports";

  static String getAllDiagnosticReportOfCondition({
    required String conditionId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/diagnostic-reports";

  static String makeAsFinal({
    required String diagnosticReportId,
    required String patientId,
    required String conditionId,
  }) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/diagnostic-reports/$diagnosticReportId/final";

  static String deleteDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
    required String conditionId,
  }) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/diagnostic-reports/$diagnosticReportId";

  static String updateDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
    required String conditionId,
  }) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/diagnostic-reports/$diagnosticReportId";

  static String createDiagnosticReport({
    required String patientId,
    required String appointmentId,
    required String conditionId,
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/conditions/$conditionId/diagnostic-reports";
}
