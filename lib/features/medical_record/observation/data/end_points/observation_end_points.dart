class ObservationEndPoints {
  static String getDetailsObservation({required String patientId,required String serviceRequestId,required String observationId}) => "/practitioner/patients/$patientId/service-requests/$serviceRequestId/observations/$observationId";
}
