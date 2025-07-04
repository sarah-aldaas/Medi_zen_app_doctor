class ImagingStudyEndPoints {
  static String getDetailsImagingStudy({required String patientId, required String serviceRequestId, required String imagingStudyId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/imaging-studies/$imagingStudyId";
}
