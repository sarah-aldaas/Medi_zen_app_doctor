class ServiceRequestEndPoints {
  static String getAllServiceRequestForPatient({required String patientId}) => "/practitioner/patients/$patientId/service-requests";

  static String getAllServiceRequestForAppointment({required String appointmentId, required String patientId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/service-requests";

  static String getDetailsService({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId";

  static String updateServiceRequest({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId";

  static String deleteServiceRequest({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId";

  static String createServiceRequest({required String appointmentId, required String patientId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/service-requests";

  static String changeServiceRequestToActive({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/active-status";

  static String changeServiceRequestToEnteredInError({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/entered-in-error-status";

  static String changeServiceRequestOnHoldStatus({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/on-hold-status";

  static String changeServiceRequestRevokeStatus({required String serviceRequestId, required String patientId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/revoke-status";
}
