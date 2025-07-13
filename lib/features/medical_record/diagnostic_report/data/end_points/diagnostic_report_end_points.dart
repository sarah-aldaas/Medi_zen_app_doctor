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
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/diagnostic-reports";

  static String getAllDiagnosticReportOfCondition({
    required String conditionId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/conditions/$conditionId/diagnostic-report";

  static String makeAsFinal({
    required String diagnosticReportId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId/final";

  static String deleteDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String updateDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String createDiagnosticReport({required String patientId}) =>
      "/practitioner/patients/$patientId/diagnostic-reports";
}
