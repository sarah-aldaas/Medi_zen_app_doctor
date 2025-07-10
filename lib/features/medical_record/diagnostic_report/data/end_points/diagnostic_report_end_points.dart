class DiagnosticReportEndPoints {
  static String getAllDiagnosticReport({required String patientId}) =>
      "practitioner/patients/$patientId/diagnostic-reports";

  static String getDetailsDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  }) =>
      "practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String getAllDiagnosticReportOfAppointment({
    required String appointmentId,
    required String patientId,
  }) => "practitioner/patients/appointments/$appointmentId/diagnostic-reports";

  static String MarkDiagnosticReportAsFinal({
    required String patientId,
    required String diagnosticReportId,
  }) =>
      "practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId/final";

  static String getAllDiagnosticReportOfCondition({
    required String conditionId,
    required String patientId,
  }) =>
      "practitioner/patients/$patientId/conditions/$conditionId/diagnostic-report";

  static String createDiagnosticReport({required String patientId}) =>
      "practitioner/patients/$patientId/diagnostic-reports";

  static String updateDiagnosticReport({
    required String patientId,
    required String diagnosticReportId,
  }) =>
      "practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String deleteDiagnosticReport({
    required String patientId,
    required String diagnosticReportId,
  }) =>
      "practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";
}
