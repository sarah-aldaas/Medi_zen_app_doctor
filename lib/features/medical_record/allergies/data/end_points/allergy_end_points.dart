class AllergyEndPoints {
  static String create({required String patientId,required String appointmentId}) => "/practitioner/patients/$patientId/appointments/$appointmentId/allergies";

  static String view({required String patientId, required String allergyId}) => "/practitioner/patients/$patientId/allergies/$allergyId";

  static String update({required String patientId, required String allergyId,required String appointmentId}) => "/practitioner/patients/$patientId/appointments/$appointmentId/allergies/$allergyId";

  static String delete({required String patientId, required String allergyId}) => "/practitioner/patients/$patientId/allergies/$allergyId";

  static String byAppointment({required String patientId, required String appointmentId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/allergies";

  static String forPatient({required String patientId}) => "/practitioner/patients/$patientId/allergies";
}
