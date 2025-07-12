class DiagnosticReportEndPoints {
  static String getAllDiagnosticReport({required String patientId}) =>
      "/practitioner/patients/$patientId/diagnostic-reports";

  static String getAllDiagnosticReportOfAppointment({
    required String appointmentId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/diagnostic-reports";

  static String markDiagnosticReportAsFinal({
    required String patientId,
    required String diagnosticReportId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId/final";

  static String getAppointmentDiagnosticReportsWithCondition({
    required String patientId,
    required String appointmentId,
    required String conditionId,
    required String paginationCount,
  }) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/diagnostic-reports?condition_id=$conditionId&pagination_count=$paginationCount";

  static String createDiagnosticReport({required String patientId}) =>
      "/practitioner/patients/$patientId/diagnostic-reports";

  static String updateDiagnosticReport({
    required String patientId,
    required String diagnosticReportId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String deleteDiagnosticReport({
    required String patientId,
    required String diagnosticReportId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";

  static String getDetailsDiagnosticReport({
    required String diagnosticReportId,
    required String patientId,
  }) =>
      "/practitioner/patients/$patientId/diagnostic-reports/$diagnosticReportId";
}
