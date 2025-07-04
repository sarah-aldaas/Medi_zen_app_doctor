class SeriesEndPoints {
  static String getDetailsSeries({required String patientId,required String serviceRequestId, required String imagingStudyId, required String seriesId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/imaging-studies/$imagingStudyId/series/$seriesId";

  static String getAllSeries({required String patientId,required String serviceRequestId, required String imagingStudyId}) =>
      "/practitioner/patients/$patientId/service-requests/$serviceRequestId/imaging-studies/$imagingStudyId/series";
}
