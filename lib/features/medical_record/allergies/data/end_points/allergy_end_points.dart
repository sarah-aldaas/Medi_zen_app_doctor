class AllergyEndPoints {
  static String create({required int patientId}) => "/practitioner/patients/$patientId/allergies";

  static String view({required int patientId, required int allergyId}) => "/practitioner/patients/$patientId/allergies/$allergyId";

  static String update({required int patientId, required int allergyId}) => "/practitioner/patients/$patientId/allergies/$allergyId";

  static String delete({required int patientId, required int allergyId}) => "/practitioner/patients/$patientId/allergies/$allergyId";

  static String byAppointment({required int patientId, required int appointmentId}) =>
      "/practitioner/patients/$patientId/appointments/$appointmentId/allergies";

  static String forPatient({required int patientId}) => "/practitioner/patients/$patientId/allergies";
}
